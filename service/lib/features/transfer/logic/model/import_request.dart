import 'package:service/dumpling.dart';

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
        code: 'transfer.notAnExport',
      )
      ..field('version', version).custom(
        (v) => v == TransferFile.version
            ? null
            : intl.errors.transfer.version(version: TransferFile.version),
        code: 'transfer.version',
      )
      ..field('workspaces', workspaces).size(min: 1);
    for (final (i, w) in workspaces.indexed) {
      context.merge(w.workspace.validate(), prefix: 'workspaces[$i].workspace');
    }
    return context;
  }
}
