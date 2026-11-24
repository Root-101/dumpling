import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The workspaces and the current one. App-wide: the rail shows the current
/// workspace on every screen. The URL says which one is open
/// (`/workspaces/{slug}/…`); [select] follows it and remembers it for the
/// screens outside a workspace
class WorkspacesCubit extends Cubit<WorkspacesState>
    with GlobalEventBusCommunication<WorkspacesState> {
  final AuthCubit auth;
  final WorkspacesRepo repo;

  WorkspacesCubit({required this.auth, required this.repo})
    : super(const WorkspacesInitialState()) {
    // what changes the list, or the counts of its cards (the failing ones of
    // the rail): a workspace saved, deleted or imported, a run ended
    onBus<WorkspaceFormProcessingOKState>((_) => load());
    onBus<WorkspaceFormDeletedOkState>((_) => load());
    onBus<WorkspaceTransferImportedOkState>((_) => load());
    onBus<BackupsRanNowOkState>((_) => load());
    onBus<CanvasRanNowOkState>((_) => load());
    onBus<CanvasSavedOkState>((_) => load());
  }

  /// The workspace opened last, before the first screen
  Future<void> restore() async {
    final slug = await repo.loadLast();
    emit(WorkspacesInitialState(data: state.data.withCurrent(slug)));
  }

  Future<void> load() async {
    emit(WorkspacesSearchingState(data: state.data));
    try {
      final workspaces = await repo.list(token: auth.auth?.accessToken);
      emit(WorkspacesSearchOkState(data: state.data.withList(workspaces)));
    } on Exception catch (e) {
      emit(
        WorkspacesSearchErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  /// [slug] is now the current workspace (the URL opened it)
  void select(String slug) {
    if (state.data.currentSlug == slug) return;
    repo.saveLast(slug);
    final data = state.data.withCurrent(slug);
    // a load in progress keeps showing as such
    emit(
      state is WorkspacesSearchingState
          ? WorkspacesSearchingState(data: data)
          : WorkspacesSearchOkState(data: data),
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

  WorkspacesData withList(List<WorkspaceModel> workspaces) =>
      WorkspacesData._of(
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
  /// The workspaces and the current one, kept in every state
  final WorkspacesData data;

  const WorkspacesState({this.data = const WorkspacesData.empty()});
}

final class WorkspacesInitialState extends WorkspacesState {
  const WorkspacesInitialState({super.data});
}

//----------------- search -----------------\\
abstract class WorkspacesSearchState extends WorkspacesState {
  const WorkspacesSearchState({required super.data});
}

final class WorkspacesSearchingState extends WorkspacesSearchState {
  const WorkspacesSearchingState({required super.data});
}

final class WorkspacesSearchOkState extends WorkspacesSearchState {
  const WorkspacesSearchOkState({required super.data});
}

final class WorkspacesSearchErrorState extends WorkspacesSearchState {
  final GlobalException exception;

  const WorkspacesSearchErrorState(this.exception, {required super.data});
}
