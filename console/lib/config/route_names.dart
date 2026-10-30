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

  /// The dialog of one item over its screen: `sources/{id}`,
  /// `destinations/{id}`, `runs/{id}`, `backups/runs/{id}`
  static const String source = 'source';
  static const String destination = 'destination';
  static const String run = 'run';
  static const String backupRun = 'backup-run';

  /// `?from=` of [login]: the location asked for without a session, opened
  /// again after logging in
  static const String loginFromParam = 'from';

  /// `:slug` of every screen inside a workspace
  static const String slugParam = 'slug';

  /// `:id` of an item ([source], [destination], [run], [backupRun])
  static const String idParam = 'id';

  /// Opens [section] (one of the names above) of the workspace [slug]
  static void openWorkspace(String slug, {String section = backups}) {
    app.navigator.go(section, pathParameters: {slugParam: slug});
  }

  /// Opens the dialog of the item [id] ([name] is one of the item routes);
  /// [query] keeps the filters of its screen
  static void openItem(
    String slug,
    String name,
    String id, {
    Map<String, String> query = const {},
  }) {
    app.navigator.go(
      name,
      pathParameters: {slugParam: slug, idParam: id},
      queryParameters: query,
    );
  }
}
