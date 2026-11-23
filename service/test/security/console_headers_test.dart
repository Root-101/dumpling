import 'dart:io';

import 'package:test/test.dart';

import '../support/test_app.dart';

void main() {
  // The console is served only when its web build is next to the service
  final built = Directory('../console/build/web').existsSync();
  final server = TestApp();

  setUpAll(() async {
    if (built) await server.start();
  });
  tearDownAll(() async {
    if (built) await server.stop();
  });

  test(
    'Should serve every file of the console with its security headers',
    () async {
      for (final path in ['/', '/workspaces/production/runs', '/env.js']) {
        final response = await server.get(path);
        expect(response.statusCode, 200, reason: path);
        expect(response.headers['x-frame-options'], 'DENY', reason: path);
        expect(response.headers['x-content-type-options'], 'nosniff');
        expect(response.headers['referrer-policy'], 'no-referrer');
        // the console needs its inline scripts
        expect(response.headers['content-security-policy'], isNull);
        // a new build is seen on reload, not after the heuristic cache
        expect(response.headers['cache-control'], 'no-cache', reason: path);
      }
      // the API too, its errors included
      final api = await server.get('/api/nothing');
      expect(api.statusCode, 404);
      expect(api.headers['referrer-policy'], 'no-referrer');
    },
    skip: built ? false : 'no console build (fvm flutter build web)',
  );
}
