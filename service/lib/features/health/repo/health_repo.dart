import 'package:service/dumpling.dart';

class HealthRepo {
  final AppDatabase _db;

  HealthRepo(this._db);

  /// Throws when SQLite can't answer.
  Future<void> ping() => _db.customSelect('SELECT 1').get();
}
