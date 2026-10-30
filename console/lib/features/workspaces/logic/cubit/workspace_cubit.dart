import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The workspaces and the current one. App-wide: the rail shows the current
/// workspace on every screen. The URL says which one is open
/// (`/workspaces/{slug}/…`); [select] follows it and remembers it for the
/// screens outside a workspace
class WorkspaceCubit extends Cubit<WorkspaceState> {
  final WorkspaceRepo _repo;
  final AuthCubit _auth;

  WorkspaceCubit(this._repo, this._auth) : super(const WorkspaceInitialState());

  /// The workspace opened last, before the first screen
  Future<void> restore() async {
    final slug = await _repo.loadLast();
    emit(WorkspaceInitialState(data: state.data.withCurrent(slug)));
  }

  Future<void> load() async {
    emit(WorkspaceLoadingInProgressState(data: state.data));
    try {
      final workspaces = await _repo.list(token: _auth.auth?.accessToken);
      emit(WorkspaceLoadingSuccessState(data: state.data.withList(workspaces)));
    } catch (e) {
      emit(
        WorkspaceLoadingErrorState(
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
      state is WorkspaceLoadingInProgressState
          ? WorkspaceLoadingInProgressState(data: data)
          : WorkspaceLoadingSuccessState(data: data),
    );
  }

  /// After signing out: another session may see other workspaces
  void reset() => emit(const WorkspaceInitialState());
}

/// The loaded workspaces and the current one. [current] is filled on every
/// change: null until the list is loaded or when the slug isn't in it
class WorkspaceData {
  final List<WorkspaceModel> workspaces;
  final bool loaded;
  final String? currentSlug;
  final WorkspaceModel? current;

  const WorkspaceData._({
    required this.workspaces,
    required this.loaded,
    required this.currentSlug,
    required this.current,
  });

  const WorkspaceData.empty()
    : this._(
        workspaces: const [],
        loaded: false,
        currentSlug: null,
        current: null,
      );

  factory WorkspaceData._of({
    required List<WorkspaceModel> workspaces,
    required bool loaded,
    required String? currentSlug,
  }) => WorkspaceData._(
    workspaces: workspaces,
    loaded: loaded,
    currentSlug: currentSlug,
    current: workspaces.where((w) => w.slug == currentSlug).firstOrNull,
  );

  WorkspaceData withList(List<WorkspaceModel> workspaces) => WorkspaceData._of(
    workspaces: workspaces,
    loaded: true,
    currentSlug: currentSlug,
  );

  WorkspaceData withCurrent(String? slug) => WorkspaceData._of(
    workspaces: workspaces,
    loaded: loaded,
    currentSlug: slug,
  );
}

abstract class WorkspaceState {
  final WorkspaceData data;

  const WorkspaceState({this.data = const WorkspaceData.empty()});
}

class WorkspaceInitialState extends WorkspaceState {
  const WorkspaceInitialState({super.data});
}

//------------------------- LOADING -------------------------\
class WorkspaceLoadingInProgressState extends WorkspaceState {
  const WorkspaceLoadingInProgressState({required super.data});
}

class WorkspaceLoadingSuccessState extends WorkspaceState {
  const WorkspaceLoadingSuccessState({required super.data});
}

class WorkspaceLoadingErrorState extends WorkspaceState {
  final GlobalException exception;

  const WorkspaceLoadingErrorState(this.exception, {required super.data});
}
