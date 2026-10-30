import 'package:console/app_exporter.dart';

/// A line of the log of a run: technical, in English, like the tools it runs
class RunLogLine {
  final DateTime at;
  final String message;

  const RunLogLine(this.at, this.message);

  factory RunLogLine.fromJson(Map<String, dynamic> json) =>
      RunLogLine(DateTime.parse(json['at']), json['message']);
}

enum RunStepState { done, failed, running, waiting, skipped }

/// A step of a run ([RunModel.steps]) and how long it took, when known
class RunStep {
  final RunStepState state;
  final Duration? duration;

  const RunStep(this.state, [this.duration]);
}

/// A backup that ran (or runs): the names of its config, source and
/// destination are those it had then
class RunModel {
  final String id;

  /// Null once its config was deleted
  final String? configId;
  final String configName;
  final String sourceName;
  final String sourceType;
  final String destinationName;
  final String destinationType;

  /// `schedule` or `manual`
  final String trigger;
  final RunStatus status;

  /// Where the file went (`s3://bucket/key`); null before the dump starts
  final String? location;
  final int? sizeBytes;
  final String? error;
  final DateTime startedAt;
  final DateTime? finishedAt;

  /// Only in the detail of a run; null in the list
  final List<RunLogLine>? log;

  const RunModel({
    required this.id,
    required this.configId,
    required this.configName,
    required this.sourceName,
    required this.sourceType,
    required this.destinationName,
    required this.destinationType,
    required this.trigger,
    required this.status,
    required this.startedAt,
    this.location,
    this.sizeBytes,
    this.error,
    this.finishedAt,
    this.log,
  });

  factory RunModel.fromJson(Map<String, dynamic> json) {
    final finished = json['finished_at'];
    final log = json['log'] as List?;
    return RunModel(
      id: json['id'],
      configId: json['config_id'],
      configName: json['config_name'],
      sourceName: json['source_name'],
      sourceType: json['source_type'],
      destinationName: json['destination_name'],
      destinationType: json['destination_type'],
      trigger: json['trigger'],
      status: RunStatus.values.byName(json['status']),
      location: json['location'],
      sizeBytes: json['size_bytes'],
      error: json['error'],
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: finished == null ? null : DateTime.parse(finished),
      log: log?.map((e) => RunLogLine.fromJson(e)).toList(),
    );
  }

  bool get manual => trigger == 'manual';

  Duration? get duration => finishedAt?.difference(startedAt);

  /// Connect, then dump and upload (one stream), read from the lines the
  /// service writes. While it runs there is no log yet (written at the end):
  /// bytes uploaded mean it got past connecting
  List<RunStep> get steps {
    final lines = log ?? const <RunLogLine>[];
    RunLogLine? find(String start) =>
        lines.where((l) => l.message.startsWith(start)).firstOrNull;
    final checking = find('Checking the connection');
    final connected = find('Connected:');
    final dumping = find('Dumping into');
    final uploaded = find('Uploaded');
    final failure = find('Failed:');
    Duration? between(RunLogLine? a, RunLogLine? b) =>
        a == null || b == null ? null : b.at.difference(a.at);

    switch (status) {
      case RunStatus.success:
        return [
          RunStep(RunStepState.done, between(checking, connected)),
          RunStep(RunStepState.done, between(dumping, uploaded)),
        ];
      case RunStatus.running:
        final pastConnect = connected != null || (sizeBytes ?? 0) > 0;
        return pastConnect
            ? const [RunStep(RunStepState.done), RunStep(RunStepState.running)]
            : const [
                RunStep(RunStepState.running),
                RunStep(RunStepState.waiting),
              ];
      case RunStatus.failed:
        return connected == null
            ? [
                RunStep(RunStepState.failed, between(checking, failure)),
                const RunStep(RunStepState.skipped),
              ]
            : [
                RunStep(RunStepState.done, between(checking, connected)),
                RunStep(RunStepState.failed, between(dumping, failure)),
              ];
    }
  }

  /// The log as text, to copy: one `time  message` per line
  String get logText => [
    for (final line in log ?? const <RunLogLine>[])
      '${line.at.toUtc().toIso8601String()}  ${line.message}',
  ].join('\n');
}
