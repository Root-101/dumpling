import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart' as pg;
import 'package:service/dumpling.dart';

class PostgresSourceDriver implements SourceDriver {
  /// To connect and to answer each query.
  static const Duration timeout = Duration(seconds: 10);

  /// The end of what pg_dump writes to stderr that goes into the error.
  static const int _stderrTail = 2000;

  @override
  String extension(SourceSettings settings) =>
      switch ((settings as PostgresSettings).format) {
        PostgresDumpFormat.custom => '.dump',
        PostgresDumpFormat.plain => '.sql',
      };

  @override
  String databaseName(SourceSettings settings) =>
      (settings as PostgresSettings).database!.trim();

  /// `pg_dump` to stdout. The password goes in `PGPASSWORD`, never in the
  /// arguments (which any user of the machine can list).
  @override
  Stream<List<int>> dump(SourceSettings settings, Map<String, String> secrets) {
    final postgres = settings as PostgresSettings;
    late final StreamController<List<int>> controller;
    Process? process;
    controller = StreamController<List<int>>(
      onListen: () async {
        try {
          process = await Process.start(
            env.pgDumpPath,
            [
              '--host=${postgres.host!.trim()}',
              '--port=${postgres.portOrDefault}',
              '--username=${postgres.username!.trim()}',
              '--dbname=${postgres.database!.trim()}',
              '--format=${postgres.format == PostgresDumpFormat.custom ? 'custom' : 'plain'}',
              '--no-password',
            ],
            environment: {
              'PGPASSWORD': secrets[PostgresSettings.passwordKey] ?? '',
              'PGSSLMODE': postgres.ssl.name,
              'PGCONNECT_TIMEOUT': '${timeout.inSeconds}',
              'PGAPPNAME': 'dumpling',
            },
          );
        } on ProcessException catch (e) {
          controller.addError(DumpException('pg_dump could not start: $e'));
          await controller.close();
          return;
        }
        final stderr = StringBuffer();
        final errors = process!.stderr
            .transform(utf8.decoder)
            .forEach(stderr.write);
        // The stream waits for the upload: pausing it holds pg_dump back
        await controller.addStream(process!.stdout);
        final code = await process!.exitCode;
        await errors;
        if (code != 0) {
          final text = stderr.toString().trim();
          controller.addError(
            DumpException(
              'pg_dump exited with code $code: '
              '${text.length > _stderrTail ? text.substring(text.length - _stderrTail) : text}',
            ),
          );
        }
        await controller.close();
      },
      onCancel: () => process?.kill(),
    );
    return controller.stream;
  }

  @override
  Future<ConnectionCheck> testConnection(
    SourceSettings settings,
    Map<String, String> secrets,
  ) async {
    final postgres = settings as PostgresSettings;
    final watch = Stopwatch()..start();
    final tool = await PgDump.version();

    ConnectionCheck result(
      CheckStatus status, {
      String? serverVersion,
      String? message,
    }) => ConnectionCheck(
      status: status,
      serverVersion: serverVersion,
      toolVersion: tool == null ? null : 'pg_dump $tool',
      message: message,
      durationMs: watch.elapsedMilliseconds,
      checkedAt: DateTime.now().toUtc(),
    );

    final String serverVersion;
    final int serverMajor;
    try {
      final connection = await pg.Connection.open(
        pg.Endpoint(
          host: postgres.host!.trim(),
          port: postgres.portOrDefault,
          database: postgres.database!.trim(),
          username: postgres.username!.trim(),
          password: secrets[PostgresSettings.passwordKey],
        ),
        settings: pg.ConnectionSettings(
          sslMode: switch (postgres.ssl) {
            PostgresSslMode.disable => pg.SslMode.disable,
            PostgresSslMode.require => pg.SslMode.require,
          },
          connectTimeout: timeout,
          queryTimeout: timeout,
          applicationName: 'dumpling',
        ),
      );
      try {
        // `16.4 (Debian 16.4-1.pgdg120+2)` → `16.4`
        final version = await connection.execute('SHOW server_version');
        serverVersion = (version.first.first as String).split(' ').first;
        // 160004 → 16 (and 90624 → 9, before PostgreSQL 10)
        final number = await connection.execute('SHOW server_version_num');
        serverMajor = int.parse(number.first.first as String) ~/ 10000;
      } finally {
        await connection.close();
      }
    } on pg.ServerException catch (e) {
      // Wrong password, unknown database or role…
      return result(CheckStatus.failed, message: e.message);
    } on SocketException catch (e) {
      return result(
        CheckStatus.failed,
        message: e.osError?.message ?? e.message,
      );
    } on TimeoutException {
      return result(
        CheckStatus.failed,
        message: 'Timed out after ${timeout.inSeconds} s',
      );
    } on Object catch (e) {
      // A TLS handshake that fails, a closed connection…
      logger.warning('Connection test failed', fields: {'error': '$e'});
      return result(CheckStatus.failed, message: '$e');
    }

    if (tool == null) {
      return result(CheckStatus.toolMissing, serverVersion: serverVersion);
    }
    return result(
      serverMajor > PgDump.major(tool)
          ? CheckStatus.incompatible
          : CheckStatus.connected,
      serverVersion: serverVersion,
    );
  }
}
