import 'package:material_ui/material_ui.dart';

/// Tokens of the dumpling design (dark only for now)
class AppColors {
  static final AppColors _instance = AppColors._internal();

  AppColors._internal();

  factory AppColors() => _instance;

  final SurfaceColor surface = const SurfaceColor();
  final BrandColor brand = const BrandColor();
  final TextColor text = const TextColor();
  final StatusColor status = const StatusColor();
}

class SurfaceColor {
  const SurfaceColor();

  /// Canvas and page background: 121019
  Color get background => const Color(0xFF121019);

  /// Rail, header, nodes: 17151f
  Color get surface1 => const Color(0xFF17151F);

  /// Inspector and popovers: 1d1a28
  Color get surface2 => const Color(0xFF1D1A28);

  /// Controls (secondary buttons, segmented tracks, chips): 2c2939
  Color get control => const Color(0xFF2C2939);

  /// Borders: 4f4c5c
  Color get border => const Color(0xFF4F4C5C);

  /// Unselected wires and ports: 6a6778
  Color get wire => const Color(0xFF6A6778);
}

class BrandColor {
  const BrandColor();

  /// Selection, links, section titles: 9d8fd0
  Color get primary => const Color(0xFF9D8FD0);

  /// Fill of primary buttons and switches: 5b4a9a
  Color get primaryAction => const Color(0xFF5B4A9A);

  /// Fill of the active item (rail, segments): 3b2f63
  Color get primarySelected => const Color(0xFF3B2F63);

  /// Darker violet of the logo's arrow: 6d5bb5
  Color get primaryDeep => const Color(0xFF6D5BB5);

  /// Amber accent: free ports, drop targets, hints: e6b77e
  Color get accent => const Color(0xFFE6B77E);

  /// Postgres blue: 8aa8ff
  Color get postgres => const Color(0xFF8AA8FF);
}

class TextColor {
  const TextColor();

  Color get primary => const Color(0xFFFFFFFF);

  Color get secondary => const Color(0xFFE5E5E5);

  Color get muted => const Color(0xFFB0AEB8);

  /// Labels and meta: 5.3:1 over surface1
  Color get subtle => const Color(0xFF8C8A98);
}

class StatusColor {
  const StatusColor();

  Color get success => const Color(0xFF34B257);

  Color get error => const Color(0xFFEC6A66);

  Color get pending => const Color(0xFF8C8A98);
}
