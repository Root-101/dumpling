import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

/// The positions live in the rows of the nodes (`canvas_x`, `canvas_y`): a
/// node deleted takes its position with it.
class CanvasRepo {
  static const List<String> _tables = ['source', 'destination', 'config'];

  final AppDatabase _db;

  CanvasRepo(this._db);

  /// The nodes of [workspace] that are on the canvas.
  Future<Map<String, CanvasPosition>> get(String workspace) async {
    final rows = await _db
        .customSelect(
          _tables
              .map(
                (t) =>
                    'SELECT id, canvas_x, canvas_y FROM $t '
                    'WHERE workspace_slug = ?1 AND canvas_x IS NOT NULL',
              )
              .join(' UNION ALL '),
          variables: [Variable.withString(workspace)],
          readsFrom: {_db.sourceTable, _db.destinationTable, _db.configTable},
        )
        .get();
    return {
      for (final row in rows)
        row.read<String>('id'): CanvasPosition(
          row.read<double>('canvas_x'),
          row.read<double>('canvas_y'),
        ),
    };
  }

  /// Takes every node of [workspace] off the canvas but [nodes], which move
  /// to their position, in one transaction. An id that isn't of [workspace]
  /// changes nothing.
  Future<void> replace(String workspace, Map<String, CanvasPosition> nodes) =>
      _db.batch((batch) {
        for (final table in _tables) {
          batch.customStatement(
            'UPDATE $table SET canvas_x = NULL, canvas_y = NULL '
            'WHERE workspace_slug = ?',
            [workspace],
          );
          for (final MapEntry(key: id, value: p) in nodes.entries) {
            batch.customStatement(
              'UPDATE $table SET canvas_x = ?, canvas_y = ? '
              'WHERE workspace_slug = ? AND id = ?',
              [p.x, p.y, workspace, id],
            );
          }
        }
      });
}
