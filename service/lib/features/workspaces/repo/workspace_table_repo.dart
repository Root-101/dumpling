import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class WorkspaceTableRepo {
  final AppDatabase _db;

  WorkspaceTableRepo(this._db);

  /// Every workspace, oldest first.
  Future<List<WorkspaceTableData>> getAll() => (_db.select(
    _db.workspaceTable,
  )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();

  /// What each workspace has, by slug: one query for all of them.
  Future<Map<String, WorkspaceStats>> stats() async {
    final rows = await _db
        .customSelect(
          'SELECT w.slug, '
          '(SELECT COUNT(*) FROM source WHERE workspace_slug = w.slug) AS sources, '
          '(SELECT COUNT(*) FROM destination WHERE workspace_slug = w.slug) AS destinations, '
          '(SELECT COUNT(*) FROM config WHERE workspace_slug = w.slug) AS configs, '
          // The configs whose last run failed
          '(SELECT COUNT(*) FROM run r WHERE r.workspace_slug = w.slug '
          "AND r.config_id IS NOT NULL AND r.status = 'failed' "
          'AND r.started_at = (SELECT MAX(started_at) FROM run '
          'WHERE config_id = r.config_id)) AS failing, '
          "(SELECT COUNT(*) FROM run WHERE workspace_slug = w.slug AND status = 'running') AS running, "
          '(SELECT MAX(started_at) FROM run WHERE workspace_slug = w.slug) AS last_run_at '
          'FROM workspace w',
          readsFrom: {
            _db.workspaceTable,
            _db.sourceTable,
            _db.destinationTable,
            _db.configTable,
            _db.runTable,
          },
        )
        .get();
    return {
      for (final row in rows)
        row.read<String>('slug'): WorkspaceStats(
          sources: row.read<int>('sources'),
          destinations: row.read<int>('destinations'),
          configs: row.read<int>('configs'),
          failing: row.read<int>('failing'),
          running: row.read<int>('running'),
          lastRunAt: row.readNullable<DateTime>('last_run_at'),
        ),
    };
  }

  Future<WorkspaceTableData?> get(String slug) => (_db.select(
    _db.workspaceTable,
  )..where((tbl) => tbl.slug.equals(slug))).getSingleOrNull();

  /// The slugs that start with [prefix], to find a free one.
  Future<Set<String>> slugsStartingWith(String prefix) async {
    final rows = await (_db.select(
      _db.workspaceTable,
    )..where((tbl) => tbl.slug.like('$prefix%'))).get();
    return {for (final row in rows) row.slug};
  }

  Future<void> insert({
    required String slug,
    required WorkspaceRequest request,
  }) async {
    await _db
        .into(_db.workspaceTable)
        .insert(
          WorkspaceTableCompanion.insert(
            slug: slug,
            name: request.trimmedName,
            description: Value(request.cleanDescription),
            color: Value(request.color),
            defaultSchedule: request.schedule,
            defaultCompression: request.compression,
            defaultObjectKey: request.objectKey,
          ),
        );
  }

  /// Replaces everything but the slug and the creation date.
  Future<void> update({
    required String slug,
    required WorkspaceRequest request,
  }) async {
    await (_db.update(
      _db.workspaceTable,
    )..where((tbl) => tbl.slug.equals(slug))).write(
      WorkspaceTableCompanion(
        name: Value(request.trimmedName),
        description: Value(request.cleanDescription),
        color: Value(request.color),
        defaultSchedule: Value(request.schedule),
        defaultCompression: Value(request.compression),
        defaultObjectKey: Value(request.objectKey),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> delete(String slug) async {
    await (_db.delete(
      _db.workspaceTable,
    )..where((tbl) => tbl.slug.equals(slug))).go();
  }
}
