import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The destinations of the open workspace: list, search, the type filter and
/// the row actions (test the connection, add or delete a folder, delete). The
/// backups (configs) are loaded with them to say how many write to each
/// destination and each folder
class DestinationsCubit extends Cubit<DestinationsState>
    with GlobalEventBusCommunication<DestinationsState> {
  final AuthCubit auth;
  final DestinationsRepo repo;
  final ConfigsRepo configs;

  DestinationsCubit({
    required this.auth,
    required this.repo,
    required this.configs,
  }) : super(const DestinationsInitialState()) {
    onBus<CanvasSavedOkState>((_) => reload());
    // a destination saved in its form: the list again
    onBus<DestinationFormProcessingOKState>((_) => reload());
  }

  /// The service gives no refresh token: the one of the session, or none
  String? get _token => auth.auth?.accessToken;

  /// The destinations of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : DestinationsData.empty(workspace);
    emit(DestinationsSearchingState(data: data));
    try {
      final results = await Future.wait([
        repo.types(token: _token),
        repo.list(workspace: workspace, token: _token),
        configs.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(
        DestinationsSearchOkState(
          data: state.data.withList(
            results[0] as List<DestinationTypeModel>,
            results[1] as List<DestinationModel>,
            results[2] as List<ConfigModel>,
          ),
        ),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        DestinationsSearchErrorState(
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
    emit(DestinationsSearchOkState(data: state.data.withQuery(query)));
  }

  /// Only the destinations of [type]; null: all of them
  void filterType(String? type) {
    emit(DestinationsSearchOkState(data: state.data.withType(type)));
  }

  void clearFilters() {
    emit(
      DestinationsSearchOkState(data: state.data.withQuery('').withType(null)),
    );
  }

  /// Tests the saved connection; the row shows *Testing…* meanwhile and then
  /// what it found
  Future<void> test(DestinationModel destination) async {
    final workspace = state.data.workspace!;
    emit(
      DestinationsTestingState(
        destination,
        data: state.data.withTesting(destination.id, true),
      ),
    );
    try {
      final check = await repo.testSaved(
        workspace: workspace,
        id: destination.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(
        DestinationsTestedOkState(
          destination.withCheck(check),
          data: state.data
              .withTesting(destination.id, false)
              .withCheck(destination.id, check),
        ),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        DestinationsTestingErrorState(
          ExceptionConverter.parse(e),
          data: state.data.withTesting(destination.id, false),
        ),
      );
    }
  }

  /// Adds [path] (already clean) to the folders of [destination]
  Future<void> addFolder(DestinationModel destination, String path) async {
    emit(DestinationsAddingFolderState(destination, path, data: state.data));
    try {
      final saved = await _saveFolders(destination, [
        ...destination.folders,
        path,
      ]);
      emit(DestinationsAddedFolderOkState(saved, path, data: state.data));
    } on Exception catch (e) {
      emit(
        DestinationsAddingFolderErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// The service refuses it (409) while a backup writes to it
  Future<void> deleteFolder(DestinationModel destination, String path) async {
    emit(DestinationsDeletingFolderState(destination, path, data: state.data));
    try {
      final saved = await _saveFolders(
        destination,
        destination.folders.where((f) => f != path).toList(),
      );
      emit(DestinationsDeletedFolderOkState(saved, path, data: state.data));
    } on Exception catch (e) {
      emit(
        DestinationsDeletingFolderErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// Moves the folder of [destination] at [from] to [to] and saves it; back
  /// as it was if that fails. Its last check stays: the same folders
  Future<void> moveFolder(DestinationModel destination, int from, int to) {
    final folders = reordered(destination.folders, from, to);
    return _saveOrder(
      (data) => data._copy(
        destinations: [
          for (final d in data.destinations)
            d.id == destination.id ? d.withFolders(folders) : d,
        ],
      ),
      (workspace) => repo.save(
        workspace: workspace,
        id: destination.id,
        draft: DestinationDraft.of(destination, folders: folders),
        token: _token,
      ),
    );
  }

  /// Moves the destination at [from] to [to] (with no filter on, the list
  /// shown is the whole one) and saves the order; back as it was if that
  /// fails
  Future<void> reorder(int from, int to) {
    final destinations = reordered(state.data.destinations, from, to);
    return _saveOrder(
      (data) => data._copy(destinations: destinations),
      (workspace) => repo.reorder(
        workspace: workspace,
        ids: [for (final d in destinations) d.id],
        token: _token,
      ),
    );
  }

  /// Shows [change] at once and runs [save]; an error puts the list back
  Future<void> _saveOrder(
    DestinationsData Function(DestinationsData) change,
    Future<void> Function(String workspace) save,
  ) async {
    final before = state.data;
    emit(DestinationsSearchOkState(data: change(before)));
    try {
      await save(before.workspace!);
    } on Exception catch (e) {
      if (state.data.workspace != before.workspace) return;
      emit(
        DestinationsReorderingErrorState(
          ExceptionConverter.parse(e),
          data: before,
        ),
      );
    }
  }

  /// The saved settings as they are: without the secret key, the service
  /// keeps the saved one
  Future<DestinationModel> _saveFolders(
    DestinationModel destination,
    List<String> folders,
  ) => repo.save(
    workspace: state.data.workspace!,
    id: destination.id,
    draft: DestinationDraft.of(destination, folders: folders),
    token: _token,
  );

  Future<void> delete(DestinationModel destination) async {
    emit(DestinationsDeletingState(destination, data: state.data));
    try {
      await repo.delete(
        workspace: state.data.workspace!,
        id: destination.id,
        token: _token,
      );
      emit(DestinationsDeletedOkState(destination, data: state.data));
    } on Exception catch (e) {
      emit(
        DestinationsDeletingErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// After signing out
  void reset() => emit(const DestinationsInitialState());
}

/// The loaded destinations and what the search and the filter leave
/// ([visibleDestinations], filled on every change). [usage] counts the
/// backups of each destination by its id, and within it by folder (null: the
/// bucket root); [configs] are those backups, for the detail
class DestinationsData {
  final String? workspace;
  final bool loaded;
  final List<DestinationTypeModel> types;
  final List<DestinationModel> destinations;
  final Map<String, Map<String?, int>> usage;
  final List<ConfigModel> configs;
  final String query;

  /// Null: every type
  final String? type;

  /// The ids of the destinations being tested
  final Set<String> testing;
  final List<DestinationModel> visibleDestinations;

  const DestinationsData._({
    required this.workspace,
    required this.loaded,
    required this.types,
    required this.destinations,
    required this.usage,
    required this.configs,
    required this.query,
    required this.type,
    required this.testing,
    required this.visibleDestinations,
  });

  const DestinationsData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        types: const [],
        destinations: const [],
        usage: const {},
        configs: const [],
        query: '',
        type: null,
        testing: const {},
        visibleDestinations: const [],
      );

  factory DestinationsData._of({
    required String? workspace,
    required bool loaded,
    required List<DestinationTypeModel> types,
    required List<DestinationModel> destinations,
    required Map<String, Map<String?, int>> usage,
    required List<ConfigModel> configs,
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
        // the list shows only the endpoint: the bucket is still found
        d.s3?.bucket ?? '',
        ...d.folders,
      ].join(' ').toLowerCase();
      return (type == null || d.type == type) &&
          (needle.isEmpty || text.contains(needle));
    }

    return DestinationsData._(
      workspace: workspace,
      loaded: loaded,
      types: types,
      destinations: destinations,
      usage: usage,
      configs: configs,
      query: query,
      type: type,
      testing: testing,
      visibleDestinations: destinations.where(matches).toList(),
    );
  }

  DestinationsData _copy({
    bool? loaded,
    List<DestinationTypeModel>? types,
    List<DestinationModel>? destinations,
    Map<String, Map<String?, int>>? usage,
    List<ConfigModel>? configs,
    String? query,
    String? Function()? type,
    Set<String>? testing,
  }) => DestinationsData._of(
    workspace: workspace,
    loaded: loaded ?? this.loaded,
    types: types ?? this.types,
    destinations: destinations ?? this.destinations,
    usage: usage ?? this.usage,
    configs: configs ?? this.configs,
    query: query ?? this.query,
    type: type == null ? this.type : type(),
    testing: testing ?? this.testing,
  );

  DestinationsData withList(
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
      configs: configs,
    );
  }

  DestinationsData withQuery(String query) => _copy(query: query);

  DestinationsData withType(String? type) => _copy(type: () => type);

  DestinationsData withTesting(String id, bool testing) => _copy(
    testing: testing ? {...this.testing, id} : ({...this.testing}..remove(id)),
  );

  DestinationsData withCheck(String id, ConnectionCheckModel check) => _copy(
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

  /// The backups that write to [folder] of [destination] (null: its root)
  List<ConfigModel> writersOf(DestinationModel destination, String? folder) =>
      configs
          .where((c) => c.destinationId == destination.id && c.folder == folder)
          .toList();

  /// How many filters are on (the search box apart)
  int get activeFilters => type == null ? 0 : 1;

  /// The rows can be dragged only when they are all shown
  bool get filtered => activeFilters > 0 || query.trim().isNotEmpty;
}

abstract class DestinationsState {
  /// The destinations of the open workspace, kept in every state: the list
  /// stays on screen while a row is tested, changed or deleted
  final DestinationsData data;

  const DestinationsState({this.data = const DestinationsData.empty()});
}

final class DestinationsInitialState extends DestinationsState {
  const DestinationsInitialState();
}

//----------------- search -----------------\\
abstract class DestinationsSearchState extends DestinationsState {
  const DestinationsSearchState({required super.data});
}

final class DestinationsSearchingState extends DestinationsSearchState {
  const DestinationsSearchingState({required super.data});
}

final class DestinationsSearchOkState extends DestinationsSearchState {
  const DestinationsSearchOkState({required super.data});
}

final class DestinationsSearchErrorState extends DestinationsSearchState {
  final GlobalException exception;

  const DestinationsSearchErrorState(this.exception, {required super.data});
}

//----------------- test a saved destination -----------------\\
final class DestinationsTestingState extends DestinationsState {
  final DestinationModel destination;

  const DestinationsTestingState(this.destination, {required super.data});
}

/// With its new check
final class DestinationsTestedOkState extends DestinationsState {
  final DestinationModel destination;

  const DestinationsTestedOkState(this.destination, {required super.data});
}

final class DestinationsTestingErrorState extends DestinationsState {
  final GlobalException exception;

  const DestinationsTestingErrorState(this.exception, {required super.data});
}

//----------------- add a folder -----------------\\
final class DestinationsAddingFolderState extends DestinationsState {
  final DestinationModel destination;
  final String folder;

  const DestinationsAddingFolderState(
    this.destination,
    this.folder, {
    required super.data,
  });
}

final class DestinationsAddedFolderOkState extends DestinationsState {
  final DestinationModel destination;
  final String folder;

  const DestinationsAddedFolderOkState(
    this.destination,
    this.folder, {
    required super.data,
  });
}

final class DestinationsAddingFolderErrorState extends DestinationsState {
  final GlobalException exception;

  const DestinationsAddingFolderErrorState(
    this.exception, {
    required super.data,
  });
}

//----------------- delete a folder -----------------\\
final class DestinationsDeletingFolderState extends DestinationsState {
  final DestinationModel destination;
  final String folder;

  const DestinationsDeletingFolderState(
    this.destination,
    this.folder, {
    required super.data,
  });
}

final class DestinationsDeletedFolderOkState extends DestinationsState {
  final DestinationModel destination;
  final String folder;

  const DestinationsDeletedFolderOkState(
    this.destination,
    this.folder, {
    required super.data,
  });
}

final class DestinationsDeletingFolderErrorState extends DestinationsState {
  final GlobalException exception;

  const DestinationsDeletingFolderErrorState(
    this.exception, {
    required super.data,
  });
}

//----------------- delete -----------------\\
final class DestinationsDeletingState extends DestinationsState {
  final DestinationModel destination;

  const DestinationsDeletingState(this.destination, {required super.data});
}

final class DestinationsDeletedOkState extends DestinationsState {
  final DestinationModel destination;

  const DestinationsDeletedOkState(this.destination, {required super.data});
}

final class DestinationsDeletingErrorState extends DestinationsState {
  final GlobalException exception;

  const DestinationsDeletingErrorState(this.exception, {required super.data});
}

//----------------- reorder -----------------\\
/// The order (of the destinations or of the folders of one) went back as it
/// was: the move is shown before it is saved
final class DestinationsReorderingErrorState extends DestinationsState {
  final GlobalException exception;

  const DestinationsReorderingErrorState(this.exception, {required super.data});
}
