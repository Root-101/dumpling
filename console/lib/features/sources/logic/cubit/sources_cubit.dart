import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The sources of the open workspace: list, search, the type filter and the
/// row actions (test the connection, delete). The backups (configs) are loaded
/// with them to say how many use each source
class SourcesCubit extends Cubit<SourcesState>
    with GlobalEventBusCommunication<SourcesState> {
  final AuthCubit auth;
  final SourcesRepo repo;
  final ConfigsRepo configs;

  SourcesCubit({required this.auth, required this.repo, required this.configs})
    : super(const SourcesInitialState()) {
    // a source saved in its form, or the canvas saved: the list again
    onBus<SourceFormProcessingOKState>((_) => reload());
  }

  /// The service gives no refresh token: the one of the session, or none
  String? get _token => auth.auth?.accessToken;

  /// The sources of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : SourcesData.empty(workspace);
    emit(SourcesSearchingState(data: data));
    try {
      final results = await Future.wait([
        repo.types(token: _token),
        repo.list(workspace: workspace, token: _token),
        configs.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(
        SourcesSearchOkState(
          data: state.data.withList(
            results[0] as List<SourceTypeModel>,
            results[1] as List<SourceModel>,
            results[2] as List<ConfigModel>,
          ),
        ),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        SourcesSearchErrorState(ExceptionConverter.parse(e), data: state.data),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By name, type or host, over the sources already loaded
  void search(String query) {
    emit(SourcesSearchOkState(data: state.data.withQuery(query)));
  }

  /// Only the sources of [type]; null: all of them
  void filterType(String? type) {
    emit(SourcesSearchOkState(data: state.data.withType(type)));
  }

  void clearFilters() {
    emit(SourcesSearchOkState(data: state.data.withQuery('').withType(null)));
  }

  /// Tests the saved connection; the row shows *Testing…* meanwhile and then
  /// what it found
  Future<void> test(SourceModel source) async {
    final workspace = state.data.workspace!;
    emit(
      SourcesTestingState(
        source,
        data: state.data.withTesting(source.id, true),
      ),
    );
    try {
      final check = await repo.testSaved(
        workspace: workspace,
        id: source.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(
        SourcesTestedOkState(
          source.withCheck(check),
          data: state.data
              .withTesting(source.id, false)
              .withCheck(source.id, check),
        ),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        SourcesTestingErrorState(
          ExceptionConverter.parse(e),
          data: state.data.withTesting(source.id, false),
        ),
      );
    }
  }

  Future<void> delete(SourceModel source) async {
    emit(SourcesDeletingState(source, data: state.data));
    try {
      await repo.delete(
        workspace: state.data.workspace!,
        id: source.id,
        token: _token,
      );
      emit(SourcesDeletedOkState(source, data: state.data));
    } on Exception catch (e) {
      emit(
        SourcesDeletingErrorState(
          ExceptionConverter.parse(e),
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// Moves the source at [from] to [to] (with no filter on, the list shown
  /// is the whole one) and saves the order; back as it was if that fails
  Future<void> reorder(int from, int to) async {
    final before = state.data;
    final sources = reordered(before.sources, from, to);
    emit(SourcesSearchOkState(data: before._copy(sources: sources)));
    try {
      await repo.reorder(
        workspace: before.workspace!,
        ids: [for (final s in sources) s.id],
        token: _token,
      );
    } on Exception catch (e) {
      if (state.data.workspace != before.workspace) return;
      emit(
        SourcesReorderingErrorState(ExceptionConverter.parse(e), data: before),
      );
    }
  }

  /// After signing out
  void reset() => emit(const SourcesInitialState());
}

/// What a row action did, so the view can confirm it

/// The loaded sources and what the search and the filter leave
/// ([visibleSources], filled on every change). [usage] counts the backups of
/// each source by its id; [configs] are those backups, for the detail
class SourcesData {
  final String? workspace;
  final bool loaded;
  final List<SourceTypeModel> types;
  final List<SourceModel> sources;
  final Map<String, int> usage;
  final List<ConfigModel> configs;
  final String query;

  /// Null: every type
  final String? type;

  /// The ids of the sources being tested
  final Set<String> testing;
  final List<SourceModel> visibleSources;

  const SourcesData._({
    required this.workspace,
    required this.loaded,
    required this.types,
    required this.sources,
    required this.usage,
    required this.configs,
    required this.query,
    required this.type,
    required this.testing,
    required this.visibleSources,
  });

  const SourcesData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        types: const [],
        sources: const [],
        usage: const {},
        configs: const [],
        query: '',
        type: null,
        testing: const {},
        visibleSources: const [],
      );

  factory SourcesData._of({
    required String? workspace,
    required bool loaded,
    required List<SourceTypeModel> types,
    required List<SourceModel> sources,
    required Map<String, int> usage,
    required List<ConfigModel> configs,
    required String query,
    required String? type,
    required Set<String> testing,
  }) {
    final needle = query.trim().toLowerCase();
    bool matches(SourceModel s) {
      final text = [
        s.name,
        SourceTypeLook.labelOf(s.type),
        s.postgres?.address ?? '',
      ].join(' ').toLowerCase();
      return (type == null || s.type == type) &&
          (needle.isEmpty || text.contains(needle));
    }

    return SourcesData._(
      workspace: workspace,
      loaded: loaded,
      types: types,
      sources: sources,
      usage: usage,
      configs: configs,
      query: query,
      type: type,
      testing: testing,
      visibleSources: sources.where(matches).toList(),
    );
  }

  SourcesData _copy({
    bool? loaded,
    List<SourceTypeModel>? types,
    List<SourceModel>? sources,
    Map<String, int>? usage,
    List<ConfigModel>? configs,
    String? query,
    String? Function()? type,
    Set<String>? testing,
  }) => SourcesData._of(
    workspace: workspace,
    loaded: loaded ?? this.loaded,
    types: types ?? this.types,
    sources: sources ?? this.sources,
    usage: usage ?? this.usage,
    configs: configs ?? this.configs,
    query: query ?? this.query,
    type: type == null ? this.type : type(),
    testing: testing ?? this.testing,
  );

  SourcesData withList(
    List<SourceTypeModel> types,
    List<SourceModel> sources,
    List<ConfigModel> configs,
  ) {
    final usage = <String, int>{};
    for (final config in configs) {
      usage.update(config.sourceId, (n) => n + 1, ifAbsent: () => 1);
    }
    return _copy(
      loaded: true,
      types: types,
      sources: sources,
      usage: usage,
      configs: configs,
    );
  }

  SourcesData withQuery(String query) => _copy(query: query);

  SourcesData withType(String? type) => _copy(type: () => type);

  SourcesData withTesting(String id, bool testing) => _copy(
    testing: testing ? {...this.testing, id} : ({...this.testing}..remove(id)),
  );

  SourcesData withCheck(String id, ConnectionCheckModel check) => _copy(
    sources: [for (final s in sources) s.id == id ? s.withCheck(check) : s],
  );

  /// How many backups dump [source]
  int usageOf(SourceModel source) => usage[source.id] ?? 0;

  /// The backups that dump [source]
  List<ConfigModel> usesOf(SourceModel source) =>
      configs.where((c) => c.sourceId == source.id).toList();

  /// How many filters are on (the search box apart)
  int get activeFilters => type == null ? 0 : 1;

  /// The rows can be dragged only when they are all shown
  bool get filtered => activeFilters > 0 || query.trim().isNotEmpty;
}

abstract class SourcesState {
  /// The sources of the open workspace, kept in every state: the list stays on
  /// screen while a row is tested or deleted
  final SourcesData data;

  const SourcesState({this.data = const SourcesData.empty()});
}

final class SourcesInitialState extends SourcesState {
  const SourcesInitialState();
}

//----------------- search -----------------\\
abstract class SourcesSearchState extends SourcesState {
  const SourcesSearchState({required super.data});
}

final class SourcesSearchingState extends SourcesSearchState {
  const SourcesSearchingState({required super.data});
}

final class SourcesSearchOkState extends SourcesSearchState {
  const SourcesSearchOkState({required super.data});
}

final class SourcesSearchErrorState extends SourcesSearchState {
  final GlobalException exception;

  const SourcesSearchErrorState(this.exception, {required super.data});
}

//----------------- test a saved source -----------------\\
abstract class SourcesTestState extends SourcesState {
  const SourcesTestState({required super.data});
}

final class SourcesTestingState extends SourcesTestState {
  final SourceModel source;

  const SourcesTestingState(this.source, {required super.data});
}

final class SourcesTestedOkState extends SourcesTestState {
  /// With its new check
  final SourceModel source;

  const SourcesTestedOkState(this.source, {required super.data});
}

final class SourcesTestingErrorState extends SourcesTestState {
  final GlobalException exception;

  const SourcesTestingErrorState(this.exception, {required super.data});
}

//----------------- delete -----------------\\
abstract class SourcesDeleteState extends SourcesState {
  const SourcesDeleteState({required super.data});
}

final class SourcesDeletingState extends SourcesDeleteState {
  final SourceModel source;

  const SourcesDeletingState(this.source, {required super.data});
}

final class SourcesDeletedOkState extends SourcesDeleteState {
  final SourceModel source;

  const SourcesDeletedOkState(this.source, {required super.data});
}

final class SourcesDeletingErrorState extends SourcesDeleteState {
  final GlobalException exception;

  const SourcesDeletingErrorState(this.exception, {required super.data});
}

//----------------- reorder -----------------\\
/// The order went back as it was (the move is shown before it is saved)
final class SourcesReorderingErrorState extends SourcesState {
  final GlobalException exception;

  const SourcesReorderingErrorState(this.exception, {required super.data});
}
