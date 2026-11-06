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

  group('HealthController', () {
    test('Should answer up without a token', () async {
      final response = await http.get(server.url('/api/health'));
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body), {'status': 'up'});
    });

    test('Should answer down (503) when the database fails', () async {
      final db = di.find<AppDatabase>();
      await db.close();
      final response = await http.get(server.url('/api/health'));
      expect(response.statusCode, 503);
      expect(jsonDecode(response.body), {'status': 'down'});
    });
  });
}
