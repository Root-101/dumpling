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
    );
  }
}

/// The destinations of a workspace: where it writes backups, the folders of
/// each bucket, how many backups use them and how the last connection test
/// went
class DestinationsScreen extends StatefulWidget {
  static final DestinationsScreenNavigator navigator =
      DestinationsScreenNavigator();

  final String workspace;

  const DestinationsScreen({required this.workspace, super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  late final DestinationCubit cubit;
  final _searchController = TextEditingController();

  /// The ids of the rows with their folders open
  final Set<String> _open = {};

  @override
  void initState() {
    super.initState();
    cubit = context.read<DestinationCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant DestinationsScreen oldWidget) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: app.intl.destinations.title,
            description: app.intl.destinations.description(
              workspace: workspaceName,
            ),
            actions: [
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
        ],
      ),
    );
  }

  void _onState(BuildContext context, DestinationState state) {
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
        ],
      ),
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
                  onTap: () => _openForm(destination: destination),
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
      AppRowMenu(
        tooltip: app.intl.common.optionsFor(name: destination.name),
        items: [
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
      ),
    ];
  }
}
