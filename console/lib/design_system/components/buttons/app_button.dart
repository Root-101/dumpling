import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

enum AppButtonType { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final Widget? icon;
  final double height;

  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.icon,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final (Color bg, Color fg) = switch (type) {
      AppButtonType.primary => (
        colors.brand.primaryAction,
        colors.text.primary,
      ),
      AppButtonType.secondary => (colors.surface.control, colors.text.primary),
      AppButtonType.ghost => (Colors.transparent, colors.text.secondary),
      AppButtonType.danger => (Colors.transparent, colors.status.error),
    };
    return TextButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        minimumSize: Size(0, height),
        padding: EdgeInsets.symmetric(horizontal: icon == null ? 16 : 12),
        backgroundColor: bg,
        foregroundColor: fg,
        shape: RoundedRectangleBorder(borderRadius: app.dimensions.radius.s),
        textStyle: TextStyle(
          fontFamily: AppText.sans,
          fontSize: height < 40 ? 13 : 14,
          fontWeight: type == AppButtonType.primary
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 7)],
          Text(label),
        ],
      ),
    );
  }
}

/// Square button with only an icon (it needs a [tooltip] for screen readers)
class AppIconButton extends StatelessWidget {
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final Color? background;

  const AppIconButton({
    required this.icon,
    required this.tooltip,
    super.key,
    this.onPressed,
    this.size = 36,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size.square(size),
          fixedSize: Size.square(size),
          padding: EdgeInsets.zero,
          backgroundColor: background ?? Colors.transparent,
          foregroundColor: app.colors.text.secondary,
          shape: RoundedRectangleBorder(borderRadius: app.dimensions.radius.s),
        ),
        child: icon,
      ),
    );
  }
}
