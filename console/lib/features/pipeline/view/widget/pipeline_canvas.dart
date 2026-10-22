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

/// Wire in progress, from a source (new config) or a config (relink)
typedef _Link = ({NodeKind kind, String id, Offset point});

/// The interactive pipeline editor. World coordinates are those of the
/// nodes; the view shows them translated by [_pan] and scaled by [_zoom]
class PipelineCanvas extends StatefulWidget {
  const PipelineCanvas({super.key});

  @override
  State<PipelineCanvas> createState() => _PipelineCanvasState();
}

class _PipelineCanvasState extends State<PipelineCanvas>
    with SingleTickerProviderStateMixin {
  static const double _minZoom = 0.4;
  static const double _maxZoom = 2;

  final FocusNode _focus = FocusNode(debugLabel: 'pipeline-canvas');
  final GlobalKey _viewport = GlobalKey();
  late final AnimationController _flow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  Offset _pan = Offset.zero;
  double _zoom = 1;
  bool _ctrlZoom = true;
  bool _showKeys = true;
  bool _showSettings = false;
  bool _space = false;

  _Pan? _panning;
  _Drag? _drag;
  _Link? _link;

  /// A child (node, port, button, overlay) took the pointer down, so the
  /// background must not start a pan. Children get the event first
  bool _claimed = false;

  PipelineCubit get _cubit => context.read<PipelineCubit>();

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

  void _fit() {
    final b = PipelineGeometry.bounds(_cubit.state);
    if (b.isEmpty) return;
    const pad = 64.0;
    final size = _viewSize;
    final z = math
        .min(
          (size.width - pad * 2) / b.width,
          (size.height - pad * 2) / b.height,
        )
        .clamp(_minZoom, 1.25);
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
    if (_space || e.buttons != kPrimaryButton) {
      _startPan(e);
      return;
    }
    final s = _cubit.state;
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
    if (_space || e.buttons != kPrimaryButton) {
      _startPan(e);
      return;
    }
    if (kind == NodeKind.config) _cubit.select(id);
    setState(() => _link = (kind: kind, id: id, point: _toWorld(e.position)));
  }

  /// Last of the pointer-down handlers (it wraps the rest)
  void _canvasDown(PointerDownEvent e) {
    _focus.requestFocus();
    if (_claimed) {
      _claimed = false;
      return;
    }
    setState(() {
      _showSettings = false;
      _startPan(e);
    });
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
      _cubit.move(
        drag.kind,
        drag.id,
        Offset(pos.dx.roundToDouble(), pos.dy.roundToDouble()),
      );
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
    if (drag != null && !drag.moved) _cubit.tapNode(drag.kind, drag.id);
    if (link != null) {
      final target = PipelineGeometry.hit(
        _cubit.state.destinations,
        link.point,
      );
      if (target != null) {
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
        _showSettings = false;
      });
      return KeyEventResult.handled;
    }
    if (e is KeyRepeatEvent) return KeyEventResult.ignored;
    // by key too: on web `character` can be missing for shifted keys (`?`, `+`)
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final char = e.character;
    if (char == '?' || (key == LogicalKeyboardKey.slash && shift)) {
      setState(() => _showKeys = !_showKeys);
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
        label: 'Pipeline canvas. Drag the background or hold Space to move it; arrow keys pan; Ctrl and scroll zooms; F centers; Escape closes the config',
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
                        painter: GridDotPainter(
                          offset: _pan,
                          scale: _zoom,
                          color: Colors.white.withValues(alpha: 0.11),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..translateByDouble(_pan.dx, _pan.dy, 0, 1)
                        ..scaleByDouble(_zoom, _zoom, 1, 1),
                      child: BlocBuilder<PipelineCubit, PipelineState>(
                        builder: (context, s) => _world(s),
                      ),
                    ),
                  ),
                  // the cursor of the background (nodes set their own)
                  if (_space || _panning != null)
                    Positioned.fill(
                      child: MouseRegion(cursor: cursor, opaque: false),
                    ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: _overlay(
                      AddToolbar(
                        onAddSource: _cubit.addSource,
                        onAddDestination: _cubit.addDestination,
                      ),
                    ),
                  ),
                  if (_showKeys)
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: _overlay(
                        ShortcutsPanel(
                          ctrlZoom: _ctrlZoom,
                          onClose: () => setState(() => _showKeys = false),
                        ),
                      ),
                    ),
                  if (_showSettings)
                    Positioned(
                      right: 16,
                      bottom: 62,
                      child: _overlay(
                        CanvasSettingsPopover(
                          ctrlZoom: _ctrlZoom,
                          showKeys: _showKeys,
                          onCtrlZoom: () =>
                              setState(() => _ctrlZoom = !_ctrlZoom),
                          onKeys: () => setState(() => _showKeys = !_showKeys),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _overlay(
                      ViewControls(
                        zoom: _zoom,
                        showSettings: _showSettings,
                        showKeys: _showKeys,
                        onSettings: () =>
                            setState(() => _showSettings = !_showSettings),
                        onKeys: () => setState(() => _showKeys = !_showKeys),
                        onFit: _fit,
                        onZoomIn: () => _zoomBy(1.2),
                        onZoomOut: () => _zoomBy(1 / 1.2),
                        onReset: _reset,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _world(PipelineState s) {
    final colors = app.colors;
    final sel = s.selected;
    final link = _link;
    final target = link != null
        ? PipelineGeometry.hit(s.destinations, link.point)
        : null;
    final handlers = NodeHandlers(
      nodeDown: _nodeDown,
      portDown: _portDown,
      claim: _claim,
    );

    final wires = <Wire>[];
    for (final c in s.configs) {
      final source = s.source(c.sourceId);
      final dest = s.destination(c.destinationId);
      final on = sel?.id == c.id;
      if (source != null) {
        wires.add(
          Wire(
            PipelineGeometry.sourceOut(source),
            PipelineGeometry.configIn(c),
            selected: on,
          ),
        );
      }
      // while relinking, the live wire replaces the config's out wire
      if (dest != null &&
          !(link?.kind == NodeKind.config && link?.id == c.id)) {
        wires.add(
          Wire(
            PipelineGeometry.configOut(c),
            PipelineGeometry.destinationPort(dest, c.folderId),
            selected: on,
          ),
        );
      }
    }

    (Offset, Offset)? live;
    Offset? ghost;
    if (link != null) {
      final from = link.kind == NodeKind.source
          ? PipelineGeometry.sourceOut(s.source(link.id)!)
          : PipelineGeometry.configOut(
              s.configs.firstWhere((c) => c.id == link.id),
            );
      final to = target != null
          ? PipelineGeometry.destinationPort(
              s.destination(target.destinationId)!,
              target.folderId,
            )
          : link.point;
      live = (from, to);
      if (link.kind == NodeKind.source) {
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
              canDelete: s.canDelete(c),
              handlers: handlers,
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
              handlers: handlers,
              onAddFolder: () => _cubit.addFolder(d.id),
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
    Widget hint(
      double left,
      double width,
      String text,
      Color border,
      Color color, {
      bool dot = false,
    }) => Positioned(
      left: left,
      top: 760,
      child: IgnorePointer(
        child: DashedBorder(
          color: border,
          child: Container(
            width: width,
            height: 44,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dot) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return UnboundedStack(
      children: [
        label(40, 'SOURCES'),
        label(380, 'CONFIG · ONE PER CONNECTION'),
        label(760, 'DESTINATIONS'),
        hint(
          40,
          200,
          'Drag from a source port',
          colors.brand.accent.withValues(alpha: 0.75),
          colors.brand.accent,
          dot: true,
        ),
        hint(
          380,
          240,
          'Config is created here',
          colors.brand.primary.withValues(alpha: 0.6),
          colors.text.muted,
        ),
        hint(
          760,
          256,
          'Drop on a folder or bucket',
          colors.brand.accent.withValues(alpha: 0.75),
          colors.brand.accent,
        ),
        Positioned(
          left: 0,
          top: 0,
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HintArrowsPainter(
                colors.brand.accent.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
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
                      AppIcon(
                        AppIcons.clock,
                        size: 18,
                        color: colors.brand.primary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        target != null
                            ? 'Release to create the config'
                            : 'Config is created here',
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

/// The dotted arrows between the hints at the bottom
class _HintArrowsPainter extends CustomPainter {
  final Color color;

  _HintArrowsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(246, 782)
      ..lineTo(374, 782)
      ..moveTo(626, 782)
      ..lineTo(754, 782);
    drawDashedPath(canvas, path, paint, dash: 2, gap: 5);
  }

  @override
  bool shouldRepaint(covariant _HintArrowsPainter old) => old.color != color;
}
