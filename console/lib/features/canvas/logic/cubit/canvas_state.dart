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
  });

  const CanvasData.empty([this.workspace])
    : loaded = false,
      sources = const [],
      configs = const [],
      destinations = const [],
      sourcePool = const [],
      destinationPool = const [],
      selectedId = null,
      seq = 1;

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
  );
}

abstract class CanvasState {
  final CanvasData data;

  const CanvasState({this.data = const CanvasData.empty()});
}

class CanvasInitialState extends CanvasState {
  const CanvasInitialState();
}

//------------------------- LOADING -------------------------\
class CanvasLoadingInProgressState extends CanvasState {
  const CanvasLoadingInProgressState({required super.data});
}

/// Loaded, and every edit after it
class CanvasLoadingSuccessState extends CanvasState {
  const CanvasLoadingSuccessState({required super.data});
}

class CanvasLoadingErrorState extends CanvasState {
  final GlobalException exception;

  const CanvasLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
class CanvasProcessInProgressState extends CanvasState {
  const CanvasProcessInProgressState({required super.data});
}

class CanvasProcessingOKState extends CanvasState {
  const CanvasProcessingOKState({required super.data});
}

class CanvasProcessingErrorState extends CanvasState {
  final String message;

  const CanvasProcessingErrorState(this.message, {required super.data});
}
