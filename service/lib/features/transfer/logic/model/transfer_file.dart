import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

/// The file of an export, and the body of an import: workspaces with their
/// canvas, their credentials as stored (encrypted, bound to the ids in the
/// file) and the runs of their last month. What carries the data between
/// versions of 0.x, which don't migrate the database.
abstract final class TransferFile {
  static const String format = 'dumpling';

  /// Of the file, not of Dumpling: it changes only when an import can't read
  /// what an older export wrote.
  static const int version = 1;

  /// The runs it carries, newest back to this.
  static const Duration runsSince = Duration(days: 30);

  static Map<String, Object?> toJson(
    List<TransferWorkspace> workspaces, {
    required DateTime exportedAt,
  }) => {
    'format': format,
    'version': version,
    'exported_at': exportedAt.toUtc().toIso8601String(),
    'workspaces': workspaces,
  };
}

/// One workspace of an export.
class TransferWorkspace {
  final WorkspaceModel workspace;
  final CanvasModel canvas;

  /// The encrypted secrets of each source and destination, by its id.
  final Map<String, String> secrets;
  final List<RunTableData> runs;

  TransferWorkspace({
    required this.workspace,
    required this.canvas,
    required this.secrets,
    required this.runs,
  });

  Map<String, Object?> toJson() {
    final nodes = canvas.toJson();
    return {
      'workspace': {
        'name': workspace.name,
        'description': workspace.description,
        'color': workspace.color,
        'defaults': workspace.defaults,
      },
      'canvas': {
        'sources': nodes['sources'],
        'destinations': nodes['destinations'],
        'configs': nodes['configs'],
      },
      'secrets': secrets,
      'runs': [for (final run in runs) RunModel(run, withLog: true)],
    };
  }
}

/// Body of an import: a [TransferFile]. The canvas of each workspace is
/// checked once its ids and secrets are resolved, by [TransferService].
class ImportRequest implements Validatable {
  final String? format;
  final int? version;
  final List<ImportedWorkspace> workspaces;

  ImportRequest({this.format, this.version, required this.workspaces});

  factory ImportRequest.fromJson(Map<String, dynamic> json) => ImportRequest(
    format: json.field<String?>('format'),
    version: json.field<int?>('version'),
    workspaces: [
      for (final (i, w) in json.field<List<Object?>>('workspaces').indexed)
        if (w is Map<String, dynamic>)
          ImportedWorkspace.fromJson(w, path: '\$.workspaces[$i]')
        else
          throw DeserializationException(
            'expected an object',
            path: '\$.workspaces[$i]',
          ),
    ],
  );

  @override
  ConstraintValidatorContext validate() {
    final context = ConstraintValidatorContext()
      ..field('format', format).custom(
        (f) =>
            f == TransferFile.format ? null : intl.errors.transfer.notAnExport,
      )
      ..field('version', version).custom(
        (v) => v == TransferFile.version
            ? null
            : intl.errors.transfer.version(version: TransferFile.version),
      )
      ..field('workspaces', workspaces).size(min: 1);
    for (final (i, w) in workspaces.indexed) {
      context.merge(w.workspace.validate(), prefix: 'workspaces[$i].workspace');
    }
    return context;
  }
}

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
