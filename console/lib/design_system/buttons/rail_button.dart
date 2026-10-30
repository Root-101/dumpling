import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Square button of the rail: 44x44 and radius 10, the icon in `grey3` and,
/// when [selected], white over `purple`. With a [label] (the rail expanded) it
/// is as wide as the rail, the icon with its name. [onPressed] gets the
/// button's context, to anchor a menu to it
class RailButton extends StatelessWidget {
  static const double size = 44;

  static final BorderRadius _radius = BorderRadius.circular(10);

  final String tooltip;
  final void Function(BuildContext context)? onPressed;
  final Widget Function(Color color) icon;
  final bool selected;

  /// Painted over the top right corner (e.g. how many configs fail); with a
  /// [label], at the end of the row
  final Widget? badge;

  /// The name next to the icon, when the rail is expanded
  final String? label;

  const RailButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.selected = false,
    this.badge,
    this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = onPressed == null
        ? app.colors.neutral.grey5
        : selected
        ? app.colors.neutral.white
        : app.colors.neutral.grey3;
    final label = this.label;
    final content = label == null
        ? SizedBox.square(
            dimension: size,
            child: Center(child: icon(color)),
          )
        : SizedBox(
            height: size,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 12,
                children: [
                  icon(color),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ),
                  ?badge,
                ],
              ),
            ),
          );
    return Tooltip(
      // with its name on screen, the tooltip would only repeat it
      message: label == null ? tooltip : '',
      child: Semantics(
        label: label == null ? null : tooltip,
        selected: selected,
        button: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppFocusRing(
              borderRadius: _radius,
              child: Material(
                color: selected
                    ? app.colors.primary.purple
                    : app.colors.neutral.transparent,
                borderRadius: _radius,
                child: InkWell(
                  borderRadius: _radius,
                  hoverColor: app.colors.surface.control.withValues(alpha: 0.8),
                  onTap: onPressed == null ? null : () => onPressed!(context),
                  child: content,
                ),
              ),
            ),
            if (badge != null && label == null)
              Positioned(
                top: 4,
                right: 4,
                // doesn't block the button's tap
                child: IgnorePointer(child: badge),
              ),
          ],
        ),
      ),
    );
  }
}

/// Small amber count over a [RailButton]
class RailBadge extends StatelessWidget {
  final int count;

  const RailBadge({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: app.colors.primary.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
          color: app.colors.primary.background1,
        ),
      ),
    );
  }
}
