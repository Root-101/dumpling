@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/fake_s3.dart';
import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8184);
  final s3 = FakeS3();

  setUpAll(() async {
    await s3.start();
    await server.start();
    await server.createWorkspace('Production');
    await server.createWorkspace('Staging');
  });
  tearDownAll(() async {
    await server.stop();
    await s3.stop();
  });

  String path(String workspace, [String rest = '']) =>
      '/api/workspaces/$workspace/destinations$rest';

  Map<String, String> jsonHeaders() => {
    ...server.auth(),
    'content-type': 'application/json',
  };

  Map<String, Object?> bucket({
    String name = 'bucket-backups',
    String? secret = FakeS3.secretAccessKey,
    List<String>? folders,
    String? endpoint,
  }) => {
    'name': name,
    'type': 's3',
    'settings': {
      'endpoint': endpoint ?? s3.endpoint,
      'bucket': 'backups',
      'access_key_id': FakeS3.accessKeyId,
      'secret_access_key': ?secret,
      'path_style': true,
    },
    'folders': ?folders,
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

  Future<Map<String, dynamic>> testConnection(Object body) async {
    final response = await http.post(
      server.url(path('production', '/test')),
      headers: jsonHeaders(),
      body: jsonEncode(body),
    );
    expect(response.statusCode, 200, reason: response.body);
    return jsonDecode(response.body);
  }

  group('DestinationController', () {
    test('Should list every type, only S3 enabled', () async {
      final response = await http.get(
        server.url('/api/destination-types'),
        headers: server.auth(),
      );
      final types = {
        for (final t in jsonDecode(response.body) as List)
          t['type']: t['enabled'],
      };
      expect(types, {
        's3': true,
        'gdrive': false,
        'azure': false,
        'dropbox': false,
        'sftp': false,
      });
    });

    test(
      'Should create a destination with its folders, no secret back',
      () async {
        final response = await create(
          bucket(folders: ['/orders/', 'daily/billing', 'users']),
        );
        expect(response.statusCode, 201, reason: response.body);
        expect(response.body, isNot(contains(FakeS3.secretAccessKey)));
        final body = jsonDecode(response.body);
        expect(body['id'], startsWith('dst_'));
        expect(body['settings'], {
          'endpoint': s3.endpoint,
          'region': 'us-east-1',
          'bucket': 'backups',
          'access_key_id': FakeS3.accessKeyId,
          'path_style': true,
        });
        // Without slashes around, in alphabetical order
        expect(body['folders'], ['daily/billing', 'orders', 'users']);
      },
    );

    test('Should replace the folders and keep the secret on update', () async {
      final destination = await created(bucket(folders: ['a', 'b']));
      final response = await http.put(
        server.url(path('production', '/${destination['id']}')),
        headers: jsonHeaders(),
        body: jsonEncode(bucket(secret: null, folders: ['c'])),
      );
      expect(response.statusCode, 200, reason: response.body);
      expect(jsonDecode(response.body)['folders'], ['c']);

      // The stored secret still signs
      final tested = await http.post(
        server.url(path('production', '/${destination['id']}/test')),
        headers: server.auth(),
      );
      expect(jsonDecode(tested.body)['status'], 'connected');
    });

    test('Should reject invalid data (422) naming each field', () async {
      final response = await create({
        'name': 'x',
        'type': 's3',
        'settings': {
          'endpoint': 'ftp://host',
          'bucket': 'Not_A_Bucket',
          'access_key_id': 'key',
          'secret_access_key': 'secret',
        },
        'folders': ['Orders', 'ok', 'ok', '../up'],
      });
      expect(response.statusCode, 422);
      final fields = {
        for (final v in jsonDecode(response.body)['violations'] as List)
          v['fieldName'],
      };
      expect(
        fields,
        containsAll(['settings.endpoint', 'settings.bucket', 'folders']),
      );

      final noSecret = await create(bucket(secret: null));
      expect(noSecret.statusCode, 422);
      expect(noSecret.body, contains('settings.secret_access_key'));

      final disabled = await create({'name': 'drive', 'type': 'gdrive'});
      expect(disabled.statusCode, 422);
      expect(disabled.body, contains('not available yet'));
    });

    test('Should not find a destination from another workspace', () async {
      final destination = await created(bucket(name: 'replica'));
      final response = await http.get(
        server.url(path('staging', '/${destination['id']}')),
        headers: server.auth(),
      );
      expect(response.statusCode, 404);
    });

    test('Should delete a destination with its folders', () async {
      final destination = await created(bucket(folders: ['gone']));
      final deleted = await http.delete(
        server.url(path('production', '/${destination['id']}')),
        headers: server.auth(),
      );
      expect(deleted.statusCode, 204);
      final db = di.find<AppDatabase>();
      final folders = await (db.select(
        db.destinationFolderTable,
      )..where((t) => t.destinationId.equals(destination['id']))).get();
      expect(folders, isEmpty);
    });
  });

  group('Connection test', () {
    setUp(s3.requests.clear);

    test('Should start and abort an upload in each folder', () async {
      final check = await testConnection(
        bucket(folders: ['orders', 'daily/billing']),
      );
      expect(check['status'], 'connected');
      expect(s3.openUploads, isEmpty);
      final creates = s3.requests.where((r) => r.startsWith('POST')).toList();
      expect(creates, hasLength(2));
      expect(creates[0], startsWith('POST /backups/orders/.dumpling-check-'));
      expect(
        creates[1],
        startsWith('POST /backups/daily/billing/.dumpling-check-'),
      );
      expect(s3.requests.where((r) => r.startsWith('DELETE')), hasLength(2));
    });

    test('Should test the bucket root when there are no folders', () async {
      final check = await testConnection(bucket());
      expect(check['status'], 'connected');
      expect(s3.requests.first, startsWith('POST /backups/.dumpling-check-'));
    });

    test('Should name the folder that is denied', () async {
      final check = await testConnection(bucket(folders: ['orders', 'denied']));
      expect(check['status'], 'failed');
      expect(check['message'], 'denied: AccessDenied: AccessDenied here');
    });

    test('Should report a wrong secret', () async {
      final check = await testConnection(bucket(secret: 'wrong-secret'));
      expect(check['status'], 'failed');
      expect(check['message'], contains('SignatureDoesNotMatch'));
    });

    test('Should report an endpoint that does not answer', () async {
      final check = await testConnection(
        bucket(endpoint: 'http://127.0.0.1:1'),
      );
      expect(check['status'], 'failed');
      expect(check['message'], isNotEmpty);
    });

    test('Should report an endpoint that does not speak HTTP', () async {
      // http on a TLS port, or any server that answers something else
      final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(socket.close);
      socket.listen((client) async {
        client.write('not http\r\n\r\n');
        await client.close();
      });
      final check = await testConnection(
        bucket(endpoint: 'http://127.0.0.1:${socket.port}'),
      );
      expect(check['status'], 'failed');
      expect(check['message'], isNotEmpty);
    });

    test('Should keep the result of testing a saved destination', () async {
      final destination = await created(bucket(folders: ['denied']));
      await http.post(
        server.url(path('production', '/${destination['id']}/test')),
        headers: server.auth(),
      );
      final read = jsonDecode(
        (await http.get(
          server.url(path('production', '/${destination['id']}')),
          headers: server.auth(),
        )).body,
      );
      expect(read['last_check']['status'], 'failed');
    });
  });
}
