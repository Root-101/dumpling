import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The last connection check of a detail: what it found and when
class ConnectionCheckPanel extends StatelessWidget {
  final ConnectionCheckModel? check;
  final bool testing;

  /// Before the first test: what the test does
  final String idleSub;

  /// After a test that connected: what it found
  final String Function(ConnectionCheckModel check) connectedSub;

  const ConnectionCheckPanel({
    required this.check,
    required this.testing,
    required this.idleSub,
    required this.connectedSub,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final check = this.check;
    final color = testing
        ? colors.status.running
        : ConnectionStatusLabel.colorOf(check);
    final detail = testing
        ? ''
        : check == null
        ? idleSub
        : check.status == CheckStatus.connected
        ? connectedSub(check)
        : check.message ?? '';
    return DetailPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DetailPanelTitle(
            app.intl.connections.checkTitle,
            note: app.intl.connections.checkNote,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    testing
                        ? app.intl.connections.testing
                        : ConnectionStatusLabel.labelOf(check),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    detail,
                    style: TextStyle(fontSize: 13, color: colors.neutral.grey3),
                  ),
                ),
                if (check != null && !testing)
                  AppDateTime(time: check.checkedAt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
