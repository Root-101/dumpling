import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The initial of a workspace in white over its color (violet without one)
class WorkspaceAvatar extends StatelessWidget {
  final String initial;
  final Color? color;
  final double size;

  const WorkspaceAvatar({
    required this.initial,
    this.color,
    this.size = 34,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? app.colors.palette.violet,
        // 8 at 34 px, 7 at 30 px, as in the design
        borderRadius: BorderRadius.circular(size * 0.235),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.41,
          fontWeight: FontWeight.w700,
          color: app.colors.neutral.white,
        ),
      ),
    );
  }
}
