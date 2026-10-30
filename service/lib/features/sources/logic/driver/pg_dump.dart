import 'dart:io';

import 'package:service/dumpling.dart';

/// The `pg_dump` of the service (`PG_DUMP_PATH`). It dumps servers of its own
/// major version or older, never newer ones.
class PgDump {
  /// Its version (`18.0`), read once; null when it is not installed.
  static Future<String?> version() => _version ??= _read();
  static Future<String?>? _version;

  static Future<String?> _read() async {
    try {
      final result = await Process.run(env.pgDumpPath, ['--version']);
      if (result.exitCode != 0) return null;
      return parseVersion(result.stdout as String);
    } on ProcessException {
      return null;
    }
  }

  /// `pg_dump (PostgreSQL) 17.2 (Debian 17.2-1)` → `17.2`.
  static String? parseVersion(String output) =>
      RegExp(r'\(PostgreSQL\)\s+(\d+(?:\.\d+)?)').firstMatch(output)?.group(1);

  /// `17.2` → 17, `9.6` → 9.
  static int major(String version) => int.parse(version.split('.').first);
}
