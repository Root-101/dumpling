import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class ConfigTableRepo {
  final AppDatabase _db;

  ConfigTableRepo(this._db);

  /// The configs of [workspace], oldest first.
  Future<List<ConfigTableData>> getAll(String workspace) =>
      (_db.select(_db.configTable)
            ..where((tbl) => tbl.workspaceSlug.equals(workspace))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();

  /// The config [id] of [workspace]: one of another workspace is not found.
  Future<ConfigTableData?> get(String workspace, String id) =>
      (_db.select(_db.configTable)..where(
            (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
          ))
          .getSingleOrNull();

  /// The config [id], of any workspace (the engine runs them all).
  Future<ConfigTableData?> byId(String id) => (_db.select(
    _db.configTable,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Every enabled config, to schedule them on start.
  Future<List<ConfigTableData>> getAllEnabled() => (_db.select(
    _db.configTable,
  )..where((tbl) => tbl.enabled.equals(true))).get();

  /// The configs that dump [sourceId].
  Future<List<ConfigTableData>> bySource(String sourceId) => (_db.select(
    _db.configTable,
  )..where((tbl) => tbl.sourceId.equals(sourceId))).get();

  /// The configs that write to [destinationId].
  Future<List<ConfigTableData>> byDestination(String destinationId) =>
      (_db.select(
        _db.configTable,
      )..where((tbl) => tbl.destinationId.equals(destinationId))).get();

  Future<void> insert(ConfigTableCompanion config) async {
    await _db.into(_db.configTable).insert(config);
  }

  /// Replaces everything but the id, the workspace and the creation date.
  Future<void> update(String id, ConfigTableCompanion config) async {
    await (_db.update(_db.configTable)..where((tbl) => tbl.id.equals(id)))
        .write(config.copyWith(updatedAt: Value(DateTime.now())));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.configTable)..where((tbl) => tbl.id.equals(id))).go();
  }
}
