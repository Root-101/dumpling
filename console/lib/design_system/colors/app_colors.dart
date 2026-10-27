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

  /// The groups of feather-io's design system, with the colors of dumpling:
  /// the components that come from there use them
  final PrimaryColor primary = const PrimaryColor();
  final NeutralColor neutral = const NeutralColor();
  final PaletteColor palette = const PaletteColor();
}

/// Colors the user can pick (a workspace's color). All of them exceed 5:1
/// with a white initial on top
class PaletteColor {
  const PaletteColor();

  Color get violet => const Color(0xFF5B4A9A);

  Color get blue => const Color(0xFF2652E0);

  Color get teal => const Color(0xFF0F766E);

  Color get green => const Color(0xFF2E7D32);

  Color get amber => const Color(0xFFA15C00);

  Color get red => const Color(0xFFC62828);

  Color get pink => const Color(0xFFC0156E);

  Color get slate => const Color(0xFF475569);

  /// Wedges of the custom color circle, clockwise from the top
  List<Color> get wheel => const [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];
}

class PrimaryColor {
  const PrimaryColor();

  /// Fill of the active item (rail, segments): 3b2f63
  Color get purple => const Color(0xFF3B2F63);

  /// Fill of primary buttons: 5b4a9a
  Color get primaryAction => const Color(0xFF5B4A9A);

  /// Inputs and dialogs: 1d1a28
  Color get backgroundForm => const Color(0xFF1D1A28);

  /// Page background: 121019
  Color get background1 => const Color(0xFF121019);

  /// Rail, headers, cards and panels: 17151f
  Color get background2 => const Color(0xFF17151F);

  /// Secondary buttons and the border of panels: 2f2c3f
  Color get background3 => const Color(0xFF2F2C3F);

  /// Selection, links and focus: 9d8fd0
  Color get primaryFaded => const Color(0xFF9D8FD0);

  /// Text over `primaryFaded` at 20%, and links on hover: c3b8ea
  Color get primaryLight => const Color(0xFFC3B8EA);

  /// Keyboard focus ring
  Color get focusRing => primaryFaded;

  /// Checked boxes and the border of what is selected
  Color get selection => primaryFaded;

  /// Amber accent: e6b77e
  Color get secondary => const Color(0xFFE6B77E);

  /// Error text, icons and borders over dark backgrounds: e95450
  Color get error => const Color(0xFFE95450);

  /// Fill of destructive actions and of the error snackbar
  Color get errorAction => const Color(0xFFC62828);

  /// Success text and icons: 34b257
  Color get green => const Color(0xFF34B257);

  /// Fill of the success snackbar
  Color get greenAction => const Color(0xFF2E7D32);
}

class NeutralColor {
  const NeutralColor();

  /// Borders: 4f4c5c
  Color get grey5 => const Color(0xFF4F4C5C);

  /// Labels, meta and disabled text: 8c8a98
  Color get grey4 => const Color(0xFF8C8A98);

  /// Icons and the border of inputs: b0aeb8
  Color get grey3 => const Color(0xFFB0AEB8);

  Color get grey2 => const Color(0xFFE5E5E5);

  Color get grey1 => const Color(0xFFF7F7F7);

  Color get white => const Color(0xFFFFFFFF);

  Color get black => const Color(0xFF000000);

  Color get transparent => Colors.transparent;
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

  /// Brand copy, lilac tinted (login's tagline and tags): d9d2f2
  Color get brand => const Color(0xFFD9D2F2);
}

class StatusColor {
  const StatusColor();

  Color get success => const Color(0xFF34B257);

  Color get error => const Color(0xFFEC6A66);

  Color get pending => const Color(0xFF8C8A98);

  /// Works, but needs a look (a server newer than its dump tool)
  Color get warning => const Color(0xFFFDCA3C);

  /// In progress (running, testing)
  Color get running => const Color(0xFFB4A8E6);
}
