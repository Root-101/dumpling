@TestOn('vm')
library;

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8190);

  Future<Map<String, dynamic>> export([String? workspace]) async {
    final response = await http.get(
      server.url(
        workspace == null ? '/api/export' : '/api/export?workspace=$workspace',
      ),
      headers: server.auth(),
    );
    expect(response.statusCode, 200, reason: response.body);
    return jsonDecode(response.body);
  }

  Future<http.Response> import(Object body) => http.post(
    server.url('/api/import'),
    headers: {...server.auth(), 'content-type': 'application/json'},
    body: jsonEncode(body),
  );

  Future<List<String>> names() async => [
    for (final w in jsonDecode(
      (await http.get(
        server.url('/api/workspaces'),
        headers: server.auth(),
      )).body,
    ) as List)
      w['name'] as String,
  ];

  late String configId;

  setUpAll(() async {
    await server.start();
    await server.createWorkspace('Production');
    await server.createWorkspace('Staging');
    final response = await http.put(
      server.url('/api/workspaces/production/canvas'),
      headers: {...server.auth(), 'content-type': 'application/json'},
      body: jsonEncode({
        'sources': [
          {
            'id': 'new_s',
            'name': 'orders-db',
            'type': 'postgres',
            'settings': {
              'host': 'pg.internal',
              'database': 'orders',
              'username': 'u',
              'password': 'pg-secret',
            },
            'position': {'x': 40, 'y': 120},
          },
        ],
        'destinations': [
          {
            'id': 'new_d',
            'name': 'bucket',
            'type': 's3',
            'settings': {
              'endpoint': 'http://127.0.0.1:1',
              'bucket': 'backups',
              'access_key_id': 'key',
              'secret_access_key': 's3-secret',
            },
            'folders': ['orders'],
            'position': {'x': 760, 'y': 120},
          },
        ],
        'configs': [
          {
            'id': 'new_c',
            'name': 'Orders nightly',
            'source_id': 'new_s',
            'destination_id': 'new_d',
            'folder': 'orders',
            'enabled': false,
            'position': {'x': 400, 'y': 130},
          },
        ],
      }),
    );
    expect(response.statusCode, 200, reason: response.body);
    configId = (jsonDecode(response.body)['ids'] as Map)['new_c'];

    // A run of the last month and one older, which stays behind
    final runs = RunTableRepo(di.find());
    RunTableCompanion run(String id, DateTime startedAt) =>
        RunTableCompanion.insert(
          id: id,
          workspaceSlug: 'production',
          configId: Value(configId),
          configName: 'Orders nightly',
          sourceName: 'orders-db',
          sourceType: SourceType.postgres,
          destinationName: 'bucket',
          destinationType: DestinationType.s3,
          trigger: RunTrigger.manual,
          status: RunStatus.success,
          location: const Value('backups/orders/x.dump.gz'),
          startedAt: startedAt,
          finishedAt: Value(startedAt.add(const Duration(seconds: 3))),
        );
    await runs.insert(run('run_recent', DateTime.now()));
    await runs.insert(
      run('run_old', DateTime.now().subtract(const Duration(days: 40))),
    );
  });
  tearDownAll(server.stop);

  group('Export', () {
    test(
      'Should export one workspace with its credentials encrypted',
      () async {
        final file = await export('production');
        expect(file['format'], 'dumpling');
        expect(file['version'], 1);
        final w = (file['workspaces'] as List).single;
        expect(w['workspace']['name'], 'Production');
        expect((w['canvas']['configs'] as List).single['id'], configId);
        expect((w['secrets'] as Map), hasLength(2));
        expect(jsonEncode(file), isNot(contains('pg-secret')));
        expect(jsonEncode(file), isNot(contains('s3-secret')));
        expect([for (final r in w['runs'] as List) r['id']], ['run_recent']);
      },
    );

    test('Should export every workspace without a slug', () async {
      final file = await export();
      expect(
        [for (final w in file['workspaces'] as List) w['workspace']['name']],
        ['Production', 'Staging'],
      );
    });

    test('Should answer 404 for an unknown workspace', () async {
      final response = await http.get(
        server.url('/api/export?workspace=nope'),
        headers: server.auth(),
      );
      expect(response.statusCode, 404);
    });
  });

  group('Import', () {
    test('Should add the workspaces, a taken name with (2)', () async {
      final response = await import(await export('production'));
      expect(response.statusCode, 201, reason: response.body);
      final created = (jsonDecode(response.body) as List).single;
      expect(created['name'], 'Production (2)');
      final slug = created['slug'] as String;

      final canvas = jsonDecode(
        (await http.get(
          server.url('/api/workspaces/$slug/canvas'),
          headers: server.auth(),
        )).body,
      );
      final config = (canvas['configs'] as List).single;
      expect(config['id'], isNot(configId));
      expect(config['enabled'], isFalse);
      expect(config['position'], {'x': 400.0, 'y': 130.0});
      expect((canvas['sources'] as List).single['name'], 'orders-db');

      // The credentials came along: decrypted with this key, bound to the new id
      final source = (canvas['sources'] as List).single['id'] as String;
      final row = await SourceTableRepo(di.find()).get(slug, source);
      expect(Secrets().decrypt(source, row!.secretsEncrypted), {
        'password': 'pg-secret',
      });

      final runs = jsonDecode(
        (await http.get(
          server.url('/api/workspaces/$slug/runs'),
          headers: server.auth(),
        )).body,
      ) as List;
      expect(runs.single['config_id'], config['id']);
      expect(runs.single['location'], 'backups/orders/x.dump.gz');
    });

    test('Should count up: a second import is Production (3)', () async {
      final response = await import(await export('production'));
      expect(
        (jsonDecode(response.body) as List).single['name'],
        'Production (3)',
      );
    });

    test('Should refuse credentials of another key, adding nothing', () async {
      final file = await export('production');
      final secrets =
          (file['workspaces'] as List).single['secrets']
              as Map<String, dynamic>;
      final id = secrets.keys.first;
      secrets[id] = SecretCipher('another-key')
          .encrypt('{"password":"x"}', associatedData: id);
      final before = await names();

      final response = await import(file);
      expect(response.statusCode, 422, reason: response.body);
      expect(response.body, contains('workspaces[0].secrets.$id'));
      expect(await names(), before);
    });

    test('Should delete what it added when a later workspace fails', () async {
      final file = await export();
      // Staging gets a config that points at no source
      ((file['workspaces'] as List)[1]['canvas']['configs'] as List).add({
        'id': 'cfg_x',
        'name': 'broken',
        'source_id': 'src_missing',
        'destination_id': 'dst_missing',
      });
      final before = await names();

      final response = await import(file);
      expect(response.statusCode, 422, reason: response.body);
      expect(await names(), before);
    });

    test('Should refuse a file that is not an export', () async {
      final response = await import({'format': 'other', 'workspaces': []});
      expect(response.statusCode, 422, reason: response.body);
      expect(response.body, contains('format'));
    });
  });
}
