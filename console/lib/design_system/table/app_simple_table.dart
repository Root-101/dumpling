import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A column of [AppSimpleTable]
class AppTableColumn {
  /// Header text; empty for an actions column
  final String title;

  /// Fixed width; null shares the remaining space by [flex]
  final double? width;

  /// Share of the remaining space, like `fr` in a CSS grid
  final int flex;

  /// Without padding and centered, for an icon button or a menu
  final bool compact;

  const AppTableColumn(
    this.title, {
    this.width,
    this.flex = 10,
    this.compact = false,
  });

  const AppTableColumn.actions({double width = 56})
    : this('', width: width, compact: true);
}

/// A row of [AppSimpleTable]: one widget per column
class AppTableRow {
  final List<Widget> cells;

  /// Rows grow beyond it when a cell needs more (two lines, chips that wrap)
  final double minHeight;

  /// Shown under the cells, inside the same row (e.g. the folders of a bucket)
  final Widget? expanded;

  /// A click anywhere on the cells, e.g. to open [expanded]
  final VoidCallback? onTap;

  /// Under the cells while [expanded] is shown
  final Color? background;

  /// What the row shows, unique in the table: needed to drag it
  final Object? id;

  const AppTableRow(
    this.cells, {
    this.id,
    this.minHeight = 56,
    this.expanded,
    this.onTap,
    this.background,
  });
}

/// Bordered table for short lists with rich cells (several lines, chips,
/// badges): sources and destinations. Under [minWidth] it scrolls sideways
/// instead of squeezing the columns
class AppSimpleTable extends StatelessWidget {
  static const double headerHeight = 44;

  /// Inside the border, above the column titles: search, filters…
  final Widget? toolbar;

  final List<AppTableColumn> columns;
  final List<AppTableRow> rows;

  /// Shown after the rows, e.g. an empty state or "no results"
  final Widget? placeholder;

  /// Info line at the bottom of the table, and [hintEnd] on its right
  final String? hint;
  final Widget? hintEnd;

  final double minWidth;

  /// Replaces the column titles and the rows, e.g. the same items as cards
  final Widget? body;

  /// With it each row starts with an [AppDragHandle] and moves by dragging
  /// it from `from` to `to` (see [reordered])
  final void Function(int from, int to)? onReorder;

  /// Why the rows can't move now (a filter on): the handles are dimmed
  final String? reorderBlocked;

  const AppSimpleTable({
    required this.columns,
    required this.rows,
    this.toolbar,
    this.placeholder,
    this.hint,
    this.hintEnd,
    this.minWidth = 760,
    this.body,
    this.onReorder,
    this.reorderBlocked,
    super.key,
  });

  static const double _handleWidth = 32;

  @override
  Widget build(BuildContext context) {
    final divider = BorderSide(
      color: app.colors.neutral.white.withValues(alpha: 0.08),
    );
    final table = Column(
      children: [
        Container(
          height: headerHeight,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: app.colors.neutral.grey5)),
          ),
          child: _buildRow([
            if (onReorder != null) const SizedBox(),
            for (final column in columns)
              Text(
                column.title,
                style: TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
              ),
          ]),
        ),
        if (onReorder == null)
          for (final row in rows) _buildBodyRow(row, divider)
        else
          AppReorderableList<AppTableRow>(
            items: rows,
            keyOf: (row) => row.id!,
            onReorder: onReorder!,
            itemBuilder: (index, row) => _buildBodyRow(
              row,
              divider,
              handle: AppDragHandle(index: index, blocked: reorderBlocked),
            ),
          ),
        ?placeholder,
        if (hint != null) _buildHint(hint!),
      ],
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: app.colors.neutral.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (toolbar != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: app.dimensions.padding.m,
                vertical: app.dimensions.padding.sm,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: app.colors.neutral.grey5.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: toolbar,
            ),
          if (body != null) ...[body!, ?placeholder],
          if (body == null)
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= minWidth) return table;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: minWidth, child: table),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBodyRow(AppTableRow row, BorderSide divider, {Widget? handle}) {
    return Container(
      decoration: BoxDecoration(
        color: row.background,
        border: Border(bottom: divider),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: row.onTap,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: row.minHeight),
              child: _buildRow([?handle, ...row.cells]),
            ),
          ),
          ?row.expanded,
        ],
      ),
    );
  }

  /// The columns, after the one of the handles when the rows move
  List<AppTableColumn> get _columns => [
    if (onReorder != null)
      const AppTableColumn('', width: _handleWidth, compact: true),
    ...columns,
  ];

  Widget _buildRow(List<Widget> cells) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: app.dimensions.padding.xs),
      child: Row(
        children: [
          for (final (index, column) in _columns.indexed)
            column.width == null
                ? Expanded(
                    flex: column.flex,
                    child: _cell(column, cells[index]),
                  )
                : _cell(column, cells[index]),
        ],
      ),
    );
  }

  Widget _cell(AppTableColumn column, Widget child) {
    if (column.compact) {
      return SizedBox(
        width: column.width,
        child: Center(child: child),
      );
    }
    return SizedBox(
      width: column.width,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: app.dimensions.padding.sm),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _buildHint(String text) {
    final style = TextStyle(fontSize: 12, color: app.colors.neutral.grey4);
    return Padding(
      padding: EdgeInsets.all(app.dimensions.padding.l),
      child: Row(
        children: [
          Expanded(child: Text(text, style: style)),
          if (hintEnd != null)
            DefaultTextStyle.merge(style: style, child: hintEnd!),
        ],
      ),
    );
  }
}

/// Inside the table when there is nothing to list
class AppTablePlaceholder extends StatelessWidget {
  final String title;
  final String? description;
  final String action;
  final VoidCallback onPressed;

  const AppTablePlaceholder({
    required this.title,
    required this.action,
    required this.onPressed,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          if (description != null) ...[
            app.dimensions.padding.s.gap(),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: app.colors.neutral.grey4),
            ),
          ],
          app.dimensions.padding.m.gap(),
          PrimaryButton.secondary(
            onPressed: onPressed,
            title: action,
            color: app.colors.surface.control,
            h: 38,
            horizontalPadding: 14,
          ),
        ],
      ),
    );
  }
}
