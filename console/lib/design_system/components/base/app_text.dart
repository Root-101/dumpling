import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class AppText {
  AppText._();

  static const String sans = 'DMSans';

  static const String monoFamily = 'JetBrainsMono';

  /// Cron expressions, paths and object keys
  static const TextStyle mono = TextStyle(fontFamily: monoFamily);

  /// Uppercase section labels (SOURCES, 01 SCHEDULE...)
  static TextStyle get overline => app.styles.xs.copyWith(
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: app.colors.text.subtle,
  );

  static TextStyle get meta =>
      app.styles.xs.copyWith(height: 15 / 11, color: app.colors.text.subtle);

  static final TextStyle nodeTitle = app.styles.l.copyWith(
    height: 19 / 14,
    fontWeight: FontWeight.w600,
  );
}
