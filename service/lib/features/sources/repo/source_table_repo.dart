import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class SourceTableRepo {
  final AppDatabase _db;

  SourceTableRepo(this._db);

  /// The sources of [workspace], in their order.
  Future<List<SourceTableData>> getAll(String workspace) =>
      (_db.select(_db.sourceTable)
            ..where((tbl) => tbl.workspaceSlug.equals(workspace))
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.position),
              (tbl) => OrderingTerm.asc(tbl.createdAt),
            ]))
          .get();

  /// The source [id] of [workspace]: one of another workspace is not found.
  Future<SourceTableData?> get(String workspace, String id) =>
      (_db.select(_db.sourceTable)..where(
            (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
          ))
          .getSingleOrNull();

  Future<void> insert({
    required String id,
    required String workspace,
    required String name,
    required SourceType type,
    required String settings,
    required String secretsEncrypted,
  }) async {
    await _db
        .into(_db.sourceTable)
        .insert(
          SourceTableCompanion.insert(
            id: id,
            workspaceSlug: workspace,
            name: name,
            type: type,
            settings: settings,
            secretsEncrypted: secretsEncrypted,
            position: Value(await _next(workspace)),
          ),
        );
  }

  /// Replaces the name, type and connection. The last check goes only when
  /// [connectionChanged]: it was of the old connection.
  Future<void> update({
    required String id,
    required String name,
    required SourceType type,
    required String settings,
    required String secretsEncrypted,
    required bool connectionChanged,
  }) async {
    await (_db.update(
      _db.sourceTable,
    )..where((tbl) => tbl.id.equals(id))).write(
      SourceTableCompanion(
        name: Value(name),
        type: Value(type),
        settings: Value(settings),
        secretsEncrypted: Value(secretsEncrypted),
        lastCheck: connectionChanged ? const Value(null) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> updateLastCheck({
    required String id,
    required String lastCheck,
  }) async {
    await (_db.update(_db.sourceTable)..where((tbl) => tbl.id.equals(id)))
        .write(SourceTableCompanion(lastCheck: Value(lastCheck)));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.sourceTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Saves the order of [ids], the first at 0: the ones of a workspace, all of
  /// them, checked by the caller.
  Future<void> reorder(List<String> ids) async {
    await _db.batch((batch) {
      for (final (i, id) in ids.indexed) {
        batch.update(
          _db.sourceTable,
          SourceTableCompanion(position: Value(i)),
          where: (tbl) => tbl.id.equals(id),
        );
      }
    });
  }

  /// The position after the last one of [workspace]: where a new one goes.
  Future<int> _next(String workspace) async {
    final last = _db.sourceTable.position.max();
    final row =
        await (_db.selectOnly(_db.sourceTable)
              ..addColumns([last])
              ..where(_db.sourceTable.workspaceSlug.equals(workspace)))
            .getSingle();
    final value = row.read(last);
    return value == null ? 0 : value + 1;
  }
}
