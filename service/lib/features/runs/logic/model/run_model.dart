import 'dart:convert';

import 'package:service/dumpling.dart';

enum RunTrigger { schedule, manual }

enum RunStatus { running, success, failed }

/// A line of the log of a run: technical, in English, like the tools it runs.
class RunLogLine {
  final DateTime at;
  final String message;

  RunLogLine(this.at, this.message);

  factory RunLogLine.fromJson(Map<String, dynamic> json) => RunLogLine(
    DateTime.parse(json['at'] as String),
    json['message'] as String,
  );

  Map<String, Object?> toJson() => {
    'at': at.toUtc().toIso8601String(),
    'message': message,
  };
}

class RunModel {
  final RunTableData row;

  /// With [withLog], the lines of its log too (only the detail has them).
  final bool withLog;

  RunModel(this.row, {this.withLog = false});

  Map<String, Object?> toJson() => {
    'id': row.id,
    'workspace': row.workspaceSlug,
    'config_id': row.configId,
    'config_name': row.configName,
    'source_name': row.sourceName,
    'source_type': row.sourceType.name,
    'destination_name': row.destinationName,
    'destination_type': row.destinationType.name,
    'trigger': row.trigger.name,
    'status': row.status.name,
    'location': row.location,
    'size_bytes': row.sizeBytes,
    'error': row.error,
    'started_at': row.startedAt.toUtc().toIso8601String(),
    'finished_at': row.finishedAt?.toUtc().toIso8601String(),
    // A run cut by a stop has no measure: the times give it to the second
    'duration_ms':
        row.durationMs ??
        row.finishedAt?.difference(row.startedAt).inMilliseconds,
    if (withLog) 'log': jsonDecode(row.log),
  };
}
