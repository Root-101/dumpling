import 'package:material_ui/material_ui.dart';

/// The sizes of text of the design; weight and color go on top
/// (`app.styles.m.copyWith(fontWeight: FontWeight.w600)`)
class AppTextStyles {
  static final AppTextStyles _instance = AppTextStyles._internal();

  AppTextStyles._internal();

  factory AppTextStyles() => _instance;

  /// 10: the smallest badges
  final TextStyle xxs = const TextStyle(fontSize: 10);

  /// 11: captions, chips, column headers
  final TextStyle xs = const TextStyle(fontSize: 11);

  /// 12: secondary text, hints, table cells
  final TextStyle s = const TextStyle(fontSize: 12);

  /// 13: body text, inputs, buttons
  final TextStyle m = const TextStyle(fontSize: 13);

  /// 14: emphasized body text, dialog sections
  final TextStyle l = const TextStyle(fontSize: 14);

  /// 15: card titles
  final TextStyle ml = const TextStyle(fontSize: 15);

  /// 16: dialog titles
  final TextStyle xl = const TextStyle(fontSize: 16);

  /// 18: subtitles of a page
  final TextStyle h4 = const TextStyle(fontSize: 18);

  /// 20: big numbers of a summary
  final TextStyle h3 = const TextStyle(fontSize: 20);

  /// 22: page titles
  final TextStyle h2 = const TextStyle(fontSize: 22);

  /// 32: the login title
  final TextStyle h1 = const TextStyle(fontSize: 32);

  /// 72: the code of the error page
  final TextStyle display = const TextStyle(fontSize: 72);
}
