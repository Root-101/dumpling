import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class SourceTableRepo {
  final AppDatabase _db;

  SourceTableRepo(this._db);

  /// The sources of [workspace], oldest first.
  Future<List<SourceTableData>> getAll(String workspace) =>
      (_db.select(_db.sourceTable)
            ..where((tbl) => tbl.workspaceSlug.equals(workspace))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
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
          ),
        );
  }

  /// Replaces the name, type and connection; the last check goes, since it
  /// was of the old connection.
  Future<void> update({
    required String id,
    required String name,
    required SourceType type,
    required String settings,
    required String secretsEncrypted,
  }) async {
    await (_db.update(
      _db.sourceTable,
    )..where((tbl) => tbl.id.equals(id))).write(
      SourceTableCompanion(
        name: Value(name),
        type: Value(type),
        settings: Value(settings),
        secretsEncrypted: Value(secretsEncrypted),
        lastCheck: const Value(null),
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
}
