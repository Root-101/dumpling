import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

class WorkspaceTableRepo {
  final AppDatabase _db;

  WorkspaceTableRepo(this._db);

  /// Every workspace, oldest first.
  Future<List<WorkspaceTableData>> getAll() => (_db.select(
    _db.workspaceTable,
  )..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)])).get();

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
