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

  const AppTableRow(this.cells, {this.minHeight = 56, this.expanded});
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

  /// Info line at the bottom of the table
  final String? hint;

  final double minWidth;

  const AppSimpleTable({
    required this.columns,
    required this.rows,
    this.toolbar,
    this.placeholder,
    this.hint,
    this.minWidth = 760,
    super.key,
  });

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
            for (final column in columns)
              Text(
                column.title,
                style: TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
              ),
          ]),
        ),
        for (final row in rows)
          Container(
            decoration: BoxDecoration(border: Border(bottom: divider)),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: row.minHeight),
                  child: _buildRow(row.cells),
                ),
                ?row.expanded,
              ],
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

  Widget _buildRow(List<Widget> cells) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: app.dimensions.padding.xs),
      child: Row(
        children: [
          for (final (index, column) in columns.indexed)
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
    return Padding(
      padding: EdgeInsets.all(app.dimensions.padding.l),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
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
