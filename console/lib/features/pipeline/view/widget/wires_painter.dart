import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class Wire {
  final Offset from;
  final Offset to;
  final bool selected;

  /// Clicked to be removed: amber and solid
  final bool picked;

  /// Part of an incomplete flow (discarded on save): faded amber
  final bool orphan;

  const Wire(
    this.from,
    this.to, {
    this.selected = false,
    this.picked = false,
    this.orphan = false,
  });
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
        ..color = w.picked
            ? colors.brand.accent
            : w.selected
            ? colors.brand.primary
            : w.orphan
            ? colors.brand.accent.withValues(alpha: 0.6)
            : colors.surface.wire
        ..strokeWidth = w.selected || w.picked ? 2.5 : 1.5;
      final path = PipelineGeometry.curve(w.from, w.to);
      if (w.selected && !w.picked) {
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
