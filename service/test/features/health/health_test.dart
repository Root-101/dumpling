@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8191);

  setUpAll(server.start);
  tearDownAll(server.stop);

  group('Health', () {
    test('Should pass without a token', () async {
      final response = await http.get(server.url('/api/health'));
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['status'], 'pass');
      expect(
        response.headers['content-type'],
        startsWith('application/health+json'),
      );
    });

    test('Should fail (503) when the database fails', () async {
      final db = di.find<AppDatabase>();
      await db.close();
      final response = await http.get(server.url('/api/health'));
      expect(response.statusCode, 503);
      expect(jsonDecode(response.body)['status'], 'fail');
      expect(
        jsonDecode(response.body)['checks']['database'][0]['status'],
        'fail',
      );
    });
  });
}
