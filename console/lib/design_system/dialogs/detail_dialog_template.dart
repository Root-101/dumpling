import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog with the detail of an item (a source, a destination): the [header],
/// a row of [stats], and under them the [main] panels with the [aside] on
/// their right (below them when there is no room)
class DetailDialogTemplate extends StatelessWidget {
  final DetailHeader header;
  final List<DetailStat> stats;
  final List<Widget> main;
  final Widget aside;

  const DetailDialogTemplate({
    required this.header,
    required this.stats,
    required this.main,
    required this.aside,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppDialogFrame(
        color: app.colors.primary.background1,
        child: SizedBox(
          width: 1100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(spacing: 12, children: stats),
                      16.gap(),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final column = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 16,
                            children: main,
                          );
                          // side by side when there is room
                          if (constraints.maxWidth < 760) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [column, 16.gap(), aside],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: column),
                              16.gap(),
                              SizedBox(width: 300, child: aside),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top of [DetailDialogTemplate]: badge, name, a status chip, what it is, and
/// *Test connection* and *Edit*
class DetailHeader extends StatelessWidget {
  final TypeLook look;
  final String name;
  final String status;
  final Color statusColor;
  final String description;
  final bool testing;
  final VoidCallback onTest;
  final VoidCallback onEdit;

  const DetailHeader({
    required this.look,
    required this.name,
    required this.status,
    required this.statusColor,
    required this.description,
    required this.testing,
    required this.onTest,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 28, 16),
      decoration: BoxDecoration(
        color: colors.primary.background2,
        border: Border(
          bottom: BorderSide(
            color: colors.neutral.grey5.withValues(alpha: 0.5),
          ),
        ),
      ),
      // the title on the left, taking the room; the buttons on the right,
      // under it when the dialog is narrow
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Row(
            children: [
              TypeBadge(look: look, size: 40),
              12.gap(),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              height: 28 / 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        10.gap(),
                        _chip(),
                      ],
                    ),
                    2.gap(),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              PrimaryButton.secondary(
                onPressed: testing ? null : onTest,
                title: testing
                    ? app.intl.connections.testing
                    : app.intl.connections.test,
                icon: app.assets.icons.actions.test,
                color: colors.surface.control,
                h: 40,
                horizontalPadding: 16,
              ),
              PrimaryButton.primary(
                onPressed: onEdit,
                title: app.intl.common.edit,
                color: colors.primary.primaryAction,
                h: 40,
                w: 90,
              ),
            ],
          );
          if (constraints.maxWidth < 640) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [title, buttons],
            );
          }
          return Row(
            children: [
              Expanded(child: title),
              16.gap(),
              buttons,
            ],
          );
        },
      ),
    );
  }

  Widget _chip() {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A figure of [DetailDialogTemplate]: *Backups · 2 write here*
class DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const DetailStat(this.label, this.value, this.sub, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Expanded(
      child: DetailPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 30 / 22,
                      fontWeight: FontWeight.w700,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (sub.isNotEmpty)
                    TextSpan(
                      text: '  $sub',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.neutral.grey4,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bordered box of a section of the detail
class DetailPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const DetailPanel({
    required this.child,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: app.colors.neutral.grey5),
      ),
      child: child,
    );
  }
}

/// `FOLDERS` at the top of a [DetailPanel] and, on the right, a note or a
/// [trailing] widget
class DetailPanelTitle extends StatelessWidget {
  static TextStyle get style => TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w700,
    color: app.colors.primary.primaryFaded,
  );

  final String text;
  final String? note;
  final Widget? trailing;

  const DetailPanelTitle(this.text, {this.note, this.trailing, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: app.colors.neutral.grey5)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (note != null)
            Text(
              note!,
              style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
            ),
          ?trailing,
        ],
      ),
    );
  }
}

/// The aside of the detail: label over value (monospace when [mono]) and a
/// button at the end, e.g. *Edit connection*
class DetailFields extends StatelessWidget {
  final String title;
  final List<(String label, String value, bool mono)> items;
  final String action;
  final VoidCallback onAction;

  const DetailFields({
    required this.title,
    required this.items,
    required this.action,
    required this.onAction,
    super.key,
  });

  /// `AKIA••••••••7Q2K`: enough to tell which key it is
  static String masked(String key) => key.length <= 8
      ? '••••••••'
      : '${key.substring(0, 4)}••••••••${key.substring(key.length - 4)}';

  @override
  Widget build(BuildContext context) {
    return DetailPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(title.toUpperCase(), style: DetailPanelTitle.style),
          for (final (label, value, mono) in items)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: app.colors.neutral.grey4,
                  ),
                ),
                Text(
                  value,
                  style: mono
                      ? AppText.mono.copyWith(fontSize: 13)
                      : const TextStyle(fontSize: 13),
                ),
              ],
            ),
          PrimaryButton.secondary(
            onPressed: onAction,
            title: action,
            color: app.colors.surface.control,
            h: 38,
          ),
        ],
      ),
    );
  }
}
