import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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

  /// What the request that started it sent (`v1.4.2`, a commit), if any.
  TextColumn get label => text().nullable()();

  /// The API key that started it, kept by name too: the key may be deleted.
  TextColumn get keyId => text().nullable()();

  TextColumn get keyName => text().nullable()();

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
