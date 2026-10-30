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
}
