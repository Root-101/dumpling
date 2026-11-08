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

/// A [ReorderableListView] of [items] moved by their [AppDragHandle]s. On a
/// drop it shows the new order right away and then calls [onReorder]: the
/// list drops its gap in that same frame, and a cubit's state comes a frame
/// later, so waiting for it shows the old order for a moment
class AppReorderableList<T> extends StatefulWidget {
  final List<T> items;

  /// Unique per item, kept across the moves
  final Object Function(T item) keyOf;
  final Widget Function(int index, T item) itemBuilder;
  final void Function(int from, int to) onReorder;

  const AppReorderableList({
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    required this.onReorder,
    super.key,
  });

  @override
  State<AppReorderableList<T>> createState() => _AppReorderableListState<T>();
}

class _AppReorderableListState<T> extends State<AppReorderableList<T>> {
  late List<T> _items = widget.items;

  @override
  void didUpdateWidget(AppReorderableList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _items = widget.items;
  }

  void _move(int from, int to) {
    setState(() => _items = reordered(_items, from, to));
    widget.onReorder(from, to);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorderItem: _move,
      proxyDecorator: (child, _, _) => Material(
        color: app.colors.primary.background2,
        elevation: 6,
        child: child,
      ),
      children: [
        for (final (index, item) in _items.indexed)
          KeyedSubtree(
            key: ValueKey(widget.keyOf(item)),
            child: widget.itemBuilder(index, item),
          ),
      ],
    );
  }
}
