/// The permission of each endpoint, checked by its `AuthFilter`. The admin, the
/// only user for now, gets [all] in its token; users with fewer can come later.
abstract final class Permissions {
  static const String authSession = 'auth.session';

  static const String workspaceList = 'workspace.list';
  static const String workspaceGet = 'workspace.get';
  static const String workspaceCreate = 'workspace.create';
  static const String workspaceUpdate = 'workspace.update';
  static const String workspaceDelete = 'workspace.delete';

  static const String sourceList = 'source.list';
  static const String sourceGet = 'source.get';
  static const String sourceCreate = 'source.create';
  static const String sourceUpdate = 'source.update';
  static const String sourceDelete = 'source.delete';
  static const String sourceTest = 'source.test';

  static const String destinationList = 'destination.list';
  static const String destinationGet = 'destination.get';
  static const String destinationCreate = 'destination.create';
  static const String destinationUpdate = 'destination.update';
  static const String destinationDelete = 'destination.delete';
  static const String destinationTest = 'destination.test';

  static const String configList = 'config.list';
  static const String configGet = 'config.get';
  static const String configCreate = 'config.create';
  static const String configUpdate = 'config.update';
  static const String configDelete = 'config.delete';
  static const String configRun = 'config.run';

  static const String runList = 'run.list';
  static const String runGet = 'run.get';

  static const String canvasGet = 'canvas.get';
  static const String canvasSave = 'canvas.save';

  /// Every permission: add each new one here too.
  static const List<String> all = [
    authSession,
    workspaceList,
    workspaceGet,
    workspaceCreate,
    workspaceUpdate,
    workspaceDelete,
    sourceList,
    sourceGet,
    sourceCreate,
    sourceUpdate,
    sourceDelete,
    sourceTest,
    destinationList,
    destinationGet,
    destinationCreate,
    destinationUpdate,
    destinationDelete,
    destinationTest,
    configList,
    configGet,
    configCreate,
    configUpdate,
    configDelete,
    configRun,
    runList,
    runGet,
    canvasGet,
    canvasSave,
  ];
}
