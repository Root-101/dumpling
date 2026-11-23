import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

class ImportedWorkspace {
  final WorkspaceRequest workspace;

  /// As exported: saved ids, settings without their secrets.
  final Map<String, dynamic> canvas;
  final Map<String, String> secrets;
  final List<RunTableCompanion> runs;

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
  static RunTableCompanion _run(
    Map<String, dynamic> json, {
    required String path,
  }) {
    T byName<T extends Enum>(List<T> values, String name) =>
        values.asNameMap()[json.field<String>(name)] ??
        (throw DeserializationException(
          'expected one of ${values.map((v) => v.name).join(', ')}',
          path: '$path.$name',
        ));
    return RunTableCompanion.insert(
      id: json.field<String>('id'),
      workspaceSlug: '',
      configId: Value(json.field<String?>('config_id')),
      configName: json.field<String>('config_name'),
      sourceName: json.field<String>('source_name'),
      sourceType: byName(SourceType.values, 'source_type'),
      destinationName: json.field<String>('destination_name'),
      destinationType: byName(DestinationType.values, 'destination_type'),
      trigger: byName(RunTrigger.values, 'trigger'),
      status: byName(RunStatus.values, 'status'),
      label: Value(json.field<String?>('label')),
      // The keys are not exported: the name stays, the id would point nowhere
      keyName: Value(json.field<String?>('key_name')),
      location: Value(json.field<String?>('location')),
      sizeBytes: Value(json.field<int?>('size_bytes') ?? 0),
      error: Value(json.field<String?>('error')),
      log: Value(jsonEncode(json.field<List<Object?>?>('log') ?? const [])),
      startedAt: json.field<DateTime>('started_at'),
      finishedAt: Value(json.field<DateTime?>('finished_at')),
      durationMs: Value(json.field<int?>('duration_ms')),
    );
  }
}
