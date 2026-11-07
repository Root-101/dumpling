@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8192);
  const base = '/api/workspaces/production';
  late String nightly;
  late String hourly;

  Map<String, String> jsonHeaders([Map<String, String>? auth]) => {
    ...(auth ?? server.auth()),
    'content-type': 'application/json',
  };

  Map<String, String> bearer(String key) => {'authorization': 'Bearer $key'};

  Map<String, String> basic(String id, String secret) => {
    'authorization': 'Basic ${base64.encode(utf8.encode('$id:$secret'))}',
  };

  Future<Map<String, dynamic>> post(String path, Object body) async {
    final response = await http.post(
      server.url(path),
      headers: jsonHeaders(),
      body: jsonEncode(body),
    );
    expect(response.statusCode, anyOf(200, 201), reason: response.body);
    return jsonDecode(response.body);
  }

  Future<http.Response> createKey(Object body) => http.post(
    server.url('$base/keys'),
    headers: jsonHeaders(),
    body: jsonEncode(body),
  );

  Future<Map<String, dynamic>> key(
    List<String> permissions, {
    String name = 'deploy-key',
    List<String> configs = const [],
  }) async {
    final response = await createKey({
      'name': name,
      'permissions': permissions,
      'config_ids': configs,
    });
    expect(response.statusCode, 201, reason: response.body);
    return jsonDecode(response.body);
  }

  setUpAll(() async {
    await server.start();
    await server.createWorkspace('Production');
    await server.createWorkspace('Staging');
    final source = await post('$base/sources', {
      'name': 'orders-db',
      'type': 'postgres',
      'settings': {
        'host': 'pg.internal',
        'database': 'orders',
        'username': 'u',
        'password': 'p',
      },
    });
    final destination = await post('$base/destinations', {
      'name': 'bucket',
      'type': 's3',
      'settings': {
        'endpoint': 'http://127.0.0.1:1',
        'bucket': 'backups',
        'access_key_id': 'a',
        'secret_access_key': 'b',
        'path_style': true,
      },
    });
    Future<String> config(String name) async => (await post('$base/configs', {
      'name': name,
      'source_id': source['id'],
      'destination_id': destination['id'],
    }))['id'];
    nightly = await config('Nightly');
    hourly = await config('Hourly');
  });
  tearDownAll(server.stop);

  group('API keys', () {
    test('Should create a key, shown once and stored as a hash', () async {
      final created = await key(['config.run', 'run.get', 'run.list']);
      final text = created['key'] as String;
      expect(created['id'], startsWith('key_'));
      expect(
        text,
        startsWith('dmp_${(created['id'] as String).substring(4)}_'),
      );
      expect(created['permissions'], ['config.run', 'run.list', 'run.get']);
      expect(created['config_ids'], isEmpty);
      expect(created['last_used_at'], isNull);

      final db = di.find<AppDatabase>();
      final row = await (db.select(
        db.apiKeyTable,
      )..where((t) => t.id.equals(created['id']))).getSingle();
      final secret = text.split('_').last;
      expect(row.secretHash, isNot(contains(secret)));
      expect(row.secretHash, ApiKeyToken.hash(secret));

      final listed = jsonDecode(
        (await http.get(server.url('$base/keys'), headers: server.auth())).body,
      ) as List;
      final again = listed.firstWhere((k) => k['id'] == created['id']);
      expect(again.containsKey('key'), isFalse);
    });

    test('Should use a key as Bearer or as Basic auth', () async {
      final created = await key(['run.list']);
      final text = created['key'] as String;
      final runs = await http.get(
        server.url('$base/runs'),
        headers: bearer(text),
      );
      expect(runs.statusCode, 200, reason: runs.body);

      final secret = text.substring(text.lastIndexOf('_') + 1);
      final viaBasic = await http.get(
        server.url('$base/runs'),
        headers: basic(created['id'], secret),
      );
      expect(viaBasic.statusCode, 200, reason: viaBasic.body);

      final listed = jsonDecode(
        (await http.get(server.url('$base/keys'), headers: server.auth())).body,
      ) as List;
      expect(
        listed.firstWhere((k) => k['id'] == created['id'])['last_used_at'],
        isNotNull,
      );
    });

    test('Should answer 401 to a wrong or unknown key', () async {
      final created = await key(['run.list']);
      final text = created['key'] as String;
      final wrong = await http.get(
        server.url('$base/runs'),
        headers: bearer('${text.substring(0, text.length - 1)}x'),
      );
      expect(wrong.statusCode, 401);
      final unknown = await http.get(
        server.url('$base/runs'),
        headers: bearer('dmp_aaaaaaaaaaaaaaaa_${'x' * 32}'),
      );
      expect(unknown.statusCode, 401);
    });

    test('Should only reach its own workspace and permissions', () async {
      final text = (await key(['run.list', 'config.list']))['key'] as String;
      final other = await http.get(
        server.url('/api/workspaces/staging/runs'),
        headers: bearer(text),
      );
      expect(other.statusCode, 403);
      for (final path in [
        '$base/sources',
        '/api/workspaces',
        '$base/keys',
        '/api/export',
      ]) {
        final response = await http.get(
          server.url(path),
          headers: bearer(text),
        );
        expect(response.statusCode, 403, reason: path);
      }
      // A key can't make another
      final another = await http.post(
        server.url('$base/keys'),
        headers: jsonHeaders(bearer(text)),
        body: jsonEncode({
          'name': 'x',
          'permissions': ['run.list'],
        }),
      );
      expect(another.statusCode, 403);
    });

    test('Should reach only its configs and their runs when limited', () async {
      final text =
          (await key(
                ['config.list', 'config.get', 'config.run', 'run.list'],
                configs: [nightly],
              ))['key']
              as String;
      final configs = jsonDecode(
        (await http.get(
          server.url('$base/configs'),
          headers: bearer(text),
        )).body,
      ) as List;
      expect(configs.map((c) => c['id']), [nightly]);

      final outside = await http.get(
        server.url('$base/configs/$hourly'),
        headers: bearer(text),
      );
      expect(outside.statusCode, 404);
      final run = await http.post(
        server.url('$base/configs/$hourly/run'),
        headers: bearer(text),
      );
      expect(run.statusCode, 404);
      // nor changes or deletes it, even with the permissions
      final editor =
          (await key(
                ['config.update', 'config.delete'],
                configs: [nightly],
              ))['key']
              as String;
      final delete = await http.delete(
        server.url('$base/configs/$hourly'),
        headers: bearer(editor),
      );
      expect(delete.statusCode, 404);
    });

    test('Should refuse what a key can not have (422)', () async {
      for (final body in <Map<String, Object?>>[
        {'name': 'x', 'permissions': <String>[]},
        {
          'name': 'x',
          'permissions': ['workspace.delete'],
        },
        {
          'name': 'x',
          'permissions': ['apikey.create'],
        },
        {
          'name': 'x',
          'permissions': ['auth.session'],
        },
        {
          'name': 'x',
          'permissions': ['config.run'],
          'config_ids': ['cfg_doesnotexist0000'],
        },
        {
          'permissions': ['config.run'],
        },
      ]) {
        final response = await createKey(body);
        expect(response.statusCode, 422, reason: '$body ${response.body}');
      }
    });

    test('Should change a key without changing its secret', () async {
      final created = await key(['run.list'], name: 'grafana');
      final text = created['key'] as String;
      final changed = await http.put(
        server.url('$base/keys/${created['id']}'),
        headers: jsonHeaders(),
        body: jsonEncode({
          'name': 'grafana-ro',
          'permissions': ['run.list', 'run.get'],
          'config_ids': [hourly],
        }),
      );
      expect(changed.statusCode, 200, reason: changed.body);
      final body = jsonDecode(changed.body);
      expect(body['name'], 'grafana-ro');
      expect(body['config_ids'], [hourly]);
      expect(body.containsKey('key'), isFalse);
      final still = await http.get(
        server.url('$base/runs'),
        headers: bearer(text),
      );
      expect(still.statusCode, 200);
    });

    test('Should reorder the keys and delete one', () async {
      final keys = jsonDecode(
        (await http.get(server.url('$base/keys'), headers: server.auth())).body,
      ) as List;
      final ids = [for (final k in keys) k['id'] as String].reversed.toList();
      final reordered = await http.put(
        server.url('$base/keys/order'),
        headers: jsonHeaders(),
        body: jsonEncode({'ids': ids}),
      );
      expect(reordered.statusCode, 200, reason: reordered.body);
      expect([for (final k in jsonDecode(reordered.body)) k['id']], ids);

      final partial = await http.put(
        server.url('$base/keys/order'),
        headers: jsonHeaders(),
        body: jsonEncode({'ids': ids.skip(1).toList()}),
      );
      expect(partial.statusCode, 422);

      final created = await key(['run.list'], name: 'to-delete');
      final deleted = await http.delete(
        server.url('$base/keys/${created['id']}'),
        headers: server.auth(),
      );
      expect(deleted.statusCode, 204);
      final after = await http.get(
        server.url('$base/runs'),
        headers: bearer(created['key']),
      );
      expect(after.statusCode, 401);
      final again = await http.delete(
        server.url('$base/keys/${created['id']}'),
        headers: server.auth(),
      );
      expect(again.statusCode, 404);
    });
  });
}
