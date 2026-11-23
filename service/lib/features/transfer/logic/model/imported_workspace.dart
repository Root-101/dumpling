import 'dart:convert';

import 'package:service/dumpling.dart';

class ImportedWorkspace {
  final WorkspaceRequest workspace;

  /// As exported: saved ids, settings without their secrets.
  final Map<String, dynamic> canvas;
  final Map<String, String> secrets;
  final List<ImportedRun> runs;

  ImportedWorkspace({
    required this.workspace,
    required this.canvas,
    required this.secrets,
    required this.runs,
  });

  factory ImportedWorkspace.fromJson(
    Map<String, dynamic> json, {
    required String path,
  }) => ImportedWorkspace(
    workspace: json.object('workspace', WorkspaceRequest.fromJson),
    canvas: json.field<Map<String, dynamic>>('canvas'),
    secrets: {
      for (final MapEntry(:key, :value)
          in (json.field<Map<String, dynamic>?>('secrets') ?? const {}).entries)
        key: value is String
            ? value
            : throw DeserializationException(
                'expected a string',
                path: '$path.secrets.$key',
              ),
    },
    runs: [
      for (final (i, run)
          in (json.field<List<Object?>?>('runs') ?? const []).indexed)
        if (run is Map<String, dynamic>)
          _run(run, path: '$path.runs[$i]')
        else
          throw DeserializationException(
            'expected an object',
            path: '$path.runs[$i]',
          ),
    ],
  );

  /// A finished run of the file; its id and config are set on import.
  static ImportedRun _run(Map<String, dynamic> json, {required String path}) {
    T byName<T extends Enum>(List<T> values, String name) =>
        values.asNameMap()[json.field<String>(name)] ??
        (throw DeserializationException(
          'expected one of ${values.map((v) => v.name).join(', ')}',
          path: '$path.$name',
        ));
    return ImportedRun(
      configId: json.field<String?>('config_id'),
      configName: json.field<String>('config_name'),
      sourceName: json.field<String>('source_name'),
      sourceType: byName(SourceType.values, 'source_type'),
      destinationName: json.field<String>('destination_name'),
      destinationType: byName(DestinationType.values, 'destination_type'),
      trigger: byName(RunTrigger.values, 'trigger'),
      status: byName(RunStatus.values, 'status'),
      label: json.field<String?>('label'),
      // The keys are not exported: the name stays, the id would point nowhere
      keyName: json.field<String?>('key_name'),
      location: json.field<String?>('location'),
      sizeBytes: json.field<int?>('size_bytes') ?? 0,
      error: json.field<String?>('error'),
      log: jsonEncode(json.field<List<Object?>?>('log') ?? const []),
      startedAt: json.field<DateTime>('started_at'),
      finishedAt: json.field<DateTime?>('finished_at'),
      durationMs: json.field<int?>('duration_ms'),
    );
  }
}

/// A run of an export as the file has it: the config id is the one in the
/// file, replaced on import by the id the config gets.
class ImportedRun {
  final String? configId;
  final String configName;
  final String sourceName;
  final SourceType sourceType;
  final String destinationName;
  final DestinationType destinationType;
  final RunTrigger trigger;
  final RunStatus status;
  final String? label;
  final String? keyName;
  final String? location;
  final int sizeBytes;
  final String? error;

  /// JSON of its lines
  final String log;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int? durationMs;

  const ImportedRun({
    required this.configId,
    required this.configName,
    required this.sourceName,
    required this.sourceType,
    required this.destinationName,
    required this.destinationType,
    required this.trigger,
    required this.status,
    required this.sizeBytes,
    required this.log,
    required this.startedAt,
    this.label,
    this.keyName,
    this.location,
    this.error,
    this.finishedAt,
    this.durationMs,
  });
}
