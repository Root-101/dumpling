import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The backups (saved configs) of the open workspace with their last and next
/// run, from the canvas: one request brings them with the names of their
/// source and destination. Search, health filter, sort and Run now
class BackupCubit extends Cubit<BackupState> {
  final CanvasRepo _repo;
  final AuthCubit _auth;

  /// How often a run started here is asked how it goes
  final Duration pollEvery;

  BackupCubit(
    this._repo,
    this._auth, {
    this.pollEvery = const Duration(seconds: 2),
  }) : super(const BackupInitialState());

  String? get _token => _auth.auth?.accessToken;

  /// The backups of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : BackupData.empty(workspace);
    emit(BackupLoadingInProgressState(data: data));
    try {
      final canvas = await _repo.get(workspace: workspace, token: _token);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(BackupLoadingSuccessState(data: state.data.withCanvas(canvas)));
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        BackupLoadingErrorState(ExceptionConverter.parse(e), data: state.data),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By backup, source or destination name
  void search(String query) =>
      emit(BackupLoadingSuccessState(data: state.data._copy(query: query)));

  /// Null: every health
  void filterHealth(BackupHealth? health) => emit(
    BackupLoadingSuccessState(data: state.data._copy(health: () => health)),
  );

  void sort(BackupSort sort) =>
      emit(BackupLoadingSuccessState(data: state.data._copy(sort: sort)));

  void clearFilters() => emit(
    BackupLoadingSuccessState(
      data: state.data._copy(query: '', health: () => null),
    ),
  );

  /// Starts a run of [backup] and follows it until it ends
  Future<void> runNow(BackupRow backup) async {
    final workspace = state.data.workspace!;
    final id = backup.config.id;
    try {
      var run = await _repo.runNow(
        workspace: workspace,
        configId: id,
        token: _token,
      );
      while (true) {
        if (isClosed || state.data.workspace != workspace) return;
        emit(BackupLoadingSuccessState(data: state.data.withRun(id, run)));
        if (!run.running) break;
        await Future.delayed(pollEvery);
        run = await _repo.run(workspace: workspace, id: run.id, token: _token);
      }
      emit(BackupRunFinishedState(backup.config.name, run, data: state.data));
    } catch (e) {
      if (isClosed || state.data.workspace != workspace) return;
      emit(
        BackupProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data,
        ),
      );
    }
  }

  /// After signing out
  void reset() => emit(const BackupInitialState());
}

/// How a backup is doing, from its last run
enum BackupHealth {
  healthy,
  failing,
  running,
  neverRan,

  /// Disabled: it only runs with Run now
  paused;

  static BackupHealth of(BackupConfig c) => switch (c.lastRun?.status) {
    RunStatus.running => running,
    _ when !c.enabled => paused,
    null => neverRan,
    RunStatus.failed => failing,
    RunStatus.success => healthy,
  };
}

enum BackupSort { name, lastRun, nextRun }

/// A backup with the nodes it connects
class BackupRow {
  final BackupConfig config;
  final SourceNode source;
  final DestinationNode destination;

  const BackupRow(this.config, this.source, this.destination);

  BackupHealth get health => BackupHealth.of(config);
}

/// The backups loaded and what the search and the filter leave, sorted
/// ([visible], filled on every change)
class BackupData {
  final String? workspace;
  final bool loaded;
  final List<BackupRow> backups;
  final String query;
  final BackupHealth? health;
  final BackupSort sort;
  final List<BackupRow> visible;

  const BackupData._({
    required this.workspace,
    required this.loaded,
    required this.backups,
    required this.query,
    required this.health,
    required this.sort,
    required this.visible,
  });

  const BackupData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        backups: const [],
        query: '',
        health: null,
        sort: BackupSort.name,
        visible: const [],
      );

  BackupData _copy({
    bool? loaded,
    List<BackupRow>? backups,
    String? query,
    BackupHealth? Function()? health,
    BackupSort? sort,
  }) {
    final backups_ = backups ?? this.backups;
    final query_ = query ?? this.query;
    final health_ = health == null ? this.health : health();
    final sort_ = sort ?? this.sort;
    final needle = query_.trim().toLowerCase();
    bool matches(BackupRow b) =>
        (health_ == null || b.health == health_) &&
        (needle.isEmpty ||
            [
              b.config.name,
              b.source.name,
              b.destination.name,
            ].join(' ').toLowerCase().contains(needle));
    // the ones without a date go last
    int byDate(DateTime? a, DateTime? b, {bool newest = false}) {
      if (a == null || b == null) return a == b ? 0 : (a == null ? 1 : -1);
      return newest ? b.compareTo(a) : a.compareTo(b);
    }

    final visible = backups_.where(matches).toList()
      ..sort(
        (a, b) => switch (sort_) {
          BackupSort.name => a.config.name.toLowerCase().compareTo(
            b.config.name.toLowerCase(),
          ),
          // newest first
          BackupSort.lastRun => byDate(
            a.config.lastRun?.startedAt,
            b.config.lastRun?.startedAt,
            newest: true,
          ),
          BackupSort.nextRun => byDate(a.config.nextRun, b.config.nextRun),
        },
      );
    return BackupData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      backups: backups_,
      query: query_,
      health: health_,
      sort: sort_,
      visible: visible,
    );
  }

  /// The saved configs; one whose node is missing (it can't be saved so) is
  /// left out
  BackupData withCanvas(CanvasModel canvas) {
    final sources = {
      for (final s in [...canvas.sources, ...canvas.sourcePool]) s.id: s,
    };
    final destinations = {
      for (final d in [...canvas.destinations, ...canvas.destinationPool])
        d.id: d,
    };
    return _copy(
      loaded: true,
      backups: [
        for (final c in canvas.configs)
          if ((sources[c.sourceId], destinations[c.destinationId]) case (
            final s?,
            final d?,
          ))
            BackupRow(c, s, d),
      ],
    );
  }

  BackupData withRun(String configId, LastRun run) => _copy(
    backups: [
      for (final b in backups)
        b.config.id == configId
            ? BackupRow(
                b.config.copyWith(lastRun: run),
                b.source,
                b.destination,
              )
            : b,
    ],
  );

  int count(BackupHealth health) =>
      backups.where((b) => b.health == health).length;

  /// The backup that runs first, if any is scheduled
  BackupRow? get next {
    final scheduled = [
      for (final b in backups)
        if (b.config.nextRun != null) b,
    ];
    if (scheduled.isEmpty) return null;
    return scheduled.reduce(
      (a, b) => a.config.nextRun!.isAfter(b.config.nextRun!) ? b : a,
    );
  }

  /// How many filters are on (the search box and the sort apart)
  int get activeFilters => health == null ? 0 : 1;
}

abstract class BackupState {
  final BackupData data;

  const BackupState({this.data = const BackupData.empty()});
}

class BackupInitialState extends BackupState {
  const BackupInitialState();
}

//------------------------- LOADING -------------------------\
class BackupLoadingInProgressState extends BackupState {
  const BackupLoadingInProgressState({required super.data});
}

class BackupLoadingSuccessState extends BackupState {
  const BackupLoadingSuccessState({required super.data});
}

class BackupLoadingErrorState extends BackupState {
  final GlobalException exception;

  const BackupLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
/// A Run now started here ended: [run] says how
class BackupRunFinishedState extends BackupState {
  final String name;
  final LastRun run;

  const BackupRunFinishedState(this.name, this.run, {required super.data});
}

class BackupProcessingErrorState extends BackupState {
  final String message;

  const BackupProcessingErrorState(this.message, {required super.data});
}
