import 'dart:convert';

import 'package:service/dumpling.dart';

class SourceModel {
  final String id;
  final String workspace;
  final String name;
  final SourceType type;

  /// The connection data without its secrets.
  final Map<String, Object?> settings;

  /// The last connection test, null until the first one.
  final ConnectionCheck? lastCheck;
  final DateTime createdAt;
  final DateTime updatedAt;

  SourceModel({
    required this.id,
    required this.workspace,
    required this.name,
    required this.type,
    required this.settings,
    this.lastCheck,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SourceModel.fromRow(SourceTableData row) => SourceModel(
    id: row.id,
    workspace: row.workspaceSlug,
    name: row.name,
    type: row.type,
    settings: jsonDecode(row.settings) as Map<String, Object?>,
    lastCheck: row.lastCheck == null
        ? null
        : ConnectionCheck.fromJson(jsonDecode(row.lastCheck!)),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'workspace': workspace,
    'name': name,
    'type': type.name,
    'settings': settings,
    'last_check': lastCheck,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}
