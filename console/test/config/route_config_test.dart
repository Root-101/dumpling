import 'package:go_router/go_router.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteConfig.afterLogin', () {
    final workspaces = WorkspacesScreen.navigator.path;

    test('Goes back to the page asked for', () {
      expect(
        RouteConfig.afterLogin('/workspaces/production/runs'),
        '/workspaces/production/runs',
      );
    });

    test('Without a page, goes to the workspaces', () {
      expect(RouteConfig.afterLogin(null), workspaces);
      expect(RouteConfig.afterLogin(''), workspaces);
    });

    test('Never leaves the console (no open redirect)', () {
      expect(RouteConfig.afterLogin('https://evil.example/phish'), workspaces);
      expect(RouteConfig.afterLogin('//evil.example/phish'), workspaces);
      expect(RouteConfig.afterLogin('javascript:alert(1)'), workspaces);
    });

    test('Never goes back to the login itself', () {
      expect(RouteConfig.afterLogin(LoginScreen.navigator.path), workspaces);
    });
  });

  group('SectionNavigator.routes', () {
    test('A screen with items shares its page with the dialog of one', () {
      final routes = BackupsScreen.navigator.routes().cast<GoRoute>();
      expect(routes.map((r) => r.path), ['backups', 'backups/runs/:id']);
      expect(routes.map((r) => r.name), ['backups', 'backup-run']);
    });

    test('A screen without items is one route', () {
      final routes = ApiKeysScreen.navigator.routes().cast<GoRoute>();
      expect(routes.map((r) => r.path), ['keys']);
    });
  });
}
