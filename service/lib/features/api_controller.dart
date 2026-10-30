import 'package:service/dumpling.dart';

/// The API of the console, under `/api`. Everything but the login needs a
/// token with the permission of the endpoint (see [Permissions]).
class ApiController {
  final AuthController authController;
  final WorkspaceController workspaceController;
  final SourceController sourceController;
  final DestinationController destinationController;
  final ConfigController configController;
  final RunController runController;
  final CanvasController canvasController;

  ApiController()
    : authController = AuthController(),
      workspaceController = WorkspaceController(),
      sourceController = SourceController(),
      destinationController = DestinationController(),
      configController = ConfigController(),
      runController = RunController(),
      canvasController = CanvasController();

  Route get routing => Route.parent(
    path: '/api',
    filterConfig: [JwtFilter()].toFilterConfig(),
    routes: [
      Route.post(
        key: 'auth.login',
        path: '/auth/login',
        handler: authController.login,
      ),
      Route.get(
        key: 'auth.session',
        path: '/auth/session',
        handler: authController.session,
        filterConfig: _permission(Permissions.authSession),
      ),
      Route.get(
        key: 'workspace.list',
        path: '/workspaces',
        handler: workspaceController.list,
        filterConfig: _permission(Permissions.workspaceList),
      ),
      Route.post(
        key: 'workspace.create',
        path: '/workspaces',
        handler: workspaceController.create,
        filterConfig: _permission(Permissions.workspaceCreate),
      ),
      Route.get(
        key: 'workspace.get',
        path: '/workspaces/{slug}',
        handler: workspaceController.get,
        filterConfig: _permission(Permissions.workspaceGet),
      ),
      Route.put(
        key: 'workspace.update',
        path: '/workspaces/{slug}',
        handler: workspaceController.update,
        filterConfig: _permission(Permissions.workspaceUpdate),
      ),
      Route.delete(
        key: 'workspace.delete',
        path: '/workspaces/{slug}',
        handler: workspaceController.delete,
        filterConfig: _permission(Permissions.workspaceDelete),
      ),
      Route.get(
        key: 'source.types',
        path: '/source-types',
        handler: sourceController.types,
        filterConfig: _permission(Permissions.sourceList),
      ),
      Route.get(
        key: 'source.list',
        path: '/workspaces/{slug}/sources',
        handler: sourceController.list,
        filterConfig: _permission(Permissions.sourceList),
      ),
      Route.post(
        key: 'source.create',
        path: '/workspaces/{slug}/sources',
        handler: sourceController.create,
        filterConfig: _permission(Permissions.sourceCreate),
      ),
      Route.post(
        key: 'source.test-unsaved',
        path: '/workspaces/{slug}/sources/test',
        handler: sourceController.testUnsaved,
        filterConfig: _permission(Permissions.sourceTest),
      ),
      Route.get(
        key: 'source.get',
        path: '/workspaces/{slug}/sources/{id}',
        handler: sourceController.get,
        filterConfig: _permission(Permissions.sourceGet),
      ),
      Route.put(
        key: 'source.update',
        path: '/workspaces/{slug}/sources/{id}',
        handler: sourceController.update,
        filterConfig: _permission(Permissions.sourceUpdate),
      ),
      Route.delete(
        key: 'source.delete',
        path: '/workspaces/{slug}/sources/{id}',
        handler: sourceController.delete,
        filterConfig: _permission(Permissions.sourceDelete),
      ),
      Route.post(
        key: 'source.test',
        path: '/workspaces/{slug}/sources/{id}/test',
        handler: sourceController.testSaved,
        filterConfig: _permission(Permissions.sourceTest),
      ),
      Route.get(
        key: 'destination.types',
        path: '/destination-types',
        handler: destinationController.types,
        filterConfig: _permission(Permissions.destinationList),
      ),
      Route.get(
        key: 'destination.list',
        path: '/workspaces/{slug}/destinations',
        handler: destinationController.list,
        filterConfig: _permission(Permissions.destinationList),
      ),
      Route.post(
        key: 'destination.create',
        path: '/workspaces/{slug}/destinations',
        handler: destinationController.create,
        filterConfig: _permission(Permissions.destinationCreate),
      ),
      Route.post(
        key: 'destination.test-unsaved',
        path: '/workspaces/{slug}/destinations/test',
        handler: destinationController.testUnsaved,
        filterConfig: _permission(Permissions.destinationTest),
      ),
      Route.get(
        key: 'destination.get',
        path: '/workspaces/{slug}/destinations/{id}',
        handler: destinationController.get,
        filterConfig: _permission(Permissions.destinationGet),
      ),
      Route.put(
        key: 'destination.update',
        path: '/workspaces/{slug}/destinations/{id}',
        handler: destinationController.update,
        filterConfig: _permission(Permissions.destinationUpdate),
      ),
      Route.delete(
        key: 'destination.delete',
        path: '/workspaces/{slug}/destinations/{id}',
        handler: destinationController.delete,
        filterConfig: _permission(Permissions.destinationDelete),
      ),
      Route.post(
        key: 'destination.test',
        path: '/workspaces/{slug}/destinations/{id}/test',
        handler: destinationController.testSaved,
        filterConfig: _permission(Permissions.destinationTest),
      ),
      Route.get(
        key: 'config.list',
        path: '/workspaces/{slug}/configs',
        handler: configController.list,
        filterConfig: _permission(Permissions.configList),
      ),
      Route.post(
        key: 'config.create',
        path: '/workspaces/{slug}/configs',
        handler: configController.create,
        filterConfig: _permission(Permissions.configCreate),
      ),
      Route.get(
        key: 'config.get',
        path: '/workspaces/{slug}/configs/{id}',
        handler: configController.get,
        filterConfig: _permission(Permissions.configGet),
      ),
      Route.put(
        key: 'config.update',
        path: '/workspaces/{slug}/configs/{id}',
        handler: configController.update,
        filterConfig: _permission(Permissions.configUpdate),
      ),
      Route.delete(
        key: 'config.delete',
        path: '/workspaces/{slug}/configs/{id}',
        handler: configController.delete,
        filterConfig: _permission(Permissions.configDelete),
      ),
      Route.post(
        key: 'config.run',
        path: '/workspaces/{slug}/configs/{id}/run',
        handler: runController.runNow,
        filterConfig: _permission(Permissions.configRun),
      ),
      Route.get(
        key: 'run.list',
        path: '/workspaces/{slug}/runs',
        handler: runController.list,
        filterConfig: _permission(Permissions.runList),
      ),
      Route.get(
        key: 'run.get',
        path: '/workspaces/{slug}/runs/{id}',
        handler: runController.get,
        filterConfig: _permission(Permissions.runGet),
      ),
      Route.get(
        key: 'canvas.get',
        path: '/workspaces/{slug}/canvas',
        handler: canvasController.get,
        filterConfig: _permission(Permissions.canvasGet),
      ),
      Route.put(
        key: 'canvas.save',
        path: '/workspaces/{slug}/canvas',
        handler: canvasController.save,
        filterConfig: _permission(Permissions.canvasSave),
      ),
    ],
  );

  static FilterConfig _permission(String permission) =>
      FilterConfig([AuthFilter(rules: hasPermission(permission))]);
}
