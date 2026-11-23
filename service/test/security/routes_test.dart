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
  setUpAll(server.start);
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

  test(
    'Should answer 401 on every route but the public ones without a token',
    () async {
      expect(routes(), hasLength(greaterThan(40)));
      for (final (path, method, key) in routes()) {
        if (public.contains(key)) continue;
        // Any value for the path params: the token is checked before them
        final concrete = path.replaceAllMapped(
          RegExp(r'\{(\w+)\}'),
          (m) => 'x',
        );
        final response = await server.client.request(
          method.name.toUpperCase(),
          concrete,
          headers: {'content-type': 'application/json'},
          body: '{}',
        );
        expect(response.statusCode, 401, reason: '$method $path ($key)');
      }
    },
  );

  test('Should answer the public routes without a token', () async {
    expect((await server.get('/api/health')).statusCode, 200);
  });
}
