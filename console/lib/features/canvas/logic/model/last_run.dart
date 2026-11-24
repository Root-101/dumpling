import 'package:console/app_exporter.dart';

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

  /// Queued or running: not ended yet
  bool get running => status == RunStatus.running || status == RunStatus.queued;
}
