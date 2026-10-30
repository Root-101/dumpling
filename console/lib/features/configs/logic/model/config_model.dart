import 'package:console/app_exporter.dart';

/// A backup: what it dumps ([sourceId]) and where it writes it
/// ([destinationId], in [folder]), when ([schedule]) and how its last run
/// went. Only what the lists and the details need so far
class ConfigModel {
  final String id;
  final String name;
  final String sourceId;
  final String destinationId;

  /// Null: the root of the destination
  final String? folder;

  /// Cron in UTC: `0 2 * * *`
  final String schedule;
  final bool enabled;

  /// Null while it is disabled
  final DateTime? nextRun;

  /// Null until it runs the first time
  final RunModel? lastRun;

  const ConfigModel({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    this.folder,
    this.schedule = '',
    this.enabled = true,
    this.nextRun,
    this.lastRun,
  });
}
