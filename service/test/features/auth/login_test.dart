@TestOn('vm')
library;

import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/test_server.dart';

void main() {
  final server = TestServer(port: 8181);

  setUpAll(server.start);
  tearDownAll(server.stop);

  Future<http.Response> login(Object body, {String? language}) => http.post(
    server.url('/api/auth/login'),
    headers: {'content-type': 'application/json', 'accept-language': ?language},
    body: jsonEncode(body),
  );

  Future<int> sessionWith(String token) async => (await http.get(
    server.url('/api/auth/session'),
    headers: {'authorization': 'Bearer $token'},
  )).statusCode;

  group('AuthController - Login', () {
    test('Should issue a token of 12 hours with valid credentials', () async {
      final response = await login({
        'username': testUser,
        'password': testPassword,
      });
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['access_token'], isNotEmpty);
      expect(body['expires_in'], const Duration(hours: 12).inMilliseconds);
      expect(
        body['expire_at'],
        greaterThan(DateTime.now().millisecondsSinceEpoch),
      );
    });

    test(
      'Should reject wrong credentials (401) after the 1 s penalty',
      () async {
        final watch = Stopwatch()..start();
        final response = await login({
          'username': testUser,
          'password': 'wrong',
        });
        expect(response.statusCode, 401);
        expect(
          jsonDecode(response.body)['detail'],
          'Wrong username or password',
        );
        expect(
          watch.elapsed,
          greaterThanOrEqualTo(const Duration(milliseconds: 900)),
        );
      },
    );

    test('Should answer in the language of the request', () async {
      final response = await login({
        'username': 'nobody',
        'password': 'wrong',
      }, language: 'es-MX');
      expect(response.statusCode, 401);
      expect(
        jsonDecode(response.body)['detail'],
        'Usuario o contraseña incorrectos',
      );
    });

    test('Should reject a malformed body (400) naming the field', () async {
      final missing = await login({'username': testUser});
      expect(missing.statusCode, 400);
      expect(
        missing.headers['content-type'],
        startsWith('application/problem+json'),
      );
      expect(jsonDecode(missing.body)['detail'], r'$.password: missing');
    });

    test('Should not reveal internal details on a malformed login', () async {
      final response = await login({'username': 1, 'password': true});
      expect(response.statusCode, 400);
      expect(response.body, isNot(contains('Exception')));
      expect(response.body, isNot(contains('subtype')));
    });
  });

  group('AuthController - Session', () {
    final claims = {
      'sub': testUser,
      'permissions': [Permissions.authSession],
    };
    String sign(Map<String, Object?> payload, [String? secret]) =>
        JWT(payload).sign(SecretKey(secret ?? testJwtSecret(server.port)));
    int inOneHour() =>
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000;

    test('Should answer who is signed in with the issued token', () async {
      final response = await http.get(
        server.url('/api/auth/session'),
        headers: server.auth(),
      );
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body);
      expect(body['username'], testUser);
      expect(
        body['expire_at'],
        greaterThan(DateTime.now().millisecondsSinceEpoch),
      );
    });

    test('Should forbid a valid token without the permission (403)', () async {
      final token = sign({
        'sub': testUser,
        'permissions': <String>[],
        'exp': inOneHour(),
      });
      expect(await sessionWith(token), 403);
    });

    test('Should reject a request without a token', () async {
      final response = await http.get(server.url('/api/auth/session'));
      expect(response.statusCode, 401);
    });

    test('Should reject a token without exp (it would never expire)', () async {
      expect(await sessionWith(sign(claims)), 401);
    });

    test('Should reject an expired token', () async {
      expect(await sessionWith(sign({...claims, 'exp': 1000})), 401);
    });

    test('Should reject a token signed with another secret', () async {
      final token = sign({...claims, 'exp': inOneHour()}, 'other-secret');
      expect(await sessionWith(token), 401);
    });

    test('Should reject an unsigned token (alg none)', () async {
      String b64(Object o) =>
          base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
      final token =
          '${b64({'alg': 'none', 'typ': 'JWT'})}.${b64({...claims, 'exp': inOneHour()})}.';
      expect(await sessionWith(token), 401);
    });

    test('Should answer 404 for an unknown route of the API', () async {
      final response = await http.get(
        server.url('/api/nothing-here'),
        headers: server.auth(),
      );
      expect(response.statusCode, 404);
    });
  });
}
