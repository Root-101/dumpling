@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8182);

  setUpAll(server.start);
  tearDownAll(server.stop);

  Map<String, String> jsonHeaders({String? language}) => {
    ...server.auth(),
    'content-type': 'application/json',
    'accept-language': ?language,
  };

  Future<http.Response> create(Object body, {String? language}) => http.post(
    server.url('/api/workspaces'),
    headers: jsonHeaders(language: language),
    body: jsonEncode(body),
  );

  Future<http.Response> update(String slug, Object body) => http.put(
    server.url('/api/workspaces/$slug'),
    headers: jsonHeaders(),
    body: jsonEncode(body),
  );

  Future<http.Response> get(String slug, {String? language}) => http.get(
    server.url('/api/workspaces/$slug'),
    headers: jsonHeaders(language: language),
  );

  group('WorkspaceController', () {
    test('Should create a workspace with the default config values', () async {
      final response = await create({
        'name': '  Production  ',
        'color': 0xFF5B4A9A,
      });
      expect(response.statusCode, 201);
      final body = jsonDecode(response.body);
      expect(body['slug'], 'production');
      expect(body['name'], 'Production');
      expect(body['description'], isNull);
      expect(body['color'], 0xFF5B4A9A);
      expect(body['defaults'], {
        'schedule': WorkspaceDefaults.defaultSchedule,
        'compression': 'gzip',
        'object_key': WorkspaceDefaults.defaultObjectKey,
      });
      expect(DateTime.parse(body['created_at']).isUtc, isTrue);
    });

    test('Should give a repeated name the next free slug', () async {
      final first = jsonDecode((await create({'name': 'Staging'})).body);
      final second = jsonDecode((await create({'name': 'staging'})).body);
      final third = jsonDecode((await create({'name': 'STAGING!'})).body);
      expect(first['slug'], 'staging');
      expect(second['slug'], 'staging-2');
      expect(third['slug'], 'staging-3');
    });

    test('Should list every workspace, oldest first', () async {
      await create({'name': 'Listed'});
      final response = await http.get(
        server.url('/api/workspaces'),
        headers: server.auth(),
      );
      expect(response.statusCode, 200);
      final slugs = [
        for (final w in jsonDecode(response.body) as List) w['slug'],
      ];
      expect(slugs.last, 'listed');
      expect((jsonDecode(response.body) as List).last['stats'], {
        'sources': 0,
        'destinations': 0,
        'configs': 0,
        'failing': 0,
        'running': 0,
        'last_run_at': null,
        'preview': [],
      });
    });

    test('Should replace the data but keep the slug on update', () async {
      await create({'name': 'Client Acme', 'description': 'Old'});
      final response = await update('client-acme', {
        'name': 'Acme Corp',
        'defaults': {
          'schedule': '0 */6 * * *',
          'compression': 'none',
          'object_key': '{db}/{yyyy}-{MM}-{dd}',
        },
      });
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['slug'], 'client-acme');
      expect(body['name'], 'Acme Corp');
      // A missing description clears it
      expect(body['description'], isNull);
      expect(body['defaults']['schedule'], '0 */6 * * *');
      expect(body['defaults']['compression'], 'none');

      final read = jsonDecode((await get('client-acme')).body);
      expect(read['name'], 'Acme Corp');
    });

    test('Should delete a workspace', () async {
      await create({'name': 'Temporary'});
      final response = await http.delete(
        server.url('/api/workspaces/temporary'),
        headers: server.auth(),
      );
      expect(response.statusCode, 204);
      expect((await get('temporary')).statusCode, 404);
    });

    test('Should answer 404 for an unknown slug, translated', () async {
      final response = await get('nope', language: 'es');
      expect(response.statusCode, 404);
      expect(
        jsonDecode(response.body)['detail'],
        'El workspace "nope" no existe.',
      );
      expect((await update('nope', {'name': 'X'})).statusCode, 404);
    });

    test('Should reject invalid data (422) naming each field', () async {
      final response = await create({
        'name': '   ',
        'color': -1,
        'defaults': {
          'schedule': 'every day',
          'compression': 'zstd',
          'object_key': '/abs/path',
        },
      });
      expect(response.statusCode, 422);
      final fields = {
        for (final v in jsonDecode(response.body)['violations'] as List)
          v['fieldName'],
      };
      expect(
        fields,
        containsAll([
          'name',
          'color',
          'defaults.schedule',
          'defaults.compression',
          'defaults.object_key',
        ]),
      );
    });

    test('Should reject an object key with an extension', () async {
      for (final key in ['{yyyy}/{MM}/{dd}.dump.gz', 'daily/{db}.SQL']) {
        final response = await create({
          'name': 'With extension',
          'defaults': {'object_key': key},
        });
        expect(response.statusCode, 422, reason: key);
        expect(response.body, contains('Leave out the extension'));
      }
      // A dot in a folder is not an extension
      final folder = await create({
        'name': 'Dotted folder',
        'defaults': {'object_key': 'orders.v2/{yyyy}-{MM}-{dd}'},
      });
      expect(folder.statusCode, 201);
    });

    test('Should require the token', () async {
      final response = await http.get(server.url('/api/workspaces'));
      expect(response.statusCode, 401);
    });
  });

  group('WorkspaceService.slugOf', () {
    test('Should keep lowercase letters, digits and single hyphens', () {
      expect(WorkspaceService.slugOf('Staging EU · Ñandú'), 'staging-eu-nandu');
      expect(
        WorkspaceService.slugOf('  --Client__Acme 2026-- '),
        'client-acme-2026',
      );
    });

    test('Should fall back to workspace when nothing is left', () {
      expect(WorkspaceService.slugOf('!!!'), 'workspace');
    });

    test('Should cut long names without a trailing hyphen', () {
      final slug = WorkspaceService.slugOf('${'a' * 47} bbbb');
      expect(slug, 'a' * 47);
    });
  });
}
