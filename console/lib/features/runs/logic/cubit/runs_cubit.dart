import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The run log of the open workspace: the 200 newest runs, the search and the
/// filters over them, and the detail (with its log) of the runs opened
class RunsCubit extends Cubit<RunsState>
    with GlobalEventBusCommunication<RunsState> {
  final AuthCubit auth;
  final RunsRepo repo;

  RunsCubit({required this.auth, required this.repo})
    : super(const RunsInitialState());

  /// The service gives no refresh token: the one of the session, or none
  String? get _token => auth.auth?.accessToken;

  /// The runs of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : RunsData.empty(workspace);
    emit(RunsSearchingState(data: data));
    try {
      final runs = await repo.list(workspace: workspace, token: _token);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(RunsSearchOkState(data: state.data.withRuns(runs)));
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(RunsSearchErrorState(ExceptionConverter.parse(e), data: state.data));
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// Runs the config of [run] again (Retry now, Run again in its dialog) and
  /// reloads the log with the new run; false when the service refused it
  Future<bool> runAgain(RunModel run, {String? workspace}) async {
    final configId = run.configId;
    workspace ??= state.data.workspace;
    if (configId == null || workspace == null) return false;
    emit(RunsRunningAgainState(run, data: state.data));
    try {
      final started = await repo.runAgain(
        workspace: workspace,
        configId: configId,
        token: _token,
      );
      emit(RunsRanAgainOkState(started, data: state.data));
      if (state.data.workspace == workspace) await load(workspace);
      return true;
    } on Exception catch (e) {
      emit(
        RunsRunningAgainErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return false;
    }
  }

  /// Loads the log of [run]; a run still running is asked again every time
  ///
  /// [workspace] when it is opened out of the run log (Backups), whose list
  /// may be of another workspace or not loaded yet
  Future<void> detail(RunModel run, {String? workspace}) async {
    workspace ??= state.data.workspace!;
    final data = state.data.workspace == workspace
        ? state.data
        : RunsData.empty(workspace);
    emit(RunsLoadingDetailState(run, data: data));
    try {
      final detail = await repo.get(
        workspace: workspace,
        id: run.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(
        RunsLoadedDetailOkState(detail, data: state.data.withDetail(detail)),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        RunsLoadingDetailErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  /// The run [id] of [workspace] for its dialog: from what is loaded, or from
  /// the service (older than the list, or the list not loaded); null when
  /// there is none
  Future<RunModel?> find(String workspace, String id) async {
    final data = state.data;
    if (data.workspace == workspace) {
      final known =
          data.details[id] ?? data.runs.where((r) => r.id == id).firstOrNull;
      if (known != null) return known;
    }
    try {
      return await repo.get(workspace: workspace, id: id, token: _token);
    } on Exception {
      return null;
    }
  }

  /// By config, source or destination name, over the runs already loaded
  void search(String query) =>
      emit(RunsSearchOkState(data: state.data.withQuery(query)));

  /// Null: every status
  void filterStatus(RunStatus? status) =>
      emit(RunsSearchOkState(data: state.data._copy(status: () => status)));

  void filterSourceType(String? type) =>
      emit(RunsSearchOkState(data: state.data._copy(sourceType: () => type)));

  void filterDestinationType(String? type) => emit(
    RunsSearchOkState(data: state.data._copy(destinationType: () => type)),
  );

  /// `schedule`, `manual` or `api`; null: all of them
  void filterTrigger(String? trigger) =>
      emit(RunsSearchOkState(data: state.data._copy(trigger: () => trigger)));

  void clearFilters() => emit(
    RunsSearchOkState(
      data: state.data._copy(
        query: '',
        status: () => null,
        sourceType: () => null,
        destinationType: () => null,
        trigger: () => null,
      ),
    ),
  );

  /// After signing out
  void reset() => emit(const RunsInitialState());
}

/// The loaded runs, newest first, and what the search and the filters leave
/// ([visibleRuns], filled on every change). [details]: the runs opened, with
/// their log, by id
class RunsData {
  final String? workspace;
  final bool loaded;
  final List<RunModel> runs;
  final Map<String, RunModel> details;
  final String query;
  final RunStatus? status;
  final String? sourceType;
  final String? destinationType;

  /// Who started them: `schedule`, `manual` or `api`
  final String? trigger;
  final List<RunModel> visibleRuns;

  const RunsData._({
    required this.workspace,
    required this.loaded,
    required this.runs,
    required this.details,
    required this.query,
    required this.status,
    required this.sourceType,
    required this.destinationType,
    required this.trigger,
    required this.visibleRuns,
  });

  const RunsData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        runs: const [],
        details: const {},
        query: '',
        status: null,
        sourceType: null,
        destinationType: null,
        trigger: null,
        visibleRuns: const [],
      );

  RunsData _copy({
    bool? loaded,
    List<RunModel>? runs,
    Map<String, RunModel>? details,
    String? query,
    RunStatus? Function()? status,
    String? Function()? sourceType,
    String? Function()? destinationType,
    String? Function()? trigger,
  }) {
    final runs_ = runs ?? this.runs;
    final query_ = query ?? this.query;
    final status_ = status == null ? this.status : status();
    final sourceType_ = sourceType == null ? this.sourceType : sourceType();
    final destinationType_ = destinationType == null
        ? this.destinationType
        : destinationType();
    final trigger_ = trigger == null ? this.trigger : trigger();
    final needle = query_.trim().toLowerCase();
    bool matches(RunModel r) =>
        (status_ == null || r.status == status_) &&
        (sourceType_ == null || r.sourceType == sourceType_) &&
        (destinationType_ == null || r.destinationType == destinationType_) &&
        (trigger_ == null || r.trigger == trigger_) &&
        (needle.isEmpty ||
            [
              r.configName,
              r.sourceName,
              r.destinationName,
              ?r.label,
              ?r.keyName,
            ].join(' ').toLowerCase().contains(needle));
    return RunsData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      runs: runs_,
      details: details ?? this.details,
      query: query_,
      status: status_,
      sourceType: sourceType_,
      destinationType: destinationType_,
      trigger: trigger_,
      visibleRuns: runs_.where(matches).toList(),
    );
  }

  /// A detail of a run that has changed since (it was running) is dropped
  RunsData withRuns(List<RunModel> runs) => _copy(
    loaded: true,
    runs: runs,
    details: {
      for (final r in runs)
        if (details[r.id] case final d? when d.status == r.status) r.id: d,
    },
  );

  RunsData withDetail(RunModel run) => _copy(
    runs: [for (final r in runs) r.id == run.id ? run : r],
    details: {...details, run.id: run},
  );

  RunsData withQuery(String query) => _copy(query: query);

  /// How many filters are on (the search box apart)
  int get activeFilters => [
    status,
    sourceType,
    destinationType,
    trigger,
  ].where((f) => f != null).length;
}

abstract class RunsState {
  /// The runs of the open workspace and the details opened, kept in every
  /// state
  final RunsData data;

  const RunsState({this.data = const RunsData.empty()});
}

final class RunsInitialState extends RunsState {
  const RunsInitialState();
}

//----------------- search -----------------\\
abstract class RunsSearchState extends RunsState {
  const RunsSearchState({required super.data});
}

final class RunsSearchingState extends RunsSearchState {
  const RunsSearchingState({required super.data});
}

final class RunsSearchOkState extends RunsSearchState {
  const RunsSearchOkState({required super.data});
}

final class RunsSearchErrorState extends RunsSearchState {
  final GlobalException exception;

  const RunsSearchErrorState(this.exception, {required super.data});
}

//----------------- the detail of a run -----------------\\
abstract class RunsDetailState extends RunsState {
  const RunsDetailState({required super.data});
}

final class RunsLoadingDetailState extends RunsDetailState {
  final RunModel run;

  const RunsLoadingDetailState(this.run, {required super.data});
}

final class RunsLoadedDetailOkState extends RunsDetailState {
  /// With its log
  final RunModel run;

  const RunsLoadedDetailOkState(this.run, {required super.data});
}

final class RunsLoadingDetailErrorState extends RunsDetailState {
  final GlobalException exception;

  const RunsLoadingDetailErrorState(this.exception, {required super.data});
}

//----------------- run the config of a run again -----------------\\
abstract class RunsRunAgainState extends RunsState {
  const RunsRunAgainState({required super.data});
}

final class RunsRunningAgainState extends RunsRunAgainState {
  final RunModel run;

  const RunsRunningAgainState(this.run, {required super.data});
}

final class RunsRanAgainOkState extends RunsRunAgainState {
  /// The new run
  final RunModel run;

  const RunsRanAgainOkState(this.run, {required super.data});
}

final class RunsRunningAgainErrorState extends RunsRunAgainState {
  final GlobalException exception;

  const RunsRunningAgainErrorState(this.exception, {required super.data});
}
