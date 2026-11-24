import 'package:drift/native.dart';
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

const String testUser = 'test_admin';
// Long enough not to trigger the start-up warning about short secrets
const String testPassword = 'test_password_1';

/// The JWT secret of the tests (32 characters or more).
const String testJwtSecret = 'test-jwt-secret-of-the-dumpling-tests';

/// The whole service in memory for a test file: an in-memory database, the
/// real filters, security and routes, served by `WinterTestClient` (no port).
class TestApp {
  late final DumplingApp app;
  late final WinterTestClient client;

  /// JWT obtained in [start] with the test credentials.
  late final String token;

  bool _listening = false;

  Future<void> start() async {
    env.put('DUMPLING_ADMIN_USER', testUser);
    env.put('DUMPLING_ADMIN_PASSWORD', testPassword);
    env.put('JWT_SECRET', testJwtSecret);
    env.put(
      'SECRETS_ENCRYPTION_KEY',
      'test-secrets-encryption-key-of-the-tests',
    );
    // Only problems: every request would otherwise write two lines
    env.put('LOG_LEVEL', 'error');

    app = await Dumpling.setUp(database: AppDatabase(NativeDatabase.memory()));
    // What Winter.start does: the schedules of the configs get their next run
    app.scheduler.start();
    client = WinterTestClient.build(
      router: app.router,
      globalFilterConfig: app.filters,
      securityConfig: app.security,
      trustedProxies: app.trustedProxies,
      requestTimeout: app.requestTimeout,
    );

    final login = await post(
      '/api/auth/login',
      headers: {'content-type': 'application/json'},
      body: {'username': testUser, 'password': testPassword},
    );
    expect(login.statusCode, 200, reason: 'login: ${login.body}');
    token = login.json['access_token'] as String;
  }

  /// Also serves it on [port], for what needs a real socket (a body that
  /// never arrives). Each test file that does uses its own port.
  Future<void> listen(int port) {
    _listening = true;
    return Winter.start(
      config: ServerConfig(
        port: port,
        trustedProxies: app.trustedProxies,
        requestTimeout: app.requestTimeout,
        handleSignals: false,
      ),
      globalFilterConfig: app.filters,
      securityConfig: app.security,
      router: app.router,
    );
  }

  Future<void> stop() async {
    await app.scheduler.stop();
    if (_listening) await Winter.close(force: true);
    await di.find<AppDatabase>().close();
  }

  /// Headers with the JWT.
  Map<String, String> auth() => {'authorization': 'Bearer $token'};

  Future<TestResponse> get(String path, {Map<String, Object>? headers}) =>
      client.get(path, headers: headers);

  Future<TestResponse> delete(String path, {Map<String, Object>? headers}) =>
      client.delete(path, headers: headers);

  Future<TestResponse> post(
    String path, {
    Map<String, Object>? headers,
    Object? body,
  }) => client.post(path, headers: headers, body: body);

  Future<TestResponse> put(
    String path, {
    Map<String, Object>? headers,
    Object? body,
  }) => client.put(path, headers: headers, body: body);

  /// Creates a workspace; its slug is [name] in lowercase.
  Future<void> createWorkspace(String name) async {
    final response = await post(
      '/api/workspaces',
      headers: {...auth(), 'content-type': 'application/json'},
      body: {'name': name},
    );
    expect(response.statusCode, 201, reason: 'workspace: ${response.body}');
  }
}
