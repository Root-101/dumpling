import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

enum NodeKind { source, config, destination }

/// How the last run of a config went, as the service says it
enum RunStatus { running, success, failed }

enum Frequency {
  hourly('Hourly'),
  daily('Daily'),
  weekly('Weekly'),
  cron('Cron');

  final String label;

  const Frequency(this.label);

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
  String get detail => type == DestinationTypes.s3
      ? 'S3 · ${settings['bucket']}'
      : DestinationTypeLook.labelOf(type);

  String get bucket => settings['bucket'] ?? name;

  DestinationNode copyWith({Offset? pos}) => DestinationNode(
    id: id,
    name: name,
    type: type,
    settings: settings,
    folders: folders,
    pos: pos ?? this.pos,
  );
}

/// The last run of a config
class LastRun {
  final RunStatus status;
  final DateTime startedAt;
  final int? sizeBytes;
  final String? error;

  const LastRun({
    required this.status,
    required this.startedAt,
    this.sizeBytes,
    this.error,
  });
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
    String? schedule,
    String? Function()? objectKey,
  }) => BackupConfig(
    id: id,
    sourceId: sourceId != null ? sourceId() : this.sourceId,
    destinationId: destinationId != null ? destinationId() : this.destinationId,
    folderId: folderId != null ? folderId() : this.folderId,
    pos: pos ?? this.pos,
    name: name,
    schedule: schedule ?? this.schedule,
    compression: compression,
    objectKey: objectKey != null ? objectKey() : this.objectKey,
    enabled: enabled,
    // what the service computed is stale once the schedule changes
    nextRun: schedule != null ? null : nextRun,
    lastRun: lastRun,
  );
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
