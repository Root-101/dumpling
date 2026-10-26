import 'package:console/app_exporter.dart';

class AppAssets {
  static final AppAssets _instance = AppAssets._internal();

  AppAssets._internal();

  factory AppAssets() => _instance;

  final AppIcons icons = const AppIcons();

  /// The mark with the name, from the design canvas
  final String wordmark = 'assets/brand/wordmark.svg';
}
