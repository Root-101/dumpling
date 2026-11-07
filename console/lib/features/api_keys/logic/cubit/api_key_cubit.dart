import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The API keys of the open workspace: list, search, the filters, the order
/// and the form's save. The configs (and the names of their sources) are
/// loaded with them, for the form and the filter by config
class ApiKeyCubit extends Cubit<ApiKeyState> {
  final ApiKeyRepo _repo;
  final ConfigRepo _configs;
  final SourceRepo _sources;
  final AuthCubit _auth;

  ApiKeyCubit(this._repo, this._configs, this._sources, this._auth)
    : super(const ApiKeyInitialState());

  String? get _token => _auth.auth?.accessToken;

  /// The keys of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : ApiKeyData.empty(workspace);
    emit(ApiKeyLoadingInProgressState(data: data));
    try {
      final results = await Future.wait([
        _repo.list(workspace: workspace, token: _token),
        _configs.list(workspace: workspace, token: _token),
        _sources.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      final sources = {
        for (final s in results[2] as List<SourceModel>) s.id: s.name,
      };
      emit(
        ApiKeyLoadingSuccessState(
          data: state.data._copy(
            loaded: true,
            keys: results[0] as List<ApiKeyModel>,
            configs: results[1] as List<ConfigModel>,
            sourceNames: sources,
          ),
        ),
      );
    } catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        ApiKeyLoadingErrorState(ExceptionConverter.parse(e), data: state.data),
      );
    }
  }

  Future<void> reload() async {
    final workspace = state.data.workspace;
    if (workspace != null) await load(workspace);
  }

  /// By name or id, over the keys already loaded
  void search(String query) => _show(state.data._copy(query: query));

  /// Null: every access
  void filterAccess(ApiKeyAccess? access) =>
      _show(state.data._copy(access: () => access));

  /// A config id, [ApiKeyData.unlimited] or null for every key
  void filterConfig(String? config) =>
      _show(state.data._copy(config: () => config));

  /// Null: any permission
  void filterPermission(String? permission) =>
      _show(state.data._copy(permission: () => permission));

  void clearFilters() => _show(
    state.data._copy(
      query: '',
      access: () => null,
      config: () => null,
      permission: () => null,
    ),
  );

  void _show(ApiKeyData data) => emit(ApiKeyLoadingSuccessState(data: data));

  /// Creates the key, or changes [id]; the new key comes with its text. Null
  /// when the service refuses it (the error goes to the state)
  Future<ApiKeyModel?> save(ApiKeyDraft draft, {String? id}) async {
    final workspace = state.data.workspace!;
    emit(ApiKeyProcessInProgressState(data: state.data));
    try {
      final key = await _repo.save(
        workspace: workspace,
        draft: draft,
        id: id,
        token: _token,
      );
      if (state.data.workspace != workspace) return null;
      final keys = id == null
          ? [...state.data.keys, key]
          : [for (final k in state.data.keys) k.id == id ? key : k];
      emit(
        ApiKeyProcessingOKState(
          id == null ? ApiKeyAction.created : ApiKeyAction.saved,
          key,
          data: state.data._copy(keys: keys),
        ),
      );
      return key;
    } catch (e) {
      emit(
        ApiKeyProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data,
        ),
      );
      return null;
    }
  }

  Future<void> delete(ApiKeyModel key) async {
    emit(ApiKeyProcessInProgressState(data: state.data));
    try {
      await _repo.delete(
        workspace: state.data.workspace!,
        id: key.id,
        token: _token,
      );
      emit(
        ApiKeyProcessingOKState(
          ApiKeyAction.deleted,
          key,
          data: state.data._copy(
            keys: [
              for (final k in state.data.keys)
                if (k.id != key.id) k,
            ],
          ),
        ),
      );
    } catch (e) {
      emit(
        ApiKeyProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: state.data,
        ),
      );
    }
  }

  /// Moves the key at [from] to [to] (with no filter on, the list shown is the
  /// whole one) and saves the order; back as it was if that fails
  Future<void> reorder(int from, int to) async {
    final before = state.data;
    final keys = reordered(before.keys, from, to);
    emit(ApiKeyLoadingSuccessState(data: before._copy(keys: keys)));
    try {
      await _repo.reorder(
        workspace: before.workspace!,
        ids: [for (final k in keys) k.id],
        token: _token,
      );
    } catch (e) {
      if (state.data.workspace != before.workspace) return;
      emit(
        ApiKeyProcessingErrorState(
          ExceptionConverter.parse(e).message,
          data: before,
        ),
      );
    }
  }

  /// After signing out
  void reset() => emit(const ApiKeyInitialState());
}

/// What a key action did, so the view can confirm it
enum ApiKeyAction { created, saved, deleted }

/// The loaded keys and what the search and the filters leave ([visibleKeys],
/// filled on every change)
class ApiKeyData {
  /// [config] of a key that reaches every config
  static const String unlimited = '*';

  final String? workspace;
  final bool loaded;
  final List<ApiKeyModel> keys;
  final List<ConfigModel> configs;

  /// The name of each source by its id: the form shows what a config dumps
  final Map<String, String> sourceNames;
  final String query;
  final ApiKeyAccess? access;
  final String? config;
  final String? permission;
  final List<ApiKeyModel> visibleKeys;

  const ApiKeyData._({
    required this.workspace,
    required this.loaded,
    required this.keys,
    required this.configs,
    required this.sourceNames,
    required this.query,
    required this.access,
    required this.config,
    required this.permission,
    required this.visibleKeys,
  });

  const ApiKeyData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        keys: const [],
        configs: const [],
        sourceNames: const {},
        query: '',
        access: null,
        config: null,
        permission: null,
        visibleKeys: const [],
      );

  ApiKeyData _copy({
    bool? loaded,
    List<ApiKeyModel>? keys,
    List<ConfigModel>? configs,
    Map<String, String>? sourceNames,
    String? query,
    ApiKeyAccess? Function()? access,
    String? Function()? config,
    String? Function()? permission,
  }) {
    final next = ApiKeyData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      keys: keys ?? this.keys,
      configs: configs ?? this.configs,
      sourceNames: sourceNames ?? this.sourceNames,
      query: query ?? this.query,
      access: access == null ? this.access : access(),
      config: config == null ? this.config : config(),
      permission: permission == null ? this.permission : permission(),
      visibleKeys: const [],
    );
    return ApiKeyData._(
      workspace: next.workspace,
      loaded: next.loaded,
      keys: next.keys,
      configs: next.configs,
      sourceNames: next.sourceNames,
      query: next.query,
      access: next.access,
      config: next.config,
      permission: next.permission,
      visibleKeys: next.keys.where(next.matches).toList(),
    );
  }

  /// Whether [key] passes the search and every filter but [skip] (the filter
  /// counts each option with the others on)
  bool matches(ApiKeyModel key, {String? skip}) {
    final needle = query.trim().toLowerCase();
    return (needle.isEmpty ||
            '${key.name} ${key.id}'.toLowerCase().contains(needle)) &&
        (skip == 'access' || access == null || key.access == access) &&
        (skip == 'config' ||
            config == null ||
            (config == unlimited ? !key.limited : key.reaches(config!))) &&
        (skip == 'permission' ||
            permission == null ||
            key.permissions.contains(permission));
  }

  /// The configs of [key], by name
  List<String> configNamesOf(ApiKeyModel key) => [
    for (final c in configs)
      if (key.configIds.contains(c.id)) c.name,
  ];

  /// How many filters are on (the search box apart)
  int get activeFilters =>
      [access, config, permission].where((f) => f != null).length;

  /// The rows can be dragged only when they are all shown
  bool get filtered => activeFilters > 0 || query.trim().isNotEmpty;
}

abstract class ApiKeyState {
  final ApiKeyData data;

  const ApiKeyState({this.data = const ApiKeyData.empty()});
}

class ApiKeyInitialState extends ApiKeyState {
  const ApiKeyInitialState();
}

//------------------------- LOADING -------------------------\
class ApiKeyLoadingInProgressState extends ApiKeyState {
  const ApiKeyLoadingInProgressState({required super.data});
}

class ApiKeyLoadingSuccessState extends ApiKeyState {
  const ApiKeyLoadingSuccessState({required super.data});
}

class ApiKeyLoadingErrorState extends ApiKeyState {
  final GlobalException exception;

  const ApiKeyLoadingErrorState(this.exception, {required super.data});
}

//------------------------- PROCESSING -------------------------\
class ApiKeyProcessInProgressState extends ApiKeyState {
  const ApiKeyProcessInProgressState({required super.data});
}

class ApiKeyProcessingOKState extends ApiKeyState {
  final ApiKeyAction action;
  final ApiKeyModel key;

  const ApiKeyProcessingOKState(this.action, this.key, {required super.data});
}

class ApiKeyProcessingErrorState extends ApiKeyState {
  final String message;

  const ApiKeyProcessingErrorState(this.message, {required super.data});
}
