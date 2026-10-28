import 'package:console/app_exporter.dart';

/// Names of the routes and their parameters. A feature navigates to another
/// feature's screen by its route name, without importing it
abstract class RouteNames {
  static const String login = 'login';
  static const String workspaces = 'workspaces';
  static const String backups = 'backups';
  static const String canvas = 'canvas';
  static const String sources = 'sources';
  static const String destinations = 'destinations';
  static const String runs = 'runs';

  /// `?from=` of [login]: the location asked for without a session, opened
  /// again after logging in
  static const String loginFromParam = 'from';

  /// `:slug` of every screen inside a workspace
  static const String slugParam = 'slug';

  /// Opens [section] (one of the names above) of the workspace [slug]
  static void openWorkspace(String slug, {String section = backups}) {
    app.navigator.go(section, pathParameters: {slugParam: slug});
  }
}
