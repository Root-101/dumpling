import 'package:console/app_exporter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class RouteConfig {
  RouteConfig._();

  static final GoRouter router = GoRouter(
    initialLocation: WorkspacesScreen.navigator.path,
    navigatorKey: navigatorKey,
    refreshListenable: GoRouterRefreshStream(app.di.find<AuthCubit>().stream),
    redirect: (context, state) {
      final auth = app.di.find<AuthCubit>();
      final isLoggingIn = state.matchedLocation == LoginScreen.navigator.path;

      if (auth.auth == null) {
        if (isLoggingIn) return null;
        // Remember where the user was going, to open it after logging in
        return Uri(
          path: LoginScreen.navigator.path,
          queryParameters: {RouteNames.loginFromParam: state.uri.toString()},
        ).toString();
      }

      if (isLoggingIn) {
        return afterLogin(state.uri.queryParameters[RouteNames.loginFromParam]);
      }

      return null;
    },
    errorBuilder: (context, state) => ErrorPage(
      title: app.intl.errors.notFoundTitle,
      message: app.intl.errors.pageNotFound,
      buttonText: app.intl.nav.workspaces,
      onRetry: () => app.navigator.go(RouteNames.workspaces),
    ),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => WorkspacesScreen.navigator.path,
      ),
      GoRoute(
        name: LoginScreen.navigator.name,
        path: LoginScreen.navigator.path,
        builder: LoginScreen.navigator.builder,
      ),
      ShellRoute(
        builder: (context, state, child) =>
            BaseScreen(state: state, child: child),
        routes: [
          ///   /workspaces
          GoRoute(
            name: WorkspacesScreen.navigator.name,
            path: WorkspacesScreen.navigator.path,
            builder: WorkspacesScreen.navigator.builder,
          ),

          ///   /workspaces/{slug}: its backups. Beside the list, not under
          /// it: as a child, opening a section from its URL would also build
          /// the list below it, never laid out
          GoRoute(
            path: '${WorkspacesScreen.navigator.path}/:${RouteNames.slugParam}',
            redirect: (context, state) =>
                state.fullPath == '/workspaces/:${RouteNames.slugParam}'
                ? '${state.matchedLocation}/${RouteNames.backups}'
                : null,
            routes: [
              ..._withItem(
                name: SourcesScreen.navigator.name,
                path: SourcesScreen.navigator.path,
                itemName: RouteNames.source,
                builder: SourcesScreen.navigator.builder,
              ),
              ..._withItem(
                name: DestinationsScreen.navigator.name,
                path: DestinationsScreen.navigator.path,
                itemName: RouteNames.destination,
                builder: DestinationsScreen.navigator.builder,
              ),
              GoRoute(
                name: CanvasScreen.navigator.name,
                path: CanvasScreen.navigator.path,
                builder: CanvasScreen.navigator.builder,
                onExit: (context, state) => CanvasScreen.confirmLeave(),
              ),
              ..._withItem(
                name: BackupsScreen.navigator.name,
                path: BackupsScreen.navigator.path,
                itemName: RouteNames.backupRun,
                itemPath: RouteNames.runs,
                builder: BackupsScreen.navigator.builder,
              ),
              ..._withItem(
                name: RunsScreen.navigator.name,
                path: RunsScreen.navigator.path,
                itemName: RouteNames.run,
                builder: RunsScreen.navigator.builder,
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// [name] at [path] and [itemName] at `[path]/[itemPath]/:id` share one
  /// page: an id keeps the screen as it is and opens its dialog over it
  static List<GoRoute> _withItem({
    required String name,
    required String path,
    required String itemName,
    required GoRouterWidgetBuilder builder,
    String? itemPath,
  }) {
    Page<void> page(BuildContext context, GoRouterState state) =>
        MaterialPage(key: ValueKey(path), child: builder(context, state));
    return [
      GoRoute(name: name, path: path, pageBuilder: page),
      GoRoute(
        name: itemName,
        path: [path, ?itemPath, ':${RouteNames.idParam}'].join('/'),
        pageBuilder: page,
      ),
    ];
  }

  /// The location saved in `?from=` if it is one of ours (a path, not the login
  /// itself); otherwise the workspaces
  static String afterLogin(String? from) {
    final uri = from == null ? null : Uri.tryParse(from);
    final valid =
        uri != null &&
        !uri.hasScheme &&
        !uri.hasAuthority &&
        uri.path.startsWith('/') &&
        uri.path != LoginScreen.navigator.path;
    return valid ? from! : WorkspacesScreen.navigator.path;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) => notifyListeners());
  }
}
