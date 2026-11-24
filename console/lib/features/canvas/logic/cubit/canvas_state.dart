import 'package:console/app_exporter.dart';

/// The graph of the canvas of [workspace], as it is edited. Nothing reaches
/// the service until it is saved
class CanvasData {
  final String? workspace;
  final bool loaded;
  final List<SourceNode> sources;
  final List<BackupConfig> configs;
  final List<DestinationNode> destinations;
  final String? selectedId;

  /// To make unique ids of new configs
  final int seq;

  /// Saved but off the canvas: what the toolbar adds
  final List<SourceNode> sourcePool;
  final List<DestinationNode> destinationPool;

  /// See [CanvasModel.order]
  final Map<String, int> order;

  const CanvasData({
    required this.sources,
    required this.configs,
    required this.destinations,
    required this.sourcePool,
    required this.destinationPool,
    this.workspace,
    this.loaded = false,
    this.selectedId,
    this.seq = 1,
    this.order = const {},
  });

  const CanvasData.empty([this.workspace])
    : loaded = false,
      sources = const [],
      configs = const [],
      destinations = const [],
      sourcePool = const [],
      destinationPool = const [],
      selectedId = null,
      seq = 1,
      order = const {};

  /// [canvas] loaded (or just saved); the selection follows its new id
  CanvasData withCanvas(CanvasModel canvas) {
    final selected = canvas.ids[selectedId] ?? selectedId;
    return CanvasData(
      workspace: workspace,
      loaded: true,
      sources: canvas.sources,
      configs: canvas.configs,
      destinations: canvas.destinations,
      sourcePool: canvas.sourcePool,
      destinationPool: canvas.destinationPool,
      selectedId: canvas.configs.any((c) => c.id == selected) ? selected : null,
      seq: seq,
      order: canvas.order,
    );
  }

  BackupConfig? get selected => config(selectedId);

  SourceNode? source(String? id) => _find(sources, id, (s) => s.id);

  DestinationNode? destination(String? id) =>
      _find(destinations, id, (d) => d.id);

  BackupConfig? config(String? id) => _find(configs, id, (c) => c.id);

  /// Orphans: everything outside a complete flow source → config →
  /// destination. A config missing either end; a source or destination with
  /// no complete config. Saving drops the orphan configs; the sources and
  /// destinations stay, they are only shown in amber
  bool sourceOrphan(String id) =>
      !configs.any((c) => c.sourceId == id && !configOrphan(c));

  bool destinationOrphan(String id) =>
      !configs.any((c) => c.destinationId == id && !configOrphan(c));

  static bool configOrphan(BackupConfig c) =>
      c.sourceId == null || c.destinationId == null;

  /// The configs a save discards
  int get orphans => configs.where(configOrphan).length;

  static T? _find<T>(List<T> list, String? id, String Function(T) idOf) {
    if (id == null) return null;
    for (final x in list) {
      if (idOf(x) == id) return x;
    }
    return null;
  }

  CanvasData copyWith({
    List<SourceNode>? sources,
    List<BackupConfig>? configs,
    List<DestinationNode>? destinations,
    String? Function()? selectedId,
    int? seq,
    List<SourceNode>? sourcePool,
    List<DestinationNode>? destinationPool,
  }) => CanvasData(
    workspace: workspace,
    loaded: loaded,
    sources: sources ?? this.sources,
    configs: configs ?? this.configs,
    destinations: destinations ?? this.destinations,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
    seq: seq ?? this.seq,
    sourcePool: sourcePool ?? this.sourcePool,
    destinationPool: destinationPool ?? this.destinationPool,
    order: order,
  );
}

abstract class CanvasState {
  /// The graph of the open workspace, kept in every state
  final CanvasData data;

  const CanvasState({this.data = const CanvasData.empty()});
}

final class CanvasInitialState extends CanvasState {
  const CanvasInitialState();
}

//----------------- load -----------------\\
abstract class CanvasLoadState extends CanvasState {
  const CanvasLoadState({required super.data});
}

final class CanvasLoadingState extends CanvasLoadState {
  const CanvasLoadingState({required super.data});
}

final class CanvasLoadedOkState extends CanvasLoadState {
  const CanvasLoadedOkState({required super.data});
}

final class CanvasLoadingErrorState extends CanvasLoadState {
  final GlobalException exception;

  const CanvasLoadingErrorState(this.exception, {required super.data});
}

//----------------- edit -----------------\\
/// Every edit, and the selection: not saved until [CanvasSavedOkState]
final class CanvasEditedState extends CanvasState {
  const CanvasEditedState({required super.data});
}

//----------------- save -----------------\\
abstract class CanvasSaveState extends CanvasState {
  const CanvasSaveState({required super.data});
}

final class CanvasSavingState extends CanvasSaveState {
  const CanvasSavingState({required super.data});
}

/// Public contract: sources, destinations, backups and workspaces may have
/// changed (the bus)
final class CanvasSavedOkState extends CanvasSaveState {
  const CanvasSavedOkState({required super.data});
}

final class CanvasSavingErrorState extends CanvasSaveState {
  final GlobalException exception;

  /// What to show: a refused field says the name of its node
  final String message;

  const CanvasSavingErrorState(
    this.exception, {
    required this.message,
    required super.data,
  });
}

//----------------- test run -----------------\\
abstract class CanvasTestState extends CanvasState {
  const CanvasTestState({required super.data});
}

final class CanvasTestingState extends CanvasTestState {
  const CanvasTestingState({required super.data});
}

/// [checks] says how each source and destination did (a failure is a check
/// with its error); empty when there was no complete flow to test
final class CanvasTestedOkState extends CanvasTestState {
  final List<CanvasCheck> checks;

  const CanvasTestedOkState(this.checks, {required super.data});
}

//----------------- Run now -----------------\\
abstract class CanvasRunNowState extends CanvasState {
  const CanvasRunNowState({required super.data});
}

/// Each answer while it runs: its node shows how it goes
final class CanvasRunningNowState extends CanvasRunNowState {
  final String configName;
  final LastRun run;

  const CanvasRunningNowState(this.configName, this.run, {required super.data});
}

/// Public contract: it ended, [run] says how (the rail counts failures from
/// the workspaces, which reload on it)
final class CanvasRanNowOkState extends CanvasRunNowState {
  final String configName;
  final LastRun run;

  const CanvasRanNowOkState(this.configName, this.run, {required super.data});
}

final class CanvasRunningNowErrorState extends CanvasRunNowState {
  final GlobalException exception;

  const CanvasRunningNowErrorState(this.exception, {required super.data});
}
