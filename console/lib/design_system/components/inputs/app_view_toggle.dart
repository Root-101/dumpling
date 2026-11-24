import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// How a list shows its items
enum AppView { list, grid }

/// The two buttons that switch a list between rows and cards
class AppViewToggle extends StatelessWidget {
  final AppView value;
  final ValueChanged<AppView> onChanged;

  const AppViewToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    Widget option(AppView view, SvgAsset icon, String label) {
      final on = view == value;
      return Semantics(
        inMutuallyExclusiveGroup: true,
        checked: on,
        child: Tooltip(
          message: label,
          child: Material(
            color: on
                ? colors.brand.primarySelected
                : colors.neutral.transparent,
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: on ? null : () => onChanged(view),
              child: SizedBox(
                width: 34,
                height: 32,
                child: Center(
                  child: icon.build(
                    size: 16,
                    color: on ? colors.neutral.white : colors.neutral.grey3,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.primary.backgroundForm,
        borderRadius: app.dimensions.border.borderRadius.s,
        border: Border.all(color: colors.neutral.grey5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          option(
            AppView.list,
            app.assets.icons.actions.list,
            app.intl.common.listView,
          ),
          option(
            AppView.grid,
            app.assets.icons.actions.grid,
            app.intl.common.gridView,
          ),
        ],
      ),
    );
  }
}
