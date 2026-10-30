import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Top of a screen: its title, what it is for and its main [actions] (spaced
/// apart here, not by the screens). Inside
/// a workspace the title reads `Workspace › Screen`
class PageHeader extends StatelessWidget {
  final String title;
  final String? workspace;
  final String? description;
  final List<Widget> actions;

  const PageHeader({
    required this.title,
    this.workspace,
    this.description,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: app.colors.neutral.grey4,
      fontWeight: FontWeight.w500,
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: EdgeInsets.fromLTRB(
        14,
        app.dimensions.padding.sm,
        app.dimensions.padding.xxl,
        app.dimensions.padding.sm,
      ),
      color: app.colors.primary.background2,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      if (workspace != null) ...[
                        TextSpan(text: workspace, style: muted),
                        TextSpan(
                          text: ' › ',
                          style: muted.copyWith(
                            color: app.colors.neutral.grey5,
                          ),
                        ),
                      ],
                      TextSpan(text: title),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description != null)
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: app.colors.neutral.grey4,
                    ),
                  ),
              ],
            ),
          ),
          if (actions.isNotEmpty) ...[
            app.dimensions.padding.l.gap(),
            Row(spacing: app.dimensions.padding.sm, children: actions),
          ],
        ],
      ),
    );
  }
}

/// What goes under a [PageHeader] inside the shell: a panel whose top-left
/// corner curves where the rail and the header meet
class PagePanel extends StatelessWidget {
  final Widget child;

  const PagePanel({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final background = app.colors.primary.background1;
    // the border is the outer box showing 1 px around the inner one: Flutter
    // only rounds uniform borders
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
      child: ColoredBox(
        color: Color.alphaBlend(
          app.colors.neutral.grey5.withValues(alpha: 0.75),
          background,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 1, top: 1),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(15)),
            child: ColoredBox(color: background, child: child),
          ),
        ),
      ),
    );
  }
}
