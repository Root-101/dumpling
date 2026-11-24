import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The workspaces and the current one. App-wide: the rail shows the current
/// workspace on every screen. The URL says which one is open
/// (`/workspaces/{slug}/…`); [select] follows it and remembers it for the
/// screens outside a workspace
class WorkspacesCubit extends Cubit<WorkspacesState> {
  final WorkspacesRepo _repo;
  final AuthCubit _auth;

  WorkspacesCubit(this._repo, this._auth) : super(const WorkspacesInitialState());

  /// The workspace opened last, before the first screen
  Future<void> restore() async {
    final slug = await _repo.loadLast();
    emit(WorkspacesInitialState(data: state.data.withCurrent(slug)));
  }

  Future<void> load() async {
    emit(WorkspacesLoadingInProgressState(data: state.data));
    try {
      final workspaces = await _repo.list(token: _auth.auth?.accessToken);
      emit(WorkspacesLoadingSuccessState(data: state.data.withList(workspaces)));
    } catch (e) {
      emit(
        WorkspacesLoadingErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  /// [slug] is now the current workspace (the URL opened it)
  void select(String slug) {
    if (state.data.currentSlug == slug) return;
    _repo.saveLast(slug);
    final data = state.data.withCurrent(slug);
    // a load in progress keeps showing as such
    emit(
      state is WorkspacesLoadingInProgressState
          ? WorkspacesLoadingInProgressState(data: data)
          : WorkspacesLoadingSuccessState(data: data),
    );
  }

  /// After signing out: another session may see other workspaces
  void reset() => emit(const WorkspacesInitialState());
}

/// The loaded workspaces and the current one. [current] is filled on every
/// change: null until the list is loaded or when the slug isn't in it
class WorkspacesData {
  final List<WorkspaceModel> workspaces;
  final bool loaded;
  final String? currentSlug;
  final WorkspaceModel? current;

  const WorkspacesData._({
    required this.workspaces,
    required this.loaded,
    required this.currentSlug,
    required this.current,
  });

  const WorkspacesData.empty()
    : this._(
        workspaces: const [],
        loaded: false,
        currentSlug: null,
        current: null,
      );

  factory WorkspacesData._of({
    required List<WorkspaceModel> workspaces,
    required bool loaded,
    required String? currentSlug,
  }) => WorkspacesData._(
    workspaces: workspaces,
    loaded: loaded,
    currentSlug: currentSlug,
    current: workspaces.where((w) => w.slug == currentSlug).firstOrNull,
  );

  WorkspacesData withList(List<WorkspaceModel> workspaces) => WorkspacesData._of(
    workspaces: workspaces,
    loaded: true,
    currentSlug: currentSlug,
  );

  WorkspacesData withCurrent(String? slug) => WorkspacesData._of(
    workspaces: workspaces,
    loaded: loaded,
    currentSlug: slug,
  );
}

abstract class WorkspacesState {
  final WorkspacesData data;

  const WorkspacesState({this.data = const WorkspacesData.empty()});
}

class WorkspacesInitialState extends WorkspacesState {
  const WorkspacesInitialState({super.data});
}

//------------------------- LOADING -------------------------\
class WorkspacesLoadingInProgressState extends WorkspacesState {
  const WorkspacesLoadingInProgressState({required super.data});
}

class WorkspacesLoadingSuccessState extends WorkspacesState {
  const WorkspacesLoadingSuccessState({required super.data});
}

class WorkspacesLoadingErrorState extends WorkspacesState {
  final GlobalException exception;

  const WorkspacesLoadingErrorState(this.exception, {required super.data});
}
