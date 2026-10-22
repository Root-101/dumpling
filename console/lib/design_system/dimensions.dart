import 'package:material_ui/material_ui.dart';

class AppDimensions {
  static final AppDimensions _instance = AppDimensions._internal();

  AppDimensions._internal();

  factory AppDimensions() => _instance;

  final AppRadius radius = const AppRadius();
}

class AppRadius {
  const AppRadius();

  /// 6.0: key caps, folder rows
  BorderRadius get xs => BorderRadius.circular(6);

  /// 8.0: controls (buttons, inputs)
  BorderRadius get s => BorderRadius.circular(8);

  /// 10.0: floating panels and toolbars
  BorderRadius get m => BorderRadius.circular(10);

  /// 12.0: canvas nodes
  BorderRadius get l => BorderRadius.circular(12);
}
