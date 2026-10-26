import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The sources of the open workspace: list, search, the type filter and the
/// row actions (test the connection, delete). The backups (configs) are loaded
/// with them to say how many use each source
class SourceCubit extends Cubit<SourceState> {
  final SourceRepo _repo;
  final ConfigRepo _configs;
  final AuthCubit _auth;

  SourceCubit(this._repo, this._configs, this._auth)
    : super(const SourceInitialState());

  String? get _token => _auth.auth?.accessToken;

  /// The sources of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : SourceData.empty(workspace);
    emit(SourceLoadingInProgressState(data: data));
    try {
      final results = await Future.wait([
        _repo.types(token: _token),
        _repo.list(workspace: workspace, token: _token),
        _configs.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      emit(
        SourceLoadingSuccessState(
          data: state.data.withList(
            results[0] as List<SourceTypeModel>,
            results[1] as List<SourceModel>,
            results[2] as List<ConfigModel>,
          ),
        ),
      );
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        SourceLoadingErrorState(ExceptionConverter.parse(e), data: state.data),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By name, type or host, over the sources already loaded
  void search(String query) {
    emit(SourceLoadingSuccessState(data: state.data.withQuery(query)));
  }

  /// Only the sources of [type]; null: all of them
  void filterType(String? type) {
    emit(SourceLoadingSuccessState(data: state.data.withType(type)));
  }

  void clearFilters() {
    emit(
      SourceLoadingSuccessState(data: state.data.withQuery('').withType(null)),
    );
  }

  /// Tests the saved connection; the row shows *Testing…* meanwhile and then
  /// what it found
  Future<void> test(SourceModel source) async {
    final workspace = state.data.workspace!;
    emit(
      SourceLoadingSuccessState(data: state.data.withTesting(source.id, true)),
    );
    try {
      final check = await _repo.testSaved(
        workspace: workspace,
        id: source.id,
        token: _token,
      );
      if (state.data.workspace != workspace) return;
      emit(
        SourceProcessingOKState(
          SourceAction.tested,
          source.withCheck(check),
          data: state.data
              .withTesting(source.id, false)
              .withCheck(source.id, check),
        ),
      );
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        SourceProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data.withTesting(source.id, false),
        ),
      );
    }
  }

  Future<void> delete(SourceModel source) async {
    emit(SourceProcessInProgressState(data: state.data));
    try {
      await _repo.delete(
        workspace: state.data.workspace!,
        id: source.id,
        token: _token,
      );
      emit(
        SourceProcessingOKState(SourceAction.deleted, source, data: state.data),
      );
    } catch (e) {
      emit(
        SourceProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data,
        ),
      );
      return;
    }
    await reload();
  }

  /// After signing out
  void reset() => emit(const SourceInitialState());
}

/// What a row action did, so the view can confirm it
enum SourceAction { tested, deleted }

/// The loaded sources and what the search and the filter leave
/// ([visibleSources], filled on every change). [usage] counts the backups of
/// each source by its id
class SourceData {
  final String? workspace;
  final bool loaded;
  final List<SourceTypeModel> types;
  final List<SourceModel> sources;
  final Map<String, int> usage;
  final String query;

  /// Null: every type
  final String? type;

  /// The ids of the sources being tested
  final Set<String> testing;
  final List<SourceModel> visibleSources;

  const SourceData._({
    required this.workspace,
    required this.loaded,
    required this.types,
    required this.sources,
    required this.usage,
    required this.query,
    required this.type,
    required this.testing,
    required this.visibleSources,
  });

  const SourceData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        types: const [],
        sources: const [],
        usage: const {},
        query: '',
        type: null,
        testing: const {},
        visibleSources: const [],
      );

  factory SourceData._of({
    required String? workspace,
    required bool loaded,
    required List<SourceTypeModel> types,
    required List<SourceModel> sources,
    required Map<String, int> usage,
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

    return SourceData._(
      workspace: workspace,
      loaded: loaded,
      types: types,
      sources: sources,
      usage: usage,
      query: query,
      type: type,
      testing: testing,
      visibleSources: sources.where(matches).toList(),
    );
  }

  SourceData _copy({
    bool? loaded,
    List<SourceTypeModel>? types,
    List<SourceModel>? sources,
    Map<String, int>? usage,
    String? query,
    String? Function()? type,
    Set<String>? testing,
  }) => SourceData._of(
    workspace: workspace,
    loaded: loaded ?? this.loaded,
    types: types ?? this.types,
    sources: sources ?? this.sources,
    usage: usage ?? this.usage,
    query: query ?? this.query,
    type: type == null ? this.type : type(),
    testing: testing ?? this.testing,
  );

  SourceData withList(
    List<SourceTypeModel> types,
    List<SourceModel> sources,
    List<ConfigModel> configs,
  ) {
    final usage = <String, int>{};
    for (final config in configs) {
      usage.update(config.sourceId, (n) => n + 1, ifAbsent: () => 1);
    }
    return _copy(loaded: true, types: types, sources: sources, usage: usage);
  }

  SourceData withQuery(String query) => _copy(query: query);

  SourceData withType(String? type) => _copy(type: () => type);

  SourceData withTesting(String id, bool testing) => _copy(
    testing: testing ? {...this.testing, id} : ({...this.testing}..remove(id)),
  );

  SourceData withCheck(String id, ConnectionCheckModel check) => _copy(
    sources: [for (final s in sources) s.id == id ? s.withCheck(check) : s],
  );

  /// How many backups dump [source]
  int usageOf(SourceModel source) => usage[source.id] ?? 0;

  /// How many filters are on (the search box apart)
  int get activeFilters => type == null ? 0 : 1;
}

abstract class SourceState {
  final SourceData data;

  const SourceState({this.data = const SourceData.empty()});
}

class SourceInitialState extends SourceState {
  const SourceInitialState();
}

//------------------------- LOADING -------------------------\
class SourceLoadingInProgressState extends SourceState {
  const SourceLoadingInProgressState({required super.data});
}

class SourceLoadingSuccessState extends SourceState {
  const SourceLoadingSuccessState({required super.data});
}

class SourceLoadingErrorState extends SourceState {
  final GlobalException exception;

  const SourceLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
class SourceProcessInProgressState extends SourceState {
  const SourceProcessInProgressState({required super.data});
}

class SourceProcessingOKState extends SourceState {
  final SourceAction action;

  /// The source acted on; after [SourceAction.tested], with its new check
  final SourceModel source;

  const SourceProcessingOKState(
    this.action,
    this.source, {
    required super.data,
  });
}

class SourceProcessingErrorState extends SourceState {
  final String message;

  const SourceProcessingErrorState(this.message, {required super.data});
}
