import 'package:console/app_exporter.dart';

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
