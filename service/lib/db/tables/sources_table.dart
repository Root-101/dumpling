import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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

  /// Its place in the lists, set by hand (dragging); new ones go last.
  IntColumn get position => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
