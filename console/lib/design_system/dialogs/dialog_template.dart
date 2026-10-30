import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class DialogTemplate extends StatelessWidget {
  /// Completes when it closes
  static Future<void> open({
    required String title,
    required Widget child,
    BuildContext? context,
    double? w,
    double? h,
  }) {
    return app.dialog.open(
      dialog: DialogTemplate(title: title, w: w, h: h, child: child),
      context: context,
    );
  }

  final double? w;
  final double? h;

  final String title;
  final Widget child;

  const DialogTemplate({
    required this.title,
    required this.child,
    this.w,
    this.h,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppDialogFrame(
        color: app.colors.primary.backgroundForm,
        child: SizedBox(
          width: w ?? 550,
          height: h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 50,
                child: Center(
                  child: Text(title, style: app.textTheme.titleMedium),
                ),
              ),
              Flexible(child: SingleChildScrollView(child: child)),
            ],
          ),
        ),
      ),
    );
  }
}
