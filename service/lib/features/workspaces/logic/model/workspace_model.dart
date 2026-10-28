import 'package:service/dumpling.dart';

class WorkspaceModel {
  final String slug;
  final String name;
  final String? description;
  final int? color;
  final WorkspaceDefaults defaults;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Only in the list: what the cards of the console show.
  final WorkspaceStats? stats;

  WorkspaceModel({
    required this.slug,
    required this.name,
    this.description,
    this.color,
    required this.defaults,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
  });

  factory WorkspaceModel.fromRow(
    WorkspaceTableData row, {
    WorkspaceStats? stats,
  }) => WorkspaceModel(
    slug: row.slug,
    name: row.name,
    description: row.description,
    color: row.color,
    defaults: WorkspaceDefaults(
      schedule: row.defaultSchedule,
      compression: row.defaultCompression,
      objectKey: row.defaultObjectKey,
    ),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    stats: stats,
  );

  Map<String, Object?> toJson() => {
    'slug': slug,
    'name': name,
    'description': description,
    'color': color,
    'defaults': defaults,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (stats != null) 'stats': stats,
  };
}

/// What a workspace has: its nodes, the configs whose last run failed, the
/// runs in progress and when the last one started.
class WorkspaceStats {
  /// The most configs [preview] has.
  static const int previewConfigs = 3;

  final int sources;
  final int destinations;
  final int configs;
  final int failing;
  final int running;
  final DateTime? lastRunAt;

  /// The first configs (the oldest), with what they connect.
  final List<WorkspacePreviewLink> preview;

  WorkspaceStats({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.failing,
    required this.running,
    this.lastRunAt,
    this.preview = const [],
  });

  Map<String, Object?> toJson() => {
    'sources': sources,
    'destinations': destinations,
    'configs': configs,
    'failing': failing,
    'running': running,
    'last_run_at': lastRunAt?.toUtc().toIso8601String(),
    'preview': preview,
  };
}

/// A config of [WorkspaceStats.preview]: its source, its destination and
/// whether its last run failed.
class WorkspacePreviewLink {
  final String source;
  final String destination;
  final bool failing;

  const WorkspacePreviewLink({
    required this.source,
    required this.destination,
    required this.failing,
  });

  Map<String, Object?> toJson() => {
    'source': source,
    'destination': destination,
    'failing': failing,
  };
}

/// What a new config of the workspace starts with.
class WorkspaceDefaults {
  /// Every day at 02:00 UTC
  static const String defaultSchedule = '0 2 * * *';

  /// The default dump (custom format, `pg_dump -Fc`) is compressed already
  static const Compression defaultCompression = Compression.none;

  /// With the run id: two runs of a day (Run now, or an hourly schedule)
  /// never write the same file
  static const String defaultObjectKey = '{db}/{yyyy}-{MM}-{dd}-{run_id}';

  /// A cron expression, always in UTC.
  final String schedule;
  final Compression compression;

  /// Relative to the folder each config writes to, with placeholders
  /// (`{yyyy}`, `{MM}`, `{dd}`, `{db}`, `{run_id}`) and without extension: the
  /// backup engine adds it from the dump format and the compression (`.dump`,
  /// `.sql`, `.sql.gz`…).
  final String objectKey;

  WorkspaceDefaults({
    required this.schedule,
    required this.compression,
    required this.objectKey,
  });

  Map<String, Object?> toJson() => {
    'schedule': schedule,
    'compression': compression.name,
    'object_key': objectKey,
  };
}
