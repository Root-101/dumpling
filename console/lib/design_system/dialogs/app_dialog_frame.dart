import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The box of every dialog: [child] clipped to its rounded border, and the
/// close button apart, over its top-right corner and half out of it
class AppDialogFrame extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;

  const AppDialogFrame({
    required this.child,
    this.color,
    this.radius = 16,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // the margin keeps the whole ✕ inside the stack: out of it, it would
    // take neither the mouse nor the click
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Material(
            color: color ?? app.colors.primary.backgroundForm,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(color: app.colors.neutral.grey5),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
        const Positioned(top: 0, right: 0, child: DialogCloseButton()),
      ],
    );
  }
}

/// The ✕ of [AppDialogFrame]: a small raised square of its own
class DialogCloseButton extends StatelessWidget {
  const DialogCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(9);
    return Tooltip(
      message: app.intl.common.close,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: app.colors.surface.control,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: app.colors.neutral.grey5),
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: () => Navigator.of(context).maybePop(),
            mouseCursor: SystemMouseCursors.click,
            child: SizedBox.square(
              dimension: 34,
              child: Center(
                child: app.assets.icons.actions.close.build(
                  size: 16,
                  color: app.colors.neutral.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
