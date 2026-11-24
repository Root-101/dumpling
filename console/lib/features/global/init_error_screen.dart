import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// In place of the splash when the console could not start (`Init` failed):
/// what happened and «Try again», which runs the start again
class InitErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const InitErrorScreen({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      localizationsDelegates: AppIntl.delegates,
      supportedLocales: AppIntl.supportedLocales,
      builder: (context, child) => Scaffold(
        backgroundColor: colors.surface.background,
        body: CustomPaint(
          painter: GridLinePainter(
            color: colors.brand.primary.withValues(alpha: 0.05),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DumplingLogo(height: 72),
                  24.gap(),
                  Text(
                    app.intl.app.initErrorTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  10.gap(),
                  Text(
                    app.intl.app.initErrorHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: colors.neutral.grey3),
                  ),
                  28.gap(),
                  PrimaryButton.primary(
                    title: app.intl.common.tryAgain,
                    onPressed: onRetry,
                    color: colors.primary.primaryAction,
                    h: 42,
                    horizontalPadding: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
