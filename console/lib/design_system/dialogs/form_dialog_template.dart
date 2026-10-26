import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog with a form: title, description and close at the top, [child] in
/// the middle and [actions] at the bottom right. It sits near the top of the
/// screen, so a form that grows doesn't move its title
class FormDialogTemplate extends StatelessWidget {
  static Future<void> show({
    required String title,
    required Widget child,
    required List<Widget> actions,
    String? description,

    /// Id of its [LoadingOverlay], to cover it while the form saves
    String? loadingId,
    double width = 560,
    BuildContext? context,
  }) {
    return showGeneralDialog(
      context: context ?? app.context,
      barrierDismissible: true,
      barrierLabel: app.intl.common.close,
      barrierColor: app.colors.neutral.black.withValues(alpha: 0.54),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FormDialogTemplate(
            title: title,
            description: description,
            actions: actions,
            loadingId: loadingId,
            width: width,
            child: child,
          ),
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  final String title;
  final String? description;
  final Widget child;
  final List<Widget> actions;
  final String? loadingId;
  final double width;

  const FormDialogTemplate({
    required this.title,
    required this.child,
    required this.actions,
    this.description,
    this.loadingId,
    this.width = 560,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = app.dimensions.border.borderRadius.m;
    final padding = app.dimensions.padding.xxl;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 20, padding, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null) ...[
                      2.gap(),
                      Text(
                        description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: app.colors.neutral.grey4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              app.dimensions.padding.m.gap(),
              PrimaryButton.svgIcon(
                icon: app.assets.icons.actions.close,
                tooltipMessage: app.intl.common.close,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 20),
            child: child,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: app.colors.neutral.grey5.withValues(alpha: 0.4),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: app.dimensions.padding.m,
            children: actions,
          ),
        ),
      ],
    );
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 84, 16, 16),
        child: Material(
          color: app.colors.primary.backgroundForm,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: app.colors.neutral.grey5),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: width,
            child: loadingId == null
                ? content
                : LoadingOverlay(
                    id: loadingId,
                    overlayWidgetBuilder: LoadingOverlayStyles.form,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
