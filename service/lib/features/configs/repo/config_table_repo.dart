import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

/// What a config stores, besides its id, workspace and order.
typedef ConfigValues = ({
  String name,
  String sourceId,
  String destinationId,
  String? folder,
  String schedule,
  Compression compression,
  String objectKey,
  bool enabled,
});

class ConfigTableRepo {
  final AppDatabase _db;

  ConfigTableRepo(this._db);

  /// The configs of [workspace], in their order.
  Future<List<ConfigTableData>> getAll(String workspace) =>
      (_db.select(_db.configTable)
            ..where((tbl) => tbl.workspaceSlug.equals(workspace))
            ..orderBy([
              (tbl) => OrderingTerm.asc(tbl.position),
              (tbl) => OrderingTerm.asc(tbl.createdAt),
            ]))
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

  /// A new config of [workspace]; it goes last.
  Future<void> insert({
    required String id,
    required String workspace,
    required ConfigValues values,
  }) async {
    final position = await _next(workspace);
    await _db
        .into(_db.configTable)
        .insert(
          _companion(values).copyWith(
            id: Value(id),
            workspaceSlug: Value(workspace),
            position: Value(position),
          ),
        );
  }

  /// Replaces everything but the id, the workspace and the creation date.
  Future<void> update(String id, ConfigValues values) async {
    await (_db.update(_db.configTable)..where((tbl) => tbl.id.equals(id)))
        .write(_companion(values).copyWith(updatedAt: Value(utcNow())));
  }

  static ConfigTableCompanion _companion(ConfigValues values) =>
      ConfigTableCompanion(
        name: Value(values.name),
        sourceId: Value(values.sourceId),
        destinationId: Value(values.destinationId),
        folder: Value(values.folder),
        schedule: Value(values.schedule),
        compression: Value(values.compression),
        objectKey: Value(values.objectKey),
        enabled: Value(values.enabled),
      );

  Future<void> delete(String id) async {
    await (_db.delete(_db.configTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// Saves the order of [ids], the first at 0: the ones of a workspace, all of
  /// them, checked by the caller.
  Future<void> reorder(List<String> ids) async {
    await _db.batch((batch) {
      for (final (i, id) in ids.indexed) {
        batch.update(
          _db.configTable,
          ConfigTableCompanion(position: Value(i)),
          where: (tbl) => tbl.id.equals(id),
        );
      }
    });
  }

  /// The position after the last one of [workspace]: where a new one goes.
  Future<int> _next(String workspace) async {
    final last = _db.configTable.position.max();
    final row =
        await (_db.selectOnly(_db.configTable)
              ..addColumns([last])
              ..where(_db.configTable.workspaceSlug.equals(workspace)))
            .getSingle();
    final value = row.read(last);
    return value == null ? 0 : value + 1;
  }
}
