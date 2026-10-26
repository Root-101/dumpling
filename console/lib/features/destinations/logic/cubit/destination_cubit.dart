import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The destinations of the open workspace: list, search, the type filter and
/// the row actions (test the connection, add or delete a folder, delete). The
/// backups (configs) are loaded with them to say how many write to each
/// destination and each folder
class DestinationCubit extends Cubit<DestinationState> {
  final DestinationRepo _repo;
  final ConfigRepo _configs;
  final AuthCubit _auth;

  DestinationCubit(this._repo, this._configs, this._auth)
    : super(const DestinationInitialState());

  String? get _token => _auth.auth?.accessToken;

  /// The destinations of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : DestinationData.empty(workspace);
    emit(DestinationLoadingInProgressState(data: data));
    try {
      final results = await Future.wait([
        _repo.types(token: _token),
        _repo.list(workspace: workspace, token: _token),
        _configs.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(
        DestinationLoadingSuccessState(
          data: state.data.withList(
            results[0] as List<DestinationTypeModel>,
            results[1] as List<DestinationModel>,
            results[2] as List<ConfigModel>,
          ),
        ),
      );
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        DestinationLoadingErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By name, type or endpoint, over the destinations already loaded
  void search(String query) {
    emit(DestinationLoadingSuccessState(data: state.data.withQuery(query)));
  }

  /// Only the destinations of [type]; null: all of them
  void filterType(String? type) {
    emit(DestinationLoadingSuccessState(data: state.data.withType(type)));
  }

  void clearFilters() {
    emit(
      DestinationLoadingSuccessState(
        data: state.data.withQuery('').withType(null),
      ),
    );
  }

  /// Tests the saved connection; the row shows *Testing…* meanwhile and then
  /// what it found
  Future<void> test(DestinationModel destination) async {
    final workspace = state.data.workspace!;
    emit(
      DestinationLoadingSuccessState(
        data: state.data.withTesting(destination.id, true),
      ),
    );
    try {
      final check = await _repo.testSaved(
        workspace: workspace,
        id: destination.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(
        DestinationProcessingOKState(
          DestinationAction.tested,
          destination.withCheck(check),
          data: state.data
              .withTesting(destination.id, false)
              .withCheck(destination.id, check),
        ),
      );
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        DestinationProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data.withTesting(destination.id, false),
        ),
      );
    }
  }

  /// Adds [path] (already clean) to the folders of [destination]
  Future<void> addFolder(DestinationModel destination, String path) =>
      _saveFolders(DestinationAction.folderAdded, destination, [
        ...destination.folders,
        path,
      ], path);

  /// The service refuses it (409) while a backup writes to it
  Future<void> deleteFolder(DestinationModel destination, String path) =>
      _saveFolders(
        DestinationAction.folderDeleted,
        destination,
        destination.folders.where((f) => f != path).toList(),
        path,
      );

  Future<void> _saveFolders(
    DestinationAction action,
    DestinationModel destination,
    List<String> folders,
    String path,
  ) async {
    await _process(action, path, () {
      // the saved settings as they are: without the secret key, the service
      // keeps the saved one
      return _repo.save(
        workspace: state.data.workspace!,
        id: destination.id,
        draft: DestinationDraft.of(destination, folders: folders),
        token: _token,
      );
    });
  }

  Future<void> delete(DestinationModel destination) async {
    await _process(DestinationAction.deleted, null, () async {
      await _repo.delete(
        workspace: state.data.workspace!,
        id: destination.id,
        token: _token,
      );
      return destination;
    });
  }

  Future<void> _process(
    DestinationAction action,
    String? folder,
    Future<DestinationModel> Function() run,
  ) async {
    emit(DestinationProcessInProgressState(data: state.data));
    try {
      final destination = await run();
      emit(
        DestinationProcessingOKState(
          action,
          destination,
          folder: folder,
          data: state.data,
        ),
      );
    } catch (e) {
      emit(
        DestinationProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// After signing out
  void reset() => emit(const DestinationInitialState());
}

/// What a row action did, so the view can confirm it
enum DestinationAction { tested, folderAdded, folderDeleted, deleted }

/// The loaded destinations and what the search and the filter leave
/// ([visibleDestinations], filled on every change). [usage] counts the
/// backups of each destination by its id, and within it by folder (null: the
/// bucket root)
class DestinationData {
  final String? workspace;
  final bool loaded;
  final List<DestinationTypeModel> types;
  final List<DestinationModel> destinations;
  final Map<String, Map<String?, int>> usage;
  final String query;

  /// Null: every type
  final String? type;

  /// The ids of the destinations being tested
  final Set<String> testing;
  final List<DestinationModel> visibleDestinations;

  const DestinationData._({
    required this.workspace,
    required this.loaded,
    required this.types,
    required this.destinations,
    required this.usage,
    required this.query,
    required this.type,
    required this.testing,
    required this.visibleDestinations,
  });

  const DestinationData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        types: const [],
        destinations: const [],
        usage: const {},
        query: '',
        type: null,
        testing: const {},
        visibleDestinations: const [],
      );

  factory DestinationData._of({
    required String? workspace,
    required bool loaded,
    required List<DestinationTypeModel> types,
    required List<DestinationModel> destinations,
    required Map<String, Map<String?, int>> usage,
    required String query,
    required String? type,
    required Set<String> testing,
  }) {
    final needle = query.trim().toLowerCase();
    bool matches(DestinationModel d) {
      final text = [
        d.name,
        DestinationTypeLook.labelOf(d.type),
        d.s3?.address ?? '',
        ...d.folders,
      ].join(' ').toLowerCase();
      return (type == null || d.type == type) &&
          (needle.isEmpty || text.contains(needle));
    }

    return DestinationData._(
      workspace: workspace,
      loaded: loaded,
      types: types,
      destinations: destinations,
      usage: usage,
      query: query,
      type: type,
      testing: testing,
      visibleDestinations: destinations.where(matches).toList(),
    );
  }

  DestinationData _copy({
    bool? loaded,
    List<DestinationTypeModel>? types,
    List<DestinationModel>? destinations,
    Map<String, Map<String?, int>>? usage,
    String? query,
    String? Function()? type,
    Set<String>? testing,
  }) => DestinationData._of(
    workspace: workspace,
    loaded: loaded ?? this.loaded,
    types: types ?? this.types,
    destinations: destinations ?? this.destinations,
    usage: usage ?? this.usage,
    query: query ?? this.query,
    type: type == null ? this.type : type(),
    testing: testing ?? this.testing,
  );

  DestinationData withList(
    List<DestinationTypeModel> types,
    List<DestinationModel> destinations,
    List<ConfigModel> configs,
  ) {
    final usage = <String, Map<String?, int>>{};
    for (final config in configs) {
      usage
          .putIfAbsent(config.destinationId, () => {})
          .update(config.folder, (n) => n + 1, ifAbsent: () => 1);
    }
    return _copy(
      loaded: true,
      types: types,
      destinations: destinations,
      usage: usage,
    );
  }

  DestinationData withQuery(String query) => _copy(query: query);

  DestinationData withType(String? type) => _copy(type: () => type);

  DestinationData withTesting(String id, bool testing) => _copy(
    testing: testing ? {...this.testing, id} : ({...this.testing}..remove(id)),
  );

  DestinationData withCheck(String id, ConnectionCheckModel check) => _copy(
    destinations: [
      for (final d in destinations) d.id == id ? d.withCheck(check) : d,
    ],
  );

  /// How many backups write to [destination], in any folder
  int usageOf(DestinationModel destination) =>
      (usage[destination.id]?.values ?? const <int>[]).fold(0, (a, b) => a + b);

  /// How many backups write to [folder] of [destination] (null: its root)
  int folderUsageOf(DestinationModel destination, String? folder) =>
      usage[destination.id]?[folder] ?? 0;

  /// How many filters are on (the search box apart)
  int get activeFilters => type == null ? 0 : 1;
}

abstract class DestinationState {
  final DestinationData data;

  const DestinationState({this.data = const DestinationData.empty()});
}

class DestinationInitialState extends DestinationState {
  const DestinationInitialState();
}

//------------------------- LOADING -------------------------\
class DestinationLoadingInProgressState extends DestinationState {
  const DestinationLoadingInProgressState({required super.data});
}

class DestinationLoadingSuccessState extends DestinationState {
  const DestinationLoadingSuccessState({required super.data});
}

class DestinationLoadingErrorState extends DestinationState {
  final GlobalException exception;

  const DestinationLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
class DestinationProcessInProgressState extends DestinationState {
  const DestinationProcessInProgressState({required super.data});
}

class DestinationProcessingOKState extends DestinationState {
  final DestinationAction action;

  /// The destination acted on; after [DestinationAction.tested], with its
  /// new check
  final DestinationModel destination;

  /// The folder added or deleted
  final String? folder;

  const DestinationProcessingOKState(
    this.action,
    this.destination, {
    required super.data,
    this.folder,
  });
}

class DestinationProcessingErrorState extends DestinationState {
  final String message;

  const DestinationProcessingErrorState(this.message, {required super.data});
}
