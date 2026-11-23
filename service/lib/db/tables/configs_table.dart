import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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

  /// Its place in the lists, set by hand (dragging); new ones go last.
  IntColumn get position => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
