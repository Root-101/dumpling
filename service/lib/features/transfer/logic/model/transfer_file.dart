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
    'exported_at': exportedAt.toJsonDate(),
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
