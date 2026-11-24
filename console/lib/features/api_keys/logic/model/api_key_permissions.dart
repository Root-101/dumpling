import 'package:console/app_exporter.dart';

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

  /// What a key limited to some configs sees only for them: without one of
  /// these the limit changes nothing, as the service says
  static const List<String> limitable = [
    'config.list',
    'config.get',
    'config.update',
    'config.delete',
    'config.run',
    'run.list',
    'run.get',
  ];

  /// What a key limited to some configs can't have: the canvas reaches every
  /// config, and one it created would be out of its reach
  static const List<String> notLimitable = [
    'config.create',
    'canvas.get',
    'canvas.save',
  ];

  /// The permissions of [access], without [notLimitable] when [limited]
  static List<String> of(ApiKeyAccess access, {bool limited = false}) => [
    for (final p in templates[access]!)
      if (!limited || !notLimitable.contains(p)) p,
  ];

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
