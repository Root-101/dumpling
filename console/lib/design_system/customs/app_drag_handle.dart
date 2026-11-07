import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The six dots that drag item [index] of a [ReorderableListView] built
/// without default handles. With [blocked] (why it can't move now) it is
/// dimmed and its tooltip says so
class AppDragHandle extends StatelessWidget {
  static const double width = 16;

  final int index;
  final String? blocked;

  const AppDragHandle({required this.index, this.blocked, super.key});

  @override
  Widget build(BuildContext context) {
    final icon = app.assets.icons.actions.drag.build(
      size: 14,
      color: app.colors.neutral.grey4,
    );
    if (blocked != null) {
      return Tooltip(
        message: blocked!,
        child: Opacity(opacity: 0.35, child: icon),
      );
    }
    return Tooltip(
      message: app.intl.common.dragToReorder,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: ReorderableDragStartListener(index: index, child: icon),
      ),
    );
  }
}

/// [list] with the item at [from] moved to [to], as
/// `ReorderableListView.onReorderItem` reports it
List<T> reordered<T>(List<T> list, int from, int to) {
  final result = [...list];
  result.insert(to, result.removeAt(from));
  return result;
}
