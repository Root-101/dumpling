import 'dart:convert';

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
  final SourceRepo _sources;
  final DestinationRepo _destinations;
  final AuthCubit _auth;

  /// How often a run started here is asked how it goes
  final Duration pollEvery;

  CanvasCubit(
    this._repo,
    this._sources,
    this._destinations,
    this._auth, {
    this.pollEvery = const Duration(seconds: 2),
  }) : super(const CanvasInitialState());

  String? get _token => _auth.auth?.accessToken;

  CanvasData get _data => state.data;

  /// The graph as it was loaded or saved last, as a save sends it
  String? _saved;

  String _request(CanvasData data) => jsonEncode(data.toRequest().toJson());

  /// Edits not saved yet; undoing them leaves none. The selection, a run or a
  /// test are not edits
  bool get dirty => _data.loaded && _saved != null && _saved != _request(_data);

  void _edit(CanvasData data) => emit(CanvasLoadingSuccessState(data: data));

  /// The save or test in progress: a run waits for it to show how it goes,
  /// so the overlay stays up and the saved canvas doesn't drop its update
  Future<void>? _process;

  Future<void> _track(Future<void> process) async {
    _process = process;
    try {
      await process;
    } finally {
      if (_process == process) _process = null;
    }
  }

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
      final loaded = _data.withCanvas(canvas);
      // before the state: its listeners ask for [dirty]
      _saved = _request(loaded);
      emit(CanvasLoadingSuccessState(data: loaded));
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
  Future<void> save() => _track(_save());

  Future<void> _save() async {
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
      final saved = _data.withCanvas(canvas);
      _saved = _request(saved);
      emit(CanvasProcessingOKState(data: saved));
    } catch (e) {
      if (_data.workspace != workspace) return;
      emit(CanvasProcessingErrorState(_saveError(e), data: _data));
    }
  }

  /// A 422 names each field by its place in the request
  /// (`configs[0].schedule`): it says the name of that node instead
  String _saveError(Object e) {
    final exception = ExceptionConverter.parse(e);
    final errors = exception.data;
    if (exception.type != GlobalExceptionType.validation ||
        errors is! List<ValidationError> ||
        errors.isEmpty) {
      return exception.message;
    }
    final request = _data.toRequest().toJson();
    final node = RegExp(r'^(sources|destinations|configs)\[(\d+)\]');
    String nameOf(String field) {
      final m = node.firstMatch(field);
      final nodes = m == null ? null : request[m.group(1)] as List?;
      final i = m == null ? null : int.parse(m.group(2)!);
      return nodes != null && i! < nodes.length
          ? (nodes[i] as Map)['name'] as String
          : field;
    }

    return [for (final v in errors) '${nameOf(v.source)}: ${v.message}']
        .join(' · ');
  }

  /// Checks, without backing anything up, that every complete flow could
  /// run: each source connects and its server is not newer than `pg_dump`;
  /// each destination takes a write in every folder (or the root), the ones
  /// added here and not saved yet too
  Future<void> testRun() => _track(_testRun());

  Future<void> _testRun() async {
    final workspace = _data.workspace;
    if (workspace == null || !_data.loaded) return;
    final complete = _data.configs.where((c) => !CanvasData.configOrphan(c));
    final sources = {for (final c in complete) ?_data.source(c.sourceId)};
    final destinations = {
      for (final c in complete) ?_data.destination(c.destinationId),
    };
    Future<CanvasCheck> check(
      String name,
      Future<ConnectionCheckModel> Function() test,
    ) async {
      try {
        return CanvasCheck(name, check: await test());
      } catch (e) {
        return CanvasCheck(name, error: ExceptionConverter.parse(e).message);
      }
    }

    emit(CanvasProcessInProgressState(data: _data));
    final checks = await Future.wait([
      for (final s in sources)
        check(
          s.name,
          () =>
              _sources.testSaved(workspace: workspace, id: s.id, token: _token),
        ),
      for (final d in destinations)
        check(
          d.name,
          () => _destinations.testUnsaved(
            workspace: workspace,
            draft: d.toDraft(),
            destinationId: d.id,
            token: _token,
          ),
        ),
    ]);
    if (_data.workspace != workspace) return;
    emit(CanvasTestedState(checks, data: _data));
  }

  /// Runs the saved [configId] for real, whether it is enabled or not, and
  /// follows it: its node shows it running until the service says how it
  /// ended. A run uses the config as it is saved, not the edits on the canvas
  Future<void> runNow(String configId) async {
    final workspace = _data.workspace;
    final config = _data.config(configId);
    if (workspace == null || config == null) return;
    try {
      var run = await _repo.runNow(
        workspace: workspace,
        configId: configId,
        token: _token,
      );
      while (true) {
        await _process;
        if (isClosed || _data.workspace != workspace) return;
        _setRun(configId, run);
        if (!run.running) break;
        await Future.delayed(pollEvery);
        run = await _repo.run(workspace: workspace, id: run.id, token: _token);
      }
      await _process;
      if (isClosed || _data.workspace != workspace) return;
      emit(CanvasRunFinishedState(config.name, run, data: _data));
    } catch (e) {
      await _process;
      if (isClosed || _data.workspace != workspace) return;
      emit(
        CanvasProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: _data,
        ),
      );
    }
  }

  /// Without selecting it: the user may be on another config meanwhile
  void _setRun(String configId, LastRun run) => _edit(
    _data.copyWith(
      configs: [
        for (final c in _data.configs)
          c.id == configId ? c.copyWith(lastRun: run) : c,
      ],
    ),
  );

  /// After signing out
  void reset() {
    _saved = null;
    emit(const CanvasInitialState());
  }

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
  /// compression and object key start as the [defaults] of the workspace, so
  /// its dialog shows them; without them they stay empty and the service
  /// fills them in on save
  void connect(
    String sourceId,
    DropTarget target, {
    WorkspaceDefaults? defaults,
  }) {
    final s = _data;
    final source = s.source(sourceId);
    final dest = s.destination(target.destinationId);
    if (source == null || dest == null) return;
    final a = CanvasGeometry.sourceOut(source);
    final b = CanvasGeometry.destinationPort(dest, target.folderId);
    final id = '$newPrefix${s.seq}';
    var pos = Offset(
      ((a.dx + b.dx) / 2 - 120).roundToDouble(),
      ((a.dy + b.dy) / 2 - 76).roundToDouble(),
    );
    // another wire to the same place has a config there: below it
    while (s.configs.any(
      (c) =>
          CanvasGeometry.configRect(c)
              .inflate(12)
              .overlaps(pos & CanvasGeometry.configSize),
    )) {
      pos += Offset(0, CanvasGeometry.configSize.height + 24);
    }
    final config = BackupConfig(
      id: id,
      sourceId: sourceId,
      destinationId: target.destinationId,
      folderId: target.folderId,
      pos: pos,
      name: app.intl.canvas.newConfig,
      schedule: defaults?.schedule,
      compression: defaults?.compression,
      objectKey: defaults?.objectKey,
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

  /// Adds [path] (checked with [FolderPath.error]) to a destination; it is
  /// created in the bucket on save. With the first folder the root stops being
  /// a connection point: the configs that write to it are disconnected
  void addFolder(String destinationId, String path) {
    final s = _data;
    final dest = s.destination(destinationId);
    if (dest == null) return;
    final first = dest.folders.isEmpty;
    _edit(
      s.copyWith(
        destinations: [
          for (final d in s.destinations)
            d.id == destinationId
                ? d.copyWith(folders: [...d.folders, path])
                : d,
        ],
        configs: [
          for (final c in s.configs)
            first && c.destinationId == destinationId
                ? c.copyWith(destinationId: () => null, folderId: () => null)
                : c,
        ],
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

  /// What the config dialog left: its name, schedule, output and whether it
  /// is enabled (its place and its wires stay)
  void applyConfig(BackupConfig edited) => _update(
    edited.id,
    (c) => c.copyWith(
      name: edited.name,
      schedule: () => edited.schedule,
      compression: edited.compression,
      objectKey: () => edited.objectKey,
      enabled: edited.enabled,
    ),
  );

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
