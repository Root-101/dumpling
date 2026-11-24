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
    errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => WorkspacesScreen.navigator.path,
      ),
      ...LoginScreen.navigator.routes(),
      ShellRoute(
        builder: (context, state, child) =>
            BaseScreen(state: state, child: child),
        routes: [
          ///   /workspaces
          ...WorkspacesScreen.navigator.routes(),

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
              ...SourcesScreen.navigator.routes(),
              ...DestinationsScreen.navigator.routes(),
              ...CanvasScreen.navigator.routes(),
              ...BackupsScreen.navigator.routes(),
              ...RunsScreen.navigator.routes(),
              ...ApiKeysScreen.navigator.routes(),
            ],
          ),
        ],
      ),
    ],
  )..routerDelegate.addListener(_closeDialogsOfOtherScreen);

  /// The screen of the last URL (`/workspaces/production/sources`)
  static String? _screen;

  /// Another screen took the URL (the address bar, the browser's back): what
  /// was open over the last one closes with it. Not *Your session expired*,
  /// which only a new login closes
  static void _closeDialogsOfOtherScreen() {
    final uri = router.routerDelegate.currentConfiguration.uri;
    final screen = uri.pathSegments.take(3).join('/');
    final changed = _screen != null && _screen != screen;
    _screen = screen;
    if (!changed) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => navigatorKey.currentState?.popUntil(
        (route) =>
            route is! PopupRoute ||
            route.settings.name == SessionExpiredDialog.routeName,
      ),
    );
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
