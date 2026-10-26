import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Sizes of the nodes and where their ports are, in world coordinates. The
/// widgets use the same numbers so the wires land on the ports
class CanvasGeometry {
  CanvasGeometry._();

  static const Size sourceSize = Size(200, 88);
  static const Size configSize = Size(240, 112);
  static const double destinationWidth = 256;
  static const double destinationHeader = 60;
  static const double folderRow = 40;
  static const double rootNote = 30;
  static const double destinationPadding = 6;

  /// Port y inside a config (center of its in and out ports)
  static const double configPortY = 76;

  static double destinationHeight(DestinationNode d) =>
      2 + // border
      destinationHeader +
      destinationPadding * 2 +
      (d.folders.isEmpty ? rootNote : d.folders.length * folderRow);

  static Offset sourceOut(SourceNode s) =>
      s.pos + Offset(sourceSize.width, sourceSize.height / 2);

  static Offset configIn(BackupConfig c) =>
      c.pos + const Offset(0, configPortY);

  static Offset configOut(BackupConfig c) =>
      c.pos + Offset(configSize.width, configPortY);

  static Offset destinationPort(DestinationNode d, String? folderId) {
    final i = folderId == null ? -1 : d.folders.indexOf(folderId);
    if (i < 0) return d.pos + const Offset(0, 30);
    // border + header + padding + half a row
    return d.pos +
        Offset(
          0,
          1 +
              destinationHeader +
              destinationPadding +
              folderRow * i +
              folderRow / 2,
        );
  }

  static Rect sourceRect(SourceNode s) => s.pos & sourceSize;

  static Rect configRect(BackupConfig c) => c.pos & configSize;

  static Rect destinationRect(DestinationNode d) =>
      d.pos & Size(destinationWidth, destinationHeight(d));

  /// The destination (and folder) under [p], with some slack on the left so
  /// the drop can be on the ports
  static DropTarget? hit(List<DestinationNode> destinations, Offset p) {
    for (final d in destinations.reversed) {
      final r = destinationRect(d);
      if (p.dx < r.left - 24 ||
          p.dx > r.right ||
          p.dy < r.top ||
          p.dy > r.bottom) {
        continue;
      }
      if (d.folders.isEmpty) return DropTarget(d.id, null);
      final row =
          ((p.dy - (d.pos.dy + 1 + destinationHeader + destinationPadding)) /
                  folderRow)
              .floor();
      return DropTarget(d.id, d.folders[row.clamp(0, d.folders.length - 1)]);
    }
    return null;
  }

  /// The config under [p] (a source wire dropped on it attaches the source)
  static BackupConfig? hitConfig(List<BackupConfig> configs, Offset p) {
    for (final c in configs.reversed) {
      if (configRect(c).inflate(8).contains(p)) return c;
    }
    return null;
  }

  /// The two ends of a config's wire, if both nodes exist
  static (Offset, Offset)? wireEnds(CanvasData s, BackupConfig c, WireEnd end) {
    if (end == WireEnd.source) {
      final source = s.source(c.sourceId);
      return source == null ? null : (sourceOut(source), configIn(c));
    }
    final dest = s.destination(c.destinationId);
    return dest == null
        ? null
        : (configOut(c), destinationPort(dest, c.folderId));
  }

  /// The wire nearest to [p] within [tolerance] (world units)
  static (String, WireEnd)? hitWire(CanvasData s, Offset p, double tolerance) {
    (String, WireEnd)? best;
    var bestD = tolerance;
    for (final c in s.configs) {
      for (final end in WireEnd.values) {
        final ends = wireEnds(s, c, end);
        if (ends == null) continue;
        final d = _distanceToCurve(ends.$1, ends.$2, p);
        if (d <= bestD) {
          bestD = d;
          best = (c.id, end);
        }
      }
    }
    return best;
  }

  /// Point of [curve] at t (0..1)
  static Offset curveAt(Offset a, Offset b, double t) {
    final dx = math.max(40.0, (b.dx - a.dx).abs() / 2);
    final p1 = Offset(a.dx + dx, a.dy), p2 = Offset(b.dx - dx, b.dy);
    final u = 1 - t;
    return a * (u * u * u) +
        p1 * (3 * u * u * t) +
        p2 * (3 * u * t * t) +
        b * (t * t * t);
  }

  static double _distanceToCurve(Offset a, Offset b, Offset p) {
    const steps = 32;
    var best = double.infinity;
    var prev = a;
    for (var i = 1; i <= steps; i++) {
      final next = curveAt(a, b, i / steps);
      best = math.min(best, _distanceToSegment(p, prev, next));
      prev = next;
    }
    return best;
  }

  static double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final len2 = ab.distanceSquared;
    if (len2 == 0) return (p - a).distance;
    final t = (((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2).clamp(
      0.0,
      1.0,
    );
    return (p - (a + ab * t)).distance;
  }

  /// Horizontal S-curve between two ports
  static Path curve(Offset a, Offset b) {
    final dx = math.max(40.0, (b.dx - a.dx).abs() / 2);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx + dx, a.dy, b.dx - dx, b.dy, b.dx, b.dy);
  }

  static Rect bounds(CanvasData s) {
    final rects = [
      ...s.sources.map(sourceRect),
      ...s.configs.map(configRect),
      ...s.destinations.map(destinationRect),
    ];
    return rects.isEmpty
        ? Rect.zero
        : rects.reduce((a, b) => a.expandToInclude(b));
  }
}
