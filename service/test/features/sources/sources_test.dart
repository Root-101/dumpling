@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8183);

  setUpAll(() async {
    await server.start();
    await server.createWorkspace('Production');
    await server.createWorkspace('Staging');
  });
  tearDownAll(server.stop);

  String path(String workspace, [String rest = '']) =>
      '/api/workspaces/$workspace/sources$rest';

  Map<String, String> jsonHeaders() => {
    ...server.auth(),
    'content-type': 'application/json',
  };

  Map<String, Object?> postgres({
    String name = 'orders-db',
    String? password = 's3cr3t-pass',
    String host = 'pg-prod-01.internal',
    int? port,
  }) => {
    'name': name,
    'type': 'postgres',
    'settings': {
      'host': host,
      'port': ?port,
      'database': 'orders',
      'username': 'dumpling_backup',
      'password': ?password,
    },
  };

  Future<http.Response> create(
    Object body, {
    String workspace = 'production',
  }) => http.post(
    server.url(path(workspace)),
    headers: jsonHeaders(),
    body: jsonEncode(body),
  );

  Future<Map<String, dynamic>> created(Object body) async {
    final response = await create(body);
    expect(response.statusCode, 201, reason: response.body);
    return jsonDecode(response.body);
  }

  /// The stored secrets of [id], decrypted.
  Future<Map<String, dynamic>> storedSecrets(String id) async {
    final db = di.find<AppDatabase>();
    final row = await (db.select(
      db.sourceTable,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.secretsEncrypted, isNot(contains('s3cr3t')));
    return jsonDecode(
      di.find<SecretCipher>().decrypt(row.secretsEncrypted, associatedData: id),
    );
  }

  group('SourceController', () {
    test('Should list every type, only PostgreSQL enabled', () async {
      final response = await http.get(
        server.url('/api/source-types'),
        headers: server.auth(),
      );
      expect(response.statusCode, 200);
      final types = {
        for (final t in jsonDecode(response.body) as List)
          t['type']: t['enabled'],
      };
      expect(types, {
        'postgres': true,
        'mysql': false,
        'mariadb': false,
        'mongodb': false,
        'redis': false,
      });
    });

    test(
      'Should create a source without ever returning the password',
      () async {
        final response = await create(postgres());
        expect(response.statusCode, 201);
        expect(response.body, isNot(contains('s3cr3t')));
        final body = jsonDecode(response.body);
        expect(body['id'], startsWith('src_'));
        expect(body['workspace'], 'production');
        expect(body['settings'], {
          'host': 'pg-prod-01.internal',
          'port': 5432,
          'database': 'orders',
          'username': 'dumpling_backup',
          'dump_format': 'custom',
          'ssl_mode': 'require',
        });
        expect(body['last_check'], isNull);
        expect(await storedSecrets(body['id']), {'password': 's3cr3t-pass'});

        final read = await http.get(
          server.url(path('production', '/${body['id']}')),
          headers: server.auth(),
        );
        expect(read.body, isNot(contains('s3cr3t')));
      },
    );

    test(
      'Should keep the stored password when an update leaves it out',
      () async {
        final source = await created(postgres(name: 'users-db'));
        final response = await http.put(
          server.url(path('production', '/${source['id']}')),
          headers: jsonHeaders(),
          body: jsonEncode(postgres(name: 'users', password: null)),
        );
        expect(response.statusCode, 200, reason: response.body);
        expect(jsonDecode(response.body)['name'], 'users');
        expect(await storedSecrets(source['id']), {'password': 's3cr3t-pass'});
      },
    );

    test(
      'Should ask for the password again after SECRETS_ENCRYPTION_KEY changed',
      () async {
        final source = await created(postgres(name: 'rekeyed-db'));
        final id = source['id'] as String;
        // as if stored under the key the service had before
        final db = di.find<AppDatabase>();
        await (db.update(db.sourceTable)..where((t) => t.id.equals(id))).write(
          SourceTableCompanion(
            secretsEncrypted: Value(
              SecretCipher('the-previous-key').encrypt(
                jsonEncode({'password': 'old-pass'}),
                associatedData: id,
              ),
            ),
          ),
        );
        Future<http.Response> update(String? password) => http.put(
          server.url(path('production', '/$id')),
          headers: jsonHeaders(),
          body: jsonEncode(postgres(name: 'rekeyed-db', password: password)),
        );

        final missing = await update(null);
        expect(missing.statusCode, 422, reason: missing.body);
        expect(missing.body, contains('settings.password'));

        final updated = await update('new-pass');
        expect(updated.statusCode, 200, reason: updated.body);
        expect(await storedSecrets(id), {'password': 'new-pass'});
      },
    );

    test('Should take the connection from a URL, fields winning', () async {
      final source = await created({
        'name': 'from-url',
        'type': 'postgres',
        'settings': {
          'connection_url': 'postgresql://dumpling%40ro:s3cr3t%3Aurl@pg-billing.internal:6432/billing?sslmode=disable',
          'database': 'billing_replica',
        },
      });
      expect(source['settings'], {
        'host': 'pg-billing.internal',
        'port': 6432,
        'database': 'billing_replica',
        'username': 'dumpling@ro',
        'dump_format': 'custom',
        // from the URL too
        'ssl_mode': 'disable',
      });
      expect(await storedSecrets(source['id']), {'password': 's3cr3t:url'});
    });

    test('Should reject a URL that is not PostgreSQL (422)', () async {
      final response = await create({
        'name': 'bad-url',
        'type': 'postgres',
        'settings': {'connection_url': 'mysql://u:p@host/db'},
      });
      expect(response.statusCode, 422);
      expect(response.body, contains('settings.connection_url'));
      expect(response.body, isNot(contains('mysql://')));
    });

    test('Should require the password on create (422)', () async {
      final response = await create(postgres(password: null));
      expect(response.statusCode, 422);
      expect(response.body, contains('settings.password'));
    });

    test('Should reject a disabled type and invalid settings (422)', () async {
      final disabled = await create({
        'name': 'shop',
        'type': 'mysql',
        'settings': {'host': 'mysql.internal'},
      });
      expect(disabled.statusCode, 422);
      expect(disabled.body, contains('not available yet'));

      final invalid = await create({
        'name': 'x',
        'type': 'postgres',
        'settings': {
          'host': '',
          'port': 70000,
          'database': 'orders',
          'username': 'u',
          'password': 'p',
          'dump_format': 'directory',
          'ssl_mode': 'prefer',
        },
      });
      expect(invalid.statusCode, 422);
      final fields = {
        for (final v in jsonDecode(invalid.body)['violations'] as List)
          v['fieldName'],
      };
      expect(
        fields,
        containsAll([
          'settings.host',
          'settings.port',
          'settings.dump_format',
          'settings.ssl_mode',
        ]),
      );
    });

    test('Should not find a source from another workspace', () async {
      final source = await created(postgres(name: 'billing-db'));
      final response = await http.get(
        server.url(path('staging', '/${source['id']}')),
        headers: server.auth(),
      );
      expect(response.statusCode, 404);
    });

    test('Should delete a source', () async {
      final source = await created(postgres(name: 'tmp-db'));
      final deleted = await http.delete(
        server.url(path('production', '/${source['id']}')),
        headers: server.auth(),
      );
      expect(deleted.statusCode, 204);
      final read = await http.get(
        server.url(path('production', '/${source['id']}')),
        headers: server.auth(),
      );
      expect(read.statusCode, 404);
    });

    test('Should delete the sources with their workspace', () async {
      await server.createWorkspace('Doomed');
      await create(postgres(name: 'gone-db'), workspace: 'doomed');
      await http.delete(
        server.url('/api/workspaces/doomed'),
        headers: server.auth(),
      );
      final db = di.find<AppDatabase>();
      final left = await (db.select(
        db.sourceTable,
      )..where((t) => t.workspaceSlug.equals('doomed'))).get();
      expect(left, isEmpty);
    });

    test('Should report a connection that fails, without throwing', () async {
      // Nothing listens on port 1
      final body = postgres(host: '127.0.0.1', port: 1);
      final response = await http.post(
        server.url(path('production', '/test')),
        headers: jsonHeaders(),
        body: jsonEncode(body),
      );
      expect(response.statusCode, 200, reason: response.body);
      final check = jsonDecode(response.body);
      expect(check['status'], 'failed');
      expect(check['message'], isNotEmpty);
      expect(check['server_version'], isNull);
    });

    test('Should keep the result of testing a saved source', () async {
      final body = postgres(name: 'local-db', host: '127.0.0.1', port: 1);
      final source = await created(body);
      final tested = await http.post(
        server.url(path('production', '/${source['id']}/test')),
        headers: server.auth(),
      );
      expect(jsonDecode(tested.body)['status'], 'failed');

      final read = jsonDecode(
        (await http.get(
          server.url(path('production', '/${source['id']}')),
          headers: server.auth(),
        )).body,
      );
      expect(read['last_check']['status'], 'failed');
    });

    test('Should keep the last check unless the connection changes, also through the canvas', () async {
      final body = postgres(name: 'kept-db', host: '127.0.0.1', port: 1);
      final id = (await created(body))['id'];
      await http.post(
        server.url(path('production', '/$id/test')),
        headers: server.auth(),
      );
      Future<Object?> lastCheck() async => jsonDecode(
        (await http.get(
          server.url(path('production', '/$id')),
          headers: server.auth(),
        )).body,
      )['last_check'];
      Future<void> put(Map<String, Object?> body) async {
        final response = await http.put(
          server.url(path('production', '/$id')),
          headers: jsonHeaders(),
          body: jsonEncode(body),
        );
        expect(response.statusCode, 200, reason: response.body);
      }

      // a new name, and the same password typed again
      await put(postgres(name: 'renamed-db', host: '127.0.0.1', port: 1));
      expect(await lastCheck(), isNotNull);

      // the canvas sends every node on each save, without its password
      final canvas = jsonDecode(
        (await http.get(
          server.url('/api/workspaces/production/canvas'),
          headers: server.auth(),
        )).body,
      );
      final saved = await http.put(
        server.url('/api/workspaces/production/canvas'),
        headers: jsonHeaders(),
        body: jsonEncode(canvas),
      );
      expect(saved.statusCode, 200, reason: saved.body);
      expect(await lastCheck(), isNotNull);

      // another port is another connection: its check is of the old one
      await put(postgres(name: 'renamed-db', host: '127.0.0.1', port: 2));
      expect(await lastCheck(), isNull);
    });
  });

  group('PgDump', () {
    test('Should read the version of pg_dump', () {
      expect(PgDump.parseVersion('pg_dump (PostgreSQL) 18.2'), '18.2');
      expect(
        PgDump.parseVersion('pg_dump (PostgreSQL) 17.2 (Debian 17.2-1.pgdg)'),
        '17.2',
      );
      expect(PgDump.parseVersion('command not found'), isNull);
      expect(PgDump.major('17.2'), 17);
    });

    test('Should give pg_dump a limit for waiting on a locked table', () {
      final args = PostgresSourceDriver.dumpArguments(
        PostgresSettings(host: 'db', database: 'orders', username: 'backup'),
      );
      expect(args, containsAll(['--format=custom', '--no-password']));
      expect(args, contains('--lock-wait-timeout=60000'));
    });

    test('Should give pg_dump its connection in PG* variables, without the secrets of the service', () {
      final vars = PostgresSourceDriver.dumpEnvironment(
        PostgresSettings(
          host: ' db.internal ',
          port: 6543,
          // a connection string here stays a name: it isn't an argument
          database: 'x host=elsewhere',
          username: 'backup',
        ),
        {PostgresSettings.passwordKey: 'pw'},
      );
      expect(vars['PGHOST'], 'db.internal');
      expect(vars['PGPORT'], '6543');
      expect(vars['PGDATABASE'], 'x host=elsewhere');
      expect((vars['PGUSER'], vars['PGPASSWORD']), ('backup', 'pw'));
      for (final name in requiredEnvVariables) {
        expect(vars.keys.map((k) => k.toUpperCase()), isNot(contains(name)));
      }
      expect(
        vars.keys.where(
          (k) => k.toUpperCase().startsWith('PG') && !k.startsWith('PG'),
        ),
        isEmpty,
      );
    });
  });

  group('PostgresSourceDriver', () {
    /// pg_dump replaced by a script that writes [stderr] and exits with 1.
    Future<void> fakePgDump(List<int> stderr) async {
      final dir = await Directory.systemTemp.createTemp('fake_pg_dump');
      addTearDown(() => dir.delete(recursive: true));
      await File('${dir.path}/stderr.txt').writeAsBytes(stderr);
      final String script;
      if (Platform.isWindows) {
        script = '${dir.path}\\pg_dump.bat';
        await File(script)
            .writeAsString('@type "%~dp0stderr.txt" 1>&2\r\n@exit /b 1\r\n');
      } else {
        script = '${dir.path}/pg_dump';
        await File(script).writeAsString(
          '#!/bin/sh\ncat "\$(dirname "\$0")/stderr.txt" >&2\nexit 1\n',
        );
        await Process.run('chmod', ['+x', script]);
      }
      final before = env.pgDumpPath;
      env.put('PG_DUMP_PATH', script);
      addTearDown(() => env.put('PG_DUMP_PATH', before));
    }

    Stream<List<int>> dump() => PostgresSourceDriver().dump(
      PostgresSettings(host: 'db', database: 'orders', username: 'backup'),
      {},
    );

    test('Should keep only the end of what pg_dump writes to stderr', () async {
      await fakePgDump([...List.filled(100000, 0x78), ...'END'.codeUnits]);
      await expectLater(
        dump().drain<void>(),
        throwsA(
          isA<DumpException>()
              .having((e) => e.message, 'message', endsWith('END'))
              .having((e) => e.message.length, 'length', lessThan(2100)),
        ),
      );
    });

    test(
      'Should cut the error a server sends to the connection test',
      () async {
        // An ErrorResponse whose message is 5 MB long
        final fake = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(fake.close);
        fake.listen((socket) {
          socket.listen((_) {
            final fields = [
              ...'SFATAL'.codeUnits,
              0,
              ...'C28P01'.codeUnits,
              0,
              ...'M'.codeUnits,
              ...List.filled(5000000, 0x41),
              0,
              0,
            ];
            socket.add([
              ...'E'.codeUnits,
              ...(ByteData(
                4,
              )..setInt32(0, 4 + fields.length)).buffer.asUint8List(),
              ...fields,
            ]);
          });
        });
        final check = await PostgresSourceDriver().testConnection(
          PostgresSettings(
            host: '127.0.0.1',
            port: fake.port,
            database: 'orders',
            username: 'backup',
            sslMode: 'disable',
          ),
          {PostgresSettings.passwordKey: 'pw'},
        );
        expect(check.status, CheckStatus.failed);
        expect(check.message, startsWith('AAA'));
        expect(check.message!.length, maxServerText + 1);
      },
    );

    test(
      'Should give up on a server that makes the password hash run forever',
      () async {
        // Answers the SCRAM start with 2^40 iterations: the client would hash
        // the password for days
        final fake = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(fake.close);
        fake.listen((socket) {
          var received = <int>[];
          var startup = true;
          socket.listen((data) {
            received.addAll(data);
            int length(int at) => ByteData.sublistView(
              Uint8List.fromList(received),
              at,
            ).getInt32(0);
            List<int> auth(int code, List<int> payload) => [
              ...ascii.encode('R'),
              ...(ByteData(8)
                    ..setInt32(0, 8 + payload.length)
                    ..setInt32(4, code))
                  .buffer
                  .asUint8List(),
              ...payload,
            ];
            if (startup) {
              if (received.length < 4 || received.length < length(0)) return;
              received = received.sublist(length(0));
              startup = false;
              socket.add(auth(10, [...ascii.encode('SCRAM-SHA-256'), 0, 0]));
            }
            if (received.length < 5 || received.length < 1 + length(1)) return;
            final nonce = RegExp(r'r=([^,\x00]+)')
                .firstMatch(latin1.decode(received))!
                .group(1);
            received = [];
            socket.add(
              auth(11, ascii.encode('r=${nonce}x,s=c2FsdA==,i=${1 << 40}')),
            );
          });
        });

        final before = PostgresSourceDriver.deadline;
        PostgresSourceDriver.deadline = const Duration(seconds: 2);
        addTearDown(() => PostgresSourceDriver.deadline = before);
        // The service keeps answering meanwhile
        var ticks = 0;
        final heartbeat = Timer.periodic(
          const Duration(milliseconds: 100),
          (_) => ticks++,
        );
        addTearDown(heartbeat.cancel);

        final check = await PostgresSourceDriver().testConnection(
          PostgresSettings(
            host: '127.0.0.1',
            port: fake.port,
            database: 'orders',
            username: 'backup',
            // the attack works on a connection without TLS
            sslMode: 'disable',
          ),
          {PostgresSettings.passwordKey: 'pw'},
        );
        expect(check.status, CheckStatus.failed);
        expect(check.message, 'Timed out after 2 s');
        expect(ticks, greaterThan(10));
      },
    );

    test(
      'Should fail a dump whose errors are not UTF-8, without throwing past it',
      () async {
        // A LATIN1 database names its tables in LATIN1: 'pg' + é + an 0xFF
        await fakePgDump([0x70, 0x67, 0xE9, 0xFF, 0x0A]);
        await expectLater(
          dump().drain<void>(),
          throwsA(
            isA<DumpException>().having(
              (e) => e.message,
              'message',
              contains('pg\uFFFD'),
            ),
          ),
        );
      },
    );
  });
}
