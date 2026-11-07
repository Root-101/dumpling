import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class ApiKeysScreenNavigator {
  String get name => RouteNames.apiKeys;

  String get path => RouteNames.apiKeys;

  Widget builder(BuildContext context, GoRouterState state) {
    return ApiKeysScreen(
      workspace: state.pathParameters[RouteNames.slugParam]!,
    );
  }
}

/// The API keys of a workspace: what each one may do, on which configs, and
/// when it was last used. A key is shown once, when it is created
class ApiKeysScreen extends StatefulWidget {
  static final ApiKeysScreenNavigator navigator = ApiKeysScreenNavigator();

  /// The guide to use a key from a pipeline or a script
  static const String guideUrl =
      'https://github.com/root-101/dumpling/blob/main/docs/integrations.md';

  final String workspace;

  const ApiKeysScreen({required this.workspace, super.key});

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  late final ApiKeyCubit cubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = context.read<ApiKeyCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant ApiKeysScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace != widget.workspace) _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    _searchController.clear();
    cubit
      ..load(widget.workspace)
      ..clearFilters();
  }

  void _clearFilters() {
    _searchController.clear();
    cubit.clearFilters();
  }

  void _openForm([ApiKeyModel? key]) => ApiKeyForm.open(cubit, key: key);

  void _confirmDelete(ApiKeyModel key) {
    ConfirmDialog.show(
      title: app.intl.apiKeys.deleteTitle(name: key.name),
      description: app.intl.apiKeys.deleteConfirm,
      confirmTitle: app.intl.common.delete,
      confirmColor: app.colors.primary.errorAction,
      confirmAction: () => cubit.delete(key),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceName = context.select<WorkspaceCubit, String>(
      (c) => c.state.data.current?.name ?? widget.workspace,
    );
    final t = app.intl.apiKeys;
    return Scaffold(
      backgroundColor: app.colors.primary.background2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: t.title,
            workspace: workspaceName,
            description: t.description,
            actions: [
              BlocBuilder<ApiKeyCubit, ApiKeyState>(
                builder: (context, state) => AppRefreshButton(
                  onPressed: cubit.reload,
                  loading:
                      state is ApiKeyLoadingInProgressState &&
                      state.data.loaded,
                ),
              ),
              BlocBuilder<ApiKeyCubit, ApiKeyState>(
                builder: (context, state) => PrimaryButton.primary(
                  // the form needs the configs
                  onPressed: state.data.loaded ? () => _openForm() : null,
                  title: t.create,
                  icon: app.assets.icons.actions.add,
                  color: app.colors.primary.primaryAction,
                  h: 40,
                  w: 160,
                ),
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
              child: BlocConsumer<ApiKeyCubit, ApiKeyState>(
                listener: _onState,
                builder: (context, state) {
                  if (!state.data.loaded) {
                    return state is ApiKeyLoadingErrorState
                        ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                        : _buildSkeleton();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: app.dimensions.padding.xxl,
                      vertical: app.dimensions.padding.xl,
                    ),
                    child: _buildBody(state.data),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, ApiKeyState state) {
    if (state is ApiKeyProcessInProgressState) {
      app.loading.show();
    } else {
      app.loading.hide();
    }
    if (state is ApiKeyProcessingOKState) {
      final t = app.intl.apiKeys;
      switch (state.action) {
        case ApiKeyAction.deleted:
          app.snack.showSuccess(
            message: t.deleted(name: state.key.name),
            context: app.context,
          );
        case ApiKeyAction.saved:
          app.snack.showSuccess(
            message: t.saved(name: state.key.name),
            context: app.context,
          );
        // the form shows the key itself
        case ApiKeyAction.created:
          break;
      }
    }
    if (state is ApiKeyProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
  }

  List<AppTableColumn> get _columns {
    final t = app.intl.apiKeys;
    return [
      AppTableColumn(t.columnName, flex: 14),
      AppTableColumn(t.columnAccess, flex: 12),
      AppTableColumn(t.columnConfigs, flex: 12),
      AppTableColumn(t.columnCreated, flex: 9),
      AppTableColumn(t.columnLastUsed, flex: 11),
      const AppTableColumn.actions(width: 52),
    ];
  }

  Widget _buildSkeleton() => AppShimmer(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: app.dimensions.padding.xxl,
        vertical: app.dimensions.padding.xl,
      ),
      child: AppSimpleTable(
        toolbar: AppSkeleton.toolbar(const [96]),
        columns: _columns,
        rows: [
          for (final f in const [0.62, 0.48, 0.7, 0.55])
            AppTableRow([
              AppSkeleton.named(f),
              AppSkeleton(factor: f - 0.04, height: 11, dim: true),
              AppSkeleton(factor: 1.2 - f, height: 11, dim: true),
              const AppSkeleton(width: 70, height: 11, dim: true),
              AppSkeleton.lines(0.7, 0.5),
              const AppActionSkeleton(),
            ]),
        ],
      ),
    ),
  );

  Widget _buildBody(ApiKeyData data) {
    final t = app.intl.apiKeys;
    final colors = app.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSimpleTable(
          toolbar: Row(
            children: [
              Expanded(
                child: AppTextSearchField(
                  controller: _searchController,
                  hint: t.search,
                  // filters the keys already loaded: no wait
                  delay: 0,
                  onSearch: cubit.search,
                ),
              ),
              app.dimensions.padding.sm.gap(),
              _buildFilter(data),
            ],
          ),
          columns: _columns,
          onReorder: cubit.reorder,
          reorderBlocked: data.filtered ? app.intl.common.clearToReorder : null,
          rows: [
            for (final key in data.visibleKeys)
              AppTableRow(_buildCells(data, key), id: key.id),
          ],
          placeholder: data.keys.isEmpty
              ? AppTablePlaceholder(
                  title: t.emptyTitle,
                  description: t.emptyDescription,
                  action: t.create,
                  onPressed: () => _openForm(),
                )
              : data.visibleKeys.isEmpty
              ? AppTablePlaceholder(
                  title: app.intl.common.noMatches,
                  action: app.intl.common.clearSearch,
                  onPressed: _clearFilters,
                )
              : null,
        ),
        12.gap(),
        Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
            children: [
              TextSpan(text: '${t.footer} '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: InkWell(
                  onTap: () => BrowserWindow.openUrl(ApiKeysScreen.guideUrl),
                  child: Text(
                    t.howTo,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary.primaryFaded,
                      decoration: TextDecoration.underline,
                      decorationColor: colors.primary.primaryFaded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilter(ApiKeyData data) {
    final t = app.intl.apiKeys;
    final keys = data.keys;
    int count(String skip, bool Function(ApiKeyModel) where) =>
        keys.where((k) => data.matches(k, skip: skip) && where(k)).length;
    return AppFilterButton(
      columnWidth: 230,
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: app.intl.common.shownOf(
        shown: data.visibleKeys.length,
        total: keys.length,
      ),
      groups: [
        AppFilterGroup(
          title: t.filterAccess,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.access == null,
              count: count('access', (_) => true),
              onTap: () => cubit.filterAccess(null),
            ),
            for (final access in ApiKeyAccess.values)
              AppFilterOption(
                label: access.label,
                selected: data.access == access,
                count: count('access', (k) => k.access == access),
                onTap: () => cubit.filterAccess(access),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.filterConfig,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.config == null,
              count: count('config', (_) => true),
              onTap: () => cubit.filterConfig(null),
            ),
            AppFilterOption(
              label: t.unlimited,
              selected: data.config == ApiKeyData.unlimited,
              count: count('config', (k) => !k.limited),
              onTap: () => cubit.filterConfig(ApiKeyData.unlimited),
            ),
            for (final config in data.configs)
              AppFilterOption(
                label: config.name,
                selected: data.config == config.id,
                count: count('config', (k) => k.reaches(config.id)),
                onTap: () => cubit.filterConfig(config.id),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.filterPermission,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.permission == null,
              count: count('permission', (_) => true),
              onTap: () => cubit.filterPermission(null),
            ),
            for (final permission in ApiKeyPermissions.all)
              AppFilterOption(
                label: permission,
                selected: data.permission == permission,
                count: count(
                  'permission',
                  (k) => k.permissions.contains(permission),
                ),
                onTap: () => cubit.filterPermission(permission),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCells(ApiKeyData data, ApiKeyModel key) {
    final t = app.intl.apiKeys;
    final colors = app.colors;
    final muted = TextStyle(fontSize: 13, color: colors.neutral.grey3);
    final small = TextStyle(fontSize: 11, color: colors.neutral.grey4);
    final custom = key.access == ApiKeyAccess.custom;
    final names = data.configNamesOf(key);
    final last = key.lastRun;
    return [
      Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.primaryFaded.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: app.assets.icons.navigation.keys.build(
              size: 16,
              color: colors.primary.primaryLight,
            ),
          ),
          10.gap(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _openForm(key),
                  child: Text(
                    key.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  key.id,
                  style: AppText.mono.copyWith(
                    fontSize: 11,
                    color: colors.neutral.grey4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  (custom
                          ? colors.primary.secondary
                          : colors.primary.primaryFaded)
                      .withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              key.access.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: custom
                    ? colors.primary.secondary
                    : colors.primary.primaryLight,
              ),
            ),
          ),
          Text(t.permissionCount(n: key.permissions.length), style: small),
        ],
      ),
      Tooltip(
        message: key.limited ? names.join(', ') : t.everyConfig,
        child: Text(
          !key.limited
              ? t.allConfigs
              : names.length == 1
              ? names.single
              : t.configCount(n: key.configIds.length),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: muted,
        ),
      ),
      Text(
        app.dateFormatter.m.format(key.createdAt.toLocal()),
        style: muted.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.lastUsedAt == null
                ? t.neverUsed
                : app.intl.time.utc(
                    time: app.dateFormatter.time.format(
                      key.lastUsedAt!.toUtc(),
                    ),
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: key.lastUsedAt == null
                  ? colors.neutral.grey4
                  : colors.neutral.grey2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (last != null)
            Text(
              [t.ran(config: last.configName), ?last.label].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: small,
            ),
        ],
      ),
      AppRowMenu(
        tooltip: app.intl.common.optionsFor(name: key.name),
        items: [
          AppRowMenuItem(
            label: app.intl.common.edit,
            icon: app.assets.icons.actions.edit,
            onTap: () => _openForm(key),
          ),
          AppRowMenuItem(
            label: app.intl.common.delete,
            icon: app.assets.icons.actions.delete,
            danger: true,
            divided: true,
            onTap: () => _confirmDelete(key),
          ),
        ],
      ),
    ];
  }
}
