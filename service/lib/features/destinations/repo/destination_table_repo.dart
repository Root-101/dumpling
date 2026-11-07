import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

/// A destination's row with its folders, as stored (the secrets encrypted).
typedef DestinationRow = ({
  DestinationTableData destination,
  List<DestinationFolderTableData> folders,
});

class DestinationTableRepo {
  final AppDatabase _db;

  DestinationTableRepo(this._db);

  /// The destinations of [workspace], in their order, each with its folders in
  /// theirs.
  Future<List<DestinationRow>> getAll(String workspace) async {
    final destinations =
        await (_db.select(_db.destinationTable)
              ..where((tbl) => tbl.workspaceSlug.equals(workspace))
              ..orderBy([
                (tbl) => OrderingTerm.asc(tbl.position),
                (tbl) => OrderingTerm.asc(tbl.createdAt),
              ]))
            .get();
    final ids = [for (final d in destinations) d.id];
    final folders = await _folders(ids);
    return [
      for (final destination in destinations)
        (
          destination: destination,
          folders: [
            for (final folder in folders)
              if (folder.destinationId == destination.id) folder,
          ],
        ),
    ];
  }

  /// The destination [id] of [workspace]: one of another workspace is not
  /// found.
  Future<DestinationRow?> get(String workspace, String id) async {
    final destination =
        await (_db.select(_db.destinationTable)..where(
              (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
            ))
            .getSingleOrNull();
    if (destination == null) return null;
    return (destination: destination, folders: await _folders([id]));
  }

  Future<void> insert({
    required String id,
    required String workspace,
    required String name,
    required DestinationType type,
    required String settings,
    required String secretsEncrypted,
    required List<String> folders,
  }) async {
    await _db.transaction(() async {
      await _db
          .into(_db.destinationTable)
          .insert(
            DestinationTableCompanion.insert(
              id: id,
              workspaceSlug: workspace,
              name: name,
              type: type,
              settings: settings,
              secretsEncrypted: secretsEncrypted,
              position: Value(await _next(workspace)),
            ),
          );
      await _insertFolders(id, folders);
    });
  }

  /// Whether saving [row] with these values changes what its last check
  /// tested: the type, the settings, the secrets (stored, new) or the folders.
  static bool connectionChanged(
    DestinationRow row, {
    required DestinationType type,
    required String settings,
    required (Map<String, String>, Map<String, String>) secrets,
    required List<String> folders,
  }) {
    final saved = [for (final f in row.folders) f.path];
    return row.destination.type != type ||
        row.destination.settings != settings ||
        !Secrets.same(secrets.$1, secrets.$2) ||
        saved.length != folders.length ||
        !saved.toSet().containsAll(folders);
  }

  /// Replaces the name, type, connection and folders. The last check goes
  /// only when [connectionChanged] (the folders too: it tested each one).
  Future<void> update({
    required String id,
    required String name,
    required DestinationType type,
    required String settings,
    required String secretsEncrypted,
    required List<String> folders,
    required bool connectionChanged,
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.destinationTable,
      )..where((tbl) => tbl.id.equals(id))).write(
        DestinationTableCompanion(
          name: Value(name),
          type: Value(type),
          settings: Value(settings),
          secretsEncrypted: Value(secretsEncrypted),
          lastCheck: connectionChanged
              ? const Value(null)
              : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await (_db.delete(
        _db.destinationFolderTable,
      )..where((tbl) => tbl.destinationId.equals(id))).go();
      await _insertFolders(id, folders);
    });
  }

  Future<void> updateLastCheck({
    required String id,
    required String lastCheck,
  }) async {
    await (_db.update(_db.destinationTable)..where((tbl) => tbl.id.equals(id)))
        .write(DestinationTableCompanion(lastCheck: Value(lastCheck)));
  }

  /// Its folders go with it (foreign key in cascade).
  Future<void> delete(String id) async {
    await (_db.delete(
      _db.destinationTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Saves the order of [ids], the first at 0: the ones of a workspace, all of
  /// them, checked by the caller.
  Future<void> reorder(List<String> ids) async {
    await _db.batch((batch) {
      for (final (i, id) in ids.indexed) {
        batch.update(
          _db.destinationTable,
          DestinationTableCompanion(position: Value(i)),
          where: (tbl) => tbl.id.equals(id),
        );
      }
    });
  }

  /// The position after the last one of [workspace]: where a new one goes.
  Future<int> _next(String workspace) async {
    final last = _db.destinationTable.position.max();
    final row =
        await (_db.selectOnly(_db.destinationTable)
              ..addColumns([last])
              ..where(_db.destinationTable.workspaceSlug.equals(workspace)))
            .getSingle();
    final value = row.read(last);
    return value == null ? 0 : value + 1;
  }

  Future<List<DestinationFolderTableData>> _folders(List<String> ids) =>
      (_db.select(_db.destinationFolderTable)
            ..where((tbl) => tbl.destinationId.isIn(ids))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.position)]))
          .get();

  Future<void> _insertFolders(String id, List<String> folders) async {
    await _db.batch((batch) {
      batch.insertAll(_db.destinationFolderTable, [
        for (final (i, path) in folders.indexed)
          DestinationFolderTableCompanion.insert(
            destinationId: id,
            path: path,
            position: Value(i),
          ),
      ]);
    });
  }
}
