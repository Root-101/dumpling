import 'package:material_ui/material_ui.dart';

/// Lines every [spacing] px, the first ones just off the top left; with
/// [offset] and [scale], they follow the pan and zoom of a canvas
class GridLinePainter extends CustomPainter {
  final Color color;
  final Offset offset;
  final double scale;
  final double spacing;

  const GridLinePainter({
    required this.color,
    this.offset = Offset.zero,
    this.scale = 1,
    this.spacing = 48,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final step = spacing * scale;
    final paint = Paint()..color = color;
    for (double x = (offset.dx + step - 1) % step; x < size.width; x += step) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), paint);
    }
    for (double y = (offset.dy + step - 1) % step; y < size.height; y += step) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridLinePainter old) =>
      old.color != color || old.offset != offset || old.scale != scale;
}
