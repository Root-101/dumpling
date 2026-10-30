import 'dart:convert';

import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

const String testUser = 'test_admin';
// Long enough not to trigger the start-up warning about short secrets
const String testPassword = 'test_password_1';

/// The JWT secret of the server on [port] (32 characters or more).
String testJwtSecret(int port) => 'test-jwt-secret-of-the-server-$port';

/// Real server for a test file, on its own port.
class TestServer {
  final int port;

  /// JWT obtained in [start] with the test credentials.
  late final String token;

  TestServer({required this.port});

  Future<void> start() async {
    env.put('DUMPLING_ADMIN_USER', testUser);
    env.put('DUMPLING_ADMIN_PASSWORD', testPassword);
    env.put('JWT_SECRET', testJwtSecret(port));
    env.put('SECRETS_ENCRYPTION_KEY', 'test-secrets-encryption-key-$port');
    // Only problems: every request would otherwise write two lines
    env.put('LOG_LEVEL', 'error');

    await Dumpling.start(
      port: port,
      database: AppDatabase(NativeDatabase.memory()),
    );

    final login = await http.post(
      url('/api/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'username': testUser, 'password': testPassword}),
    );
    expect(login.statusCode, 200, reason: 'login: ${login.body}');
    token = jsonDecode(login.body)['access_token'] as String;
  }

  Future<void> stop() => Winter.close(force: true);

  Uri url(String path) => Uri.parse('http://localhost:$port$path');

  /// Headers with the JWT.
  Map<String, String> auth() => {'authorization': 'Bearer $token'};

  /// Creates a workspace; its slug is [name] in lowercase.
  Future<void> createWorkspace(String name) async {
    final response = await http.post(
      url('/api/workspaces'),
      headers: {...auth(), 'content-type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    expect(response.statusCode, 201, reason: 'workspace: ${response.body}');
  }
}
