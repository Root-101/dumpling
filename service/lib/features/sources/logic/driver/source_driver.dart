import 'package:service/dumpling.dart';

/// What the service does with a kind of source. A new type (MySQL, MongoDB…)
/// is one more implementation registered in [drivers], not a change elsewhere.
abstract class SourceDriver {
  /// The driver of each enabled type.
  static final Map<SourceType, SourceDriver> drivers = {
    SourceType.postgres: PostgresSourceDriver(),
  };

  /// Connects with [settings] and its [secrets] from the service (never from
  /// the console: the source can be in an internal network), and checks that
  /// the dump tool can back it up. It never throws: a failure is a result.
  Future<ConnectionCheck> testConnection(
    SourceSettings settings,
    Map<String, String> secrets,
  );

  /// The whole backup as it is produced (never on disk). The stream ends with
  /// an error, never quietly, when the dump tool fails; cancelling it stops
  /// the tool.
  Stream<List<int>> dump(SourceSettings settings, Map<String, String> secrets);

  /// The extension of a dump before compression (`.dump`, `.sql`).
  String extension(SourceSettings settings);

  /// The database it dumps, for `{db}` in the object key.
  String databaseName(SourceSettings settings);
}

/// The dump tool failed (exit code, connection lost…).
class DumpException implements Exception {
  final String message;

  DumpException(this.message);

  @override
  String toString() => message;
}
