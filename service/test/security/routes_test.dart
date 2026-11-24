@TestOn('vm')
library;

import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../support/test_app.dart';

/// Every route under `/api`, with its full path and method.
List<(String, HttpMethod, String)> apiRoutes(
  Route route, [
  String prefix = '',
]) => [
  if (route.method != null) (prefix + route.path, route.method!, route.key),
  for (final child in route.routes) ...apiRoutes(child, prefix + route.path),
];

void main() {
  final server = TestApp();
  setUpAll(() {
    // Every route once per permission: well above the general limit
    env.put('RATE_LIMIT_REQUESTS', '0');
    return server.start();
  });
  tearDownAll(server.stop);

  /// Answer without a token: the sign-in and the health check.
  const public = {'auth.login', 'health'};

  // Once the app is up: the controllers come from its DI
  List<(String, HttpMethod, String)> routes() =>
      apiRoutes(ApiController().routing);

  test('Should give every route of the API its own key', () {
    final keys = [for (final (_, _, key) in routes()) key];
    expect(keys.toSet(), hasLength(keys.length));
  });

  /// [route] with any value for its path params (the token is checked first)
  Future<TestResponse> call(
    String path,
    HttpMethod method, [
    Map<String, String> headers = const {},
  ]) => server.client.request(
    method.name.toUpperCase(),
    path.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) => 'x'),
    headers: {'content-type': 'application/json', ...headers},
    body: '{}',
  );

  test(
    'Should answer 401 on every route but the public ones without a token',
    () async {
      expect(routes(), hasLength(greaterThan(40)));
      for (final (path, method, key) in routes()) {
        if (public.contains(key)) continue;
        final response = await call(path, method);
        expect(response.statusCode, 401, reason: '$method $path ($key)');
      }
    },
  );

  /// A user that isn't the admin, with every permission but [missing]
  Map<String, String> without(String missing) => {
    'authorization':
        'Bearer ${di.find<JwtService>().generateToken({
          'sub': 'not-the-admin',
          'permissions': [for (final p in Permissions.all)
            if (p != missing) p],
          'exp': utcNow().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        })}',
  };

  test(
    'Should guard every private route with one permission of Permissions.all, '
    'answer 403 without it, and use every permission',
    () async {
      // route key -> the permissions whose absence makes it answer 403
      final guards = <String, Set<String>>{};
      for (final permission in Permissions.all) {
        final headers = without(permission);
        for (final (path, method, key) in routes()) {
          if (public.contains(key)) continue;
          if ((await call(path, method, headers)).statusCode == 403) {
            guards.putIfAbsent(key, () => {}).add(permission);
          }
        }
      }
      for (final (path, method, key) in routes()) {
        if (public.contains(key)) continue;
        expect(guards[key], hasLength(1), reason: '$method $path ($key)');
      }
      final used = {for (final g in guards.values) ...g};
      expect(Permissions.all.where((p) => !used.contains(p)), isEmpty);
    },
  );

  test('Should answer the public routes without a token', () async {
    expect((await server.get('/api/health')).statusCode, 200);
  });
}
