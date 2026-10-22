import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Stroke icons of the design (24x24 viewBox), one class per folder of
/// `assets/icons/`
class AppIcons {
  const AppIcons();

  final ActionsIcons actions = const ActionsIcons();
  final NavigationIcons navigation = const NavigationIcons();
  final NodesIcons nodes = const NodesIcons();
}

/// Sections of the rail
class NavigationIcons {
  const NavigationIcons();

  static const String _navigation = 'assets/icons/navigation';

  SvgAsset get backups => const SvgAsset('$_navigation/backups.svg');

  SvgAsset get pipeline => const SvgAsset('$_navigation/pipeline.svg');

  SvgAsset get events => const SvgAsset('$_navigation/events.svg');

  SvgAsset get settings => const SvgAsset('$_navigation/settings.svg');
}

/// What the canvas shows: sources, configs, destinations and folders
class NodesIcons {
  const NodesIcons();

  static const String _nodes = 'assets/icons/nodes';

  SvgAsset get database => const SvgAsset('$_nodes/database.svg');

  SvgAsset get clock => const SvgAsset('$_nodes/clock.svg');

  SvgAsset get bucket => const SvgAsset('$_nodes/bucket.svg');

  SvgAsset get folder => const SvgAsset('$_nodes/folder.svg');
}

class ActionsIcons {
  const ActionsIcons();

  static const String _actions = 'assets/icons/actions';

  SvgAsset get add => const SvgAsset('$_actions/add.svg');

  SvgAsset get close => const SvgAsset('$_actions/close.svg');

  SvgAsset get delete => const SvgAsset('$_actions/delete.svg');

  SvgAsset get center => const SvgAsset('$_actions/center.svg');

  SvgAsset get keyboard => const SvgAsset('$_actions/keyboard.svg');

  SvgAsset get warning => const SvgAsset('$_actions/warning.svg');
}

class SvgAsset {
  final double defaultSvgSize = 24.0;

  final String url;
  final Color? defaultColor;
  final double? defaultSize;

  const SvgAsset(this.url, {this.defaultColor, this.defaultSize});

  Widget build({double? size, Color? color, BoxFit? fit}) => SvgPicture.asset(
    url,
    width: size ?? defaultSize ?? defaultSvgSize,
    height: size ?? defaultSize ?? defaultSvgSize,
    fit: fit ?? BoxFit.fill,
    colorFilter: (color ?? defaultColor) != null
        ? ColorFilter.mode((color ?? defaultColor)!, BlendMode.srcIn)
        : null,
  );
}
