import 'package:drift/drift.dart';
import 'package:service/dumpling.dart';

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

  /// Its place among the folders of the destination, in the order they come.
  IntColumn get position => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {destinationId, path};
}
