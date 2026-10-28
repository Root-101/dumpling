@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8185);

  late String sourceId;
  late String foldersId;
  late String rootId;

  Map<String, String> jsonHeaders() => {
    ...server.auth(),
    'content-type': 'application/json',
  };

  Future<http.Response> post(String path, Object body) => http.post(
    server.url(path),
    headers: jsonHeaders(),
    body: jsonEncode(body),
  );

  Future<http.Response> put(String path, Object body) => http.put(
    server.url(path),
    headers: jsonHeaders(),
    body: jsonEncode(body),
  );

  Future<String> createdId(String path, Object body) async {
    final response = await post(path, body);
    expect(response.statusCode, 201, reason: response.body);
    return jsonDecode(response.body)['id'] as String;
  }

  Map<String, Object?> destination(List<String> folders) => {
    'name': 'bucket',
    'type': 's3',
    'settings': {
      'endpoint': 'http://127.0.0.1:1',
      'bucket': 'backups',
      'access_key_id': 'key',
      'secret_access_key': 'secret',
    },
    'folders': folders,
  };

  const configs = '/api/workspaces/production/configs';

  setUpAll(() async {
    await server.start();
    await server.createWorkspace('Production');
    await server.createWorkspace('Staging');
    sourceId = await createdId('/api/workspaces/production/sources', {
      'name': 'orders-db',
      'type': 'postgres',
      'settings': {
        'host': 'pg.internal',
        'database': 'orders',
        'username': 'u',
        'password': 'p',
      },
    });
    foldersId = await createdId(
      '/api/workspaces/production/destinations',
      destination(['orders', 'users']),
    );
    rootId = await createdId(
      '/api/workspaces/production/destinations',
      destination([]),
    );
  });
  tearDownAll(server.stop);

  Map<String, Object?> config({
    String name = 'Orders nightly',
    String? destinationId,
    String? folder = 'orders',
    Map<String, Object?> extra = const {},
  }) => {
    'name': name,
    'source_id': sourceId,
    'destination_id': destinationId ?? foldersId,
    'folder': ?folder,
    ...extra,
  };

  group('ConfigController', () {
    test('Should create a config with the defaults of the workspace', () async {
      final response = await post(configs, config());
      expect(response.statusCode, 201, reason: response.body);
      final body = jsonDecode(response.body);
      expect(body['id'], startsWith('cfg_'));
      expect(body['source_id'], sourceId);
      expect(body['destination_id'], foldersId);
      expect(body['folder'], 'orders');
      expect(body['schedule'], '0 2 * * *');
      expect(body['compression'], 'none');
      expect(body['object_key'], '{db}/{yyyy}-{MM}-{dd}-{run_id}');
      expect(body['enabled'], isTrue);
      // The next 02:00 UTC
      final next = DateTime.parse(body['next_run']);
      expect(next.isUtc, isTrue);
      expect([next.hour, next.minute], [2, 0]);
      expect(next.isAfter(DateTime.now()), isTrue);
    });

    test('Should write to the root of a destination without folders', () async {
      final response = await post(
        configs,
        config(destinationId: rootId, folder: null),
      );
      expect(response.statusCode, 201, reason: response.body);
      expect(jsonDecode(response.body)['folder'], isNull);
    });

    test('Should replace a config, without a next run when disabled', () async {
      final id = await createdId(configs, config(name: 'Users'));
      final response = await put(
        '$configs/$id',
        config(
          name: 'Users hourly',
          folder: 'users',
          extra: {
            'schedule': '0 * * * *',
            'compression': 'none',
            'object_key': '{db}/{yyyy}-{MM}-{dd}/{run_id}',
            'enabled': false,
          },
        ),
      );
      expect(response.statusCode, 200, reason: response.body);
      final body = jsonDecode(response.body);
      expect(body['folder'], 'users');
      expect(body['schedule'], '0 * * * *');
      expect(body['compression'], 'none');
      expect(body['enabled'], isFalse);
      expect(body['next_run'], isNull);
    });

    test('Should check the source, destination and folder (422)', () async {
      Future<Set<Object?>> fieldsOf(Map<String, Object?> body) async {
        final response = await post(configs, body);
        expect(response.statusCode, 422, reason: response.body);
        return {
          for (final v in jsonDecode(response.body)['violations'] as List)
            v['fieldName'],
        };
      }

      expect(await fieldsOf({...config(), 'source_id': 'src_nope'}), {
        'source_id',
      });
      expect(await fieldsOf({...config(), 'destination_id': 'dst_nope'}), {
        'destination_id',
      });
      // A destination with folders needs one of them, never the root
      expect(await fieldsOf(config(folder: null)), {'folder'});
      expect(await fieldsOf(config(folder: 'billing')), {'folder'});
      // One without folders only has its root
      expect(await fieldsOf(config(destinationId: rootId)), {'folder'});
      expect(
        await fieldsOf(
          config(extra: {'schedule': 'daily', 'object_key': 'a/b.sql.gz'}),
        ),
        {'schedule', 'object_key'},
      );
      // It parses, but February has no 30th: it would never run
      expect(
        await fieldsOf(config(extra: {'schedule': '0 0 30 2 *'})),
        {'schedule'},
      );
    });

    test('Should not use a source of another workspace', () async {
      final response = await post('/api/workspaces/staging/configs', config());
      expect(response.statusCode, 422);
    });

    test('Should delete a config', () async {
      final id = await createdId(configs, config(name: 'Temporary'));
      final deleted = await http.delete(
        server.url('$configs/$id'),
        headers: server.auth(),
      );
      expect(deleted.statusCode, 204);
      final read = await http.get(
        server.url('$configs/$id'),
        headers: server.auth(),
      );
      expect(read.statusCode, 404);
    });
  });

  group('What a config uses', () {
    test('Should not delete a source or destination in use (409)', () async {
      final source = await http.delete(
        server.url('/api/workspaces/production/sources/$sourceId'),
        headers: server.auth(),
      );
      expect(source.statusCode, 409);
      final destination = await http.delete(
        server.url('/api/workspaces/production/destinations/$foldersId'),
        headers: server.auth(),
      );
      expect(destination.statusCode, 409);
    });

    test('Should not remove a folder or the root in use (409)', () async {
      final path = '/api/workspaces/production/destinations';
      // `orders` has a config
      final removed = await put('$path/$foldersId', destination(['users']));
      expect(removed.statusCode, 409);
      expect(jsonDecode(removed.body)['detail'], contains('"orders"'));
      // The root has a config: it can't get folders
      final rooted = await put('$path/$rootId', destination(['new']));
      expect(rooted.statusCode, 409);
      expect(jsonDecode(rooted.body)['detail'], contains('"/"'));
      // Adding a folder keeps the others
      final added = await put(
        '$path/$foldersId',
        destination(['orders', 'users', 'billing']),
      );
      expect(added.statusCode, 200, reason: added.body);
    });

    test('Should delete the configs with their workspace', () async {
      await server.createWorkspace('Doomed');
      final base = '/api/workspaces/doomed';
      final source = await createdId('$base/sources', {
        'name': 'db',
        'type': 'postgres',
        'settings': {
          'host': 'h',
          'database': 'd',
          'username': 'u',
          'password': 'p',
        },
      });
      final target = await createdId('$base/destinations', destination([]));
      await createdId('$base/configs', {
        'name': 'c',
        'source_id': source,
        'destination_id': target,
      });
      final deleted = await http.delete(
        server.url(base),
        headers: server.auth(),
      );
      expect(deleted.statusCode, 204);
    });
  });
}
