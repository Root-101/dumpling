import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// An option of an [AppFilterGroup]
class AppFilterOption {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// How many items it leaves, shown on the right
  final int? count;

  /// Before the label, e.g. the badge of a type
  final Widget? leading;

  const AppFilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.leading,
  });
}

/// A group of options of the filter panel: one option of each group is on
/// (*All* included); between groups all of them must hold (that logic is the
/// caller's)
class AppFilterGroup {
  final String title;
  final List<AppFilterOption> options;

  const AppFilterGroup({required this.title, required this.options});
}

/// *Filters* button with the number of active filters. It opens a panel below
/// with [groups] of options that apply each change at once
class AppFilterButton extends StatefulWidget {
  static const double height = 40;

  final int activeCount;
  final List<AppFilterGroup> groups;

  /// Clears every filter (the panel's *Clear all*)
  final VoidCallback onClear;

  /// Footer of the panel, e.g. how many items the filters leave
  final String? note;

  final double panelWidth;

  const AppFilterButton({
    required this.activeCount,
    required this.groups,
    required this.onClear,
    this.note,
    this.panelWidth = 280,
    super.key,
  });

  @override
  State<AppFilterButton> createState() => _AppFilterButtonState();
}

class _AppFilterButtonState extends State<AppFilterButton> {
  static const double _gap = 8;

  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();

  void _close() {
    if (_portal.isShowing) {
      _portal.hide();
      setState(() {});
    }
  }

  void _toggle() {
    if (_portal.isShowing) {
      _close();
    } else {
      _portal.show();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = _portal.isShowing;
    final active = widget.activeCount > 0;
    final radius = app.dimensions.border.borderRadius.s;
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildPanel,
      child: CompositedTransformTarget(
        link: _link,
        child: AppFocusRing(
          borderRadius: radius,
          child: Material(
            color: open
                ? app.colors.primary.purple
                : app.colors.surface.control,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: open || active
                    ? app.colors.primary.primaryFaded
                    : app.colors.neutral.grey5,
              ),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: _toggle,
              child: Container(
                height: AppFilterButton.height,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    app.assets.icons.actions.filter.build(
                      size: 16,
                      color: app.colors.neutral.white,
                    ),
                    app.dimensions.padding.s.gap(),
                    Text(
                      app.intl.common.filters,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (active) ...[
                      app.dimensions.padding.s.gap(),
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: app.colors.primary.secondary,
                          borderRadius: app.dimensions.border.borderRadius.xs,
                        ),
                        child: Text(
                          '${widget.activeCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: app.colors.primary.background1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    // Room below the button: on a short window the panel scrolls instead of
    // being cut off by the bottom edge
    final button = this.context.findRenderObject() as RenderBox?;
    final buttonBottom = button == null
        ? 0.0
        : button.localToGlobal(Offset.zero).dy + button.size.height;
    final maxHeight =
        (MediaQuery.sizeOf(context).height -
                buttonBottom -
                _gap -
                app.dimensions.padding.l)
            .clamp(160.0, double.infinity);
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _close},
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, _gap),
              child: FocusScope(
                autofocus: true,
                // the parent rebuilds the button with the new filter, and with
                // it the panel
                child: _AppFilterPanel(
                  groups: widget.groups,
                  active: widget.activeCount > 0,
                  onClear: widget.onClear,
                  onDone: _close,
                  note: widget.note,
                  width: widget.panelWidth,
                  maxHeight: maxHeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppFilterPanel extends StatelessWidget {
  final List<AppFilterGroup> groups;
  final bool active;
  final VoidCallback onClear;
  final VoidCallback onDone;
  final String? note;
  final double width;
  final double maxHeight;

  const _AppFilterPanel({
    required this.groups,
    required this.active,
    required this.onClear,
    required this.onDone,
    required this.note,
    required this.width,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: app.colors.neutral.transparent,
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: maxHeight),
        padding: EdgeInsets.all(app.dimensions.padding.s),
        decoration: BoxDecoration(
          color: app.colors.primary.backgroundForm,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: app.colors.neutral.grey5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, group) in groups.indexed) ...[
                      if (index > 0) app.dimensions.padding.s.gap(),
                      Expanded(child: _buildGroup(group)),
                    ],
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(AppFilterGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
          child: Text(
            group.title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: app.colors.primary.primaryFaded,
            ),
          ),
        ),
        for (final option in group.options) _FilterOptionTile(option: option),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      margin: EdgeInsets.only(top: app.dimensions.padding.s),
      padding: EdgeInsets.fromLTRB(4, app.dimensions.padding.s, 4, 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: app.colors.neutral.grey5.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: active ? onClear : null,
            child: Text(
              app.intl.common.clearAll,
              style: TextStyle(
                fontSize: 13,
                color: active
                    ? app.colors.primary.primaryFaded
                    : app.colors.neutral.grey5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              note ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
            ),
          ),
          PrimaryButton.primary(
            onPressed: onDone,
            title: app.intl.common.done,
            color: app.colors.primary.primaryAction,
            h: 34,
            w: 72,
          ),
        ],
      ),
    );
  }
}

class _FilterOptionTile extends StatelessWidget {
  final AppFilterOption option;

  const _FilterOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final selected = option.selected;
    final radius = BorderRadius.circular(6);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: Material(
        color: selected
            ? app.colors.primary.primaryFaded.withValues(alpha: 0.14)
            : app.colors.neutral.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: option.onTap,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Visibility.maintain(
                  visible: selected,
                  child: app.assets.icons.actions.check.build(
                    size: 14,
                    color: app.colors.primary.primaryLight,
                  ),
                ),
                const SizedBox(width: 10),
                if (option.leading != null) ...[
                  option.leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected
                          ? app.colors.neutral.white
                          : app.colors.neutral.grey2,
                    ),
                  ),
                ),
                if (option.count != null)
                  Text(
                    '${option.count}',
                    style: TextStyle(
                      fontSize: 12,
                      color: app.colors.neutral.grey4,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
