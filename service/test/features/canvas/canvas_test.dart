@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8187);
  const canvas = '/api/workspaces/production/canvas';

  Future<http.Response> save(Object body) => http.put(
    server.url(canvas),
    headers: {...server.auth(), 'content-type': 'application/json'},
    body: jsonEncode(body),
  );

  Future<Map<String, dynamic>> saved(Object body) async {
    final response = await save(body);
    expect(response.statusCode, 200, reason: response.body);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> current() async => jsonDecode(
    (await http.get(server.url(canvas), headers: server.auth())).body,
  );

  Future<Set<Object?>> violations(Object body) async {
    final response = await save(body);
    expect(response.statusCode, 422, reason: response.body);
    return {
      for (final v in jsonDecode(response.body)['violations'] as List)
        v['fieldName'],
    };
  }

  Map<String, Object?> source(
    String id, {
    String name = 'orders-db',
    bool password = true,
    Object? position = const {'x': 40, 'y': 120},
  }) => {
    'id': id,
    'name': name,
    'type': 'postgres',
    'settings': {
      'host': 'pg.internal',
      'database': 'orders',
      'username': 'u',
      'password': ?(password ? 'p' : null),
    },
    'position': position,
  };

  Map<String, Object?> destination(
    String id, {
    List<String> folders = const ['orders'],
  }) => {
    'id': id,
    'name': 'bucket',
    'type': 's3',
    'settings': {
      'endpoint': 'http://127.0.0.1:1',
      'bucket': 'backups',
      'access_key_id': 'key',
      'secret_access_key': 'secret',
    },
    'folders': folders,
    'position': {'x': 760, 'y': 120},
  };

  Map<String, Object?> config(
    String id, {
    String? sourceId,
    String? destinationId,
    String? folder = 'orders',
  }) => {
    'id': id,
    'name': 'Orders nightly',
    'source_id': sourceId,
    'destination_id': destinationId,
    'folder': folder,
    'position': {'x': 400.5, 'y': 130},
  };

  setUpAll(() async {
    await server.start();
    await server.createWorkspace('Production');
  });
  tearDownAll(server.stop);

  group('Canvas', () {
    late String sourceId;
    late String destinationId;
    late String configId;

    test('Should create the whole graph, new ids included', () async {
      final body = await saved({
        'sources': [source('new_1')],
        'destinations': [destination('new_2')],
        'configs': [config('new_3', sourceId: 'new_1', destinationId: 'new_2')],
      });
      final ids = body['ids'] as Map<String, dynamic>;
      sourceId = ids['new_1'];
      destinationId = ids['new_2'];
      configId = ids['new_3'];
      expect(sourceId, startsWith('src_'));
      expect(destinationId, startsWith('dst_'));
      expect(configId, startsWith('cfg_'));

      final created = (body['configs'] as List).single;
      expect(created['source_id'], sourceId);
      expect(created['destination_id'], destinationId);
      expect(created['position'], {'x': 400.5, 'y': 130.0});
      // The defaults of the workspace
      expect(created['schedule'], '0 2 * * *');
      expect(
        (body['sources'] as List).single['settings'],
        isNot(contains('password')),
      );
      expect(di.find<Scheduler>()[BackupEngine.taskName(configId)], isNotNull);
    });

    test('Should replace it: moved, renamed, kept off the canvas', () async {
      final body = await saved({
        // No password: the stored one stays
        'sources': [
          source(sourceId, name: 'orders', password: false, position: null),
        ],
        'destinations': [destination(destinationId)],
        'configs': [
          config(configId, sourceId: sourceId, destinationId: destinationId),
        ],
      });
      expect(body['ids'], isEmpty);
      final s = (body['sources'] as List).single;
      expect(s['name'], 'orders');
      expect(s['position'], isNull);
      expect((await current())['sources'], hasLength(1));
    });

    test('Should delete what it leaves out, and its schedule', () async {
      final body = await saved({
        'sources': [source(sourceId, password: false)],
        'destinations': [destination(destinationId)],
        'configs': [],
      });
      expect(body['configs'], isEmpty);
      expect(di.find<Scheduler>()[BackupEngine.taskName(configId)], isNull);
    });

    test('Should check the shape of every node first (422)', () async {
      expect(
        await violations({
          'sources': [source('new_1')],
          'destinations': [destination('new_2')],
          'configs': [
            // Orphans are fine on the canvas, not once saved
            config('new_3', destinationId: 'new_2'),
            config('new_3', sourceId: 'new_1', destinationId: 'new_2'),
          ],
        }),
        {'configs[0].source_id', 'configs[1].id'},
      );
    });

    test('Should save nothing when a node is wrong (422)', () async {
      expect(
        await violations({
          'sources': [source('src_nope'), source('new_1')],
          'destinations': [destination('new_2')],
          'configs': [
            config(
              'new_3',
              sourceId: 'new_1',
              destinationId: 'new_2',
              folder: 'other',
            ),
            config('new_4', sourceId: 'new_1', destinationId: 'new_9'),
            config('new_5', sourceId: 'src_gone', destinationId: 'new_2'),
          ],
        }),
        {
          'sources[0].id',
          'configs[0].folder',
          'configs[1].destination_id',
          'configs[2].source_id',
        },
      );
      expect(
        await violations({
          'sources': [source('new_1', password: false)],
          'destinations': [],
          'configs': [],
        }),
        {'sources[0].settings.password'},
      );
      final now = await current();
      expect((now['sources'] as List).single['id'], sourceId);
      expect(now['destinations'], hasLength(1));
    });

    test('Should not remove a folder a config writes to (422)', () async {
      final body = await saved({
        'sources': [source(sourceId, password: false)],
        'destinations': [destination(destinationId)],
        'configs': [
          config('new_1', sourceId: sourceId, destinationId: destinationId),
        ],
      });
      final id = (body['configs'] as List).single['id'];
      expect(
        await violations({
          'sources': [source(sourceId, password: false)],
          'destinations': [
            destination(destinationId, folders: ['daily']),
          ],
          'configs': [
            config(id, sourceId: sourceId, destinationId: destinationId),
          ],
        }),
        {'configs[0].folder'},
      );
    });
  });
}
