import 'package:console/app_exporter.dart';

/// A key of the workspace. Its text is only known when it is created
class ApiKeyModel {
  final String id;
  final String name;
  final List<String> permissions;

  /// Empty: every config of the workspace
  final List<String> configIds;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final ApiKeyLastRun? lastRun;

  /// Only right after creating it: `dmp_…`
  final String? key;

  const ApiKeyModel({
    required this.id,
    required this.name,
    required this.permissions,
    required this.configIds,
    required this.createdAt,
    this.lastUsedAt,
    this.lastRun,
    this.key,
  });

  ApiKeyAccess get access => ApiKeyAccess.of(permissions, limited: limited);

  bool get limited => configIds.isNotEmpty;

  /// Whether it can reach [configId]: limited to it, or to none
  bool reaches(String configId) => !limited || configIds.contains(configId);
}
