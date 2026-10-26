import 'package:service/dumpling.dart';

class ConfigModel {
  final String id;
  final String workspace;
  final String name;
  final String sourceId;
  final String destinationId;

  /// Null: the root of the destination.
  final String? folder;
  final String schedule;
  final Compression compression;
  final String objectKey;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Null until it runs: the console tells healthy from failing by it.
  final RunTableData? lastRun;

  ConfigModel({
    required this.id,
    required this.workspace,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    this.folder,
    required this.schedule,
    required this.compression,
    required this.objectKey,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
    this.lastRun,
  });

  factory ConfigModel.fromRow(ConfigTableData row, {RunTableData? lastRun}) =>
      ConfigModel(
        id: row.id,
        workspace: row.workspaceSlug,
        name: row.name,
        sourceId: row.sourceId,
        destinationId: row.destinationId,
        folder: row.folder,
        schedule: row.schedule,
        compression: row.compression,
        objectKey: row.objectKey,
        enabled: row.enabled,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        lastRun: lastRun,
      );

  /// When its schedule runs next (UTC), or null while it is disabled.
  DateTime? nextRun([DateTime? after]) => enabled
      ? CronSchedule.parse(
          schedule,
          utc: true,
        ).next((after ?? DateTime.now()).toUtc())
      : null;

  Map<String, Object?> toJson() => {
    'id': id,
    'workspace': workspace,
    'name': name,
    'source_id': sourceId,
    'destination_id': destinationId,
    'folder': folder,
    'schedule': schedule,
    'compression': compression.name,
    'object_key': objectKey,
    'enabled': enabled,
    'next_run': nextRun()?.toIso8601String(),
    'last_run': lastRun == null ? null : RunModel(lastRun!),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}
