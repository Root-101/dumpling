import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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

  /// Its place in the lists, set by hand (dragging); new ones go last.
  IntColumn get position => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
