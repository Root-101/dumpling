import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Strokes [path] in dashes. [phase] moves the pattern forward along the path
/// (to animate it, like `stroke-dashoffset`)
void drawDashedPath(
  Canvas canvas,
  Path path,
  Paint paint, {
  required double dash,
  required double gap,
  double phase = 0,
}) {
  final period = dash + gap;
  for (final metric in path.computeMetrics()) {
    for (double d = phase % period - period; d < metric.length; d += period) {
      final start = math.max(0.0, d);
      final end = math.min(metric.length, d + dash);
      if (end > start) canvas.drawPath(metric.extractPath(start, end), paint);
    }
  }
}

/// A dotted / dashed rounded border around [child]
class DashedBorder extends StatelessWidget {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;
  final Widget? child;

  const DashedBorder({
    required this.color,
    super.key,
    this.strokeWidth = 2,
    this.radius = 10,
    this.dash = 2,
    this.gap = 3,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(this),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  final DashedBorder b;

  _DashedRRectPainter(this.b);

  @override
  void paint(Canvas canvas, Size size) {
    final inset = b.strokeWidth / 2;
    final rect = (Offset.zero & size).deflate(inset);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(b.radius)));
    final paint = Paint()
      ..color = b.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = b.strokeWidth;
    drawDashedPath(canvas, path, paint, dash: b.dash, gap: b.gap);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.b.color != b.color || old.b.strokeWidth != b.strokeWidth;
}
