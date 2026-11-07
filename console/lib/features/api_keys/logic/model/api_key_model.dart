import 'package:console/app_exporter.dart';

/// What a key may do, by the template its permissions match
enum ApiKeyAccess {
  run,
  read,
  full,
  custom;

  /// The template [permissions] are, or [custom]
  static ApiKeyAccess of(Iterable<String> permissions) {
    final set = permissions.toSet();
    for (final access in [run, read, full]) {
      final template = ApiKeyPermissions.templates[access]!;
      if (set.length == template.length && set.containsAll(template)) {
        return access;
      }
    }
    return custom;
  }

  String get label => switch (this) {
    run => app.intl.apiKeys.run,
    read => app.intl.apiKeys.read,
    full => app.intl.apiKeys.full,
    custom => app.intl.apiKeys.custom,
  };
}

/// A permission a key can have, as the form shows it
class ApiKeyPermission {
  /// As the service names it: `config.run`
  final String key;

  /// The action word in its group: *Run*
  final String label;

  /// What it allows, for its tooltip
  final String description;

  const ApiKeyPermission(this.key, this.label, this.description);
}

/// The permissions a key can have (those of the routes of one workspace), by
/// resource, and the templates of the form
abstract final class ApiKeyPermissions {
  static const Map<ApiKeyAccess, List<String>> templates = {
    ApiKeyAccess.run: ['config.list', 'config.run', 'run.list', 'run.get'],
    ApiKeyAccess.read: [
      'workspace.get',
      'source.list',
      'source.get',
      'destination.list',
      'destination.get',
      'config.list',
      'config.get',
      'run.list',
      'run.get',
      'canvas.get',
    ],
    ApiKeyAccess.full: all,
  };

  static const List<String> all = [
    'workspace.get',
    'workspace.update',
    'source.list',
    'source.get',
    'source.create',
    'source.update',
    'source.delete',
    'source.test',
    'destination.list',
    'destination.get',
    'destination.create',
    'destination.update',
    'destination.delete',
    'destination.test',
    'config.list',
    'config.get',
    'config.create',
    'config.update',
    'config.delete',
    'config.run',
    'run.list',
    'run.get',
    'canvas.get',
    'canvas.save',
  ];

  /// The groups of the form: their title and their permissions
  static List<(String, List<ApiKeyPermission>)> get groups {
    final g = app.intl.apiKeys.group;
    final a = app.intl.apiKeys.action;
    final d = app.intl.apiKeys.perm;
    ApiKeyPermission p(String key, String label, String description) =>
        ApiKeyPermission(key, label, description);
    return [
      (
        g.workspace,
        [
          p('workspace.get', a.view, d.workspaceGet),
          p('workspace.update', a.edit, d.workspaceUpdate),
        ],
      ),
      (
        g.sources,
        [
          p('source.list', a.list, d.sourceList),
          p('source.get', a.view, d.sourceGet),
          p('source.create', a.create, d.sourceCreate),
          p('source.update', a.edit, d.sourceUpdate),
          p('source.delete', a.delete, d.sourceDelete),
          p('source.test', a.test, d.sourceTest),
        ],
      ),
      (
        g.destinations,
        [
          p('destination.list', a.list, d.destinationList),
          p('destination.get', a.view, d.destinationGet),
          p('destination.create', a.create, d.destinationCreate),
          p('destination.update', a.edit, d.destinationUpdate),
          p('destination.delete', a.delete, d.destinationDelete),
          p('destination.test', a.test, d.destinationTest),
        ],
      ),
      (
        g.configs,
        [
          p('config.list', a.list, d.configList),
          p('config.get', a.view, d.configGet),
          p('config.create', a.create, d.configCreate),
          p('config.update', a.edit, d.configUpdate),
          p('config.delete', a.delete, d.configDelete),
          p('config.run', a.run, d.configRun),
        ],
      ),
      (
        g.runs,
        [p('run.list', a.list, d.runList), p('run.get', a.view, d.runGet)],
      ),
      (
        g.canvas,
        [
          p('canvas.get', a.view, d.canvasGet),
          p('canvas.save', a.save, d.canvasSave),
        ],
      ),
    ];
  }

  /// What [key] allows, for a tooltip
  static String describe(String key) =>
      groups
          .expand((g) => g.$2)
          .where((p) => p.key == key)
          .firstOrNull
          ?.description ??
      key;
}

/// The last run a key started
class ApiKeyLastRun {
  final String configName;
  final String? label;

  const ApiKeyLastRun({required this.configName, this.label});
}

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

  ApiKeyAccess get access => ApiKeyAccess.of(permissions);

  bool get limited => configIds.isNotEmpty;

  /// Whether it can reach [configId]: limited to it, or to none
  bool reaches(String configId) => !limited || configIds.contains(configId);
}

/// What the form sends: the secret never changes
class ApiKeyDraft {
  final String name;
  final List<String> permissions;
  final List<String> configIds;

  const ApiKeyDraft({
    required this.name,
    required this.permissions,
    required this.configIds,
  });
}
