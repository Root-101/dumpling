import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The pointer handlers the canvas gives to its nodes
class NodeHandlers {
  /// Press on the body of a node: drag it, or select on release
  final void Function(NodeKind kind, String id, PointerDownEvent e) nodeDown;

  /// Press on an out port: start a wire
  final void Function(NodeKind kind, String id, PointerDownEvent e) portDown;

  /// Press on a button inside a node: the canvas must not drag nor pan
  final VoidCallback claim;

  const NodeHandlers({
    required this.nodeDown,
    required this.portDown,
    required this.claim,
  });
}

BoxDecoration _nodeDecoration({List<BoxShadow>? shadow}) => BoxDecoration(
  color: app.colors.surface.surface1,
  borderRadius: app.dimensions.radius.l,
  boxShadow:
      shadow ??
      const [
        BoxShadow(
          color: Color(0x47000000),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
);

/// Painted over the content, so a thicker (selected) border doesn't move it
/// Orphans (not connected on both sides) get an amber border: saving drops them
BoxDecoration _nodeBorder(bool selected, {bool orphan = false}) =>
    BoxDecoration(
      borderRadius: app.dimensions.radius.l,
      border: Border.all(
        color: selected
            ? app.colors.brand.primary
            : orphan
            ? app.colors.brand.accent
            : app.colors.surface.border,
        width: selected ? 2 : (orphan ? 1.5 : 1),
      ),
    );

/// A round port. Only out ports ([onDown] set) take the pointer, and grow on hover
class NodePort extends StatefulWidget {
  final double size;
  final Color fill;
  final Color border;
  final String? tooltip;
  final PointerDownEventListener? onDown;

  const NodePort({
    required this.size,
    required this.fill,
    required this.border,
    super.key,
    this.tooltip,
    this.onDown,
  });

  @override
  State<NodePort> createState() => _NodePortState();
}

class _NodePortState extends State<NodePort> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.fill,
        shape: BoxShape.circle,
        border: Border.all(color: widget.border, width: 2),
      ),
    );
    if (widget.onDown == null) return dot;
    return Tooltip(
      message: widget.tooltip ?? '',
      child: MouseRegion(
        cursor: SystemMouseCursors.precise,
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: Listener(
          onPointerDown: widget.onDown,
          child: AnimatedScale(
            scale: hover ? 1.35 : 1,
            duration: const Duration(milliseconds: 100),
            child: dot,
          ),
        ),
      ),
    );
  }
}

/// The body of a node: grab cursor and the pointer handlers of the canvas
class _NodeBody extends StatelessWidget {
  final NodeKind kind;
  final String id;
  final NodeHandlers handlers;
  final Widget child;

  const _NodeBody({
    required this.kind,
    required this.id,
    required this.handlers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Listener(
        onPointerDown: (e) => handlers.nodeDown(kind, id, e),
        child: child,
      ),
    );
  }
}

/// Small square with an icon or the abbreviation of an engine
class _Badge extends StatelessWidget {
  final Color background;
  final Widget child;

  const _Badge({required this.background, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: app.dimensions.radius.s,
      ),
      child: child,
    );
  }
}

class SourceNodeView extends StatelessWidget {
  final SourceNode source;
  final bool selected;

  /// Has at least one config (else its port is amber: connect me)
  final bool used;
  final NodeHandlers handlers;

  const SourceNodeView({
    required this.source,
    required this.selected,
    required this.used,
    required this.handlers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final size = CanvasGeometry.sourceSize;
    // ports and buttons are siblings of the body: they stick out of it, and
    // only an UnboundedStack takes pointers outside of its size
    return UnboundedStack(
      children: [
        _NodeBody(
          kind: NodeKind.source,
          id: source.id,
          handlers: handlers,
          child: Container(
            width: size.width,
            height: size.height,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _nodeDecoration(),
            foregroundDecoration: _nodeBorder(selected, orphan: !used),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TypeBadge(look: source.look),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: AppText.nodeTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            source.engine,
                            style: AppText.meta,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  source.detail,
                  style: TextStyle(fontSize: 11, color: colors.text.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -9,
          top: size.height / 2 - 9,
          child: NodePort(
            size: 18,
            tooltip: app.intl.canvas.dragToDestination,
            fill: selected
                ? colors.brand.primary
                : used
                ? colors.surface.background
                : colors.brand.accent,
            border: selected
                ? colors.brand.primary
                : used
                ? colors.surface.wire
                : colors.brand.accent,
            onDown: (e) => handlers.portDown(NodeKind.source, source.id, e),
          ),
        ),
      ],
    );
  }
}

class ConfigNodeView extends StatelessWidget {
  final BackupConfig config;
  final bool selected;
  final NodeHandlers handlers;
  final VoidCallback onEdit;

  /// Null while it can't run (not saved, incomplete or running)
  final VoidCallback? onRun;
  final VoidCallback onDelete;

  const ConfigNodeView({
    required this.config,
    required this.selected,
    required this.handlers,
    required this.onEdit,
    required this.onRun,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final size = CanvasGeometry.configSize;
    final portY = CanvasGeometry.configPortY;
    final last = config.lastRun;
    final next = config.nextRun;
    final time = app.dateFormatter.time;
    final lastColor = switch (last?.status) {
      RunStatus.success => colors.status.success,
      RunStatus.failed => colors.status.error,
      RunStatus.running || null => colors.status.pending,
    };
    final lastLabel = switch (last?.status) {
      RunStatus.success => app.intl.canvas.runStatus.success,
      RunStatus.failed => app.intl.canvas.runStatus.failed,
      RunStatus.running => app.intl.canvas.runStatus.running,
      null => '',
    };
    final schedule = config.schedule;
    final rowStyle = TextStyle(
      fontSize: 11,
      height: 16 / 11,
      color: colors.text.secondary,
    );
    // the same time in local, small and grey under its row
    Widget local(DateTime at) => Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        app.intl.time.local(time: time.format(at.toLocal())),
        style: TextStyle(
          fontSize: 10,
          height: 14 / 10,
          color: colors.text.subtle,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    // ports and buttons are siblings of the body: they stick out of it, and
    // only an UnboundedStack takes pointers outside of its size
    return UnboundedStack(
      children: [
        _NodeBody(
          kind: NodeKind.config,
          id: config.id,
          handlers: handlers,
          child: Container(
            width: size.width,
            decoration: _nodeDecoration(
              shadow: selected
                  ? [
                      BoxShadow(
                        color: colors.brand.primary.withValues(alpha: 0.14),
                        spreadRadius: 4,
                      ),
                      const BoxShadow(
                        color: Color(0x59000000),
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            foregroundDecoration: _nodeBorder(
              selected,
              orphan: CanvasData.configOrphan(config),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      _Badge(
                        background: colors.brand.primary.withValues(
                          alpha: 0.14,
                        ),
                        child: app.assets.icons.nodes.clock.build(
                          size: 16,
                          color: colors.brand.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // the cron on the line of the name: the line
                            // under it has the whole width
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    config.name,
                                    style: AppText.nodeTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (schedule != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    height: 20,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: colors.surface.control,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      schedule,
                                      style: AppText.mono.copyWith(
                                        fontSize: 11,
                                        color: colors.text.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              schedule == null
                                  ? app.intl.canvas.workspaceDefault
                                  : config.enabled
                                  ? Frequency.of(schedule).label
                                  : app.intl.canvas.disabled,
                              style: AppText.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: colors.surface.border.withValues(alpha: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: lastColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            app.intl.canvas.last,
                            style: rowStyle.copyWith(color: colors.text.subtle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              last == null
                                  ? app.intl.canvas.neverRun
                                  : app.intl.time.utc(
                                      time: time.format(last.startedAt.toUtc()),
                                    ),
                              style: rowStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            lastLabel,
                            style: rowStyle.copyWith(
                              color: lastColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (last != null) local(last.startedAt),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.brand.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            app.intl.canvas.next,
                            style: rowStyle.copyWith(color: colors.text.subtle),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              next == null
                                  ? '—'
                                  : app.intl.time.utc(
                                      time: time.format(next.toUtc()),
                                    ),
                              style: rowStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (next != null) local(next),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -6,
          top: portY - 6,
          child: NodePort(
            size: 12,
            fill: selected
                ? colors.brand.primary
                : config.sourceId == null
                ? colors.brand.accent
                : colors.surface.background,
            border: selected
                ? colors.brand.primary
                : config.sourceId == null
                ? colors.brand.accent
                : colors.surface.wire,
          ),
        ),
        Positioned(
          right: -9,
          top: portY - 9,
          child: NodePort(
            size: 18,
            tooltip: app.intl.canvas.dragToDestination,
            // amber: free port, like an unconnected source
            fill: selected
                ? colors.brand.primary
                : config.destinationId == null
                ? colors.brand.accent
                : colors.surface.background,
            border: selected
                ? colors.brand.primary
                : config.destinationId == null
                ? colors.brand.accent
                : colors.surface.wire,
            onDown: (e) => handlers.portDown(NodeKind.config, config.id, e),
          ),
        ),
        if (selected)
          // above the node: on it they would cover the cron of its title
          Positioned(
            right: -11,
            top: -32,
            child: Listener(
              onPointerDown: (_) => handlers.claim(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  _CornerButton(
                    tooltip: app.intl.canvas.editConfig,
                    onPressed: onEdit,
                    icon: app.assets.icons.actions.edit,
                    color: colors.text.secondary,
                  ),
                  _CornerButton(
                    tooltip: app.intl.canvas.run.button,
                    onPressed: onRun,
                    icon: app.assets.icons.actions.play,
                    color: colors.brand.primary,
                  ),
                  _CornerButton(
                    tooltip: app.intl.canvas.deleteConfig,
                    onPressed: onDelete,
                    icon: app.assets.icons.actions.delete,
                    color: colors.status.error,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A round action on the corner of a selected node
class _CornerButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback? onPressed;
  final SvgAsset icon;
  final Color color;

  const _CornerButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface.control,
          border: Border.all(color: colors.surface.border),
        ),
        child: AppIconButton(
          size: 24,
          tooltip: tooltip,
          onPressed: onPressed,
          icon: icon.build(size: 13, color: color),
        ),
      ),
    );
  }
}

class DestinationNodeView extends StatelessWidget {
  final DestinationNode destination;

  /// The (folder) target of the selected config here: '' = the root, null = none
  final String? selectedFolder;

  /// Where the wire being dragged would land: '' = the root, null = none
  final String? targetFolder;
  final bool linking;

  /// Some config writes to the root
  final bool rootUsed;

  /// No config writes here
  final bool orphan;
  final NodeHandlers handlers;
  final VoidCallback onAddFolder;

  const DestinationNodeView({
    required this.destination,
    required this.selectedFolder,
    required this.targetFolder,
    required this.linking,
    required this.rootUsed,
    required this.orphan,
    required this.handlers,
    required this.onAddFolder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final d = destination;
    final noFolders = d.folders.isEmpty;
    final rootSel = selectedFolder == '';

    Widget dropOutline(bool target, Widget child) {
      if (target) {
        return DashedBorder(
          color: colors.brand.accent,
          radius: 6,
          child: child,
        );
      }
      if (linking) {
        return DashedBorder(
          color: colors.brand.accent.withValues(alpha: 0.5),
          strokeWidth: 1,
          radius: 6,
          child: child,
        );
      }
      return child;
    }

    // ports are siblings of the body so they paint over its border
    return UnboundedStack(
      children: [
        _NodeBody(
          kind: NodeKind.destination,
          id: d.id,
          handlers: handlers,
          child: Container(
            width: CanvasGeometry.destinationWidth,
            height: CanvasGeometry.destinationHeight(d),
            padding: const EdgeInsets.symmetric(vertical: 1),
            decoration: _nodeDecoration(),
            foregroundDecoration: _nodeBorder(false, orphan: orphan),
            child: Column(
              children: [
                SizedBox(
                  height: CanvasGeometry.destinationHeader - 1,
                  child: dropOutline(
                    noFolders && targetFolder == '',
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          TypeBadge(look: d.look),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.name,
                                  style: AppText.nodeTitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  d.detail,
                                  style: AppText.meta,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: colors.surface.border.withValues(alpha: 0.5),
                ),
                const SizedBox(height: CanvasGeometry.destinationPadding),
                for (final f in d.folders)
                  _FolderRow(
                    folder: f,
                    selected: selectedFolder == f,
                    wrap: (child) => dropOutline(targetFolder == f, child),
                  ),
                if (noFolders)
                  Container(
                    height: CanvasGeometry.rootNote,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      app.intl.destinations.bucketRoot,
                      style: AppText.meta,
                    ),
                  ),
                Listener(
                  onPointerDown: (_) => handlers.claim(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 2),
                    child: DashedBorder(
                      color: colors.surface.border,
                      strokeWidth: 1,
                      radius: 8,
                      dash: 4,
                      gap: 3,
                      child: SizedBox(
                        height: 30,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: onAddFolder,
                          style: TextButton.styleFrom(
                            foregroundColor: colors.text.muted,
                            textStyle: const TextStyle(
                              fontFamily: AppText.sans,
                              fontSize: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: app.dimensions.radius.s,
                            ),
                          ),
                          child: Text(app.intl.canvas.addFolder),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (noFolders)
          Positioned(
            left: -6,
            top: 30 - 6,
            child: NodePort(
              size: 12,
              fill: rootSel ? colors.brand.primary : colors.surface.background,
              border: rootSel
                  ? colors.brand.primary
                  : rootUsed
                  ? colors.surface.wire
                  : colors.text.subtle,
            ),
          ),
        for (final (i, f) in d.folders.indexed)
          Positioned(
            left: -6,
            top:
                1 +
                CanvasGeometry.destinationHeader +
                CanvasGeometry.destinationPadding +
                CanvasGeometry.folderRow * i +
                14,
            child: NodePort(
              size: 12,
              fill: selectedFolder == f
                  ? colors.brand.primary
                  : colors.surface.background,
              border: selectedFolder == f
                  ? colors.brand.primary
                  : colors.surface.wire,
            ),
          ),
      ],
    );
  }
}

class _FolderRow extends StatelessWidget {
  /// Its path, without slashes around it
  final String folder;
  final bool selected;
  final Widget Function(Widget child) wrap;

  const _FolderRow({
    required this.folder,
    required this.selected,
    required this.wrap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return SizedBox(
      height: CanvasGeometry.folderRow,
      child: wrap(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? colors.brand.primary.withValues(alpha: 0.10)
                : null,
            borderRadius: app.dimensions.radius.xs,
          ),
          child: Row(
            children: [
              app.assets.icons.nodes.folder.build(
                size: 15,
                color: selected ? colors.brand.primary : colors.text.subtle,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  FolderPath.show(folder),
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono.copyWith(
                    fontSize: 12,
                    color: selected
                        ? colors.text.primary
                        : colors.text.secondary,
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
