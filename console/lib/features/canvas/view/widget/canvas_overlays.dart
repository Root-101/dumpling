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
            label: app.intl.canvas.addSource,
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
            label: app.intl.canvas.addDestination,
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
    final keys = app.intl.canvas.shortcuts;
    final cap = app.intl.canvas.keys;
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
                  app.intl.canvas.shortcuts.title.toUpperCase(),
                  style: AppText.overline.copyWith(color: colors.brand.primary),
                ),
              ),
              AppIconButton(
                size: 28,
                tooltip: app.intl.canvas.shortcuts.hide,
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
                row(keys.moveCanvas, [
                  KeyCap(cap.space),
                  Text(keys.drag, style: hint),
                ]),
                row(keys.connect, [Text(keys.dragFromPort, style: hint)]),
                row(keys.options, [Text(keys.rightClick, style: hint)]),
                row(app.intl.canvas.removeConnection, [
                  Text(keys.clickIt, style: hint),
                  KeyCap(cap.del),
                ]),
                row(keys.zoom, [
                  if (ctrlZoom) ...[KeyCap(cap.ctrl), Text(' + ', style: hint)],
                  Text(keys.scroll, style: hint),
                ]),
                row(keys.zoomInOut, [
                  const KeyCap('+'),
                  const SizedBox(width: 4),
                  const KeyCap('−'),
                ]),
                row(keys.center, [const KeyCap('F')]),
                row(keys.reset, [const KeyCap('0')]),
                row(keys.moveWithKeys, [const KeyCap('←↑→↓')]),
                row(keys.closeConfig, [KeyCap(cap.esc)]),
                row(keys.toggle, [const KeyCap('?')]),
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
            app.intl.canvas.view.settings,
            app.assets.icons.navigation.settings.build(
              size: 16,
              color: colors.text.secondary,
            ),
            onSettings,
            showSettings ? active : null,
          ),
          divider,
          _square(
            app.intl.canvas.view.toggleShortcuts,
            app.assets.icons.actions.keyboard.build(
              size: 17,
              color: colors.text.secondary,
            ),
            onKeys,
            showKeys ? active : null,
          ),
          divider,
          Tooltip(
            message: app.intl.canvas.view.centerTooltip,
            child: AppButton(
              label: app.intl.canvas.view.center,
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
            app.intl.canvas.view.zoomOut,
            Text(
              '−',
              style: TextStyle(fontSize: 16, color: colors.text.secondary),
            ),
            onZoomOut,
            null,
          ),
          divider,
          Tooltip(
            message: app.intl.canvas.view.reset,
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
            app.intl.canvas.view.zoomIn,
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
              app.intl.canvas.view.settingsTitle.toUpperCase(),
              style: AppText.overline.copyWith(color: app.colors.brand.primary),
            ),
          ),
          AppSwitchTile(
            title: app.intl.canvas.view.ctrlZoom,
            subtitle: ctrlZoom
                ? app.intl.canvas.view.ctrlZoomOn
                : app.intl.canvas.view.ctrlZoomOff,
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
                    app.intl.canvas.orphans(n: count),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.brand.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.intl.canvas.orphansHelp,
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

/// Bottom center, until the workspace has its first config: add a source,
/// add a destination, connect them. A step with something off the canvas
/// places it; with nothing at all, it goes to create it
class CanvasGuide extends StatelessWidget {
  final CanvasData data;
  final ValueChanged<String> onPlaceSource;
  final ValueChanged<String> onPlaceDestination;
  final VoidCallback onCreateSource;
  final VoidCallback onCreateDestination;

  const CanvasGuide({
    required this.data,
    required this.onPlaceSource,
    required this.onPlaceDestination,
    required this.onCreateSource,
    required this.onCreateDestination,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = app.intl.canvas.guide;
    final hasSource = data.sources.isNotEmpty;
    final hasDestination = data.destinations.isNotEmpty;
    final source = data.sourcePool.firstOrNull;
    final destination = data.destinationPool.firstOrNull;
    return Container(
      width: 640,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: _panel(color: app.colors.surface.surface2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.title.toUpperCase(),
            style: AppText.overline.copyWith(color: app.colors.brand.primary),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _GuideStep(
                    number: 1,
                    done: hasSource,
                    title: t.source,
                    help: t.sourceHelp,
                    action: hasSource
                        ? null
                        : source == null
                        ? (t.create, onCreateSource)
                        : (
                            t.place(name: source.name),
                            () => onPlaceSource(source.id),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GuideStep(
                    number: 2,
                    done: hasDestination,
                    title: t.destination,
                    help: t.destinationHelp,
                    action: hasDestination
                        ? null
                        : destination == null
                        ? (t.create, onCreateDestination)
                        : (
                            t.place(name: destination.name),
                            () => onPlaceDestination(destination.id),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GuideStep(
                    number: 3,
                    done: false,
                    active: hasSource && hasDestination,
                    title: t.connect,
                    help: t.connectHelp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  final int number;
  final bool done;

  /// The next one to do: the others wait, dimmed
  final bool active;
  final String title;
  final String help;
  final (String, VoidCallback)? action;

  const _GuideStep({
    required this.number,
    required this.done,
    required this.title,
    required this.help,
    this.active = true,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final accent = done ? colors.status.success : colors.brand.primary;
    final action = this.action;
    return Opacity(
      opacity: active || done ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface.surface1,
          borderRadius: app.dimensions.radius.m,
          border: Border.all(
            color: done
                ? colors.status.success.withValues(alpha: 0.5)
                : colors.surface.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.16),
                  ),
                  child: done
                      ? app.assets.icons.actions.check.build(
                          size: 13,
                          color: accent,
                        )
                      : Text(
                          '$number',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              help,
              style: TextStyle(fontSize: 12, color: colors.text.muted),
            ),
            if (action != null && !done) ...[
              const Spacer(),
              const SizedBox(height: 10),
              AppButton(
                label: action.$1,
                type: AppButtonType.secondary,
                height: 30,
                onPressed: action.$2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
