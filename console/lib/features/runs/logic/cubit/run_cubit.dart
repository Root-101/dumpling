import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The run log of the open workspace: the 200 newest runs, the search and the
/// filters over them, and the detail (with its log) of the runs opened
class RunCubit extends Cubit<RunState> {
  final RunRepo _repo;
  final AuthCubit _auth;

  RunCubit(this._repo, this._auth) : super(const RunInitialState());

  String? get _token => _auth.auth?.accessToken;

  /// The runs of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : RunData.empty(workspace);
    emit(RunLoadingInProgressState(data: data));
    try {
      final runs = await _repo.list(workspace: workspace, token: _token);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(RunLoadingSuccessState(data: state.data.withRuns(runs)));
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(RunLoadingErrorState(ExceptionConverter.parse(e), data: state.data));
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// Loads the log of [run]; a run still running is asked again every time
  ///
  /// [workspace] when it is opened out of the run log (Backups), whose list
  /// may be of another workspace or not loaded yet
  Future<void> detail(RunModel run, {String? workspace}) async {
    workspace ??= state.data.workspace!;
    if (state.data.workspace != workspace) {
      emit(RunLoadingSuccessState(data: RunData.empty(workspace)));
    }
    try {
      final detail = await _repo.get(
        workspace: workspace,
        id: run.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(RunLoadingSuccessState(data: state.data.withDetail(detail)));
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        RunProcessingErrorState(
          ExceptionConverter.parse(e).message,
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
      return await _repo.get(workspace: workspace, id: id, token: _token);
    } catch (_) {
      return null;
    }
  }

  /// By config, source or destination name, over the runs already loaded
  void search(String query) =>
      emit(RunLoadingSuccessState(data: state.data.withQuery(query)));

  /// Null: every status
  void filterStatus(RunStatus? status) => emit(
    RunLoadingSuccessState(data: state.data._copy(status: () => status)),
  );

  void filterSourceType(String? type) => emit(
    RunLoadingSuccessState(data: state.data._copy(sourceType: () => type)),
  );

  void filterDestinationType(String? type) => emit(
    RunLoadingSuccessState(data: state.data._copy(destinationType: () => type)),
  );

  void clearFilters() => emit(
    RunLoadingSuccessState(
      data: state.data._copy(
        query: '',
        status: () => null,
        sourceType: () => null,
        destinationType: () => null,
      ),
    ),
  );

  /// After signing out
  void reset() => emit(const RunInitialState());
}

/// The loaded runs, newest first, and what the search and the filters leave
/// ([visibleRuns], filled on every change). [details]: the runs opened, with
/// their log, by id
class RunData {
  final String? workspace;
  final bool loaded;
  final List<RunModel> runs;
  final Map<String, RunModel> details;
  final String query;
  final RunStatus? status;
  final String? sourceType;
  final String? destinationType;
  final List<RunModel> visibleRuns;

  const RunData._({
    required this.workspace,
    required this.loaded,
    required this.runs,
    required this.details,
    required this.query,
    required this.status,
    required this.sourceType,
    required this.destinationType,
    required this.visibleRuns,
  });

  const RunData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        runs: const [],
        details: const {},
        query: '',
        status: null,
        sourceType: null,
        destinationType: null,
        visibleRuns: const [],
      );

  RunData _copy({
    bool? loaded,
    List<RunModel>? runs,
    Map<String, RunModel>? details,
    String? query,
    RunStatus? Function()? status,
    String? Function()? sourceType,
    String? Function()? destinationType,
  }) {
    final runs_ = runs ?? this.runs;
    final query_ = query ?? this.query;
    final status_ = status == null ? this.status : status();
    final sourceType_ = sourceType == null ? this.sourceType : sourceType();
    final destinationType_ = destinationType == null
        ? this.destinationType
        : destinationType();
    final needle = query_.trim().toLowerCase();
    bool matches(RunModel r) =>
        (status_ == null || r.status == status_) &&
        (sourceType_ == null || r.sourceType == sourceType_) &&
        (destinationType_ == null || r.destinationType == destinationType_) &&
        (needle.isEmpty ||
            [
              r.configName,
              r.sourceName,
              r.destinationName,
            ].join(' ').toLowerCase().contains(needle));
    return RunData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      runs: runs_,
      details: details ?? this.details,
      query: query_,
      status: status_,
      sourceType: sourceType_,
      destinationType: destinationType_,
      visibleRuns: runs_.where(matches).toList(),
    );
  }

  /// A detail of a run that has changed since (it was running) is dropped
  RunData withRuns(List<RunModel> runs) => _copy(
    loaded: true,
    runs: runs,
    details: {
      for (final r in runs)
        if (details[r.id] case final d? when d.status == r.status) r.id: d,
    },
  );

  RunData withDetail(RunModel run) => _copy(
    runs: [for (final r in runs) r.id == run.id ? run : r],
    details: {...details, run.id: run},
  );

  RunData withQuery(String query) => _copy(query: query);

  /// How many filters are on (the search box apart)
  int get activeFilters =>
      [status, sourceType, destinationType].where((f) => f != null).length;
}

abstract class RunState {
  final RunData data;

  const RunState({this.data = const RunData.empty()});
}

class RunInitialState extends RunState {
  const RunInitialState();
}

//------------------------- LOADING -------------------------\
class RunLoadingInProgressState extends RunState {
  const RunLoadingInProgressState({required super.data});
}

class RunLoadingSuccessState extends RunState {
  const RunLoadingSuccessState({required super.data});
}

class RunLoadingErrorState extends RunState {
  final GlobalException exception;

  const RunLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
class RunProcessingErrorState extends RunState {
  final String message;

  const RunProcessingErrorState(this.message, {required super.data});
}
