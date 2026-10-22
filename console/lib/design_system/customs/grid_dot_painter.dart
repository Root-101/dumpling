import 'package:material_ui/material_ui.dart';

/// Dotted background that follows the pan and zoom of a canvas
class GridDotPainter extends CustomPainter {
  final Offset offset;
  final double scale;
  final double spacing;
  final Color color;

  GridDotPainter({
    required this.offset,
    required this.scale,
    required this.color,
    this.spacing = 22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final step = spacing * scale;
    final paint = Paint()..color = color;
    // first dot left/top of the view, aligned with the world grid (dots at 11 + 22n)
    final startX = (offset.dx + step / 2) % step;
    final startY = (offset.dy + step / 2) % step;
    for (double y = startY; y < size.height; y += step) {
      for (double x = startX; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridDotPainter old) =>
      old.offset != offset || old.scale != scale || old.color != color;
}
