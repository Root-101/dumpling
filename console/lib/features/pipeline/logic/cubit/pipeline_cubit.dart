import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The graph of the canvas. The viewport (pan, zoom) and the gesture in
/// progress live in the canvas widget: they are not part of the pipeline
class PipelineCubit extends Cubit<PipelineState> {
  PipelineCubit([PipelineState? initial])
    : super(initial ?? PipelineState.demo());

  void move(NodeKind kind, String id, Offset pos) {
    final s = state;
    switch (kind) {
      case NodeKind.source:
        emit(
          s.copyWith(
            sources: [
              for (final n in s.sources) n.id == id ? n.copyWith(pos: pos) : n,
            ],
          ),
        );
      case NodeKind.config:
        emit(
          s.copyWith(
            configs: [
              for (final n in s.configs) n.id == id ? n.copyWith(pos: pos) : n,
            ],
          ),
        );
      case NodeKind.destination:
        emit(
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
      emit(state.copyWith(selectedId: () => configId));

  /// A click (no drag) on a node selects its config, or the first config
  /// that uses the source / destination
  void tapNode(NodeKind kind, String id) {
    final match = state.configs.where(
      (c) => switch (kind) {
        NodeKind.config => c.id == id,
        NodeKind.source => c.sourceId == id,
        NodeKind.destination => c.destinationId == id,
      },
    );
    if (match.isNotEmpty) select(match.first.id);
  }

  /// A wire dropped from a source creates a config halfway
  void connect(String sourceId, DropTarget target) {
    final s = state;
    final source = s.source(sourceId);
    final dest = s.destination(target.destinationId);
    if (source == null || dest == null) return;
    final a = PipelineGeometry.sourceOut(source);
    final b = PipelineGeometry.destinationPort(dest, target.folderId);
    final id = 'n${s.seq}';
    final config = BackupConfig(
      id: id,
      sourceId: sourceId,
      destinationId: target.destinationId,
      folderId: target.folderId,
      pos: Offset(
        ((a.dx + b.dx) / 2 - 120).roundToDouble(),
        ((a.dy + b.dy) / 2 - 76).roundToDouble(),
      ),
      name: 'New config',
      frequency: Frequency.daily,
      time: '03:00',
      cron: '0 3 * * *',
      human: 'Every day at 03:00',
      last: 'Never run',
      lastStatus: RunStatus.pending,
      next: '21/Oct 03:00',
      nextIn: 'in 13 h',
      objectKey:
          '${target.folderId == null ? '${source.name}/' : ''}{yyyy}/{MM}/{dd}.dump.gz',
      compression: 'gzip · level 6',
      retention: 'Last 30',
    );
    emit(
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
    emit(
      state.copyWith(
        selectedId: () => configId,
        configs: [for (final c in state.configs) c.id == configId ? f(c) : c],
      ),
    );
  }

  void deleteConfig(String id) {
    final s = state;
    if (s.config(id) == null) return;
    emit(
      s.copyWith(
        configs: s.configs.where((c) => c.id != id).toList(),
        selectedId: () => s.selectedId == id ? null : s.selectedId,
      ),
    );
  }

  void addFolder(String destinationId) {
    final s = state;
    emit(
      s.copyWith(
        seq: s.seq + 1,
        destinations: [
          for (final d in s.destinations)
            if (d.id == destinationId)
              d.copyWith(
                folders: [
                  ...d.folders,
                  DestinationFolder(
                    id: 'folder-${d.folders.length + 1}-${s.seq}',
                    path: '/folder-${d.folders.length + 1}',
                    meta: 'empty',
                  ),
                ],
              )
            else
              d,
        ],
      ),
    );
  }

  /// Adds the next source of the pool at [pos] (world), or stacked under
  /// the sources column
  void addSource([Offset? pos]) {
    final s = state;
    if (s.sourcePool.isEmpty) return;
    final n = s.sources.length - 3;
    final source = s.sourcePool.first.copyWith(
      pos: pos ?? Offset(40.0 + (n % 3) * 24, 620.0 + (n % 3) * 12),
    );
    emit(
      s.copyWith(
        sources: [...s.sources, source],
        sourcePool: s.sourcePool.sublist(1),
      ),
    );
  }

  void addDestination([Offset? pos]) {
    final s = state;
    if (s.destinationPool.isEmpty) return;
    final n = s.destinations.length - 2;
    final dest = s.destinationPool.first.copyWith(
      pos: pos ?? Offset(760.0 - n * 24, 610.0 + n * 12),
    );
    emit(
      s.copyWith(
        destinations: [...s.destinations, dest],
        destinationPool: s.destinationPool.sublist(1),
      ),
    );
  }

  /// Removes a source; its configs stay, without source. It goes back to the
  /// pool, so the toolbar can add it again
  void deleteSource(String id) {
    final s = state;
    final source = s.source(id);
    if (source == null) return;
    emit(
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

  /// Removes a destination; its configs stay, without destination
  void deleteDestination(String id) {
    final s = state;
    final dest = s.destination(id);
    if (dest == null) return;
    emit(
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

  void setFrequency(Frequency f) {
    final sel = state.selected;
    if (sel == null) return;
    final hm = sel.time.split(':');
    final h = int.parse(hm[0]).toString();
    final m = int.parse(hm[1]).toString();
    // shortcut: next run strings are fixed demo values, compute them from the cron when the scheduler exists
    final updated = switch (f) {
      Frequency.hourly => sel.copyWith(
        frequency: f,
        cron: '$m * * * *',
        human: 'Every hour at :${hm[1]}',
        next: '20/Oct 14:${hm[1]}',
        nextIn: 'in 1 h',
      ),
      Frequency.daily => sel.copyWith(
        frequency: f,
        cron: '$m $h * * *',
        human: 'Every day at ${sel.time}',
        next: '21/Oct ${sel.time}',
        nextIn: 'in 13 h',
      ),
      Frequency.weekly => sel.copyWith(
        frequency: f,
        cron: '$m $h * * 0',
        human: 'Sundays at ${sel.time}',
        next: '25/Oct ${sel.time}',
        nextIn: 'in 5 d',
      ),
      Frequency.cron => sel.copyWith(frequency: f),
    };
    emit(
      state.copyWith(
        configs: [for (final c in state.configs) c.id == sel.id ? updated : c],
      ),
    );
  }

  void setObjectKey(String key) {
    final id = state.selectedId;
    emit(
      state.copyWith(
        configs: [
          for (final c in state.configs)
            c.id == id ? c.copyWith(objectKey: key) : c,
        ],
      ),
    );
  }

  /// What the next run writes, with the placeholders of the key filled
  static String resolveKey(String key, String db) => key
      .replaceAll('{yyyy-MM-dd}', '2026-10-21')
      .replaceAll('{yyyy}', '2026')
      .replaceAll('{MM}', '10')
      .replaceAll('{dd}', '21')
      .replaceAll('{HHmm}', '0200')
      .replaceAll('{ww}', '43')
      .replaceAll('{db}', db)
      .replaceAll('{run_id}', 'r_7f3a91');
}
