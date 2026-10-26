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
