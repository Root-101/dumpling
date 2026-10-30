import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class RunTableRepo {
  final AppDatabase _db;

  RunTableRepo(this._db);

  /// The runs of [workspace], newest first, at most [limit].
  Future<List<RunTableData>> getAll(
    String workspace, {
    SourceType? sourceType,
    DestinationType? destinationType,
    RunStatus? status,
    String? configId,
    int limit = 200,
  }) =>
      (_db.select(_db.runTable)
            ..where((tbl) {
              Expression<bool> where = tbl.workspaceSlug.equals(workspace);
              if (sourceType != null) {
                where &= tbl.sourceType.equalsValue(sourceType);
              }
              if (destinationType != null) {
                where &= tbl.destinationType.equalsValue(destinationType);
              }
              if (status != null) where &= tbl.status.equalsValue(status);
              if (configId != null) where &= tbl.configId.equals(configId);
              return where;
            })
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.startedAt)])
            ..limit(limit))
          .get();

  /// The last run of each config of [workspace] that has run, by config.
  Future<Map<String, RunTableData>> lastByConfig(String workspace) async {
    final rows = await _db
        .customSelect(
          'SELECT * FROM run r WHERE workspace_slug = ? AND config_id IS NOT NULL '
          'AND started_at = (SELECT MAX(started_at) FROM run '
          'WHERE config_id = r.config_id)',
          variables: [Variable.withString(workspace)],
          readsFrom: {_db.runTable},
        )
        .get();
    return {
      for (final row in rows)
        row.read<String>('config_id'): await _db.runTable.mapFromRow(row),
    };
  }

  Future<RunTableData?> get(String workspace, String id) =>
      (_db.select(_db.runTable)..where(
            (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
          ))
          .getSingleOrNull();

  Future<void> insert(RunTableCompanion run) async {
    await _db.into(_db.runTable).insert(run);
  }

  Future<void> update(String id, RunTableCompanion run) async {
    await (_db.update(
      _db.runTable,
    )..where((tbl) => tbl.id.equals(id))).write(run);
  }

  /// The runs still running: on start, those a stop left half done.
  Future<List<RunTableData>> running() => (_db.select(
    _db.runTable,
  )..where((tbl) => tbl.status.equalsValue(RunStatus.running))).get();

  /// The runs a stop of the service left half done: failed, with [error].
  Future<int> failRunning(String error) =>
      (_db.update(
        _db.runTable,
      )..where((tbl) => tbl.status.equalsValue(RunStatus.running))).write(
        RunTableCompanion(
          status: const Value(RunStatus.failed),
          error: Value(error),
          finishedAt: Value(DateTime.now()),
        ),
      );
}
