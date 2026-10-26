import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Top of a screen: its title, what it is for and its main [actions]
class PageHeader extends StatelessWidget {
  final String title;
  final String? description;
  final List<Widget> actions;

  const PageHeader({
    required this.title,
    this.description,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: EdgeInsets.symmetric(
        horizontal: app.dimensions.padding.xxl,
        vertical: app.dimensions.padding.sm,
      ),
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        border: Border(
          bottom: BorderSide(
            color: app.colors.neutral.grey5.withValues(alpha: 0.75),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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
          ...actions,
        ],
      ),
    );
  }
}
