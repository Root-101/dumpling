import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The graph of the canvas of the open workspace: loaded whole, edited here
/// and saved whole with one Save. The viewport (pan, zoom) and the gesture in
/// progress live in the canvas widget: they are not part of the graph
class CanvasCubit extends Cubit<CanvasState> {
  /// The prefix the service takes as "create this node"
  static const String newPrefix = 'new_';

  final CanvasRepo _repo;
  final AuthCubit _auth;

  CanvasCubit(this._repo, this._auth) : super(const CanvasInitialState());

  String? get _token => _auth.auth?.accessToken;

  CanvasData get _data => state.data;

  void _edit(CanvasData data) => emit(CanvasLoadingSuccessState(data: data));

  /// The canvas of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = _data.workspace == workspace
        ? _data
        : CanvasData.empty(workspace);
    emit(CanvasLoadingInProgressState(data: data));
    try {
      final canvas = await _repo.get(workspace: workspace, token: _token);
      // the answer of a workspace already left behind is dropped
      if (_data.workspace != workspace) return;
      emit(CanvasLoadingSuccessState(data: _data.withCanvas(canvas)));
    } catch (e) {
      if (_data.workspace != workspace) return;
      emit(CanvasLoadingErrorState(ExceptionConverter.parse(e), data: _data));
    }
  }

  Future<void> reload() async {
    final workspace = _data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// Sends the whole canvas; the incomplete configs are discarded. What comes
  /// back (with the saved ids) replaces it
  Future<void> save() async {
    final workspace = _data.workspace;
    if (workspace == null || !_data.loaded) return;
    emit(CanvasProcessInProgressState(data: _data));
    try {
      final canvas = await _repo.save(
        workspace: workspace,
        data: _data,
        token: _token,
      );
      if (_data.workspace != workspace) return;
      emit(CanvasProcessingOKState(data: _data.withCanvas(canvas)));
    } catch (e) {
      if (_data.workspace != workspace) return;
      emit(
        CanvasProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: _data,
        ),
      );
    }
  }

  /// After signing out
  void reset() => emit(const CanvasInitialState());

  void move(NodeKind kind, String id, Offset pos) {
    final s = _data;
    switch (kind) {
      case NodeKind.source:
        _edit(
          s.copyWith(
            sources: [
              for (final n in s.sources) n.id == id ? n.copyWith(pos: pos) : n,
            ],
          ),
        );
      case NodeKind.config:
        _edit(
          s.copyWith(
            configs: [
              for (final n in s.configs) n.id == id ? n.copyWith(pos: pos) : n,
            ],
          ),
        );
      case NodeKind.destination:
        _edit(
          s.copyWith(
            destinations: [
              for (final n in s.destinations)
                n.id == id ? n.copyWith(pos: pos) : n,
            ],
          ),
        );
    }
  }

  void select(String? configId) =>
      _edit(_data.copyWith(selectedId: () => configId));

  /// A click (no drag) on a node selects its config, or the first config
  /// that uses the source / destination
  void tapNode(NodeKind kind, String id) {
    final match = _data.configs.where(
      (c) => switch (kind) {
        NodeKind.config => c.id == id,
        NodeKind.source => c.sourceId == id,
        NodeKind.destination => c.destinationId == id,
      },
    );
    if (match.isNotEmpty) select(match.first.id);
  }

  /// A wire dropped from a source creates a config halfway. Its schedule,
  /// compression and object key are the defaults of the workspace until
  /// changed
  void connect(String sourceId, DropTarget target) {
    final s = _data;
    final source = s.source(sourceId);
    final dest = s.destination(target.destinationId);
    if (source == null || dest == null) return;
    final a = CanvasGeometry.sourceOut(source);
    final b = CanvasGeometry.destinationPort(dest, target.folderId);
    final id = '$newPrefix${s.seq}';
    final config = BackupConfig(
      id: id,
      sourceId: sourceId,
      destinationId: target.destinationId,
      folderId: target.folderId,
      pos: Offset(
        ((a.dx + b.dx) / 2 - 120).roundToDouble(),
        ((a.dy + b.dy) / 2 - 76).roundToDouble(),
      ),
      name: app.intl.canvas.newConfig,
    );
    _edit(
      s.copyWith(
        configs: [...s.configs, config],
        selectedId: () => id,
        seq: s.seq + 1,
      ),
    );
  }

  /// A wire dropped from a config's out port (re)connects it to a destination
  void relink(String configId, DropTarget target) => _update(
    configId,
    (c) => c.copyWith(
      destinationId: () => target.destinationId,
      folderId: () => target.folderId,
    ),
  );

  /// A wire dropped from a source on a config gives it that source
  void attachSource(String sourceId, String configId) =>
      _update(configId, (c) => c.copyWith(sourceId: () => sourceId));

  /// Removes one wire of a config; the config and the nodes stay, as orphans
  void disconnect(String configId, WireEnd end) => _update(
    configId,
    (c) => end == WireEnd.source
        ? c.copyWith(sourceId: () => null)
        : c.copyWith(destinationId: () => null, folderId: () => null),
  );

  void _update(String configId, BackupConfig Function(BackupConfig) f) {
    _edit(
      _data.copyWith(
        selectedId: () => configId,
        configs: [for (final c in _data.configs) c.id == configId ? f(c) : c],
      ),
    );
  }

  void deleteConfig(String id) {
    final s = _data;
    if (s.config(id) == null) return;
    _edit(
      s.copyWith(
        configs: s.configs.where((c) => c.id != id).toList(),
        selectedId: () => s.selectedId == id ? null : s.selectedId,
      ),
    );
  }

  /// Puts [id] of the pool at [pos] (world), or stacked under the sources
  /// column
  void addSource(String id, [Offset? pos]) {
    final s = _data;
    final pooled = s.sourcePool.where((x) => x.id == id).firstOrNull;
    if (pooled == null) return;
    final n = s.sources.length;
    final source = pooled.copyWith(
      pos: pos ?? Offset(40.0 + (n % 3) * 24, 130.0 + n * 110),
    );
    _edit(
      s.copyWith(
        sources: [...s.sources, source],
        sourcePool: s.sourcePool.where((x) => x.id != id).toList(),
      ),
    );
  }

  void addDestination(String id, [Offset? pos]) {
    final s = _data;
    final pooled = s.destinationPool.where((x) => x.id == id).firstOrNull;
    if (pooled == null) return;
    final n = s.destinations.length;
    final dest = pooled.copyWith(
      pos: pos ?? Offset(760.0 - (n % 3) * 24, 88.0 + n * 200),
    );
    _edit(
      s.copyWith(
        destinations: [...s.destinations, dest],
        destinationPool: s.destinationPool.where((x) => x.id != id).toList(),
      ),
    );
  }

  /// Takes a source off the canvas (it is not deleted: back to the pool);
  /// its configs stay, without source
  void removeSource(String id) {
    final s = _data;
    final source = s.source(id);
    if (source == null) return;
    _edit(
      s.copyWith(
        sources: s.sources.where((x) => x.id != id).toList(),
        sourcePool: [...s.sourcePool, source],
        configs: [
          for (final c in s.configs)
            c.sourceId == id ? c.copyWith(sourceId: () => null) : c,
        ],
      ),
    );
  }

  /// Takes a destination off the canvas; its configs stay, without
  /// destination
  void removeDestination(String id) {
    final s = _data;
    final dest = s.destination(id);
    if (dest == null) return;
    _edit(
      s.copyWith(
        destinations: s.destinations.where((x) => x.id != id).toList(),
        destinationPool: [...s.destinationPool, dest],
        configs: [
          for (final c in s.configs)
            c.destinationId == id
                ? c.copyWith(destinationId: () => null, folderId: () => null)
                : c,
        ],
      ),
    );
  }

  /// Hourly, daily and weekly keep the minute and hour of the schedule
  /// (03:00 while it is the default of the workspace); cron keeps it as is
  void setFrequency(Frequency f) {
    final sel = _data.selected;
    if (sel == null || f == Frequency.cron) return;
    final fields = (sel.schedule ?? '0 3 * * *').trim().split(RegExp(r'\s+'));
    final m = int.tryParse(fields.first) ?? 0;
    final h = fields.length > 1 ? int.tryParse(fields[1]) ?? 3 : 3;
    final cron = switch (f) {
      Frequency.hourly => '$m * * * *',
      Frequency.daily => '$m $h * * *',
      Frequency.weekly => '$m $h * * 0',
      Frequency.cron => sel.schedule!,
    };
    _update(sel.id, (c) => c.copyWith(schedule: cron));
  }

  /// Empty: the default of the workspace
  void setObjectKey(String key) {
    final id = _data.selectedId;
    if (id == null) return;
    final value = key.trim();
    _update(
      id,
      (c) => c.copyWith(objectKey: () => value.isEmpty ? null : value),
    );
  }

  /// What a run now would write, with the placeholders of the key filled
  /// like the engine does (UTC)
  static String resolveKey(String key, String db) {
    final now = DateTime.now().toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return key
        .replaceAll('{yyyy}', '${now.year}')
        .replaceAll('{MM}', two(now.month))
        .replaceAll('{dd}', two(now.day))
        .replaceAll('{HH}', two(now.hour))
        .replaceAll('{mm}', two(now.minute))
        .replaceAll('{db}', db)
        .replaceAll('{run_id}', 'run_…');
  }
}
