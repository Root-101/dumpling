import 'package:service/dumpling.dart';

/// The API of the console, under `/api`. Everything but the login and the
/// health check needs a token with the permission of the endpoint (see
/// [Permissions]): the admin's, or an API key's, which only reaches the
/// routes of its own workspace.
class ApiController {
  final AuthController authController;
  final WorkspaceController workspaceController;
  final SourceController sourceController;
  final DestinationController destinationController;
  final ConfigController configController;
  final RunController runController;
  final CanvasController canvasController;
  final TransferController transferController;
  final ApiKeyController apiKeyController;

  ApiController()
    : authController = di.find(),
      workspaceController = di.find(),
      sourceController = di.find(),
      destinationController = di.find(),
      configController = di.find(),
      runController = di.find(),
      canvasController = di.find(),
      transferController = di.find(),
      apiKeyController = di.find();

  Route get routing => Route.parent(
    path: '/api',
    filterConfig: [JwtFilter(), ApiKeyFilter()].toFilterConfig(),
    routes: [
      // For load balancers and container checks: no token, only whether the
      // service and its database answer (application/health+json)
      Route.health(
        key: 'health',
        checks: {'database': () => di.find<AppDatabase>().ping()},
      ),
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
        path: '/workspaces/{workspace}',
        handler: workspaceController.get,
        filterConfig: _permission(Permissions.workspaceGet),
      ),
      Route.put(
        key: 'workspace.update',
        path: '/workspaces/{workspace}',
        handler: workspaceController.update,
        filterConfig: _permission(Permissions.workspaceUpdate),
      ),
      Route.delete(
        key: 'workspace.delete',
        path: '/workspaces/{workspace}',
        handler: workspaceController.delete,
        filterConfig: _permission(Permissions.workspaceDelete),
      ),
      Route.get(
        key: 'workspace.export',
        path: '/export',
        handler: transferController.export,
        filterConfig: _permission(Permissions.workspaceExport),
      ),
      Route.post(
        key: 'workspace.import',
        path: '/import',
        handler: transferController.import,
        filterConfig: _permission(Permissions.workspaceImport),
      ),
      Route.get(
        key: 'source.types',
        path: '/source-types',
        handler: sourceController.types,
        filterConfig: _permission(Permissions.sourceList),
      ),
      Route.get(
        key: 'source.list',
        path: '/workspaces/{workspace}/sources',
        handler: sourceController.list,
        filterConfig: _permission(Permissions.sourceList),
      ),
      Route.post(
        key: 'source.create',
        path: '/workspaces/{workspace}/sources',
        handler: sourceController.create,
        filterConfig: _permission(Permissions.sourceCreate),
      ),
      Route.post(
        key: 'source.test-unsaved',
        path: '/workspaces/{workspace}/sources/test',
        handler: sourceController.testUnsaved,
        filterConfig: _permission(Permissions.sourceTest),
      ),
      Route.put(
        key: 'source.reorder',
        path: '/workspaces/{workspace}/sources/order',
        handler: sourceController.reorder,
        filterConfig: _permission(Permissions.sourceUpdate),
      ),
      Route.get(
        key: 'source.get',
        path: '/workspaces/{workspace}/sources/{source}',
        handler: sourceController.get,
        filterConfig: _permission(Permissions.sourceGet),
      ),
      Route.put(
        key: 'source.update',
        path: '/workspaces/{workspace}/sources/{source}',
        handler: sourceController.update,
        filterConfig: _permission(Permissions.sourceUpdate),
      ),
      Route.delete(
        key: 'source.delete',
        path: '/workspaces/{workspace}/sources/{source}',
        handler: sourceController.delete,
        filterConfig: _permission(Permissions.sourceDelete),
      ),
      Route.post(
        key: 'source.test',
        path: '/workspaces/{workspace}/sources/{source}/test',
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
        path: '/workspaces/{workspace}/destinations',
        handler: destinationController.list,
        filterConfig: _permission(Permissions.destinationList),
      ),
      Route.post(
        key: 'destination.create',
        path: '/workspaces/{workspace}/destinations',
        handler: destinationController.create,
        filterConfig: _permission(Permissions.destinationCreate),
      ),
      Route.post(
        key: 'destination.test-unsaved',
        path: '/workspaces/{workspace}/destinations/test',
        handler: destinationController.testUnsaved,
        filterConfig: _permission(Permissions.destinationTest),
      ),
      Route.put(
        key: 'destination.reorder',
        path: '/workspaces/{workspace}/destinations/order',
        handler: destinationController.reorder,
        filterConfig: _permission(Permissions.destinationUpdate),
      ),
      Route.get(
        key: 'destination.get',
        path: '/workspaces/{workspace}/destinations/{destination}',
        handler: destinationController.get,
        filterConfig: _permission(Permissions.destinationGet),
      ),
      Route.put(
        key: 'destination.update',
        path: '/workspaces/{workspace}/destinations/{destination}',
        handler: destinationController.update,
        filterConfig: _permission(Permissions.destinationUpdate),
      ),
      Route.delete(
        key: 'destination.delete',
        path: '/workspaces/{workspace}/destinations/{destination}',
        handler: destinationController.delete,
        filterConfig: _permission(Permissions.destinationDelete),
      ),
      Route.post(
        key: 'destination.test',
        path: '/workspaces/{workspace}/destinations/{destination}/test',
        handler: destinationController.testSaved,
        filterConfig: _permission(Permissions.destinationTest),
      ),
      Route.get(
        key: 'config.list',
        path: '/workspaces/{workspace}/configs',
        handler: configController.list,
        filterConfig: _permission(Permissions.configList),
      ),
      Route.post(
        key: 'config.create',
        path: '/workspaces/{workspace}/configs',
        handler: configController.create,
        filterConfig: _permission(Permissions.configCreate),
      ),
      Route.put(
        key: 'config.reorder',
        path: '/workspaces/{workspace}/configs/order',
        handler: configController.reorder,
        filterConfig: _permission(Permissions.configUpdate),
      ),
      Route.get(
        key: 'config.get',
        path: '/workspaces/{workspace}/configs/{config}',
        handler: configController.get,
        filterConfig: _permission(Permissions.configGet),
      ),
      Route.put(
        key: 'config.update',
        path: '/workspaces/{workspace}/configs/{config}',
        handler: configController.update,
        filterConfig: _permission(Permissions.configUpdate),
      ),
      Route.delete(
        key: 'config.delete',
        path: '/workspaces/{workspace}/configs/{config}',
        handler: configController.delete,
        filterConfig: _permission(Permissions.configDelete),
      ),
      Route.post(
        key: 'config.run',
        path: '/workspaces/{workspace}/configs/{config}/run',
        handler: runController.runNow,
        filterConfig: _permission(Permissions.configRun),
      ),
      Route.get(
        key: 'run.list',
        path: '/workspaces/{workspace}/runs',
        handler: runController.list,
        filterConfig: _permission(Permissions.runList),
      ),
      Route.get(
        key: 'run.get',
        path: '/workspaces/{workspace}/runs/{run}',
        handler: runController.get,
        filterConfig: _permission(Permissions.runGet),
      ),
      Route.get(
        key: 'run.events',
        path: '/workspaces/{workspace}/runs/{run}/events',
        handler: runController.events,
        filterConfig: _permission(Permissions.runGet),
      ),
      Route.get(
        key: 'canvas.get',
        path: '/workspaces/{workspace}/canvas',
        handler: canvasController.get,
        filterConfig: _permission(Permissions.canvasGet),
      ),
      Route.put(
        key: 'canvas.save',
        path: '/workspaces/{workspace}/canvas',
        handler: canvasController.save,
        filterConfig: _permission(Permissions.canvasSave),
      ),
      Route.get(
        key: 'apikey.list',
        path: '/workspaces/{workspace}/keys',
        handler: apiKeyController.list,
        filterConfig: _permission(Permissions.apiKeyList),
      ),
      Route.post(
        key: 'apikey.create',
        path: '/workspaces/{workspace}/keys',
        handler: apiKeyController.create,
        filterConfig: _permission(Permissions.apiKeyCreate),
      ),
      Route.put(
        key: 'apikey.reorder',
        path: '/workspaces/{workspace}/keys/order',
        handler: apiKeyController.reorder,
        filterConfig: _permission(Permissions.apiKeyUpdate),
      ),
      Route.put(
        key: 'apikey.update',
        path: '/workspaces/{workspace}/keys/{key}',
        handler: apiKeyController.update,
        filterConfig: _permission(Permissions.apiKeyUpdate),
      ),
      Route.delete(
        key: 'apikey.delete',
        path: '/workspaces/{workspace}/keys/{key}',
        handler: apiKeyController.delete,
        filterConfig: _permission(Permissions.apiKeyDelete),
      ),
    ],
  );

  static FilterConfig _permission(String permission) => FilterConfig([
    AuthFilter(rule: hasPermission(permission) & _ownWorkspace),
  ]);

  /// An API key only reaches its own workspace (the routes without one, the
  /// types of sources and destinations, are the same for everybody).
  static final AuthorizationRule _ownWorkspace = rule((auth, request) {
    final principal = auth.principal;
    if (principal is! ApiKeyPrincipal) return true;
    final workspace = request.pathParams['workspace'];
    return workspace == null || workspace == principal.workspace;
  }, describe: 'ownWorkspace');
}
