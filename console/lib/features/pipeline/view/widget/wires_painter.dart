import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class Wire {
  final Offset from;
  final Offset to;
  final bool selected;

  const Wire(this.from, this.to, {this.selected = false});
}

/// The source → config → destination wires. The selected ones flow (dashes
/// moving along them, driven by [flow])
class WiresPainter extends CustomPainter {
  final List<Wire> wires;
  final Animation<double> flow;

  /// The wire being dragged, if any
  final (Offset, Offset)? live;

  WiresPainter({required this.wires, required this.flow, this.live})
    : super(repaint: flow);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = app.colors;
    for (final w in wires) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = w.selected ? colors.brand.primary : colors.surface.wire
        ..strokeWidth = w.selected ? 2.5 : 1.5;
      final path = PipelineGeometry.curve(w.from, w.to);
      if (w.selected) {
        drawDashedPath(
          canvas,
          path,
          paint,
          dash: 7,
          gap: 6,
          phase: flow.value * 13,
        );
      } else {
        canvas.drawPath(path, paint);
      }
    }
    if (live != null) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = colors.brand.accent
        ..strokeWidth = 2;
      drawDashedPath(
        canvas,
        PipelineGeometry.curve(live!.$1, live!.$2),
        paint,
        dash: 3,
        gap: 5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WiresPainter old) => true;
}
