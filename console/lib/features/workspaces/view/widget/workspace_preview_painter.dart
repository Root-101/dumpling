import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The sketch of a canvas at the top of a workspace card: up to 4 configs,
/// each one wired from a source to one of up to 3 destinations; the configs
/// that fail have a red border. Only the counts, not the real canvas
class WorkspacePreviewPainter extends CustomPainter {
  static const double height = 112;
  static const double _width = 300;
  static const Size _box = Size(60, 16);
  static const double _row = 22;

  final int configs;
  final int destinations;
  final int failing;

  WorkspacePreviewPainter({
    required this.configs,
    required this.destinations,
    required this.failing,
  });

  /// Top of the row [i] of [count], centered in the height
  static double _top(int i, int count) =>
      height / 2 - count * _row / 2 + i * _row;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = app.colors;
    // the sketch is 300 wide, centered in the card
    canvas.translate((size.width - _width) / 2, 0);

    final rows = math.min(configs, 4);
    final columns = math.min(destinations, 3);
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = colors.surface.wire;

    void box(double x, double y, Color stroke) {
      final rect = RRect.fromRectAndRadius(
        Offset(x, y) & _box,
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = colors.surface.surface2);
      canvas.drawRRect(
        rect.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = stroke,
      );
    }

    for (var i = 0; i < rows; i++) {
      final y = _top(i, rows);
      final target = math.max(math.min(i, columns - 1), 0);
      final dy = _top(target, math.max(columns, 1)) + 8;
      canvas.drawLine(Offset(90, y + 8), Offset(120, y + 8), wire);
      if (columns > 0) {
        canvas.drawPath(
          Path()
            ..moveTo(180, y + 8)
            ..cubicTo(195, y + 8, 195, dy, 210, dy),
          wire,
        );
      }
      box(30, y, colors.surface.border);
      box(120, y, i < failing ? colors.status.error : colors.surface.wire);
    }
    for (var j = 0; j < columns; j++) {
      box(210, _top(j, columns), colors.brand.accent);
    }
  }

  @override
  bool shouldRepaint(covariant WorkspacePreviewPainter old) =>
      old.configs != configs ||
      old.destinations != destinations ||
      old.failing != failing;
}
