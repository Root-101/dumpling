import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The ⟳ of a screen's header: loads the list again; a spinner while it does
class AppRefreshButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;

  const AppRefreshButton({
    required this.onPressed,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Tooltip(
      message: app.intl.common.refresh,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.neutral.grey5),
          borderRadius: app.dimensions.border.borderRadius.s,
        ),
        child: PrimaryButton(
          onPressed: loading ? null : onPressed,
          isLoading: loading,
          color: colors.surface.control,
          disabledColor: colors.surface.control,
          title: '',
          icon: app.assets.icons.actions.refresh.build(
            size: 18,
            color: colors.neutral.grey2,
          ),
          h: 40,
          w: 40,
        ),
      ),
    );
  }
}
