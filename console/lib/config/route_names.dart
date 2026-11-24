/// Names of the routes and their parameters, for the navigators of the
/// screens (`SourcesScreen.navigator.go(...)`): nothing else navigates by name
abstract class RouteNames {
  static const String login = 'login';
  static const String workspaces = 'workspaces';
  static const String backups = 'backups';
  static const String canvas = 'canvas';
  static const String sources = 'sources';
  static const String destinations = 'destinations';
  static const String runs = 'runs';
  static const String apiKeys = 'keys';

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
}
