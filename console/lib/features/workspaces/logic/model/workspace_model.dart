import 'package:material_ui/material_ui.dart';

/// A separate space with its own canvas, sources, destinations and backups.
/// Its [slug] comes from the name and never changes, so its links keep working
class WorkspaceModel {
  final String slug;
  final String name;
  final String? description;
  final Color? color;

  /// What a new config takes; null when the service doesn't send them
  final WorkspaceDefaults? defaults;
  final DateTime? createdAt;

  /// Only from the list
  final WorkspaceStatsModel? stats;

  const WorkspaceModel({
    required this.slug,
    required this.name,
    this.description,
    this.color,
    this.defaults,
    this.createdAt,
    this.stats,
  });

  /// What its avatar shows
  String get initial =>
      name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// The schedule (cron, UTC), the compression (`gzip`, `none`) and the object
/// key a new config of the workspace starts with
typedef WorkspaceDefaults = ({
  String schedule,
  String compression,
  String objectKey,
});

/// A config of [WorkspaceStatsModel.preview]: what it connects, by id
typedef WorkspacePreviewLink = ({
  String source,
  String destination,
  bool failing,
});

/// What a workspace has. [failing] counts the configs whose last run failed
class WorkspaceStatsModel {
  final int sources;
  final int destinations;
  final int configs;
  final int failing;
  final int running;
  final DateTime? lastRunAt;

  /// The first 3 configs (the oldest), for the sketch of the canvas
  final List<WorkspacePreviewLink> preview;

  const WorkspaceStatsModel({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.failing,
    required this.running,
    this.lastRunAt,
    this.preview = const [],
  });
}

/// What the form of a workspace sends. Without [defaults] the service sets
/// its own: an update must send them, it replaces everything
class WorkspaceDraft {
  final String name;
  final String? description;
  final Color? color;
  final WorkspaceDefaults? defaults;

  const WorkspaceDraft({
    required this.name,
    this.description,
    this.color,
    this.defaults,
  });
}
