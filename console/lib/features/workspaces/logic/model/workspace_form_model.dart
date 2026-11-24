import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// What the form of a workspace sends. Without [defaults] the service sets
/// its own: an update must send them, it replaces everything
class WorkspaceFormModel {
  final String name;
  final String? description;
  final Color? color;
  final WorkspaceDefaults? defaults;

  const WorkspaceFormModel({
    required this.name,
    this.description,
    this.color,
    this.defaults,
  });
}
