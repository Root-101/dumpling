import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// An entry of [AppRowMenu]. A disabled one stays visible, with [sub] saying
/// why (e.g. *Used by 2 backups. Remove them first.*)
class AppRowMenuItem {
  final String label;
  final SvgAsset icon;
  final VoidCallback onTap;
  final String? sub;
  final bool enabled;
  final bool danger;

  /// A divider goes above it
  final bool divided;

  const AppRowMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.sub,
    this.enabled = true,
    this.danger = false,
    this.divided = false,
  });
}

/// The ⋮ button at the end of a table row and its menu
class AppRowMenu extends StatelessWidget {
  final String tooltip;
  final List<AppRowMenuItem> items;

  const AppRowMenu({required this.tooltip, required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppRowMenuItem>(
      tooltip: tooltip,
      color: app.colors.primary.backgroundForm,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 232, maxWidth: 260),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: app.colors.neutral.grey5),
      ),
      icon: app.assets.icons.actions.more.build(
        size: 18,
        color: app.colors.neutral.grey2,
      ),
      onSelected: (item) => item.onTap(),
      itemBuilder: (context) => [
        for (final item in items) ...[
          if (item.divided) const PopupMenuDivider(),
          PopupMenuItem(
            value: item,
            enabled: item.enabled,
            child: _buildItem(item),
          ),
        ],
      ],
    );
  }

  Widget _buildItem(AppRowMenuItem item) {
    final color = item.danger
        ? app.colors.status.error
        : app.colors.neutral.grey2;
    return Opacity(
      opacity: item.enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            item.icon.build(size: 16, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(fontSize: 13, color: color),
                  ),
                  if (item.sub != null)
                    Text(
                      item.sub!,
                      style: TextStyle(
                        fontSize: 11,
                        color: app.colors.neutral.grey4,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
