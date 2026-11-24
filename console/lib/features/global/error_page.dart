import 'package:console/app_exporter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class ErrorPage extends StatelessWidget {
  /// Big, above [message]; null: [message] is the title
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? buttonText;

  final Color? backgroundColor;

  const ErrorPage({
    this.title,
    this.message,
    this.onRetry,
    this.buttonText,
    this.backgroundColor,
    super.key,
  });

  /// What a screen shows when it can't load: *Not found* takes back to the
  /// workspaces, *Connection lost* tries [onRetry] again; any other error,
  /// its message
  static Widget of(GlobalException exception, {VoidCallback? onRetry}) =>
      switch (exception.type) {
        GlobalExceptionType.notFound => const NotFoundPage(),
        GlobalExceptionType.offline => ErrorPage(
          title: app.intl.errors.offlineTitle,
          message: app.intl.errors.offline(url: Environment.serviceUrl),
          onRetry: () {
            // the rail lost its workspaces too when the service went away
            final workspaces = app.di.find<WorkspaceCubit>();
            if (!workspaces.state.data.loaded) workspaces.load();
            onRetry?.call();
          },
        ),
        _ => ErrorPage(message: exception.message, onRetry: onRetry),
      };

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: app.dimensions.padding.xxl,
                ),
                child: Text(
                  title ?? message ?? app.intl.common.error,
                  style: app.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              if (title != null && message != null) ...[
                app.dimensions.padding.m.gap(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    message!,
                    style: app.textTheme.bodyMedium?.copyWith(
                      color: app.colors.neutral.grey3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (onRetry != null) ...[
                (2 * app.dimensions.padding.xxl).gap(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2 * app.dimensions.padding.xxl,
                  ),
                  child: PrimaryButton.primary(
                    title: buttonText ?? app.intl.common.tryAgain,
                    onPressed: onRetry ?? () {},
                    w: 260,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A URL with nothing behind it: *404*, what may have happened, the path
/// asked for, and the way back (the Backups of the open workspace, or the
/// workspaces)
class NotFoundPage extends StatelessWidget {
  /// The URL asked for; null: the one the router shows
  final String? path;

  const NotFoundPage({this.path, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final t = app.intl.errors;
    final workspaces = app.di.find<WorkspaceCubit>().state.data;
    final slug = workspaces.currentSlug;
    final known = workspaces.workspaces.any((w) => w.slug == slug);
    final path =
        this.path ??
        GoRouter.maybeOf(context)?.routerDelegate.currentConfiguration.uri.path;
    return Scaffold(
      backgroundColor: colors.neutral.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '404',
                  style: AppText.mono.copyWith(
                    fontSize: 72,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    color: colors.primary.primaryAction.withValues(alpha: 0.6),
                  ),
                ),
                16.gap(),
                Text(
                  t.pageMissing,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                10.gap(),
                Text(
                  t.pageMissingHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: colors.neutral.grey3),
                ),
                if (path != null) ...[
                  14.gap(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.neutral.grey5),
                    ),
                    child: SelectableText(
                      path,
                      style: AppText.mono.copyWith(
                        fontSize: 12,
                        color: colors.neutral.grey3,
                      ),
                    ),
                  ),
                ],
                20.gap(),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    if (known && slug != null)
                      PrimaryButton.primary(
                        title: t.goToBackups,
                        onPressed: () => RouteNames.openWorkspace(slug),
                        color: colors.primary.primaryAction,
                        h: 42,
                        horizontalPadding: 18,
                      ),
                    PrimaryButton.primary(
                      title: known
                          ? t.switchWorkspace
                          : app.intl.nav.workspaces,
                      onPressed: () => app.navigator.go(RouteNames.workspaces),
                      color: known
                          ? colors.surface.control
                          : colors.primary.primaryAction,
                      h: 42,
                      horizontalPadding: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
