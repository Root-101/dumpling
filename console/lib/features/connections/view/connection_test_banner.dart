import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The *Test connection* box at the end of a form: what the last test of the
/// form found, and the button that runs it (always in the service)
class ConnectionTestBanner extends StatelessWidget {
  final ConnectionCheckModel? check;
  final bool testing;
  final VoidCallback onTest;

  /// Before the first test: what the test does
  final String idleSub;

  /// After a test that connected: what it found
  final String Function(ConnectionCheckModel check) connectedSub;

  const ConnectionTestBanner({
    required this.check,
    required this.testing,
    required this.onTest,
    required this.idleSub,
    required this.connectedSub,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final check = testing ? null : this.check;
    final color = testing
        ? app.colors.status.running
        : check == null
        ? app.colors.neutral.grey3
        : ConnectionStatusLabel.colorOf(check);
    final (title, sub) = _texts(check);
    final tinted = check != null;
    return Container(
      padding: EdgeInsets.all(app.dimensions.padding.m),
      decoration: BoxDecoration(
        color: tinted
            ? color.withValues(alpha: 0.08)
            : app.colors.primary.background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: tinted
              ? color.withValues(alpha: 0.4)
              : app.colors.neutral.grey5,
        ),
      ),
      child: Row(
        children: [
          testing
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : (check?.status == CheckStatus.connected
                        ? app.assets.icons.actions.check
                        : check == null
                        ? app.assets.icons.actions.info
                        : app.assets.icons.actions.warning)
                    .build(size: 18, color: color),
          app.dimensions.padding.m.gap(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (sub.isNotEmpty)
                  SelectableText(
                    sub,
                    style: TextStyle(
                      fontSize: 12,
                      color: app.colors.neutral.grey3,
                    ),
                  ),
              ],
            ),
          ),
          app.dimensions.padding.m.gap(),
          PrimaryButton.secondary(
            onPressed: testing ? null : onTest,
            title: app.intl.connections.test,
            color: app.colors.surface.control,
            h: 36,
            horizontalPadding: 14,
          ),
        ],
      ),
    );
  }

  (String, String) _texts(ConnectionCheckModel? check) {
    if (testing) return (app.intl.connections.testing, '');
    if (check == null) return (app.intl.connections.notTestedYet, idleSub);
    final message = check.message ?? '';
    return switch (check.status) {
      CheckStatus.connected => (
        app.intl.connections.connected,
        connectedSub(check),
      ),
      CheckStatus.incompatible => (
        app.intl.connections.incompatibleTitle,
        app.intl.connections.incompatibleSub(
          server: check.serverVersion ?? '?',
          tool: check.toolVersion ?? '?',
        ),
      ),
      CheckStatus.toolMissing => (
        app.intl.connections.toolMissingTitle,
        message,
      ),
      CheckStatus.failed => (app.intl.connections.failedTitle, message),
    };
  }
}
