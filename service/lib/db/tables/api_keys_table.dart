import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

/// A key another system uses the API of one workspace with (a deploy
/// pipeline, a script): what it may do is its [permissions], optionally only on
/// some configs. Only the hash of its secret is kept; it is shown once.
class ApiKeyTable extends Table {
  @override
  String get tableName => 'api_key';

  /// `key_` and 16 random characters; the key is `dmp_<those 16>_<secret>`.
  TextColumn get id => text()();

  /// Deleting the workspace deletes its keys.
  TextColumn get workspaceSlug =>
      text().references(WorkspaceTable, #slug, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();

  /// The sha256 of the secret, in hex: the secret is random and long, so no
  /// slow hash is needed.
  TextColumn get secretHash => text()();

  /// The permission keys it has, as a JSON list.
  TextColumn get permissions => text()();

  /// The configs it is limited to, as a JSON list; empty for all of them.
  TextColumn get configIds => text().withDefault(const Constant('[]'))();

  /// Its place in the list, set by hand (dragging); new ones go last.
  IntColumn get position => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// The last request it made, null until then.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
