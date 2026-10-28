import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

enum NodeKind { source, config, destination }

/// How the last run of a config went, as the service says it
enum RunStatus { running, success, failed }

enum Frequency {
  hourly,
  daily,
  weekly,
  cron;

  String get label => switch (this) {
    hourly => app.intl.canvas.frequency.hourly,
    daily => app.intl.canvas.frequency.daily,
    weekly => app.intl.canvas.frequency.weekly,
    cron => app.intl.canvas.frequency.cron,
  };

  /// What the picker shows for [cron]: the schedules it writes
  /// (`m * * * *`, `m h * * *`, `m h * * 0`), any other one is [cron]
  static Frequency of(String cron) {
    final f = cron.trim().split(RegExp(r'\s+'));
    if (f.length != 5 || f[2] != '*' || f[3] != '*') return Frequency.cron;
    final minute = int.tryParse(f[0]) != null;
    final hour = int.tryParse(f[1]) != null;
    if (minute && f[1] == '*' && f[4] == '*') return Frequency.hourly;
    if (minute && hour && f[4] == '*') return Frequency.daily;
    if (minute && hour && f[4] == '0') return Frequency.weekly;
    return Frequency.cron;
  }

  /// The cron [f] writes from [schedule]: hourly, daily and weekly keep its
  /// minute and hour (03:00 while it is the default of the workspace); cron
  /// keeps it as is
  static String? apply(Frequency f, String? schedule) {
    if (f == Frequency.cron) return schedule;
    final fields = (schedule ?? '0 3 * * *').trim().split(RegExp(r'\s+'));
    final m = int.tryParse(fields.first) ?? 0;
    final h = fields.length > 1 ? int.tryParse(fields[1]) ?? 3 : 3;
    return switch (f) {
      Frequency.hourly => '$m * * * *',
      Frequency.daily => '$m $h * * *',
      Frequency.weekly => '$m $h * * 0',
      Frequency.cron => schedule,
    };
  }
}

/// A database to back up. [settings] are the ones the service returned
/// (never the password): the save sends them back as they are, and the
/// service keeps the saved password
class SourceNode {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> settings;
  final Offset pos;

  const SourceNode({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    this.pos = Offset.zero,
  });

  String get engine => SourceTypeLook.labelOf(type);

  TypeLook get look => SourceTypeLook.lookOf(type);

  /// `pg-prod-01.internal:5432/orders`
  String get detail => type == SourceTypes.postgres
      ? '${settings['host']}:${settings['port']}/${settings['database']}'
      : '';

  SourceNode copyWith({Offset? pos}) => SourceNode(
    id: id,
    name: name,
    type: type,
    settings: settings,
    pos: pos ?? this.pos,
  );
}

/// A bucket. Each of its [folders] (`orders`, `eu/billing`) is a connection
/// point; without folders, the root is. [settings] are sent back on save, like
/// those of a [SourceNode] (the service keeps the secret key)
class DestinationNode {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> settings;
  final List<String> folders;
  final Offset pos;

  const DestinationNode({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    this.folders = const [],
    this.pos = Offset.zero,
  });

  /// `S3 · bucket-backups`
  String get detail =>
      [DestinationTypeLook.labelOf(type), ?settings['bucket']].join(' · ');

  String get bucket => settings['bucket'] ?? name;

  /// What its connection test sends: the saved settings with the folders of
  /// the canvas; without the secret key, which the service fills in
  DestinationDraft toDraft() => DestinationDraft(
    name: name,
    type: type,
    endpoint: settings['endpoint'] ?? '',
    region: settings['region'] ?? '',
    bucket: settings['bucket'] ?? '',
    accessKeyId: settings['access_key_id'] ?? '',
    pathStyle: settings['path_style'] ?? false,
    folders: folders,
  );

  DestinationNode copyWith({Offset? pos, List<String>? folders}) =>
      DestinationNode(
        id: id,
        name: name,
        type: type,
        settings: settings,
        folders: folders ?? this.folders,
        pos: pos ?? this.pos,
      );
}

/// The last run of a config
class LastRun {
  final String id;
  final RunStatus status;
  final DateTime startedAt;
  final int? sizeBytes;
  final String? error;

  const LastRun({
    required this.id,
    required this.status,
    required this.startedAt,
    this.sizeBytes,
    this.error,
  });

  factory LastRun.fromJson(Map<String, dynamic> json) => LastRun(
    id: json['id'],
    status: RunStatus.values.byName(json['status']),
    startedAt: DateTime.parse(json['started_at']),
    sizeBytes: json['size_bytes'],
    error: json['error'],
  );

  bool get running => status == RunStatus.running;
}

/// One connection source → destination (folder), with its schedule. Either
/// end can be missing: orphans are allowed while editing, and dropped on save
class BackupConfig {
  final String id;

  /// null: not connected yet (or its wire was removed)
  final String? sourceId;
  final String? destinationId;

  /// The folder it writes to (`orders`); null: the root of the bucket
  final String? folderId;
  final Offset pos;
  final String name;

  /// Cron in UTC. Null in a new config: the default of the workspace, which
  /// the service fills in on save. The same for [compression] and [objectKey]
  final String? schedule;
  final String? compression;
  final String? objectKey;
  final bool enabled;

  /// From the service: null while it is disabled or not saved yet
  final DateTime? nextRun;

  /// Null until it runs
  final LastRun? lastRun;

  const BackupConfig({
    required this.id,
    required this.sourceId,
    required this.destinationId,
    required this.folderId,
    required this.pos,
    required this.name,
    this.schedule,
    this.compression,
    this.objectKey,
    this.enabled = true,
    this.nextRun,
    this.lastRun,
  });

  BackupConfig copyWith({
    Offset? pos,
    String? Function()? sourceId,
    String? Function()? destinationId,
    String? Function()? folderId,
    String? name,
    String? schedule,
    String? compression,
    String? Function()? objectKey,
    bool? enabled,
    LastRun? lastRun,
  }) => BackupConfig(
    id: id,
    sourceId: sourceId != null ? sourceId() : this.sourceId,
    destinationId: destinationId != null ? destinationId() : this.destinationId,
    folderId: folderId != null ? folderId() : this.folderId,
    pos: pos ?? this.pos,
    name: name ?? this.name,
    schedule: schedule ?? this.schedule,
    compression: compression ?? this.compression,
    objectKey: objectKey != null ? objectKey() : this.objectKey,
    enabled: enabled ?? this.enabled,
    // what the service computed is stale once the schedule changes
    nextRun: schedule != null || enabled != null ? null : nextRun,
    lastRun: lastRun ?? this.lastRun,
  );
}

/// The values a config takes, as the service accepts them
abstract class ConfigRules {
  static const int maxNameLength = 64;
  static const int maxObjectKeyLength = 512;
  static const List<String> compressions = ['gzip', 'none'];

  /// The extensions of a backup file: the engine adds them by itself
  static const List<String> _extensions = [
    '.dump', '.sql', '.gz', '.gzip', '.zip', '.tar', '.zst', '.bz2', '.xz', //
    '.bak', '.backup',
  ];

  static final RegExp _cronField = RegExp(r'^[\w*,/-]+$');

  static String? name(String value) =>
      value.trim().isEmpty ? app.intl.common.required : null;

  /// 5 fields (minute hour day month weekday); the service checks the rest
  static String? cron(String? value) {
    if (value == null) return null;
    final fields = value.trim().split(RegExp(r'\s+'));
    return fields.length == 5 && fields.every(_cronField.hasMatch)
        ? null
        : app.intl.canvas.inspector.cronInvalid;
  }

  /// Relative and without extension; null (empty) is the default
  static String? objectKey(String? value) {
    if (value == null) return null;
    if (value.startsWith('/')) return app.intl.canvas.inspector.objectKeySlash;
    if (value.split('/').any((s) => s == '.' || s == '..')) {
      return app.intl.canvas.inspector.objectKeyDots;
    }
    final file = value.split('/').last.toLowerCase();
    return _extensions.any(file.endsWith)
        ? app.intl.canvas.inspector.objectKeyExtension
        : null;
  }

  /// What the engine adds to the key: `.dump` or `.sql` from the dump format
  /// of [source], `.gz` with gzip
  static String extension(SourceNode source, String? compression) =>
      (source.settings['dump_format'] == 'plain' ? '.sql' : '.dump') +
      (compression == 'gzip' ? '.gz' : '');

  /// gzip over the custom format (`pg_dump -Fc`), compressed already: allowed,
  /// but it barely makes the file smaller
  static bool doubleCompression(SourceNode? source, String? compression) =>
      source != null &&
      source.settings['dump_format'] != 'plain' &&
      compression == 'gzip';
}

/// Where a wire was dropped
class DropTarget {
  final String destinationId;
  final String? folderId;

  const DropTarget(this.destinationId, this.folderId);

  @override
  bool operator ==(Object other) =>
      other is DropTarget &&
      other.destinationId == destinationId &&
      other.folderId == folderId;

  @override
  int get hashCode => Object.hash(destinationId, folderId);
}

/// The two wires of a config: from its source, or to its destination
enum WireEnd { source, destination }

/// One check of a test run: a source or destination of [name], and what its
/// connection test found, or why the request failed ([error])
class CanvasCheck {
  final String name;
  final ConnectionCheckModel? check;
  final String? error;

  const CanvasCheck(this.name, {this.check, this.error});

  bool get ok => check?.status == CheckStatus.connected;
}

/// A canvas as the service returns it: the nodes without position are off
/// the canvas ([sourcePool], [destinationPool]). [ids] maps the `new_` ids of
/// a save to the saved ones
class CanvasModel {
  final List<SourceNode> sources;
  final List<SourceNode> sourcePool;
  final List<DestinationNode> destinations;
  final List<DestinationNode> destinationPool;
  final List<BackupConfig> configs;
  final Map<String, String> ids;

  const CanvasModel({
    required this.sources,
    required this.sourcePool,
    required this.destinations,
    required this.destinationPool,
    required this.configs,
    this.ids = const {},
  });
}
