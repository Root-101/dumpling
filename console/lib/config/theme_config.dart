import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class ThemeConfig {
  ThemeConfig._();

  /// Material widgets without their own style take the palette, not the
  /// Material 3 default colors
  static ThemeData get theme {
    final colors = app.colors;
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppText.sans,
      scaffoldBackgroundColor: colors.primary.background1,
      colorScheme: ColorScheme.dark(
        primary: colors.primary.primaryFaded,
        onPrimary: colors.primary.background1,
        secondary: colors.primary.secondary,
        onSecondary: colors.primary.background1,
        secondaryContainer: colors.primary.purple,
        onSecondaryContainer: colors.neutral.white,
        surface: colors.primary.background2,
        onSurface: colors.neutral.white,
        onSurfaceVariant: colors.neutral.grey3,
        error: colors.primary.error,
        onError: colors.primary.background1,
        outline: colors.neutral.grey5,
        outlineVariant: colors.neutral.grey5,
      ),
      focusColor: colors.primary.focusRing.withValues(alpha: 0.24),
      dividerTheme: DividerThemeData(color: colors.neutral.grey5),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: AppText.sans,
        bodyColor: colors.text.primary,
        displayColor: colors.text.primary,
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: colors.surface.control,
          borderRadius: app.dimensions.radius.xs,
        ),
        textStyle: TextStyle(
          fontFamily: AppText.sans,
          fontSize: 12,
          color: colors.text.secondary,
        ),
      ),
    );
  }
}
