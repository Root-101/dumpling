import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Dot and word of the last connection test of a row: *Connected*,
/// *Unreachable*… or *Testing…* while one runs
class ConnectionStatusLabel extends StatelessWidget {
  final ConnectionCheckModel? check;
  final bool testing;

  const ConnectionStatusLabel({this.check, this.testing = false, super.key});

  static Color colorOf(ConnectionCheckModel? check) => switch (check?.status) {
    null => app.colors.status.pending,
    CheckStatus.connected => app.colors.status.success,
    CheckStatus.incompatible ||
    CheckStatus.toolMissing => app.colors.status.warning,
    CheckStatus.failed => app.colors.status.error,
  };

  static String labelOf(ConnectionCheckModel? check) => switch (check?.status) {
    null => app.intl.connections.notTested,
    CheckStatus.connected => app.intl.connections.connected,
    CheckStatus.incompatible => app.intl.connections.incompatible,
    CheckStatus.toolMissing => app.intl.connections.toolMissing,
    CheckStatus.failed => app.intl.connections.unreachable,
  };

  @override
  Widget build(BuildContext context) {
    final color = testing ? app.colors.status.running : colorOf(check);
    final label = Row(
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
            testing ? app.intl.connections.testing : labelOf(check),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ),
      ],
    );
    // the raw error of the last test, on hover
    final message = check?.message;
    return message == null || testing
        ? label
        : Tooltip(message: message, child: label);
  }
}
