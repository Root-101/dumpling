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

  /// Check, cross, or a triangle while it runs
  static SvgAsset iconOf(RunStatus status) => switch (status) {
    RunStatus.success => app.assets.icons.actions.check,
    RunStatus.failed => app.assets.icons.actions.close,
    RunStatus.running => app.assets.icons.actions.play,
  };

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
        child: RunStatusLabel.iconOf(status)
            .build(size: size / 2, color: color),
      ),
    );
  }
}
