import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class ApiKeyTableRepo {
  final AppDatabase _db;

  ApiKeyTableRepo(this._db);

  /// The keys of [workspace], in their order.
  Future<List<ApiKeyTableData>> getAll(String workspace) =>
      (_db.select(_db.apiKeyTable)
            ..where((tbl) => tbl.workspaceSlug.equals(workspace))
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.position),
              (tbl) => OrderingTerm.asc(tbl.createdAt),
            ]))
          .get();

  /// The key [id] of [workspace]: one of another workspace is not found.
  Future<ApiKeyTableData?> get(String workspace, String id) =>
      (_db.select(_db.apiKeyTable)..where(
            (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
          ))
          .getSingleOrNull();

  /// The key [id] of any workspace: what a request authenticates with.
  Future<ApiKeyTableData?> byId(String id) => (_db.select(
    _db.apiKeyTable,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// A new key of [workspace], stored by the hash of its secret; it goes last.
  /// [permissions] and [configIds] are JSON lists.
  Future<void> insert({
    required String id,
    required String workspace,
    required String name,
    required String secretHash,
    required String permissions,
    required String configIds,
  }) async {
    final position = await _next(workspace);
    await _db
        .into(_db.apiKeyTable)
        .insert(
          ApiKeyTableCompanion.insert(
            id: id,
            workspaceSlug: workspace,
            name: name,
            secretHash: secretHash,
            permissions: permissions,
            configIds: Value(configIds),
            position: Value(position),
          ),
        );
  }

  /// What a key may do; its secret never changes.
  Future<void> update(
    String id, {
    required String name,
    required String permissions,
    required String configIds,
  }) => _write(
    id,
    ApiKeyTableCompanion(
      name: Value(name),
      permissions: Value(permissions),
      configIds: Value(configIds),
      updatedAt: Value(utcNow()),
    ),
  );

  /// The key was used [at].
  Future<void> touch(String id, DateTime at) =>
      _write(id, ApiKeyTableCompanion(lastUsedAt: Value(at)));

  Future<void> _write(String id, ApiKeyTableCompanion values) => (_db.update(
    _db.apiKeyTable,
  )..where((tbl) => tbl.id.equals(id))).write(values);

  Future<void> delete(String id) async {
    await (_db.delete(_db.apiKeyTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// [ids] in this order: each one's position is its index.
  Future<void> reorder(List<String> ids) async {
    await _db.batch((batch) {
      for (final (i, id) in ids.indexed) {
        batch.update(
          _db.apiKeyTable,
          ApiKeyTableCompanion(position: Value(i)),
          where: (tbl) => tbl.id.equals(id),
        );
      }
    });
  }

  /// The last run each key of [workspace] started, by key.
  Future<Map<String, RunTableData>> lastRuns(String workspace) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM run r WHERE workspace_slug = ? AND key_id IS NOT NULL '
          'AND started_at = (SELECT MAX(started_at) FROM run '
          'WHERE key_id = r.key_id)',
          variables: [Variable.withString(workspace)],
          readsFrom: {_db.runTable},
        )
        .get();
    return {
      for (final row in rows)
        row.read<String>('key_id'): await _db.runTable.mapFromRow(row),
    };
  }

  /// The position after the last one of [workspace]: where a new one goes.
  Future<int> _next(String workspace) async {
    final last = _db.apiKeyTable.position.max();
    final row =
        await (_db.selectOnly(_db.apiKeyTable)
              ..addColumns([last])
              ..where(_db.apiKeyTable.workspaceSlug.equals(workspace)))
            .getSingle();
    final value = row.read(last);
    return value == null ? 0 : value + 1;
  }
}
