import 'package:flutter/foundation.dart';
import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The sketch of a canvas at the top of a workspace card: its first configs
/// ([links], 3 at most), each wired from its source to its destination, and
/// only the sources and destinations they connect; the configs that fail
/// have a red border. Empty without configs
class WorkspacePreviewPainter extends CustomPainter {
  static const double height = 112;
  static const double _width = 300;
  static const Size _box = Size(60, 16);
  static const double _row = 22;

  final List<WorkspacePreviewLink> links;

  WorkspacePreviewPainter({required this.links});

  /// Top of the row [i] of [count], centered in the height
  static double _top(int i, int count) =>
      height / 2 - count * _row / 2 + i * _row;

  @override
  void paint(Canvas canvas, Size size) {
    if (links.isEmpty) return;
    final colors = app.colors;
    // the sketch is 300 wide, centered in the card
    canvas.translate((size.width - _width) / 2, 0);

    final sources = [
      ...{for (final l in links) l.source},
    ];
    final destinations = [
      ...{for (final l in links) l.destination},
    ];
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

    void curve(double x1, double y1, double x2, double y2) {
      final mid = (x1 + x2) / 2;
      canvas.drawPath(
        Path()
          ..moveTo(x1, y1)
          ..cubicTo(mid, y1, mid, y2, x2, y2),
        wire,
      );
    }

    for (final (i, l) in links.indexed) {
      final y = _top(i, links.length) + 8;
      final sy = _top(sources.indexOf(l.source), sources.length) + 8;
      final dy =
          _top(destinations.indexOf(l.destination), destinations.length) + 8;
      curve(90, sy, 120, y);
      curve(180, y, 210, dy);
    }
    for (final (j, _) in sources.indexed) {
      box(30, _top(j, sources.length), colors.surface.border);
    }
    for (final (i, l) in links.indexed) {
      box(
        120,
        _top(i, links.length),
        l.failing ? colors.status.error : colors.surface.wire,
      );
    }
    for (final (k, _) in destinations.indexed) {
      box(210, _top(k, destinations.length), colors.brand.accent);
    }
  }

  @override
  bool shouldRepaint(covariant WorkspacePreviewPainter old) =>
      !listEquals(old.links, links);
}
