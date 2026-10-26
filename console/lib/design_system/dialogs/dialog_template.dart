import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class DialogTemplate extends StatelessWidget {
  static void open({
    required String title,
    required Widget child,
    BuildContext? context,
    double? w,
    double? h,
  }) {
    app.dialog.open(
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
      elevation: 50.0,
      alignment: Alignment.center,
      backgroundColor: app.colors.primary.backgroundForm,
      shape: RoundedRectangleBorder(
        borderRadius: app.dimensions.border.borderRadius.s,
      ),
      clipBehavior: Clip.antiAlias,
      // Without [h], as tall as its content (up to the screen): a longer text
      // or another language never overflows it
      child: SizedBox(
        width: w ?? 550,
        height: h,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: Text(title, style: app.textTheme.titleMedium),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    top: 0,
                    right: app.dimensions.padding.xs,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          app.navigator.pop();
                        },
                        icon: app.assets.icons.actions.close.build(
                          size: 18,
                          color: app.colors.neutral.grey2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}
