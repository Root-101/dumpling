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
    RunTrigger? trigger,
    String? label,
    String? configId,
    Set<String>? configIds,
    int limit = 200,
  }) =>
      (_db.select(_db.runTable)
            ..where((tbl) {
              Expression<bool> where = tbl.workspaceSlug.equals(workspace);
              if (trigger != null) where &= tbl.trigger.equalsValue(trigger);
              if (label != null) where &= tbl.label.equals(label);
              if (configIds != null) where &= tbl.configId.isIn(configIds);
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

  /// The runs of [workspace] that ended, started at [since] or later, oldest
  /// first: what an export carries.
  Future<List<RunTableData>> finishedSince(String workspace, DateTime since) =>
      (_db.select(_db.runTable)
            ..where(
              (tbl) =>
                  tbl.workspaceSlug.equals(workspace) &
                  tbl.startedAt.isBiggerOrEqualValue(since) &
                  tbl.status.isInValues([
                    RunStatus.queued,
                    RunStatus.running,
                  ]).not(),
            )
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.startedAt)]))
          .get();

  Future<RunTableData?> get(String workspace, String id) =>
      (_db.select(_db.runTable)..where(
            (tbl) => tbl.workspaceSlug.equals(workspace) & tbl.id.equals(id),
          ))
          .getSingleOrNull();

  /// A new run; the fields after [startedAt] only for one that already ended
  /// (an import).
  Future<void> insert({
    required String id,
    required String workspace,
    required String? configId,
    required String configName,
    required String sourceName,
    required SourceType sourceType,
    required String destinationName,
    required DestinationType destinationType,
    required RunTrigger trigger,
    required RunStatus status,
    required DateTime startedAt,
    String? label,
    String? keyId,
    String? keyName,
    String? location,
    int sizeBytes = 0,
    String? error,
    String log = '[]',
    DateTime? finishedAt,
    int? durationMs,
  }) => _db
      .into(_db.runTable)
      .insert(
        RunTableCompanion.insert(
          id: id,
          workspaceSlug: workspace,
          configId: Value(configId),
          configName: configName,
          sourceName: sourceName,
          sourceType: sourceType,
          destinationName: destinationName,
          destinationType: destinationType,
          trigger: trigger,
          status: status,
          label: Value(label),
          keyId: Value(keyId),
          keyName: Value(keyName),
          location: Value(location),
          sizeBytes: Value(sizeBytes),
          error: Value(error),
          log: Value(log),
          startedAt: startedAt,
          finishedAt: Value(finishedAt),
          durationMs: Value(durationMs),
        ),
      );

  /// A queued run that starts now.
  Future<void> start(String id, DateTime at) => _write(
    id,
    RunTableCompanion(
      status: const Value(RunStatus.running),
      startedAt: Value(at),
    ),
  );

  /// Where the file of [id] goes.
  Future<void> setLocation(String id, String location) =>
      _write(id, RunTableCompanion(location: Value(location)));

  /// The bytes uploaded so far.
  Future<void> setSize(String id, int bytes) =>
      _write(id, RunTableCompanion(sizeBytes: Value(bytes)));

  /// The multipart upload in progress (JSON), to abort it after a stop.
  Future<void> setPendingUpload(String id, String pending) =>
      _write(id, RunTableCompanion(pendingUpload: Value(pending)));

  /// The end of [id]: [status] with its log and, if it failed, [error].
  Future<void> finish(
    String id, {
    required RunStatus status,
    required String log,
    required DateTime finishedAt,
    int? sizeBytes,
    String? error,
    int? durationMs,
  }) => _write(
    id,
    RunTableCompanion(
      status: Value(status),
      sizeBytes: Value.absentIfNull(sizeBytes),
      error: Value(error),
      log: Value(log),
      finishedAt: Value(finishedAt),
      durationMs: Value.absentIfNull(durationMs),
      // completed or aborted: nothing left to abort on a restart
      pendingUpload: const Value(null),
    ),
  );

  /// A queued run that can't start ([error]), without log.
  Future<void> failBeforeStart(String id, String error, DateTime at) => _write(
    id,
    RunTableCompanion(
      status: const Value(RunStatus.failed),
      error: Value(error),
      finishedAt: Value(at),
    ),
  );

  Future<void> _write(String id, RunTableCompanion values) => (_db.update(
    _db.runTable,
  )..where((tbl) => tbl.id.equals(id))).write(values);

  /// The runs still running: on start, those a stop left half done.
  Future<List<RunTableData>> running() => (_db.select(
    _db.runTable,
  )..where((tbl) => tbl.status.equalsValue(RunStatus.running))).get();

  /// The runs a stop of the service left running or queued: failed, with
  /// [error].
  Future<int> failUnfinished(String error) =>
      (_db.update(_db.runTable)..where(
            (tbl) =>
                tbl.status.isInValues([RunStatus.queued, RunStatus.running]),
          ))
          .write(
            RunTableCompanion(
              status: const Value(RunStatus.failed),
              error: Value(error),
              finishedAt: Value(utcNow()),
              pendingUpload: const Value(null),
            ),
          );
}
