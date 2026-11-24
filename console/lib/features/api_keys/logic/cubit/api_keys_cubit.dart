import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The API keys of the open workspace: list, search, the filters, the order
/// and delete. The configs (and the names of their ends) are loaded with
/// them, for the form and the filter by config
class ApiKeysCubit extends Cubit<ApiKeysState>
    with GlobalEventBusCommunication<ApiKeysState> {
  final AuthCubit auth;
  final ApiKeysRepo repo;
  final ConfigsRepo configs;
  final SourcesRepo sources;
  final DestinationsRepo destinations;

  ApiKeysCubit({
    required this.auth,
    required this.repo,
    required this.configs,
    required this.sources,
    required this.destinations,
  }) : super(const ApiKeysInitialState()) {
    // a key saved in its form: a new one goes last, a changed one in place
    onBus<ApiKeyFormProcessingOKState>(_saved);
  }

  /// The service gives no refresh token: the one of the session, or none
  String? get _token => auth.auth?.accessToken;

  /// The keys of [workspace]; another workspace starts from empty
  Future<void> load(String workspace) async {
    final data = state.data.workspace == workspace
        ? state.data
        : ApiKeysData.empty(workspace);
    emit(ApiKeysSearchingState(data: data));
    try {
      final results = await Future.wait([
        repo.list(workspace: workspace, token: _token),
        configs.list(workspace: workspace, token: _token),
        sources.list(workspace: workspace, token: _token),
        destinations.list(workspace: workspace, token: _token),
      ]);
      // the answer of a workspace already left behind is dropped
      if (state.data.workspace != workspace) return;
      final sourceNames = {
        for (final s in results[2] as List<SourceModel>) s.id: s.name,
      };
      final destinationNames = {
        for (final d in results[3] as List<DestinationModel>)
          d.id: d.s3?.bucket ?? d.name,
      };
      emit(
        ApiKeysSearchOkState(
          data: state.data._copy(
            loaded: true,
            keys: results[0] as List<ApiKeyModel>,
            configs: results[1] as List<ConfigModel>,
            sourceNames: sourceNames,
            destinationNames: destinationNames,
          ),
        ),
      );
    } on Exception catch (e) {
      if (state.data.workspace != workspace) return;
      emit(
        ApiKeysSearchErrorState(ExceptionConverter.parse(e), data: state.data),
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

  /// A config id, [ApiKeysData.unlimited] or null for every key
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

  void _show(ApiKeysData data) => emit(ApiKeysSearchOkState(data: data));

  void _saved(ApiKeyFormProcessingOKState saved) {
    if (saved.workspace != state.data.workspace) return;
    final key = saved.key;
    final keys = saved.created
        ? [...state.data.keys, key]
        : [for (final k in state.data.keys) k.id == key.id ? key : k];
    emit(ApiKeysSearchOkState(data: state.data._copy(keys: keys)));
  }

  Future<void> delete(ApiKeyModel key) async {
    emit(ApiKeysDeletingState(key, data: state.data));
    try {
      await repo.delete(
        workspace: state.data.workspace!,
        id: key.id,
        token: _token,
      );
      emit(
        ApiKeysDeletedOkState(
          key,
          data: state.data._copy(
            keys: [
              for (final k in state.data.keys)
                if (k.id != key.id) k,
            ],
          ),
        ),
      );
    } on Exception catch (e) {
      emit(
        ApiKeysDeletingErrorState(
          ExceptionConverter.parse(e),
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
    emit(ApiKeysSearchOkState(data: before._copy(keys: keys)));
    try {
      await repo.reorder(
        workspace: before.workspace!,
        ids: [for (final k in keys) k.id],
        token: _token,
      );
    } on Exception catch (e) {
      if (state.data.workspace != before.workspace) return;
      emit(
        ApiKeysReorderingErrorState(ExceptionConverter.parse(e), data: before),
      );
    }
  }

  /// After signing out
  void reset() => emit(const ApiKeysInitialState());
}

/// What a key action did, so the view can confirm it

/// The loaded keys and what the search and the filters leave ([visibleKeys],
/// filled on every change)
class ApiKeysData {
  /// [config] of a key that reaches every config
  static const String unlimited = '*';

  final String? workspace;
  final bool loaded;
  final List<ApiKeyModel> keys;
  final List<ConfigModel> configs;

  /// The name of each source by its id: the form shows what a config dumps
  final Map<String, String> sourceNames;

  /// The bucket of each destination by its id, for the same
  final Map<String, String> destinationNames;
  final String query;
  final ApiKeyAccess? access;
  final String? config;
  final String? permission;
  final List<ApiKeyModel> visibleKeys;

  const ApiKeysData._({
    required this.workspace,
    required this.loaded,
    required this.keys,
    required this.configs,
    required this.sourceNames,
    required this.destinationNames,
    required this.query,
    required this.access,
    required this.config,
    required this.permission,
    required this.visibleKeys,
  });

  const ApiKeysData.empty([String? workspace])
    : this._(
        workspace: workspace,
        loaded: false,
        keys: const [],
        configs: const [],
        sourceNames: const {},
        destinationNames: const {},
        query: '',
        access: null,
        config: null,
        permission: null,
        visibleKeys: const [],
      );

  ApiKeysData _copy({
    bool? loaded,
    List<ApiKeyModel>? keys,
    List<ConfigModel>? configs,
    Map<String, String>? sourceNames,
    Map<String, String>? destinationNames,
    String? query,
    ApiKeyAccess? Function()? access,
    String? Function()? config,
    String? Function()? permission,
  }) {
    final next = ApiKeysData._(
      workspace: workspace,
      loaded: loaded ?? this.loaded,
      keys: keys ?? this.keys,
      configs: configs ?? this.configs,
      sourceNames: sourceNames ?? this.sourceNames,
      destinationNames: destinationNames ?? this.destinationNames,
      query: query ?? this.query,
      access: access == null ? this.access : access(),
      config: config == null ? this.config : config(),
      permission: permission == null ? this.permission : permission(),
      visibleKeys: const [],
    );
    return ApiKeysData._(
      workspace: next.workspace,
      loaded: next.loaded,
      keys: next.keys,
      configs: next.configs,
      sourceNames: next.sourceNames,
      destinationNames: next.destinationNames,
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

  /// `orders-db → backups/orders`: what [config] dumps and where it writes it
  String routeOf(ConfigModel config) {
    final folder = config.folder;
    return '${sourceNames[config.sourceId] ?? config.sourceId} → '
        '${destinationNames[config.destinationId] ?? config.destinationId}'
        '${folder == null ? '' : FolderPath.show(folder)}';
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

abstract class ApiKeysState {
  /// The keys of the open workspace, kept in every state
  final ApiKeysData data;

  const ApiKeysState({this.data = const ApiKeysData.empty()});
}

final class ApiKeysInitialState extends ApiKeysState {
  const ApiKeysInitialState();
}

//----------------- search -----------------\\
abstract class ApiKeysSearchState extends ApiKeysState {
  const ApiKeysSearchState({required super.data});
}

final class ApiKeysSearchingState extends ApiKeysSearchState {
  const ApiKeysSearchingState({required super.data});
}

final class ApiKeysSearchOkState extends ApiKeysSearchState {
  const ApiKeysSearchOkState({required super.data});
}

final class ApiKeysSearchErrorState extends ApiKeysSearchState {
  final GlobalException exception;

  const ApiKeysSearchErrorState(this.exception, {required super.data});
}

//----------------- delete -----------------\\
abstract class ApiKeysDeleteState extends ApiKeysState {
  const ApiKeysDeleteState({required super.data});
}

final class ApiKeysDeletingState extends ApiKeysDeleteState {
  final ApiKeyModel key;

  const ApiKeysDeletingState(this.key, {required super.data});
}

final class ApiKeysDeletedOkState extends ApiKeysDeleteState {
  final ApiKeyModel key;

  const ApiKeysDeletedOkState(this.key, {required super.data});
}

final class ApiKeysDeletingErrorState extends ApiKeysDeleteState {
  final GlobalException exception;

  const ApiKeysDeletingErrorState(this.exception, {required super.data});
}

//----------------- reorder -----------------\\
/// The order went back as it was (the move is shown before it is saved)
final class ApiKeysReorderingErrorState extends ApiKeysState {
  final GlobalException exception;

  const ApiKeysReorderingErrorState(this.exception, {required super.data});
}
