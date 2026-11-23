import 'dart:convert';

import 'package:service/dumpling.dart';

/// An API key as the API returns it: never its secret, except [key] once, on
/// create.
class ApiKeyModel {
  final String id;
  final String workspace;
  final String name;
  final List<String> permissions;

  /// The only configs it reaches; empty: all of the workspace.
  final List<String> configIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsedAt;

  /// The last run it started, if any.
  final ApiKeyLastRun? lastRun;

  /// Only on create: the whole key, shown once.
  final String? key;

  const ApiKeyModel({
    required this.id,
    required this.workspace,
    required this.name,
    required this.permissions,
    required this.configIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastUsedAt,
    this.lastRun,
    this.key,
  });

  factory ApiKeyModel.fromRow(
    ApiKeyTableData row, {
    RunTableData? lastRun,
    String? key,
  }) => ApiKeyModel(
    id: row.id,
    workspace: row.workspaceSlug,
    name: row.name,
    permissions: (jsonDecode(row.permissions) as List).cast<String>(),
    configIds: (jsonDecode(row.configIds) as List).cast<String>(),
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    lastUsedAt: row.lastUsedAt,
    lastRun: lastRun == null ? null : ApiKeyLastRun.fromRow(lastRun),
    key: key,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'workspace': workspace,
    'name': name,
    'permissions': permissions,
    'config_ids': configIds,
    'created_at': createdAt.toJsonDate(),
    'updated_at': updatedAt.toJsonDate(),
    'last_used_at': lastUsedAt?.toJsonDate(),
    'last_run': lastRun,
    if (key != null) 'key': key,
  };
}

/// The last run an API key started, as its list shows it.
class ApiKeyLastRun {
  final String id;
  final String configName;
  final String? label;
  final RunStatus status;
  final DateTime startedAt;

  const ApiKeyLastRun({
    required this.id,
    required this.configName,
    required this.status,
    required this.startedAt,
    this.label,
  });

  factory ApiKeyLastRun.fromRow(RunTableData row) => ApiKeyLastRun(
    id: row.id,
    configName: row.configName,
    label: row.label,
    status: row.status,
    startedAt: row.startedAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'config_name': configName,
    'label': label,
    'status': status.name,
    'started_at': startedAt.toJsonDate(),
  };
}
