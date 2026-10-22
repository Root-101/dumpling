import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

BoxDecoration _panel({Color? color}) => BoxDecoration(
  color: color ?? app.colors.surface.surface1.withValues(alpha: 0.96),
  borderRadius: app.dimensions.radius.m,
  border: Border.all(color: app.colors.surface.border),
  boxShadow: const [
    BoxShadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 4)),
  ],
);

/// Top right: add a database or a destination
class AddToolbar extends StatelessWidget {
  final VoidCallback onAddSource;
  final VoidCallback onAddDestination;

  const AddToolbar({
    required this.onAddSource,
    required this.onAddDestination,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _panel(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            label: 'Database',
            type: AppButtonType.ghost,
            height: 34,
            icon: app.assets.icons.nodes.database.build(
              size: 15,
              color: colors.brand.postgres,
            ),
            onPressed: onAddSource,
          ),
          const SizedBox(width: 4),
          AppButton(
            label: 'Destination',
            type: AppButtonType.ghost,
            height: 34,
            icon: app.assets.icons.nodes.bucket.build(
              size: 15,
              color: colors.brand.accent,
            ),
            onPressed: onAddDestination,
          ),
        ],
      ),
    );
  }
}

/// Bottom left: the keyboard and mouse help
class ShortcutsPanel extends StatelessWidget {
  final bool ctrlZoom;
  final VoidCallback onClose;

  const ShortcutsPanel({
    required this.ctrlZoom,
    required this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    Widget row(String action, List<Widget> keys) => SizedBox(
      height: 23,
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: TextStyle(fontSize: 12, color: colors.text.muted),
            ),
          ),
          ...keys,
        ],
      ),
    );
    final hint = TextStyle(fontSize: 12, color: colors.text.subtle);
    return Container(
      width: 268,
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 12),
      decoration: _panel(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SHORTCUTS',
                  style: AppText.overline.copyWith(color: colors.brand.primary),
                ),
              ),
              AppIconButton(
                size: 28,
                tooltip: 'Hide shortcuts',
                onPressed: onClose,
                icon: app.assets.icons.actions.close.build(
                  size: 14,
                  color: colors.text.muted,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                row('Move canvas', [
                  const KeyCap('Space'),
                  Text(' + drag', style: hint),
                ]),
                row('Connect', [Text('drag from a port', style: hint)]),
                row('Options', [Text('right click', style: hint)]),
                row('Remove connection', [
                  Text('click it + ', style: hint),
                  const KeyCap('Del'),
                ]),
                row('Zoom', [
                  if (ctrlZoom) ...[
                    const KeyCap('Ctrl'),
                    Text(' + ', style: hint),
                  ],
                  Text('scroll', style: hint),
                ]),
                row('Zoom in / out', [
                  const KeyCap('+'),
                  const SizedBox(width: 4),
                  const KeyCap('−'),
                ]),
                row('Center canvas', [const KeyCap('F')]),
                row('Reset to 100%', [const KeyCap('0')]),
                row('Move with keys', [const KeyCap('←↑→↓')]),
                row('Close config', [const KeyCap('Esc')]),
                row('Show / hide shortcuts', [const KeyCap('?')]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom right: settings, shortcuts, center and zoom
class ViewControls extends StatelessWidget {
  final double zoom;
  final bool showSettings;
  final bool showKeys;
  final VoidCallback onSettings;
  final VoidCallback onKeys;
  final VoidCallback onFit;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const ViewControls({
    required this.zoom,
    required this.showSettings,
    required this.showKeys,
    required this.onSettings,
    required this.onKeys,
    required this.onFit,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final divider = Container(
      width: 1,
      height: 36,
      color: colors.surface.border,
    );
    final active = colors.brand.primarySelected;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface.surface1,
        borderRadius: app.dimensions.radius.s,
        border: Border.all(color: colors.surface.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _square(
            'Canvas settings',
            app.assets.icons.navigation.settings.build(
              size: 16,
              color: colors.text.secondary,
            ),
            onSettings,
            showSettings ? active : null,
          ),
          divider,
          _square(
            'Show or hide shortcuts (?)',
            app.assets.icons.actions.keyboard.build(
              size: 17,
              color: colors.text.secondary,
            ),
            onKeys,
            showKeys ? active : null,
          ),
          divider,
          Tooltip(
            message: 'Center canvas (F)',
            child: AppButton(
              label: 'Center',
              type: AppButtonType.ghost,
              height: 36,
              icon: app.assets.icons.actions.center.build(
                size: 14,
                color: colors.text.secondary,
              ),
              onPressed: onFit,
            ),
          ),
          divider,
          _square(
            'Zoom out (−)',
            Text(
              '−',
              style: TextStyle(fontSize: 16, color: colors.text.secondary),
            ),
            onZoomOut,
            null,
          ),
          divider,
          Tooltip(
            message: 'Reset to 100% (0)',
            child: SizedBox(
              width: 56,
              height: 36,
              child: TextButton(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  foregroundColor: colors.text.muted,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                  textStyle: const TextStyle(
                    fontFamily: AppText.sans,
                    fontSize: 12,
                  ),
                ),
                child: Text('${(zoom * 100).round()}%'),
              ),
            ),
          ),
          divider,
          _square(
            'Zoom in (+)',
            Text(
              '+',
              style: TextStyle(fontSize: 16, color: colors.text.secondary),
            ),
            onZoomIn,
            null,
          ),
        ],
      ),
    );
  }

  Widget _square(
    String tooltip,
    Widget icon,
    VoidCallback onPressed,
    Color? bg,
  ) => Tooltip(
    message: tooltip,
    child: SizedBox.square(
      dimension: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: bg,
          shape: const RoundedRectangleBorder(),
        ),
        child: icon,
      ),
    ),
  );
}

/// Popover of the canvas settings, above the view controls
class CanvasSettingsPopover extends StatelessWidget {
  final bool ctrlZoom;
  final VoidCallback onCtrlZoom;

  const CanvasSettingsPopover({
    required this.ctrlZoom,
    required this.onCtrlZoom,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(8),
      decoration: _panel(color: app.colors.surface.surface2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Text(
              'CANVAS',
              style: AppText.overline.copyWith(color: app.colors.brand.primary),
            ),
          ),
          AppSwitchTile(
            title: 'Hold Ctrl to zoom',
            subtitle: ctrlZoom
                ? 'Scroll moves the canvas, Ctrl + scroll zooms'
                : 'Scroll always zooms',
            value: ctrlZoom,
            onChanged: onCtrlZoom,
          ),
        ],
      ),
    );
  }
}

class ContextMenuItem {
  final String label;
  final SvgAsset icon;

  /// null: disabled (shown greyed out)
  final VoidCallback? onTap;
  final bool danger;

  const ContextMenuItem(
    this.label,
    this.icon,
    this.onTap, {
    this.danger = false,
  });
}

/// The right-click menu of the canvas
class CanvasContextMenu extends StatelessWidget {
  static const double width = 220;

  final List<ContextMenuItem> items;

  const CanvasContextMenu({required this.items, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      width: width,
      padding: const EdgeInsets.all(4),
      decoration: _panel(color: colors.surface.surface2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in items)
            Builder(
              builder: (context) {
                final color = item.onTap == null
                    ? colors.text.subtle
                    : item.danger
                    ? colors.status.error
                    : colors.text.secondary;
                return TextButton(
                  onPressed: item.onTap,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(double.infinity, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.centerLeft,
                    foregroundColor: color,
                    disabledForegroundColor: color,
                    textStyle: const TextStyle(
                      fontFamily: AppText.sans,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: app.dimensions.radius.xs,
                    ),
                  ),
                  child: Row(
                    children: [
                      item.icon.build(size: 15, color: color),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item.label)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Top right, under the toolbar, while something is not connected
class OrphansWarning extends StatelessWidget {
  final int count;

  const OrphansWarning({required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface.surface2,
          borderRadius: app.dimensions.radius.m,
          border: Border.all(color: colors.brand.accent.withValues(alpha: 0.6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x59000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            app.assets.icons.actions.warning.build(
              size: 18,
              color: colors.brand.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count == 1
                        ? '1 unconnected item'
                        : '$count unconnected items',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.brand.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Only complete flows (database → config → destination) are kept. '
                    'Everything in amber is discarded when the pipeline is saved.',
                    style: TextStyle(fontSize: 12, color: colors.text.muted),
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
