import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:service/dumpling.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

part 'database.g.dart';

// Generate the code with: fvm dart run build_runner build
// The tables are in tables/, one file per feature.

@DriftDatabase(
  tables: [
    RunTable,
    ApiKeyTable,
    ConfigTable,
    DestinationFolderTable,
    DestinationTable,
    SourceTable,
    WorkspaceTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  /// SQLite leaves the foreign keys off unless asked, on every connection:
  /// without them deleting a workspace would leave its sources behind.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );

  static const String fileName = 'dumpling.sqlite';

  /// Whether SQLite answers: the check of the health route.
  Future<bool> ping() async {
    try {
      await customSelect('SELECT 1').get();
      return true;
    } catch (e, stackTrace) {
      logger.error('Health check failed', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static String get defaultPath => p.join(env.dataPath, fileName);

  static QueryExecutor _openConnection() {
    final file = File(defaultPath);
    // SQLite creates the file but not its folder
    file.parent.createSync(recursive: true);
    return NativeDatabase.createInBackground(file, setup: _setUp);
  }

  /// WAL with `synchronous=NORMAL` (like feather-io): readers don't wait for a
  /// writer, and a crash of the process loses nothing.
  static void _setUp(Database database) {
    database
      ..execute('PRAGMA journal_mode = WAL')
      ..execute('PRAGMA synchronous = NORMAL');
  }
}
