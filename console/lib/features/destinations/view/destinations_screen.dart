import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class DestinationsScreenNavigator {
  String get name => RouteNames.destinations;

  String get path => RouteNames.destinations;

  Widget builder(BuildContext context, GoRouterState state) {
    return DestinationsScreen(
      workspace: state.pathParameters[RouteNames.slugParam]!,
      openId: state.pathParameters[RouteNames.idParam],
    );
  }
}

/// The destinations of a workspace, as rows or cards: where it writes
/// backups, the folders of each bucket, how many backups use them and how the
/// last connection test went. One opens in a dialog with its detail
class DestinationsScreen extends StatefulWidget {
  static final DestinationsScreenNavigator navigator =
      DestinationsScreenNavigator();

  final String workspace;

  /// The destination whose dialog the URL opens (`destinations/{id}`)
  final String? openId;

  const DestinationsScreen({required this.workspace, this.openId, super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen>
    with UrlDialog {
  late final DestinationCubit cubit;
  final _searchController = TextEditingController();

  /// The ids of the rows with their folders open
  final Set<String> _open = {};

  AppView _view = AppView.list;

  @override
  void initState() {
    super.initState();
    cubit = context.read<DestinationCubit>();
    _load();
    // a list loaded already changes no state
    WidgetsBinding.instance.addPostFrameCallback((_) => _followUrl());
  }

  @override
  void didUpdateWidget(covariant DestinationsScreen oldWidget) {
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
    _open.clear();
    cubit
      ..load(widget.workspace)
      ..clearFilters();
  }

  void _clearFilters() {
    _searchController.clear();
    cubit.clearFilters();
  }

  void _openForm({DestinationModel? destination, bool duplicate = false}) {
    final data = cubit.state.data;
    DestinationForm.open(
      context,
      workspace: widget.workspace,
      types: data.types,
      destination: destination,
      duplicate: duplicate,
      folderUsage: destination == null
          ? const {}
          : data.usage[destination.id] ?? const {},
    );
  }

  void _openDetail(DestinationModel destination) => RouteNames.openItem(
    widget.workspace,
    RouteNames.destination,
    destination.id,
  );

  /// The destination of the URL over the list, once it is loaded
  void _followUrl() {
    final data = cubit.state.data;
    if (!data.loaded || data.workspace != widget.workspace) return;
    followUrl(
      widget.openId,
      show: (id) async {
        final item = data.destinations.where((e) => e.id == id).firstOrNull;
        if (item == null) return false;
        await DestinationDialog.open(
          item,
          onEdit: (d) => _openForm(destination: d),
        );
        return true;
      },
      leave: () => RouteNames.openWorkspace(
        widget.workspace,
        section: RouteNames.destinations,
      ),
    );
  }

  void _confirmDelete(DestinationModel destination) {
    ConfirmDialog.show(
      title: app.intl.destinations.deleteTitle(name: destination.name),
      description: app.intl.destinations.deleteConfirm,
      confirmTitle: app.intl.common.delete,
      confirmColor: app.colors.primary.errorAction,
      confirmAction: () => cubit.delete(destination),
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
            title: app.intl.destinations.title,
            workspace: workspaceName,
            description: app.intl.destinations.description,
            actions: [
              BlocBuilder<DestinationCubit, DestinationState>(
                builder: (context, state) => AppRefreshButton(
                  onPressed: cubit.reload,
                  loading:
                      state is DestinationLoadingInProgressState &&
                      state.data.loaded,
                ),
              ),
              BlocBuilder<DestinationCubit, DestinationState>(
                builder: (context, state) => PrimaryButton.primary(
                  // the form needs the types
                  onPressed: state.data.loaded ? () => _openForm() : null,
                  title: app.intl.destinations.create,
                  icon: app.assets.icons.actions.add,
                  color: app.colors.primary.primaryAction,
                  h: 40,
                  w: 180,
                ),
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
              child: BlocConsumer<DestinationCubit, DestinationState>(
                listener: _onState,
                builder: (context, state) {
                  if (!state.data.loaded) {
                    return state is DestinationLoadingErrorState
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
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, DestinationState state) {
    _followUrl();
    if (state is DestinationProcessInProgressState) {
      app.loading.show();
    } else {
      app.loading.hide();
    }
    if (state is DestinationProcessingOKState) {
      final folder = FolderPath.show(state.folder ?? '');
      final message = switch (state.action) {
        DestinationAction.deleted => app.intl.destinations.deleted(
          name: state.destination.name,
        ),
        DestinationAction.folderAdded => app.intl.destinations.folderAdded(
          path: folder,
        ),
        DestinationAction.folderDeleted => app.intl.destinations.folderDeleted(
          path: folder,
        ),
        // the row shows what the test found
        DestinationAction.tested => null,
      };
      if (message != null) {
        app.snack.showSuccess(message: message, context: app.context);
      }
    }
    if (state is DestinationProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
  }

  Widget _buildTable(DestinationData data) {
    return AppSimpleTable(
      toolbar: Row(
        children: [
          Expanded(
            child: AppTextSearchField(
              controller: _searchController,
              hint: app.intl.destinations.search,
              // filters the destinations already loaded: no wait
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
      columns: [
        const AppTableColumn.actions(width: 40),
        AppTableColumn(app.intl.destinations.columnName, flex: 13),
        AppTableColumn(app.intl.destinations.columnType, flex: 8),
        AppTableColumn(app.intl.destinations.columnEndpoint, flex: 17),
        AppTableColumn(app.intl.destinations.columnBackups, flex: 7),
        AppTableColumn(app.intl.destinations.columnStatus, flex: 10),
        const AppTableColumn.actions(width: 52),
      ],
      rows: [
        for (final destination in data.visibleDestinations)
          AppTableRow(
            _buildCells(data, destination),
            minHeight: 58,
            expanded: _open.contains(destination.id)
                ? DestinationFolders(
                    destination: destination,
                    usageOf: (folder) =>
                        data.folderUsageOf(destination, folder),
                    onAdd: (path) => cubit.addFolder(destination, path),
                    onDelete: (path) => cubit.deleteFolder(destination, path),
                  )
                : null,
          ),
      ],
      placeholder: data.destinations.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.destinations.emptyTitle,
              description: app.intl.destinations.emptyDescription,
              action: app.intl.destinations.create,
              onPressed: () => _openForm(),
            )
          : data.visibleDestinations.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.common.noMatches,
              action: app.intl.common.clearSearch,
              onPressed: _clearFilters,
            )
          : null,
    );
  }

  Widget _buildFilter(DestinationData data) {
    // the types available, and any other one a destination still has
    final types = {
      for (final t in data.types)
        if (t.enabled) t.type,
      for (final d in data.destinations) d.type,
    };
    return AppFilterButton(
      // one group: the 280 of the design
      columnWidth: 264,
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: app.intl.common.shownOf(
        shown: data.visibleDestinations.length,
        total: data.destinations.length,
      ),
      groups: [
        AppFilterGroup(
          title: app.intl.destinations.columnType,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.type == null,
              count: data.destinations.length,
              onTap: () => cubit.filterType(null),
            ),
            for (final type in types)
              AppFilterOption(
                label: DestinationTypeLook.labelOf(type),
                leading: TypeBadge(
                  look: DestinationTypeLook.lookOf(type),
                  size: 24,
                ),
                selected: data.type == type,
                count: data.destinations.where((d) => d.type == type).length,
                onTap: () => cubit.filterType(type),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCells(DestinationData data, DestinationModel destination) {
    final used = data.usageOf(destination);
    final testing = data.testing.contains(destination.id);
    final open = _open.contains(destination.id);
    final muted = TextStyle(fontSize: 14, color: app.colors.neutral.grey3);
    final folders = destination.folders.length;
    return [
      IconButton(
        tooltip: open
            ? app.intl.destinations.hideFolders(name: destination.name)
            : app.intl.destinations.showFolders(name: destination.name),
        onPressed: () => setState(
          () => open ? _open.remove(destination.id) : _open.add(destination.id),
        ),
        icon: Transform.rotate(
          angle: open ? math.pi / 2 : 0,
          child: app.assets.icons.actions.chevron.build(
            size: 16,
            color: app.colors.neutral.grey3,
          ),
        ),
      ),
      Row(
        children: [
          TypeBadge(look: DestinationTypeLook.lookOf(destination.type)),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _openDetail(destination),
                  child: Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  folders == 0
                      ? app.intl.destinations.bucketRoot
                      : app.intl.destinations.folderCount(n: folders),
                  style: TextStyle(
                    fontSize: 12,
                    color: app.colors.neutral.grey4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      Text(
        DestinationTypeLook.labelOf(destination.type),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: muted,
      ),
      Text(
        destination.s3?.address ?? '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: muted.copyWith(fontFamily: AppText.monoFamily, fontSize: 12),
      ),
      Text(
        '$used',
        style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      ),
      ConnectionStatusLabel(check: destination.lastCheck, testing: testing),
      _buildMenu(data, destination),
    ];
  }

  Widget _buildMenu(DestinationData data, DestinationModel destination) {
    final used = data.usageOf(destination);
    final testing = data.testing.contains(destination.id);
    return AppRowMenu(
      tooltip: app.intl.common.optionsFor(name: destination.name),
      items: [
        AppRowMenuItem(
          label: app.intl.common.viewDetails,
          icon: app.assets.icons.actions.view,
          onTap: () => _openDetail(destination),
        ),
        AppRowMenuItem(
          label: app.intl.common.edit,
          icon: app.assets.icons.actions.edit,
          onTap: () => _openForm(destination: destination),
        ),
        AppRowMenuItem(
          label: app.intl.common.duplicate,
          icon: app.assets.icons.actions.duplicate,
          onTap: () => _openForm(destination: destination, duplicate: true),
        ),
        AppRowMenuItem(
          label: app.intl.connections.test,
          icon: app.assets.icons.actions.test,
          enabled: !testing,
          onTap: () => cubit.test(destination),
        ),
        AppRowMenuItem(
          label: app.intl.common.delete,
          icon: app.assets.icons.actions.delete,
          danger: true,
          divided: true,
          enabled: used == 0,
          sub: used == 0 ? null : app.intl.destinations.inUse(n: used),
          onTap: () => _confirmDelete(destination),
        ),
      ],
    );
  }

  /// The same destinations as cards, three in a row when there is room
  Widget _buildGrid(DestinationData data) {
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
              for (final destination in data.visibleDestinations)
                SizedBox(width: width, child: _buildCard(data, destination)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard(DestinationData data, DestinationModel destination) {
    final colors = app.colors;
    final folders = destination.folders.length;
    final muted = TextStyle(fontSize: 12, color: colors.neutral.grey4);
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
              TypeBadge(
                look: DestinationTypeLook.lookOf(destination.type),
                size: 36,
              ),
              10.gap(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _openDetail(destination),
                      child: Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      DestinationTypeLook.labelOf(destination.type),
                      style: muted,
                    ),
                  ],
                ),
              ),
              _buildMenu(data, destination),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                destination.s3?.address ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.mono.copyWith(
                  fontSize: 12,
                  color: colors.neutral.grey3,
                ),
              ),
              Row(
                spacing: 6,
                children: [
                  app.assets.icons.nodes.folder.build(
                    size: 13,
                    color: colors.primary.primaryFaded,
                  ),
                  Text(
                    folders == 0
                        ? app.intl.destinations.bucketRoot
                        : app.intl.destinations.folderCount(n: folders),
                    style: muted,
                  ),
                ],
              ),
            ],
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
                    app.intl.common.backupCount(n: data.usageOf(destination)),
                    style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
                  ),
                ),
                Flexible(
                  child: ConnectionStatusLabel(
                    check: destination.lastCheck,
                    testing: data.testing.contains(destination.id),
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
