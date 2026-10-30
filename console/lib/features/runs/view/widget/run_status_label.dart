import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Dot and word of the status of a run: *Success*, *Failed*, *Running*
class RunStatusLabel extends StatelessWidget {
  final RunStatus status;

  const RunStatusLabel(this.status, {super.key});

  static Color colorOf(RunStatus status) => switch (status) {
    RunStatus.success => app.colors.status.success,
    RunStatus.failed => app.colors.status.error,
    RunStatus.running => app.colors.status.running,
  };

  static String labelOf(RunStatus status) => switch (status) {
    RunStatus.success => app.intl.canvas.runStatus.success,
    RunStatus.failed => app.intl.canvas.runStatus.failed,
    RunStatus.running => app.intl.canvas.runStatus.running,
  };

  /// Check, cross, or the [RunProgressRing] while it runs, in [color]; [size]
  /// is the icon's, the ring is a bit bigger (22 for 17, as in the design)
  static Widget glyphOf(RunStatus status, {required double size}) {
    final color = colorOf(status);
    return switch (status) {
      RunStatus.success => app.assets.icons.actions.check.build(
        size: size,
        color: color,
      ),
      RunStatus.failed => app.assets.icons.actions.close.build(
        size: size,
        color: color,
      ),
      RunStatus.running => RunProgressRing(size: size * 22 / 17, color: color),
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorOf(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            labelOf(status),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
  }
}

/// The status of a run as its icon in a tinted circle
class RunStatusIcon extends StatelessWidget {
  final RunStatus status;
  final double size;

  const RunStatusIcon(this.status, {this.size = 34, super.key});

  @override
  Widget build(BuildContext context) {
    final color = RunStatusLabel.colorOf(status);
    return Semantics(
      label: RunStatusLabel.labelOf(status),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: RunStatusLabel.glyphOf(status, size: size / 2),
      ),
    );
  }
}

/// A run in progress: a ring whose arc fills from the top and fades, with a
/// dot pulsing in the middle (the design's `run-ring`, 1.6 s). Still, with
/// the arc at 60%, when the system asks for less motion
class RunProgressRing extends StatefulWidget {
  final double size;
  final Color color;

  const RunProgressRing({required this.size, required this.color, super.key});

  @override
  State<RunProgressRing> createState() => _RunProgressRingState();
}

class _RunProgressRingState extends State<RunProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: app.intl.canvas.runStatus.running,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(
            progress: _controller,
            color: widget.color,
            still: still,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;
  final bool still;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.still,
  }) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    // the design's 22 px viewBox: radius 8, stroke 3, dot 2.5
    final unit = size.width / 22;
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: 8 * unit);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * unit
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      center,
      8 * unit,
      stroke..color = color.withValues(alpha: 0.25),
    );

    final t = progress.value;
    // fills during the first 70%, then fades out
    final fill = still
        ? 0.6
        : const Cubic(0.4, 0, 0.2, 1).transform((t / 0.7).clamp(0.0, 1.0));
    final fade = still || t <= 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    if (fill > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * fill,
        false,
        stroke..color = color.withValues(alpha: fade),
      );
    }

    final pulse = still
        ? 1.0
        : 0.35 + 0.65 * Curves.easeInOut.transform(1 - (2 * t - 1).abs());
    canvas.drawCircle(
      center,
      2.5 * unit,
      Paint()..color = color.withValues(alpha: pulse),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.still != still;
}
