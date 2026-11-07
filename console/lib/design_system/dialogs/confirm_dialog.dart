import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A yes or no before something that can't be undone: the title and the
/// description to the left, Cancel and the action to the right, no ✕
class ConfirmDialog extends StatelessWidget {
  /// True when it was confirmed; false when cancelled or dismissed
  static Future<bool> show({
    required String title,
    required String description,
    required String confirmTitle,
    required VoidCallback confirmAction,
    required Color confirmColor,
    String? cancelTitle,
    VoidCallback? cancelAction,
    double? w,
  }) async {
    var confirmed = false;
    await app.dialog.open(
      dialog: ConfirmDialog(
        title: title,
        description: description,
        confirmAction: () {
          confirmed = true;
          confirmAction();
        },
        confirmColor: confirmColor,
        confirmTitle: confirmTitle,
        cancelAction: cancelAction,
        cancelTitle: cancelTitle,
        w: w,
      ),
    );
    return confirmed;
  }

  final String title;
  final String description;

  final String? cancelTitle;
  final VoidCallback? cancelAction;

  final String confirmTitle;
  final VoidCallback confirmAction;
  final Color confirmColor;

  final double? w;

  const ConfirmDialog({
    required this.title,
    required this.description,
    required this.confirmTitle,
    required this.confirmAction,
    required this.confirmColor,
    this.cancelTitle,
    this.cancelAction,
    this.w,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Material(
        color: colors.primary.backgroundForm,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.neutral.grey5),
        ),
        child: SizedBox(
          width: w ?? 440,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 26 / 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.neutral.grey3,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    PrimaryButton.secondary(
                      onPressed:
                          cancelAction ?? () => Navigator.of(context).pop(),
                      title: cancelTitle ?? app.intl.common.cancel,
                      color: colors.primary.background3,
                      h: 40,
                      w: 100,
                    ),
                    PrimaryButton.primary(
                      onPressed: () {
                        confirmAction();
                        Navigator.of(context).pop();
                      },
                      title: confirmTitle,
                      color: confirmColor,
                      h: 40,
                      horizontalPadding: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
