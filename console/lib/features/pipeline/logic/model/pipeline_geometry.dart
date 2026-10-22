import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Sizes of the nodes and where their ports are, in world coordinates. The
/// widgets use the same numbers so the wires land on the ports
class PipelineGeometry {
  PipelineGeometry._();

  static const Size sourceSize = Size(200, 88);
  static const Size configSize = Size(240, 112);
  static const double destinationWidth = 256;
  static const double destinationHeader = 60;
  static const double folderRow = 40;
  static const double rootNote = 30;
  static const double addFolderArea = 36;
  static const double destinationPadding = 6;

  /// Port y inside a config (center of its in and out ports)
  static const double configPortY = 76;

  static double destinationHeight(DestinationNode d) =>
      2 + // border
      destinationHeader +
      destinationPadding * 2 +
      (d.folders.isEmpty ? rootNote : d.folders.length * folderRow) +
      addFolderArea;

  static Offset sourceOut(SourceNode s) =>
      s.pos + Offset(sourceSize.width, sourceSize.height / 2);

  static Offset configIn(BackupConfig c) =>
      c.pos + const Offset(0, configPortY);

  static Offset configOut(BackupConfig c) =>
      c.pos + Offset(configSize.width, configPortY);

  static Offset destinationPort(DestinationNode d, String? folderId) {
    final i = d.folders.indexWhere((f) => f.id == folderId);
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
      return DropTarget(d.id, d.folders[row.clamp(0, d.folders.length - 1)].id);
    }
    return null;
  }

  /// Horizontal S-curve between two ports
  static Path curve(Offset a, Offset b) {
    final dx = math.max(40.0, (b.dx - a.dx).abs() / 2);
    return Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(a.dx + dx, a.dy, b.dx - dx, b.dy, b.dx, b.dy);
  }

  static Rect bounds(PipelineState s) {
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
