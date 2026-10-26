import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class ConfirmDialog extends StatelessWidget {
  static void show({
    required String title,
    required String description,
    required String confirmTitle,
    required VoidCallback confirmAction,
    required Color confirmColor,
    String? cancelTitle,
    VoidCallback? cancelAction,
    double? w,
    double? h,
  }) {
    DialogTemplate.open(
      title: title,
      w: w ?? 400,
      h: h,
      child: ConfirmDialog(
        description: description,
        confirmAction: confirmAction,
        confirmColor: confirmColor,
        confirmTitle: confirmTitle,
        cancelAction: cancelAction,
        cancelTitle: cancelTitle,
      ),
    );
  }

  final String description;

  final String? cancelTitle;
  final VoidCallback? cancelAction;

  final String confirmTitle;
  final VoidCallback confirmAction;
  final Color confirmColor;

  const ConfirmDialog({
    required this.description,
    required this.confirmTitle,
    required this.confirmAction,
    required this.confirmColor,
    this.cancelTitle,
    this.cancelAction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        app.dimensions.padding.xl,
        app.dimensions.padding.m,
        app.dimensions.padding.xl,
        app.dimensions.padding.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: .center,
        children: [
          Text(
            description,
            style: app.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          app.dimensions.padding.xxl.gap(),
          Row(
            children: [
              Expanded(
                child: PrimaryButton.primary(
                  onPressed:
                      cancelAction ??
                      () {
                        app.navigator.pop();
                      },
                  title: cancelTitle ?? app.intl.common.cancel,
                  color: app.colors.primary.background3,
                ),
              ),
              app.dimensions.padding.l.gap(),
              Expanded(
                child: PrimaryButton.primary(
                  onPressed: () {
                    confirmAction();
                    app.navigator.pop();
                  },
                  title: confirmTitle,
                  color: confirmColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
