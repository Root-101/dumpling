import 'package:service/dumpling.dart';

class WorkspaceModel {
  final String slug;
  final String name;
  final String? description;
  final int? color;
  final WorkspaceDefaults defaults;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkspaceModel({
    required this.slug,
    required this.name,
    this.description,
    this.color,
    required this.defaults,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkspaceModel.fromRow(WorkspaceTableData row) => WorkspaceModel(
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
  );

  Map<String, Object?> toJson() => {
    'slug': slug,
    'name': name,
    'description': description,
    'color': color,
    'defaults': defaults,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}

/// What a new config of the workspace starts with.
class WorkspaceDefaults {
  /// Every day at 02:00 UTC
  static const String defaultSchedule = '0 2 * * *';
  static const Compression defaultCompression = Compression.gzip;
  static const String defaultObjectKey = '{yyyy}/{MM}/{dd}';

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
