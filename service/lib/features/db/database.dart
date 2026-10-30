import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:service/dumpling.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

part 'database.g.dart';

// Generate the code with: fvm dart run build_runner build

/// A separate space with its own canvas, sources, destinations and configs.
/// Every time is stored in UTC.
class WorkspaceTable extends Table {
  @override
  String get tableName => 'workspace';

  /// From the name when it is created; it never changes, so the links to the
  /// workspace (`/workspaces/{slug}`) keep working after a rename.
  TextColumn get slug => text()();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  /// ARGB, as the console sends it (Color.toARGB32).
  IntColumn get color => integer().nullable()();

  /// What a new config starts with (each config can change them).
  TextColumn get defaultSchedule => text()();

  TextColumn get defaultCompression => textEnum<Compression>()();

  TextColumn get defaultObjectKey => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {slug};
}

/// What a workspace backs up. Its connection data is JSON ([SourceSettings]),
/// so a new type needs no new columns; the secrets go encrypted apart.
class SourceTable extends Table {
  @override
  String get tableName => 'source';

  /// `src_` and 16 random characters.
  TextColumn get id => text()();

  /// Deleting the workspace deletes its sources.
  TextColumn get workspaceSlug =>
      text().references(WorkspaceTable, #slug, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  TextColumn get type => textEnum<SourceType>()();

  /// [SourceSettings.toJson]: never a secret.
  TextColumn get settings => text()();

  /// The secrets as JSON (`{"password": …}`), encrypted with [SecretCipher]
  /// bound to [id].
  TextColumn get secretsEncrypted => text()();

  /// The last [ConnectionCheck] as JSON, null until the first test.
  TextColumn get lastCheck => text().nullable()();

  /// Where it sits on the canvas; null while it is off it.
  RealColumn get canvasX => real().nullable()();

  RealColumn get canvasY => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Where a workspace writes its backups, like [SourceTable]: connection data
/// as JSON ([DestinationSettings]) and the secrets encrypted apart.
class DestinationTable extends Table {
  @override
  String get tableName => 'destination';

  /// `dst_` and 16 random characters.
  TextColumn get id => text()();

  /// Deleting the workspace deletes its destinations.
  TextColumn get workspaceSlug =>
      text().references(WorkspaceTable, #slug, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  TextColumn get type => textEnum<DestinationType>()();

  /// [DestinationSettings.toJson]: never a secret.
  TextColumn get settings => text()();

  /// The secrets as JSON (`{"secret_access_key": …}`), encrypted with
  /// [SecretCipher] bound to [id].
  TextColumn get secretsEncrypted => text()();

  /// The last [ConnectionCheck] as JSON, null until the first test.
  TextColumn get lastCheck => text().nullable()();

  /// Where it sits on the canvas; null while it is off it.
  RealColumn get canvasX => real().nullable()();

  RealColumn get canvasY => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// A folder of a destination (`orders`, `daily/billing`): each one is a
/// connection point on the canvas. With none, the bucket root is the only one.
class DestinationFolderTable extends Table {
  @override
  String get tableName => 'destination_folder';

  /// Deleting the destination deletes its folders.
  TextColumn get destinationId =>
      text().references(DestinationTable, #id, onDelete: KeyAction.cascade)();

  /// Without slashes around it.
  TextColumn get path => text()();

  @override
  Set<Column> get primaryKey => {destinationId, path};
}

/// A backup: what a source dumps into a destination (one of its folders, or
/// its root when it has none) and when. It is the node between them on the
/// canvas.
class ConfigTable extends Table {
  @override
  String get tableName => 'config';

  /// `cfg_` and 16 random characters.
  TextColumn get id => text()();

  /// Deleting the workspace deletes its configs.
  TextColumn get workspaceSlug =>
      text().references(WorkspaceTable, #slug, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  /// A source or destination in use can't be deleted: the service answers 409
  /// before the foreign key would fail.
  TextColumn get sourceId => text().references(SourceTable, #id)();

  TextColumn get destinationId => text().references(DestinationTable, #id)();

  /// One of the folders of the destination, or null for its root (only when
  /// it has no folders).
  TextColumn get folder => text().nullable()();

  /// A cron expression, always in UTC.
  TextColumn get schedule => text()();

  TextColumn get compression => textEnum<Compression>()();

  /// Relative to the folder, with placeholders and without extension.
  TextColumn get objectKey => text()();

  /// A disabled config keeps everything but its schedule doesn't run.
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  /// Where it sits on the canvas; null while it is off it.
  RealColumn get canvasX => real().nullable()();

  RealColumn get canvasY => real().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// One run of a config, scheduled or manual. It keeps the names and types of
/// what it used: the history stays readable after they change or go.
///
/// The run log lists by workspace, newest first; the history of a config too.
@TableIndex(name: 'run_config_started', columns: {#configId, #startedAt})
@TableIndex(
  name: 'run_workspace_started',
  columns: {#workspaceSlug, #startedAt},
)
class RunTable extends Table {
  @override
  String get tableName => 'run';

  /// `run_` and 16 random characters (also `{run_id}` in the object key).
  TextColumn get id => text()();

  /// Deleting the workspace deletes its runs.
  TextColumn get workspaceSlug =>
      text().references(WorkspaceTable, #slug, onDelete: KeyAction.cascade)();

  /// Null once the config is deleted.
  TextColumn get configId => text().nullable().references(
    ConfigTable,
    #id,
    onDelete: KeyAction.setNull,
  )();

  TextColumn get configName => text()();

  TextColumn get sourceName => text()();

  TextColumn get sourceType => textEnum<SourceType>()();

  TextColumn get destinationName => text()();

  TextColumn get destinationType => textEnum<DestinationType>()();

  TextColumn get trigger => textEnum<RunTrigger>()();

  TextColumn get status => textEnum<RunStatus>()();

  /// Where the backup goes (`backups/orders/2026/10/20.dump.gz`), once known.
  TextColumn get location => text().nullable()();

  /// Bytes uploaded so far, and in the end the size of the backup.
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();

  /// Why it failed, when it did.
  TextColumn get error => text().nullable()();

  /// The multipart upload in progress (`{"destination", "key", "upload_id"}`):
  /// its parts are billed until it is aborted, so a start after a stop or a
  /// crash aborts it.
  TextColumn get pendingUpload => text().nullable()();

  /// The [RunLogLine]s as a JSON list.
  TextColumn get log => text().withDefault(const Constant('[]'))();

  DateTimeColumn get startedAt => dateTime()();

  DateTimeColumn get finishedAt => dateTime().nullable()();

  /// How long it took, measured: the times above are stored to the second.
  IntColumn get durationMs => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    RunTable,
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
