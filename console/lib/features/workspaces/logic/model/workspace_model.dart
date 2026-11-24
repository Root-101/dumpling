import 'package:console/app_exporter.dart';
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
