import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

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

  /// Cron in UTC. A new config starts with the default of the workspace; null:
  /// the service fills it in on save. The same for [compression] and
  /// [objectKey]
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
    String? Function()? schedule,
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
    schedule: schedule != null ? schedule() : this.schedule,
    compression: compression ?? this.compression,
    objectKey: objectKey != null ? objectKey() : this.objectKey,
    enabled: enabled ?? this.enabled,
    // what the service computed is stale once the schedule changes
    nextRun: schedule != null || enabled != null ? null : nextRun,
    lastRun: lastRun ?? this.lastRun,
  );
}
