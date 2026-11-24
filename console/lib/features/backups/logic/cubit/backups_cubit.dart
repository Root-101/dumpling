import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The backups (saved configs) of the open workspace with their last and next
/// run, from the canvas: one request brings them with the names of their
/// source and destination. Search, filters, sort, the recent runs of a row,
/// Run now, and editing or deleting a config out of the canvas
class BackupsCubit extends Cubit<BackupsState>
    with GlobalEventBusCommunication<BackupsState> {
  /// How many runs a row shows when it opens
  static const int recentRuns = 5;

  final AuthCubit auth;
  final CanvasRepo repo;
  final ConfigsRepo configs;
  final RunsRepo runs;

  /// How often a run started here is asked how it goes
  final Duration pollEvery;

  BackupsCubit({
    required this.auth,
    required this.repo,
    required this.configs,
    required this.runs,
    this.pollEvery = const Duration(seconds: 2),
  }) : super(const BackupsInitialState()) {
    onBus<CanvasSavedOkState>((_) => reload());
  }

  /// The service gives no refresh token: the one of the session, or none
  String? get _token => auth.auth?.accessToken;

  /// The backups of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : BackupsData.empty(workspace);
    emit(BackupsSearchingState(data: data));
    try {
      final canvas = await repo.get(workspace: workspace, token: _token);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(BackupsSearchOkState(data: state.data.withCanvas(canvas)));
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        BackupsSearchErrorState(ExceptionConverter.parse(e), data: state.data),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By backup, source or destination name
  void search(String query) =>
      emit(BackupsSearchOkState(data: state.data._copy(query: query)));

  /// Null: every health
  void filterHealth(BackupHealth? health) =>
      emit(BackupsSearchOkState(data: state.data._copy(health: () => health)));

  /// Null: every source
  void filterSource(String? id) =>
      emit(BackupsSearchOkState(data: state.data._copy(sourceId: () => id)));

  /// Null: every destination
  void filterDestination(String? id) => emit(
    BackupsSearchOkState(data: state.data._copy(destinationId: () => id)),
  );

  void sort(BackupSort sort) =>
      emit(BackupsSearchOkState(data: state.data._copy(sort: sort)));

  void clearFilters() => emit(
    BackupsSearchOkState(
      data: state.data._copy(
        query: '',
        health: () => null,
        sourceId: () => null,
        destinationId: () => null,
      ),
    ),
  );

  /// Moves the backup at [from] to [to] (in the manual sort with no filter
  /// on, the list shown is the whole one) and saves the order; back as it was
  /// if that fails
  Future<void> reorder(int from, int to) async {
    final before = state.data;
    final backups = reordered(before.backups, from, to);
    emit(BackupsSearchOkState(data: before._copy(backups: backups)));
    try {
      await configs.reorder(
        workspace: before.workspace!,
        ids: [for (final b in backups) b.config.id],
        token: _token,
      );
    } on Exception catch (e) {
      if (state.data.workspace != before.workspace) return;
      emit(
        BackupsReorderingErrorState(ExceptionConverter.parse(e), data: before),
      );
    }
  }

  /// The [recentRuns] newest runs of [configId], for its row once opened
  Future<void> loadRecent(String configId) async {
    final workspace = state.data.workspace!;
    emit(BackupsLoadingRecentState(configId, data: state.data));
    try {
      final recent = await runs.list(
        workspace: workspace,
        configId: configId,
        limit: recentRuns,
        token: _token,
      );
      if (isClosed || state.data.workspace != workspace) return;
      emit(
        BackupsLoadedRecentOkState(
          configId,
          data: state.data._copy(
            recent: {...state.data.recent, configId: recent},
          ),
        ),
      );
    } on Exception catch (e) {
      if (isClosed || state.data.workspace != workspace) return;
      emit(
        BackupsLoadingRecentErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  /// Saves [config] as the dialog left it; null when it went well, else
  /// what the service said (the dialog shows it and stays open)
  Future<String?> save(BackupConfig config) async {
    final workspace = state.data.workspace!;
    emit(BackupsSavingState(config.name, data: state.data));
    try {
      await configs.update(workspace: workspace, config: config, token: _token);
    } on Exception catch (e) {
      final exception = ExceptionConverter.parse(e);
      emit(BackupsSavingErrorState(exception, data: state.data));
      return exception.intlMessage;
    }
    if (isClosed || state.data.workspace != workspace) return null;
    emit(BackupsSavedOkState(config.name, data: state.data));
    await reload();
    return null;
  }

  /// Deletes its config: it stops running; its runs stay in the run log
  Future<void> delete(BackupRow backup) async {
    final deleting = _delete(backup);
    _deleting = deleting;
    await deleting;
    if (_deleting == deleting) _deleting = null;
  }

  /// A run waits for it to show how it goes: the overlay stays up meanwhile
  Future<void>? _deleting;

  Future<void> _delete(BackupRow backup) async {
    final workspace = state.data.workspace!;
    emit(BackupsDeletingState(backup.config.name, data: state.data));
    try {
      await configs.delete(
        workspace: workspace,
        id: backup.config.id,
        token: _token,
      );
      if (isClosed || state.data.workspace != workspace) return;
      emit(BackupsDeletedOkState(backup.config.name, data: state.data));
    } on Exception catch (e) {
      if (isClosed || state.data.workspace != workspace) return;
      emit(
        BackupsDeletingErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// Starts a run of [backup] and follows it until it ends
  Future<void> runNow(BackupRow backup) async {
    final workspace = state.data.workspace!;
    final id = backup.config.id;
    try {
      var run = await repo.runNow(
        workspace: workspace,
        configId: id,
        token: _token,
      );
      while (true) {
        await _deleting;
        if (isClosed || state.data.workspace != workspace) return;
        emit(
          BackupsRunningNowState(
            backup.config.name,
            run,
            data: state.data.withRun(id, run),
          ),
        );
        if (!run.running) break;
        await Future.delayed(pollEvery);
        run = await repo.run(workspace: workspace, id: run.id, token: _token);
      }
      await _deleting;
      if (isClosed || state.data.workspace != workspace) return;
      emit(BackupsRanNowOkState(backup.config.name, run, data: state.data));
      // an open row shows the new run too
      if (state.data.recent.containsKey(id)) await loadRecent(id);
    } on Exception catch (e) {
      if (isClosed || state.data.workspace != workspace) return;
      emit(
        BackupsRunningNowErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  /// After signing out
  void reset() => emit(const BackupsInitialState());
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
    RunStatus.running || RunStatus.queued => running,
    _ when !c.enabled => paused,
    null => neverRan,
    RunStatus.failed => failing,
    RunStatus.success => healthy,
  };
}

/// [name]: of the source, then of the config. [manual]: the order the user
/// dragged them to, kept in the service
enum BackupSort { lastRun, lastRunOldest, nextRun, name, manual }

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
class BackupsData {
  final String? workspace;
  final bool loaded;
  final List<BackupRow> backups;
  final String query;
  final BackupHealth? health;

  /// Null: every source / destination
  final String? sourceId;
  final String? destinationId;
  final BackupSort sort;

  /// The newest runs of each config whose row was opened
  final Map<String, List<RunModel>> recent;
  final List<BackupRow> visible;

  const BackupsData._({
    required this.workspace,
    required this.loaded,
    required this.backups,
    required this.query,
    required this.health,
    required this.sourceId,
    required this.destinationId,
    required this.sort,
    required this.recent,
    required this.visible,
  });

  const BackupsData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        backups: const [],
        query: '',
        health: null,
        sourceId: null,
        destinationId: null,
        sort: BackupSort.lastRun,
        recent: const {},
        visible: const [],
      );

  BackupsData _copy({
    bool? loaded,
    List<BackupRow>? backups,
    String? query,
    BackupHealth? Function()? health,
    String? Function()? sourceId,
    String? Function()? destinationId,
    BackupSort? sort,
    Map<String, List<RunModel>>? recent,
  }) {
    final backups_ = backups ?? this.backups;
    final query_ = query ?? this.query;
    final health_ = health == null ? this.health : health();
    final source_ = sourceId == null ? this.sourceId : sourceId();
    final destination_ = destinationId == null
        ? this.destinationId
        : destinationId();
    final sort_ = sort ?? this.sort;
    final needle = query_.trim().toLowerCase();
    bool matches(BackupRow b) =>
        (health_ == null || b.health == health_) &&
        (source_ == null || b.source.id == source_) &&
        (destination_ == null || b.destination.id == destination_) &&
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

    final position = {for (final (i, b) in backups_.indexed) b.config.id: i};
    final visible = backups_.where(matches).toList()
      ..sort(
        (a, b) => switch (sort_) {
          BackupSort.name =>
            '${a.source.name} ${a.config.name}'.toLowerCase().compareTo(
              '${b.source.name} ${b.config.name}'.toLowerCase(),
            ),
          // newest first
          BackupSort.lastRun => byDate(
            a.config.lastRun?.startedAt,
            b.config.lastRun?.startedAt,
            newest: true,
          ),
          BackupSort.lastRunOldest => byDate(
            a.config.lastRun?.startedAt,
            b.config.lastRun?.startedAt,
          ),
          BackupSort.nextRun => byDate(a.config.nextRun, b.config.nextRun),
          BackupSort.manual => position[a.config.id]!.compareTo(
            position[b.config.id]!,
          ),
        },
      );
    return BackupsData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      backups: backups_,
      query: query_,
      health: health_,
      sourceId: source_,
      destinationId: destination_,
      sort: sort_,
      recent: recent ?? this.recent,
      visible: visible,
    );
  }

  /// The saved configs; one whose node is missing (it can't be saved so) is
  /// left out
  BackupsData withCanvas(CanvasModel canvas) {
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

  BackupsData withRun(String configId, LastRun run) => _copy(
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
  int get activeFilters =>
      [health, sourceId, destinationId].where((f) => f != null).length;

  /// The rows can be dragged only when they are all shown
  bool get filtered => activeFilters > 0 || query.trim().isNotEmpty;
}

abstract class BackupsState {
  /// The backups of the open workspace, kept in every state
  final BackupsData data;

  const BackupsState({this.data = const BackupsData.empty()});
}

final class BackupsInitialState extends BackupsState {
  const BackupsInitialState();
}

//----------------- search -----------------\\
abstract class BackupsSearchState extends BackupsState {
  const BackupsSearchState({required super.data});
}

final class BackupsSearchingState extends BackupsSearchState {
  const BackupsSearchingState({required super.data});
}

final class BackupsSearchOkState extends BackupsSearchState {
  const BackupsSearchOkState({required super.data});
}

final class BackupsSearchErrorState extends BackupsSearchState {
  final GlobalException exception;

  const BackupsSearchErrorState(this.exception, {required super.data});
}

//----------------- the recent runs of a row -----------------\\
final class BackupsLoadingRecentState extends BackupsState {
  final String configId;

  const BackupsLoadingRecentState(this.configId, {required super.data});
}

final class BackupsLoadedRecentOkState extends BackupsState {
  final String configId;

  const BackupsLoadedRecentOkState(this.configId, {required super.data});
}

final class BackupsLoadingRecentErrorState extends BackupsState {
  final GlobalException exception;

  const BackupsLoadingRecentErrorState(this.exception, {required super.data});
}

//----------------- save a config from its dialog -----------------\\
final class BackupsSavingState extends BackupsState {
  final String name;

  const BackupsSavingState(this.name, {required super.data});
}

final class BackupsSavedOkState extends BackupsState {
  final String name;

  const BackupsSavedOkState(this.name, {required super.data});
}

final class BackupsSavingErrorState extends BackupsState {
  final GlobalException exception;

  const BackupsSavingErrorState(this.exception, {required super.data});
}

//----------------- delete -----------------\\
final class BackupsDeletingState extends BackupsState {
  final String name;

  const BackupsDeletingState(this.name, {required super.data});
}

final class BackupsDeletedOkState extends BackupsState {
  final String name;

  const BackupsDeletedOkState(this.name, {required super.data});
}

final class BackupsDeletingErrorState extends BackupsState {
  final GlobalException exception;

  const BackupsDeletingErrorState(this.exception, {required super.data});
}

//----------------- Run now -----------------\\
/// Each answer while it runs: the row shows how it goes
final class BackupsRunningNowState extends BackupsState {
  final String name;
  final LastRun run;

  const BackupsRunningNowState(this.name, this.run, {required super.data});
}

/// Public contract: it ended, [run] says how (the rail counts failures from
/// the workspaces, which reload on it)
final class BackupsRanNowOkState extends BackupsState {
  final String name;
  final LastRun run;

  const BackupsRanNowOkState(this.name, this.run, {required super.data});
}

final class BackupsRunningNowErrorState extends BackupsState {
  final GlobalException exception;

  const BackupsRunningNowErrorState(this.exception, {required super.data});
}

//----------------- reorder -----------------\\
/// The order went back as it was (the move is shown before it is saved)
final class BackupsReorderingErrorState extends BackupsState {
  final GlobalException exception;

  const BackupsReorderingErrorState(this.exception, {required super.data});
}
