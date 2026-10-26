import 'dart:convert';

import 'package:service/dumpling.dart';

class DestinationModel {
  final String id;
  final String workspace;
  final String name;
  final DestinationType type;

  /// The connection data without its secrets.
  final Map<String, Object?> settings;

  /// Each one is a connection point on the canvas; none: the bucket root is.
  final List<String> folders;

  /// The last connection test, null until the first one.
  final ConnectionCheck? lastCheck;
  final DateTime createdAt;
  final DateTime updatedAt;

  DestinationModel({
    required this.id,
    required this.workspace,
    required this.name,
    required this.type,
    required this.settings,
    required this.folders,
    this.lastCheck,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DestinationModel.fromRow(DestinationRow row) => DestinationModel(
    id: row.destination.id,
    workspace: row.destination.workspaceSlug,
    name: row.destination.name,
    type: row.destination.type,
    settings: jsonDecode(row.destination.settings) as Map<String, Object?>,
    folders: [for (final folder in row.folders) folder.path],
    lastCheck: row.destination.lastCheck == null
        ? null
        : ConnectionCheck.fromJson(jsonDecode(row.destination.lastCheck!)),
    createdAt: row.destination.createdAt,
    updatedAt: row.destination.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'workspace': workspace,
    'name': name,
    'type': type.name,
    'settings': settings,
    'folders': folders,
    'last_check': lastCheck,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}
