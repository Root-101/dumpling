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

  /// The destinations of [workspace], oldest first, each with its folders in
  /// alphabetical order.
  Future<List<DestinationRow>> getAll(String workspace) async {
    final destinations =
        await (_db.select(_db.destinationTable)
              ..where((tbl) => tbl.workspaceSlug.equals(workspace))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
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
            ),
          );
      await _insertFolders(id, folders);
    });
  }

  /// Replaces the name, type, connection and folders; the last check goes,
  /// since it was of the old connection.
  Future<void> update({
    required String id,
    required String name,
    required DestinationType type,
    required String settings,
    required String secretsEncrypted,
    required List<String> folders,
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
          lastCheck: const Value(null),
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

  Future<List<DestinationFolderTableData>> _folders(List<String> ids) =>
      (_db.select(_db.destinationFolderTable)
            ..where((tbl) => tbl.destinationId.isIn(ids))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.path)]))
          .get();

  Future<void> _insertFolders(String id, List<String> folders) async {
    await _db.batch((batch) {
      batch.insertAll(_db.destinationFolderTable, [
        for (final path in folders)
          DestinationFolderTableCompanion.insert(destinationId: id, path: path),
      ]);
    });
  }
}
