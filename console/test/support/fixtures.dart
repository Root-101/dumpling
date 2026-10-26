import 'package:console/app_exporter.dart';

/// A workspace with sensible defaults; each test changes only what it checks
WorkspaceModel workspace(
  String slug, {
  String? name,
  int configs = 0,
  int destinations = 0,
  int failing = 0,
  int running = 0,
  DateTime? lastRunAt,
}) => WorkspaceModel(
  slug: slug,
  name: name ?? slug,
  description: 'About $slug',
  stats: WorkspaceStatsModel(
    sources: configs,
    destinations: destinations,
    configs: configs,
    failing: failing,
    running: running,
    lastRunAt: lastRunAt,
  ),
);

/// The session every cubit reads its token from
AuthModel session() => AuthModel(accessToken: 'jwt', expireAt: DateTime(2100));

/// An error as the repos throw it (already converted)
GlobalException apiError([String message = 'boom']) =>
    GlobalException(type: GlobalExceptionType.general, message: message);
