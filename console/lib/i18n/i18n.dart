import 'package:console/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

export 'package:console/i18n/strings.g.dart' show AppLocale, AppTexts;

/// The texts of the console in the current language, without a
/// `BuildContext` (so they work in the splash, the small-screen page and
/// before the router). `LanguageCubit` changes [current]; the rest reads
/// `app.intl`.
class AppIntl {
  AppIntl._();

  /// One instance per language, built once
  static final Map<AppLocale, AppTexts> _cache = {
    for (final locale in AppLocale.values) locale: locale.buildSync(),
  };

  static AppLocale current = AppLocale.en;

  static AppTexts get texts => _cache[current]!;

  /// The language of [languageCode] (`es-MX` → `es`); an unknown one is the
  /// base one (`en`)
  static AppLocale resolve(String? languageCode) => AppLocale.values.firstWhere(
    (locale) => locale.languageCode == languageCode,
    orElse: () => AppLocale.en,
  );

  static List<Locale> get supportedLocales =>
      AppLocale.values.map((locale) => Locale(locale.languageCode)).toList();

  /// The Material texts that `material_ui` widgets read; every MaterialApp of
  /// the console uses them (app, splash, small screen)
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    ...GlobalMaterialLocalizations.delegates,
  ];
}
