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
    );
  }
}

/// The sources of a workspace: what it backs up, how many backups use each
/// one and how its last connection test went
class SourcesScreen extends StatefulWidget {
  static final SourcesScreenNavigator navigator = SourcesScreenNavigator();

  final String workspace;

  const SourcesScreen({required this.workspace, super.key});

  @override
  State<SourcesScreen> createState() => _SourcesScreenState();
}

class _SourcesScreenState extends State<SourcesScreen> {
  late final SourceCubit cubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = context.read<SourceCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant SourcesScreen oldWidget) {
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

  void _openForm({SourceModel? source, bool duplicate = false}) {
    SourceForm.open(
      context,
      workspace: widget.workspace,
      types: cubit.state.data.types,
      source: source,
      duplicate: duplicate,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: app.intl.sources.title,
            description: app.intl.sources.description(workspace: workspaceName),
            actions: [
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
            child: BlocConsumer<SourceCubit, SourceState>(
              listener: _onState,
              builder: (context, state) {
                if (!state.data.loaded) {
                  return state is SourceLoadingErrorState
                      ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                      : const LoadingPage();
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
        ],
      ),
    );
  }

  void _onState(BuildContext context, SourceState state) {
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
        ],
      ),
      columns: [
        AppTableColumn(app.intl.sources.columnName, flex: 13),
        AppTableColumn(app.intl.sources.columnType, flex: 10),
        AppTableColumn(app.intl.sources.columnHost, flex: 16),
        AppTableColumn(app.intl.sources.columnBackups, flex: 8),
        AppTableColumn(app.intl.sources.columnStatus, flex: 8),
        const AppTableColumn.actions(width: 52),
      ],
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
    final major = source.lastCheck?.serverMajor;
    final muted = TextStyle(fontSize: 14, color: app.colors.neutral.grey3);
    return [
      Row(
        children: [
          TypeBadge(look: SourceTypeLook.lookOf(source.type)),
          const SizedBox(width: 10),
          Flexible(
            child: InkWell(
              onTap: () => _openForm(source: source),
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
        [SourceTypeLook.labelOf(source.type), ?major].join(' '),
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
      AppRowMenu(
        tooltip: app.intl.common.optionsFor(name: source.name),
        items: [
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
      ),
    ];
  }
}
