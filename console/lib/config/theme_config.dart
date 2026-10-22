import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class ThemeConfig {
  ThemeConfig._();

  static ThemeData get theme {
    final colors = app.colors;
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppText.sans,
      scaffoldBackgroundColor: colors.surface.background,
      colorScheme: ColorScheme.dark(
        primary: colors.brand.primary,
        secondary: colors.brand.accent,
        surface: colors.surface.surface1,
        error: colors.status.error,
      ),
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
