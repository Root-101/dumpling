import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

/// Stroke icons of the design (24x24 viewBox), tinted with [AppIcon.color]
enum AppIcons {
  backups,
  bucket,
  center,
  clock,
  close,
  database,
  events,
  folder,
  keyboard,
  lock,
  pipeline,
  settings;

  String get path => 'assets/icons/$name.svg';
}

class AppIcon extends StatelessWidget {
  final AppIcons icon;
  final double size;
  final Color color;

  const AppIcon(this.icon, {required this.color, super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
