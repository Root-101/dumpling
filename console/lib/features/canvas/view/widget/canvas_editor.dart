import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Pan in progress: where the pointer and the pan were when it started
typedef _Pan = ({Offset pointer, Offset pan});

/// Node drag in progress. [grab] is the pointer minus the node position
typedef _Drag = ({
  NodeKind kind,
  String id,
  Offset grab,
  Offset start,
  bool moved,
});

/// Wire in progress, from a source (new config or attach) or a config (relink)
typedef _Link = ({NodeKind kind, String id, Offset point});

/// A wire picked with a click: the config and which of its two wires
typedef _WireRef = (String, WireEnd);

/// The right-click menu: where (view coordinates) and its options
typedef _Menu = ({Offset at, List<ContextMenuItem> items});

/// The interactive canvas editor. World coordinates are those of the
/// nodes; the view shows them translated by [_pan] and scaled by [_zoom]
class CanvasEditor extends StatefulWidget {
  /// Opens with the nodes centered (at most at 100 %); off, at the origin
  final bool center;

  const CanvasEditor({this.center = true, super.key});

  @override
  State<CanvasEditor> createState() => _CanvasEditorState();
}

class _CanvasEditorState extends State<CanvasEditor>
    with SingleTickerProviderStateMixin {
  static const double _minZoom = 0.4;
  static const double _maxZoom = 2;

  final FocusNode _focus = FocusNode(debugLabel: 'canvas');
  final GlobalKey _viewport = GlobalKey();
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  Offset _pan = Offset.zero;
  double _zoom = 1;
  bool _ctrlZoom = true;

  /// Shortcuts and settings are popovers above the view controls: one at a time
  bool _showKeys = false;
  bool _showSettings = false;
  bool _space = false;

  _Pan? _panning;
  _Drag? _drag;
  _Link? _link;
  _WireRef? _wire;
  _Menu? _menu;

  /// The press that opened the menu (or happened inside it) must not close it
  bool _keepMenu = false;

  /// A child (node, port, button, overlay) took the pointer down, so the
  /// background must not start a pan. Children get the event first
  bool _claimed = false;

  CanvasCubit get _cubit => context.read<CanvasCubit>();

  @override
  void initState() {
    super.initState();
    // after the first frame: the view has its size
    if (widget.center) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fit(maxZoom: 1);
      });
    }
  }

  @override
  void dispose() {
    _flow.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ---------- coordinates ----------

  RenderBox? get _box =>
      _viewport.currentContext?.findRenderObject() as RenderBox?;

  Size get _viewSize => _box?.size ?? const Size(1056, 836);

  Offset _toLocal(Offset global) => _box?.globalToLocal(global) ?? global;

  Offset _toWorld(Offset global) => (_toLocal(global) - _pan) / _zoom;

  // ---------- viewport ----------

  /// Zoom keeping the point [c] (view coordinates) still
  void _zoomAt(double z, Offset c) {
    final zoom = z.clamp(_minZoom, _maxZoom);
    final k = zoom / _zoom;
    setState(() {
      _zoom = zoom;
      _pan = c - (c - _pan) * k;
    });
  }

  void _zoomBy(double f) => _zoomAt(_zoom * f, _viewSize.center(Offset.zero));

  void _reset() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  /// From the first column label to the end of the last one
  static const double _labelsLeft = 40, _labelsRight = 880;

  void _fit({double maxZoom = 1.25}) {
    final b = CanvasGeometry.bounds(_cubit.state.data);
    // nothing yet: the column labels centered across, at their height
    if (b.isEmpty) {
      return setState(() {
        _zoom = 1;
        _pan = Offset(
          (_viewSize.width - (_labelsRight - _labelsLeft)) / 2 - _labelsLeft,
          0,
        );
      });
    }
    const pad = 64.0;
    final size = _viewSize;
    final z = math
        .min(
          (size.width - pad * 2) / b.width,
          (size.height - pad * 2) / b.height,
        )
        .clamp(_minZoom, maxZoom);
    setState(() {
      _zoom = z;
      _pan = Offset(
        (size.width - b.width * z) / 2 - b.left * z,
        (size.height - b.height * z) / 2 - b.top * z,
      );
    });
  }

  void _panBy(Offset d) => setState(() => _pan += d);

  // ---------- pointer ----------

  void _claim() => _claimed = true;

  void _startPan(PointerDownEvent e) =>
      _panning = (pointer: e.position, pan: _pan);

  void _nodeDown(NodeKind kind, String id, PointerDownEvent e) {
    if (_claimed) return;
    _claimed = true;
    _wire = null;
    if (_space || e.buttons == kMiddleMouseButton) {
      _startPan(e);
      return;
    }
    if (e.buttons == kSecondaryButton) {
      _openMenu(e, _nodeMenu(kind, id));
      return;
    }
    if (e.buttons != kPrimaryButton) return;
    final s = _cubit.state.data;
    final pos = switch (kind) {
      NodeKind.source => s.source(id)!.pos,
      NodeKind.config => s.configs.firstWhere((c) => c.id == id).pos,
      NodeKind.destination => s.destination(id)!.pos,
    };
    final p = _toWorld(e.position);
    setState(
      () => _drag = (kind: kind, id: id, grab: p - pos, start: p, moved: false),
    );
  }

  void _portDown(NodeKind kind, String id, PointerDownEvent e) {
    if (_claimed) return;
    _claimed = true;
    _wire = null;
    if (_space || e.buttons == kMiddleMouseButton) {
      _startPan(e);
      return;
    }
    if (e.buttons == kSecondaryButton) {
      _openMenu(e, _nodeMenu(kind, id));
      return;
    }
    if (e.buttons != kPrimaryButton) return;
    if (kind == NodeKind.config) _cubit.select(id);
    setState(() => _link = (kind: kind, id: id, point: _toWorld(e.position)));
  }

  /// Last of the pointer-down handlers (it wraps the rest)
  void _canvasDown(PointerDownEvent e) {
    _focus.requestFocus();
    // any press outside the menu closes it
    if (!_keepMenu && _menu != null) setState(() => _menu = null);
    _keepMenu = false;
    if (_claimed) {
      _claimed = false;
      return;
    }
    final world = _toWorld(e.position);
    final wire = CanvasGeometry.hitWire(_cubit.state.data, world, 6 / _zoom);
    setState(() {
      _showSettings = false;
      // only Space + drag (or the middle button) moves the canvas
      if (_space || e.buttons == kMiddleMouseButton) {
        _startPan(e);
      } else if (e.buttons == kSecondaryButton) {
        _wire = wire;
        _openMenu(e, wire != null ? _wireMenu() : _emptyMenu(world));
      } else {
        // a click picks the wire under it; on empty space it clears the picks
        _wire = wire;
        if (wire == null) _cubit.select(null);
      }
    });
  }

  // ---------- context menu ----------

  void _openMenu(PointerDownEvent e, List<ContextMenuItem> items) {
    final size = _viewSize;
    final at = _toLocal(e.position);
    // inside the view: flip left / up near the edges
    final h = items.length * 36.0 + 10;
    final x = at.dx + CanvasContextMenu.width > size.width - 8
        ? at.dx - CanvasContextMenu.width
        : at.dx;
    final y = at.dy + h > size.height - 8 ? at.dy - h : at.dy;
    _keepMenu = true;
    setState(() {
      _showSettings = false;
      _menu = (at: Offset(math.max(8, x), math.max(8, y)), items: items);
    });
  }

  /// Runs a menu option and closes the menu
  VoidCallback _act(VoidCallback f) => () {
    f();
    setState(() => _menu = null);
  };

  /// The dialog of config [id]: what it leaves goes to the draft of the
  /// canvas, saved with the rest
  Future<void> _openConfig(String id) async {
    final s = _cubit.state.data;
    final config = s.config(id);
    if (config == null) return;
    await ConfigDialog.open(
      context: context,
      config: config,
      source: config.sourceId == null ? null : s.source(config.sourceId!),
      destination: config.destinationId == null
          ? null
          : s.destination(config.destinationId!),
      onSave: (edited) async {
        _cubit.applyConfig(edited);
        return null;
      },
      onDelete: () => _cubit.deleteConfig(id),
    );
    if (mounted) _cubit.select(null);
  }

  /// A run uses the saved config, complete and not running already
  bool _canRun(BackupConfig config) =>
      !config.id.startsWith(CanvasCubit.newPrefix) &&
      !CanvasData.configOrphan(config) &&
      !(config.lastRun?.running ?? false);

  List<ContextMenuItem> _nodeMenu(NodeKind kind, String id) {
    final icons = app.assets.icons;
    final config = kind == NodeKind.config
        ? _cubit.state.data.config(id)
        : null;
    final canRun = config != null && _canRun(config);
    return [
      if (config != null) ...[
        ContextMenuItem(
          app.intl.canvas.editConfig,
          icons.actions.edit,
          _act(() => _openConfig(id)),
        ),
        ContextMenuItem(
          app.intl.canvas.run.button,
          icons.actions.play,
          canRun ? _act(() => _cubit.runNow(id)) : null,
        ),
      ],
      switch (kind) {
        NodeKind.source => ContextMenuItem(
          app.intl.canvas.removeFromCanvas,
          icons.actions.delete,
          _act(() => _cubit.removeSource(id)),
          danger: true,
        ),
        NodeKind.config => ContextMenuItem(
          app.intl.canvas.deleteConfig,
          icons.actions.delete,
          _act(() => _cubit.deleteConfig(id)),
          danger: true,
        ),
        NodeKind.destination => ContextMenuItem(
          app.intl.canvas.removeFromCanvas,
          icons.actions.delete,
          _act(() => _cubit.removeDestination(id)),
          danger: true,
        ),
      },
    ];
  }

  List<ContextMenuItem> _wireMenu() => [
    ContextMenuItem(
      app.intl.canvas.removeConnection,
      app.assets.icons.actions.delete,
      _act(_deleteWire),
      danger: true,
    ),
  ];

  /// Add a node of the pool where the menu was opened
  List<ContextMenuItem> _emptyMenu(Offset world) {
    final at = Offset(world.dx.roundToDouble(), world.dy.roundToDouble());
    final columns = app.intl.canvas.columns;
    return [
      ContextMenuItem.header(columns.sources),
      ..._sourceItems(at),
      ContextMenuItem.header(columns.destinations),
      ..._destinationItems(at),
    ];
  }

  /// One item per source off the canvas; [at] null: stacked in its column
  List<ContextMenuItem> _sourceItems([Offset? at]) {
    final pool = _cubit.state.data.sourcePool;
    final icon = app.assets.icons.nodes.database;
    return pool.isEmpty
        ? [ContextMenuItem(app.intl.canvas.allSourcesPlaced, icon, null)]
        : [
            for (final x in pool)
              ContextMenuItem(
                x.name,
                icon,
                _act(() => _cubit.addSource(x.id, at)),
              ),
          ];
  }

  List<ContextMenuItem> _destinationItems([Offset? at]) {
    final pool = _cubit.state.data.destinationPool;
    final icon = app.assets.icons.nodes.bucket;
    return pool.isEmpty
        ? [ContextMenuItem(app.intl.canvas.allDestinationsPlaced, icon, null)]
        : [
            for (final x in pool)
              ContextMenuItem(
                x.name,
                icon,
                _act(() => _cubit.addDestination(x.id, at)),
              ),
          ];
  }

  /// Another section of this workspace (to create what the canvas lacks)
  void _open(String section) {
    final slug = _cubit.state.data.workspace;
    if (slug != null) RouteNames.openWorkspace(slug, section: section);
  }

  /// The toolbar opens its menu under itself. On release, so the press that
  /// opened it is over: no need to keep it from closing the menu
  void _openToolbarMenu(List<ContextMenuItem> items) {
    setState(() {
      _showSettings = false;
      _menu = (at: const Offset(16, 64), items: items);
    });
  }

  void _toggleKeys() => setState(() {
    _showKeys = !_showKeys;
    if (_showKeys) _showSettings = false;
  });

  void _toggleSettings() => setState(() {
    _showSettings = !_showSettings;
    if (_showSettings) _showKeys = false;
  });

  void _deleteWire() {
    final wire = _wire;
    if (wire == null) return;
    _cubit.disconnect(wire.$1, wire.$2);
    setState(() => _wire = null);
  }

  void _pointerMove(PointerMoveEvent e) {
    final panning = _panning;
    final drag = _drag;
    final link = _link;
    if (panning != null) {
      setState(() => _pan = panning.pan + (e.position - panning.pointer));
    } else if (drag != null) {
      final p = _toWorld(e.position);
      final pos = p - drag.grab;
      final moved = drag.moved || (p - drag.start).distanceSquared > 16;
      _drag = (
        kind: drag.kind,
        id: drag.id,
        grab: drag.grab,
        start: drag.start,
        moved: moved,
      );
      // the jitter of a click is not an edit
      if (moved) {
        _cubit.move(
          drag.kind,
          drag.id,
          Offset(pos.dx.roundToDouble(), pos.dy.roundToDouble()),
        );
      }
    } else if (link != null) {
      setState(
        () =>
            _link = (kind: link.kind, id: link.id, point: _toWorld(e.position)),
      );
    }
  }

  void _pointerUp(PointerEvent e) {
    final drag = _drag;
    final link = _link;
    if (drag != null && !drag.moved) {
      // a click selects a config; its edit is a button of its corner
      _cubit.tapNode(drag.kind, drag.id);
    }
    if (link != null) {
      final s = _cubit.state.data;
      final config = link.kind == NodeKind.source
          ? CanvasGeometry.hitConfig(s.configs, link.point)
          : null;
      final target = CanvasGeometry.hit(s.destinations, link.point);
      if (config != null) {
        _cubit.attachSource(link.id, config.id);
      } else if (target != null) {
        link.kind == NodeKind.source
            ? _cubit.connect(link.id, target)
            : _cubit.relink(link.id, target);
      }
    }
    setState(() {
      _panning = null;
      _drag = null;
      _link = null;
    });
  }

  void _pointerSignal(PointerSignalEvent e) {
    // registering tells the browser not to scroll / zoom the page
    GestureBinding.instance.pointerSignalResolver.register(e, (event) {
      if (event is PointerScaleEvent) {
        _zoomAt(_zoom * event.scale, _toLocal(event.position));
      } else if (event is PointerScrollEvent) {
        final keys = HardwareKeyboard.instance;
        final wantZoom =
            !_ctrlZoom || keys.isControlPressed || keys.isMetaPressed;
        if (wantZoom) {
          _zoomAt(
            _zoom * math.exp(-event.scrollDelta.dy * 0.0015),
            _toLocal(event.position),
          );
        } else {
          _panBy(-event.scrollDelta);
        }
      }
    });
  }

  // ---------- keyboard ----------

  KeyEventResult _key(FocusNode node, KeyEvent e) {
    final key = e.logicalKey;
    if (key == LogicalKeyboardKey.space) {
      if (e is! KeyRepeatEvent) setState(() => _space = e is KeyDownEvent);
      return KeyEventResult.handled;
    }
    if (e is KeyUpEvent) return KeyEventResult.ignored;

    const step = 60.0;
    final arrows = {
      LogicalKeyboardKey.arrowLeft: const Offset(step, 0),
      LogicalKeyboardKey.arrowRight: const Offset(-step, 0),
      LogicalKeyboardKey.arrowUp: const Offset(0, step),
      LogicalKeyboardKey.arrowDown: const Offset(0, -step),
    };
    if (arrows.containsKey(key)) {
      _panBy(arrows[key]!);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _cubit.select(null);
      setState(() {
        _link = null;
        _drag = null;
        _wire = null;
        _menu = null;
        _showSettings = false;
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      final sel = _cubit.state.data.selectedId;
      if (_wire != null) {
        _deleteWire();
      } else if (sel != null) {
        _cubit.deleteConfig(sel);
      }
      return KeyEventResult.handled;
    }
    if (e is KeyRepeatEvent) return KeyEventResult.ignored;
    // by key too: on web `character` can be missing for shifted keys (`?`, `+`)
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final char = e.character;
    if (char == '?' || (key == LogicalKeyboardKey.slash && shift)) {
      _toggleKeys();
    } else if (char == '+' ||
        char == '=' ||
        key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.numpadAdd) {
      _zoomBy(1.2);
    } else if (char == '-' ||
        char == '_' ||
        key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      _zoomBy(1 / 1.2);
    } else if (key == LogicalKeyboardKey.keyF) {
      _fit();
    } else if (key == LogicalKeyboardKey.digit0 ||
        key == LogicalKeyboardKey.numpad0) {
      _reset();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // ---------- view ----------

  /// An overlay: its presses never reach the background
  Widget _overlay(Widget child) =>
      Listener(onPointerDown: (_) => _claim(), child: child);

  Widget? _contextMenu() {
    final menu = _menu;
    if (menu == null) return null;
    return Positioned(
      left: menu.at.dx,
      top: menu.at.dy,
      child: Listener(
        onPointerDown: (_) {
          _claim();
          _keepMenu = true;
        },
        child: CanvasContextMenu(items: menu.items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final cursor = _panning != null
        ? SystemMouseCursors.grabbing
        : _space
        ? SystemMouseCursors.grab
        : MouseCursor.defer;
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _key,
      child: Semantics(
        label: app.intl.canvas.semantics,
        child: MouseRegion(
          cursor: cursor,
          child: Listener(
            onPointerDown: _canvasDown,
            onPointerMove: _pointerMove,
            onPointerUp: _pointerUp,
            onPointerCancel: _pointerUp,
            onPointerSignal: _pointerSignal,
            child: ClipRect(
              key: _viewport,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(
                      color: colors.surface.background,
                      child: CustomPaint(
                        // the lines of the login, following the pan and zoom
                        painter: GridLinePainter(
                          offset: _pan,
                          scale: _zoom,
                          color: colors.primary.primaryFaded.withValues(
                            alpha: 0.05,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(_pan.dx, _pan.dy, 0, 1)
                        ..scaleByDouble(_zoom, _zoom, 1, 1),
                      child: BlocBuilder<CanvasCubit, CanvasState>(
                        builder: (context, s) => _world(s.data),
                      ),
                    ),
                  ),
                  // the cursor of the background (nodes set their own)
                  if (_space || _panning != null)
                    Positioned.fill(
                      child: MouseRegion(cursor: cursor, opaque: false),
                    ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _overlay(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddToolbar(
                            onAddSource: () => _openToolbarMenu(_sourceItems()),
                            onAddDestination: () =>
                                _openToolbarMenu(_destinationItems()),
                          ),
                          BlocBuilder<CanvasCubit, CanvasState>(
                            buildWhen: (a, b) =>
                                a.data.orphans != b.data.orphans,
                            builder: (context, s) => s.data.orphans == 0
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: OrphansWarning(
                                      count: s.data.orphans,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showKeys)
                    Positioned(
                      left: 16,
                      bottom: 62,
                      child: _overlay(
                        ShortcutsPanel(
                          ctrlZoom: _ctrlZoom,
                          onClose: () => setState(() => _showKeys = false),
                        ),
                      ),
                    ),
                  if (_showSettings)
                    Positioned(
                      left: 16,
                      bottom: 62,
                      child: _overlay(
                        CanvasSettingsPopover(
                          ctrlZoom: _ctrlZoom,
                          onCtrlZoom: () =>
                              setState(() => _ctrlZoom = !_ctrlZoom),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: _overlay(
                      ViewControls(
                        zoom: _zoom,
                        showSettings: _showSettings,
                        showKeys: _showKeys,
                        onSettings: _toggleSettings,
                        onKeys: _toggleKeys,
                        onFit: _fit,
                        onZoomIn: () => _zoomBy(1.2),
                        onZoomOut: () => _zoomBy(1 / 1.2),
                        onReset: _reset,
                      ),
                    ),
                  ),
                  // above the view controls, until the first config
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 64,
                    child: BlocBuilder<CanvasCubit, CanvasState>(
                      builder: (context, s) => s.data.configs.isNotEmpty
                          ? const SizedBox.shrink()
                          : Center(
                              child: _overlay(
                                CanvasGuide(
                                  data: s.data,
                                  onPlaceSource: _cubit.addSource,
                                  onPlaceDestination: _cubit.addDestination,
                                  onCreateSource: () =>
                                      _open(RouteNames.sources),
                                  onCreateDestination: () =>
                                      _open(RouteNames.destinations),
                                ),
                              ),
                            ),
                    ),
                  ),
                  ?_contextMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _world(CanvasData s) {
    final colors = app.colors;
    final sel = s.selected;
    final link = _link;
    final target = link != null
        ? CanvasGeometry.hit(s.destinations, link.point)
        : null;
    final handlers = NodeHandlers(
      nodeDown: _nodeDown,
      portDown: _portDown,
      claim: _claim,
    );

    final wires = <Wire>[];
    Offset? wireMid;
    for (final c in s.configs) {
      for (final end in WireEnd.values) {
        final ends = CanvasGeometry.wireEnds(s, c, end);
        if (ends == null) continue;
        // while relinking, the live wire replaces the config's out wire
        if (end == WireEnd.destination &&
            link?.kind == NodeKind.config &&
            link?.id == c.id) {
          continue;
        }
        final picked = _wire == (c.id, end);
        if (picked) wireMid = CanvasGeometry.curveAt(ends.$1, ends.$2, 0.5);
        wires.add(
          Wire(
            ends.$1,
            ends.$2,
            selected: sel?.id == c.id,
            picked: picked,
            orphan: CanvasData.configOrphan(c),
          ),
        );
      }
    }

    (Offset, Offset)? live;
    Offset? ghost;
    if (link != null) {
      final from = link.kind == NodeKind.source
          ? CanvasGeometry.sourceOut(s.source(link.id)!)
          : CanvasGeometry.configOut(s.config(link.id)!);
      // a source wire over a config attaches to it: snap to its in port
      final attach = link.kind == NodeKind.source
          ? CanvasGeometry.hitConfig(s.configs, link.point)
          : null;
      final to = attach != null
          ? CanvasGeometry.configIn(attach)
          : target != null
          ? CanvasGeometry.destinationPort(
              s.destination(target.destinationId)!,
              target.folderId,
            )
          : link.point;
      live = (from, to);
      if (link.kind == NodeKind.source && attach == null) {
        ghost = Offset((from.dx + to.dx) / 2 - 120, (from.dy + to.dy) / 2 - 44);
      }
    }

    final nodes = <(String, Widget)>[
      for (final d in s.sources)
        (
          d.id,
          Positioned(
            key: ValueKey('s-${d.id}'),
            left: d.pos.dx,
            top: d.pos.dy,
            child: SourceNodeView(
              source: d,
              selected: sel?.sourceId == d.id,
              used: s.configs.any((c) => c.sourceId == d.id),
              handlers: handlers,
            ),
          ),
        ),
      for (final c in s.configs)
        (
          c.id,
          Positioned(
            key: ValueKey('c-${c.id}'),
            left: c.pos.dx,
            top: c.pos.dy,
            child: ConfigNodeView(
              config: c,
              selected: sel?.id == c.id,
              handlers: handlers,
              onEdit: () => _openConfig(c.id),
              onRun: _canRun(c) ? () => _cubit.runNow(c.id) : null,
              onDelete: () => _cubit.deleteConfig(c.id),
            ),
          ),
        ),
      for (final d in s.destinations)
        (
          d.id,
          Positioned(
            key: ValueKey('d-${d.id}'),
            left: d.pos.dx,
            top: d.pos.dy,
            child: DestinationNodeView(
              destination: d,
              selectedFolder: sel?.destinationId == d.id
                  ? (sel!.folderId ?? '')
                  : null,
              targetFolder: target?.destinationId == d.id
                  ? (target!.folderId ?? '')
                  : null,
              linking: link != null,
              rootUsed: s.configs.any(
                (c) => c.destinationId == d.id && c.folderId == null,
              ),
              orphan: s.destinationOrphan(d.id),
              handlers: handlers,
              onAddFolder: () => AddFolderDialog.open(
                context,
                destination: d,
                onAdd: (path) => _cubit.addFolder(d.id, path),
              ),
            ),
          ),
        ),
    ];
    // the node being dragged goes on top
    if (_drag != null) {
      final i = nodes.indexWhere((n) => n.$1 == _drag!.id);
      if (i >= 0) nodes.add(nodes.removeAt(i));
    }

    Widget label(double left, String text) => Positioned(
      left: left,
      top: 60,
      child: Text(text, style: AppText.overline),
    );
    return UnboundedStack(
      children: [
        label(40, app.intl.canvas.columns.sources.toUpperCase()),
        label(380, app.intl.canvas.columns.configs.toUpperCase()),
        label(760, app.intl.canvas.columns.destinations.toUpperCase()),
        Positioned(
          left: 0,
          top: 0,
          child: IgnorePointer(
            child: CustomPaint(
              painter: WiresPainter(wires: wires, flow: _flow),
            ),
          ),
        ),
        ...nodes.map((n) => n.$2),
        if (wireMid != null)
          Positioned(
            left: wireMid.dx - 12,
            top: wireMid.dy - 12,
            child: Listener(
              onPointerDown: (_) => _claim(),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surface.control,
                  border: Border.all(color: colors.brand.accent),
                ),
                child: AppIconButton(
                  size: 24,
                  tooltip: app.intl.canvas.removeConnectionKey,
                  onPressed: _deleteWire,
                  icon: app.assets.icons.actions.delete.build(
                    size: 13,
                    color: colors.status.error,
                  ),
                ),
              ),
            ),
          ),
        if (live != null)
          Positioned(
            left: 0,
            top: 0,
            child: IgnorePointer(
              child: CustomPaint(
                painter: WiresPainter(
                  wires: const [],
                  flow: kAlwaysDismissedAnimation,
                  live: live,
                ),
              ),
            ),
          ),
        if (ghost != null)
          Positioned(
            left: ghost.dx,
            top: ghost.dy,
            child: IgnorePointer(
              child: DashedBorder(
                color: colors.brand.primary,
                radius: 12,
                child: Container(
                  width: 240,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colors.surface.background.withValues(alpha: 0.9),
                    borderRadius: app.dimensions.radius.l,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      app.assets.icons.nodes.clock.build(
                        size: 18,
                        color: colors.brand.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        target != null
                            ? app.intl.canvas.releaseToCreate
                            : app.intl.canvas.configHere,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.text.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
