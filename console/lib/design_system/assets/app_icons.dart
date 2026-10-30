import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Stroke icons of the design (24x24 viewBox), one class per folder of
/// `assets/icons/`
class AppIcons {
  const AppIcons();

  final ActionsIcons actions = const ActionsIcons();
  final NavigationIcons navigation = const NavigationIcons();
  final NodesIcons nodes = const NodesIcons();
  final LanguageIcons language = const LanguageIcons();
  final SourcesIcons sources = const SourcesIcons();
}

/// Logos of the kinds of source, in their own colors
class SourcesIcons {
  const SourcesIcons();

  static const String _sources = 'assets/icons/sources';

  SvgAsset get postgresql => const SvgAsset('$_sources/postgresql.svg');

  SvgAsset get mysql => const SvgAsset('$_sources/mysql.svg');

  SvgAsset get mariadb => const SvgAsset('$_sources/mariadb.svg');

  SvgAsset get mongodb => const SvgAsset('$_sources/mongodb.svg');
}

class LanguageIcons {
  const LanguageIcons();

  static const String _language = 'assets/icons/languages';

  SvgAsset get es => const SvgAsset('$_language/es.svg');

  SvgAsset get en => const SvgAsset('$_language/en.svg');
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

  SvgAsset get edit => const SvgAsset('$_actions/edit.svg');

  SvgAsset get logout => const SvgAsset('$_actions/logout.svg');

  SvgAsset get more => const SvgAsset('$_actions/more.svg');

  SvgAsset get refresh => const SvgAsset('$_actions/refresh.svg');

  SvgAsset get search => const SvgAsset('$_actions/search.svg');

  SvgAsset get filter => const SvgAsset('$_actions/filter.svg');

  /// Two arrows: the sort
  SvgAsset get sort => const SvgAsset('$_actions/sort.svg');

  /// Three lines: the list view
  SvgAsset get list => const SvgAsset('$_actions/list.svg');

  /// Four squares: the grid view
  SvgAsset get grid => const SvgAsset('$_actions/grid.svg');

  SvgAsset get duplicate => const SvgAsset('$_actions/duplicate.svg');

  /// A bolt: test a connection
  SvgAsset get test => const SvgAsset('$_actions/test.svg');

  /// A triangle: run now
  SvgAsset get play => const SvgAsset('$_actions/play.svg');

  SvgAsset get check => const SvgAsset('$_actions/check.svg');

  SvgAsset get info => const SvgAsset('$_actions/info.svg');

  /// An eye: show a password
  SvgAsset get view => const SvgAsset('$_actions/view.svg');

  /// Points right; rotate it for the other directions
  SvgAsset get chevron => const SvgAsset('$_actions/chevron.svg');
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
