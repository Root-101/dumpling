import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class SourcesScreenNavigator {
  String get name => RouteNames.sources;

  String get path => RouteNames.sources;

  Widget builder(BuildContext context, GoRouterState state) {
    return SourcesScreen(
      workspace: state.pathParameters[RouteNames.slugParam]!,
      openId: state.pathParameters[RouteNames.idParam],
    );
  }
}

/// The sources of a workspace, as rows or cards: what it backs up, how many
/// backups use each one and how its last connection test went. One opens in a
/// dialog with its detail
class SourcesScreen extends StatefulWidget {
  static final SourcesScreenNavigator navigator = SourcesScreenNavigator();

  final String workspace;

  /// The source whose dialog the URL opens (`sources/{id}`)
  final String? openId;

  const SourcesScreen({required this.workspace, this.openId, super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> with UrlDialog {
  late final SourceCubit cubit;
  final _searchController = TextEditingController();

  AppView _view = AppView.list;

  @override
  void initState() {
    super.initState();
    cubit = context.read<SourceCubit>();
    _load();
    // a list loaded already changes no state
    WidgetsBinding.instance.addPostFrameCallback((_) => _followUrl());
  }

  @override
  void didUpdateWidget(covariant SourcesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace != widget.workspace) _load();
    _followUrl();
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

  void _openForm({SourceModel? source, bool duplicate = false}) {
    SourceForm.open(
      context,
      workspace: widget.workspace,
      types: cubit.state.data.types,
      source: source,
      duplicate: duplicate,
    );
  }

  void _openDetail(SourceModel source) =>
      RouteNames.openItem(widget.workspace, RouteNames.source, source.id);

  /// The source of the URL over the list, once it is loaded
  void _followUrl() {
    final data = cubit.state.data;
    if (!data.loaded || data.workspace != widget.workspace) return;
    followUrl(
      widget.openId,
      show: (id) async {
        final item = data.sources.where((e) => e.id == id).firstOrNull;
        if (item == null) return false;
        await SourceDialog.open(item, onEdit: (s) => _openForm(source: s));
        return true;
      },
      leave: () => RouteNames.openWorkspace(
        widget.workspace,
        section: RouteNames.sources,
      ),
    );
  }

  void _confirmDelete(SourceModel source) {
    ConfirmDialog.show(
      title: app.intl.sources.deleteTitle(name: source.name),
      description: app.intl.sources.deleteConfirm,
      confirmTitle: app.intl.common.delete,
      confirmColor: app.colors.primary.errorAction,
      confirmAction: () => cubit.delete(source),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workspaceName = context.select<WorkspaceCubit, String>(
      (c) => c.state.data.current?.name ?? widget.workspace,
    );
    return Scaffold(
      backgroundColor: app.colors.primary.background2,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: app.intl.sources.title,
            workspace: workspaceName,
            description: app.intl.sources.description,
            actions: [
              BlocBuilder<SourceCubit, SourceState>(
                builder: (context, state) => AppRefreshButton(
                  onPressed: cubit.reload,
                  loading:
                      state is SourceLoadingInProgressState &&
                      state.data.loaded,
                ),
              ),
              BlocBuilder<SourceCubit, SourceState>(
                builder: (context, state) => PrimaryButton.primary(
                  // the form needs the types
                  onPressed: state.data.loaded ? () => _openForm() : null,
                  title: app.intl.sources.create,
                  icon: app.assets.icons.actions.add,
                  color: app.colors.primary.primaryAction,
                  h: 40,
                  w: 150,
                ),
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
              child: BlocConsumer<SourceCubit, SourceState>(
                listener: _onState,
                builder: (context, state) {
                  if (!state.data.loaded) {
                    return state is SourceLoadingErrorState
                        ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                        : _buildSkeleton();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: app.dimensions.padding.xxl,
                      vertical: app.dimensions.padding.xl,
                    ),
                    child: _buildTable(state.data),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, SourceState state) {
    _followUrl();
    if (state is SourceProcessInProgressState) {
      app.loading.show();
    } else {
      app.loading.hide();
    }
    if (state is SourceProcessingOKState &&
        state.action == SourceAction.deleted) {
      app.snack.showSuccess(
        message: app.intl.sources.deleted(name: state.source.name),
        context: app.context,
      );
    }
    if (state is SourceProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
  }

  List<AppTableColumn> get _columns => [
    AppTableColumn(app.intl.sources.columnName, flex: 13),
    AppTableColumn(app.intl.sources.columnType, flex: 10),
    AppTableColumn(app.intl.sources.columnHost, flex: 16),
    AppTableColumn(app.intl.sources.columnBackups, flex: 8),
    AppTableColumn(app.intl.sources.columnStatus, flex: 8),
    const AppTableColumn.actions(width: 52),
  ];

  /// While they load: the table as it will be, its rows in blocks
  Widget _buildSkeleton() => AppShimmer(
    child: SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: app.dimensions.padding.xxl,
        vertical: app.dimensions.padding.xl,
      ),
      child: AppSimpleTable(
        toolbar: AppSkeleton.toolbar(const [96], toggle: true),
        columns: _columns,
        rows: [
          for (final f in const [0.62, 0.48, 0.7, 0.55, 0.66])
            AppTableRow([
              AppSkeleton.named(f),
              AppSkeleton(factor: f - 0.04, height: 11, dim: true),
              AppSkeleton(factor: 1.2 - f, height: 11, dim: true),
              const AppSkeleton(width: 18),
              const AppStatusSkeleton(),
              const AppActionSkeleton(),
            ]),
        ],
      ),
    ),
  );

  Widget _buildTable(SourceData data) {
    return AppSimpleTable(
      toolbar: Row(
        children: [
          Expanded(
            child: AppTextSearchField(
              controller: _searchController,
              hint: app.intl.sources.search,
              // filters the sources already loaded: no wait
              delay: 0,
              onSearch: cubit.search,
            ),
          ),
          app.dimensions.padding.sm.gap(),
          _buildFilter(data),
          app.dimensions.padding.sm.gap(),
          Container(width: 1, height: 28, color: app.colors.neutral.grey5),
          app.dimensions.padding.sm.gap(),
          AppViewToggle(
            value: _view,
            onChanged: (view) => setState(() => _view = view),
          ),
        ],
      ),
      body: _view == AppView.grid ? _buildGrid(data) : null,
      columns: _columns,
      rows: [
        for (final source in data.visibleSources)
          AppTableRow(_buildCells(data, source)),
      ],
      placeholder: data.sources.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.sources.emptyTitle,
              description: app.intl.sources.emptyDescription,
              action: app.intl.sources.create,
              onPressed: () => _openForm(),
            )
          : data.visibleSources.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.common.noMatches,
              action: app.intl.common.clearSearch,
              onPressed: _clearFilters,
            )
          : null,
    );
  }

  Widget _buildFilter(SourceData data) {
    // the types available, and any other one a source still has
    final types = {
      for (final t in data.types)
        if (t.enabled) t.type,
      for (final s in data.sources) s.type,
    };
    return AppFilterButton(
      // one group: the 280 of the design
      columnWidth: 264,
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: app.intl.common.shownOf(
        shown: data.visibleSources.length,
        total: data.sources.length,
      ),
      groups: [
        AppFilterGroup(
          title: app.intl.sources.columnType,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.type == null,
              count: data.sources.length,
              onTap: () => cubit.filterType(null),
            ),
            for (final type in types)
              AppFilterOption(
                label: SourceTypeLook.labelOf(type),
                leading: TypeBadge(look: SourceTypeLook.lookOf(type), size: 24),
                selected: data.type == type,
                count: data.sources.where((s) => s.type == type).length,
                onTap: () => cubit.filterType(type),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCells(SourceData data, SourceModel source) {
    final used = data.usageOf(source);
    final testing = data.testing.contains(source.id);
    final muted = TextStyle(fontSize: 14, color: app.colors.neutral.grey3);
    return [
      Row(
        children: [
          TypeBadge(look: SourceTypeLook.lookOf(source.type)),
          const SizedBox(width: 10),
          Flexible(
            child: InkWell(
              onTap: () => _openDetail(source),
              child: Text(
                source.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      Text(
        _typeLabel(source),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: muted,
      ),
      Text(
        source.postgres?.address ?? '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: muted.copyWith(fontFamily: AppText.monoFamily, fontSize: 12),
      ),
      Text(
        '$used',
        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      ),
      ConnectionStatusLabel(check: source.lastCheck, testing: testing),
      _buildMenu(data, source),
    ];
  }

  /// `PostgreSQL 16`
  String _typeLabel(SourceModel source) => [
    SourceTypeLook.labelOf(source.type),
    ?source.lastCheck?.serverMajor,
  ].join(' ');

  Widget _buildMenu(SourceData data, SourceModel source) {
    final used = data.usageOf(source);
    final testing = data.testing.contains(source.id);
    return AppRowMenu(
      tooltip: app.intl.common.optionsFor(name: source.name),
      items: [
        AppRowMenuItem(
          label: app.intl.common.viewDetails,
          icon: app.assets.icons.actions.view,
          onTap: () => _openDetail(source),
        ),
        AppRowMenuItem(
          label: app.intl.common.edit,
          icon: app.assets.icons.actions.edit,
          onTap: () => _openForm(source: source),
        ),
        AppRowMenuItem(
          label: app.intl.common.duplicate,
          icon: app.assets.icons.actions.duplicate,
          onTap: () => _openForm(source: source, duplicate: true),
        ),
        AppRowMenuItem(
          label: app.intl.connections.test,
          icon: app.assets.icons.actions.test,
          enabled: !testing,
          onTap: () => cubit.test(source),
        ),
        AppRowMenuItem(
          label: app.intl.common.delete,
          icon: app.assets.icons.actions.delete,
          danger: true,
          divided: true,
          enabled: used == 0,
          sub: used == 0 ? null : app.intl.sources.inUse(n: used),
          onTap: () => _confirmDelete(source),
        ),
      ],
    );
  }

  /// The same sources as cards, three in a row when there is room
  Widget _buildGrid(SourceData data) {
    const gap = 12.0;
    return Padding(
      padding: EdgeInsets.all(app.dimensions.padding.l),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 3
              : constraints.maxWidth >= 560
              ? 2
              : 1;
          final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final source in data.visibleSources)
                SizedBox(width: width, child: _buildCard(data, source)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(SourceData data, SourceModel source) {
    final colors = app.colors;
    return Container(
      padding: EdgeInsets.all(app.dimensions.padding.l),
      decoration: BoxDecoration(
        color: colors.primary.backgroundForm,
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: colors.neutral.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            children: [
              TypeBadge(look: SourceTypeLook.lookOf(source.type), size: 36),
              10.gap(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _openDetail(source),
                      child: Text(
                        source.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      _typeLabel(source),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMenu(data, source),
            ],
          ),
          Text(
            source.postgres?.address ?? '—',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.mono.copyWith(
              fontSize: 12,
              color: colors.neutral.grey3,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colors.neutral.grey5.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    app.intl.common.backupCount(n: data.usageOf(source)),
                    style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
                  ),
                ),
                Flexible(
                  child: ConnectionStatusLabel(
                    check: source.lastCheck,
                    testing: data.testing.contains(source.id),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
