import 'package:console/app_exporter.dart';
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
  factory ErrorPage.of(GlobalException exception, {VoidCallback? onRetry}) =>
      switch (exception.type) {
        GlobalExceptionType.notFound => ErrorPage(
          title: app.intl.errors.notFoundTitle,
          message: exception.message,
          buttonText: app.intl.nav.workspaces,
          onRetry: () => app.navigator.go(RouteNames.workspaces),
        ),
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
