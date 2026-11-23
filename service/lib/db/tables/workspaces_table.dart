import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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
