import 'dart:convert';

import 'package:service/dumpling.dart';

class ApiKeyModel {
  final ApiKeyTableData row;

  /// The last run it started, if any.
  final RunTableData? lastRun;

  /// Only on create: the whole key, shown once.
  final String? key;

  ApiKeyModel(this.row, {this.lastRun, this.key});

  List<String> get permissions =>
      (jsonDecode(row.permissions) as List).cast<String>();

  List<String> get configIds =>
      (jsonDecode(row.configIds) as List).cast<String>();

  Map<String, Object?> toJson() => {
    'id': row.id,
    'workspace': row.workspaceSlug,
    'name': row.name,
    'permissions': permissions,
    'config_ids': configIds,
    'created_at': row.createdAt.toUtc().toIso8601String(),
    'updated_at': row.updatedAt.toUtc().toIso8601String(),
    'last_used_at': row.lastUsedAt?.toUtc().toIso8601String(),
    'last_run': lastRun == null
        ? null
        : {
            'id': lastRun!.id,
            'config_name': lastRun!.configName,
            'label': lastRun!.label,
            'status': lastRun!.status.name,
            'started_at': lastRun!.startedAt.toUtc().toIso8601String(),
          },
    if (key != null) 'key': key,
  };
}
