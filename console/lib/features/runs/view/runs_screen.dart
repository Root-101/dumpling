import 'dart:math' as math;

import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class RunsScreenNavigator {
  String get name => RouteNames.runs;

  String get path => RouteNames.runs;

  Widget builder(BuildContext context, GoRouterState state) {
    return RunsScreen(workspace: state.pathParameters[RouteNames.slugParam]!);
  }
}

/// The run log of a workspace: every run, newest first; a row opens to show
/// where the file went and the log
class RunsScreen extends StatefulWidget {
  static final RunsScreenNavigator navigator = RunsScreenNavigator();

  final String workspace;

  const RunsScreen({required this.workspace, super.key});

  @override
  State<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends State<RunsScreen> {
  late final RunCubit cubit;
  final _searchController = TextEditingController();

  /// The ids of the rows opened
  final Set<String> _open = {};

  @override
  void initState() {
    super.initState();
    cubit = context.read<RunCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant RunsScreen oldWidget) {
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

  void _toggle(RunModel run) {
    final open = !_open.contains(run.id);
    setState(() => open ? _open.add(run.id) : _open.remove(run.id));
    if (open) cubit.detail(run);
  }

  Future<void> _refresh() async {
    await cubit.reload();
    // the open runs whose detail was dropped (they changed) load it again
    final data = cubit.state.data;
    for (final run in data.runs) {
      if (_open.contains(run.id) && !data.details.containsKey(run.id)) {
        cubit.detail(run);
      }
    }
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
            title: app.intl.runs.title,
            description: app.intl.runs.description(workspace: workspaceName),
            actions: [
              BlocBuilder<RunCubit, RunState>(
                builder: (context, state) => PrimaryButton.secondary(
                  onPressed: state is RunLoadingInProgressState
                      ? null
                      : _refresh,
                  title: app.intl.runs.refresh,
                  icon: app.assets.icons.actions.refresh,
                  h: 40,
                  w: 120,
                ),
              ),
            ],
          ),
          Expanded(
            child: BlocConsumer<RunCubit, RunState>(
              listener: (context, state) {
                if (state is RunProcessingErrorState) {
                  app.snack.showError(
                    message: state.message,
                    context: app.context,
                  );
                }
              },
              builder: (context, state) {
                if (!state.data.loaded) {
                  return state is RunLoadingErrorState
                      ? ErrorPage(
                          message: state.exception.message,
                          onRetry: cubit.reload,
                        )
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

  Widget _buildTable(RunData data) {
    final t = app.intl.runs;
    return AppSimpleTable(
      minWidth: 900,
      toolbar: Row(
        children: [
          Expanded(
            child: AppTextSearchField(
              controller: _searchController,
              hint: t.search,
              // filters the runs already loaded: no wait
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
        AppTableColumn(t.columnStatus, flex: 8),
        AppTableColumn(t.columnConfig, flex: 13),
        AppTableColumn(t.columnSource, flex: 12),
        AppTableColumn(t.columnDestination, flex: 12),
        AppTableColumn(t.columnStarted, flex: 12),
        AppTableColumn(t.columnDuration, flex: 7),
        AppTableColumn(t.columnSize, flex: 7),
      ],
      rows: [
        for (final run in data.visibleRuns)
          AppTableRow(
            _buildCells(run),
            minHeight: 58,
            expanded: _open.contains(run.id)
                ? RunDetail(run: data.details[run.id])
                : null,
          ),
      ],
      // the service sends the 200 newest
      hint: data.runs.length >= 200 ? t.newestOnly : null,
      placeholder: data.runs.isEmpty
          ? AppTablePlaceholder(
              title: t.emptyTitle,
              description: t.emptyDescription,
              action: app.intl.nav.canvas,
              onPressed: () => RouteNames.openWorkspace(
                widget.workspace,
                section: RouteNames.canvas,
              ),
            )
          : data.visibleRuns.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.common.noMatches,
              action: app.intl.common.clearSearch,
              onPressed: _clearFilters,
            )
          : null,
    );
  }

  Widget _buildFilter(RunData data) {
    final t = app.intl.runs;
    final runs = data.runs;
    AppFilterOption all(bool selected, VoidCallback onTap) => AppFilterOption(
      label: app.intl.common.all,
      selected: selected,
      count: runs.length,
      onTap: onTap,
    );
    return AppFilterButton(
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: app.intl.common.shownOf(
        shown: data.visibleRuns.length,
        total: runs.length,
      ),
      groups: [
        AppFilterGroup(
          title: t.columnStatus,
          options: [
            all(data.status == null, () => cubit.filterStatus(null)),
            for (final status in RunStatus.values)
              AppFilterOption(
                label: RunStatusLabel.labelOf(status),
                selected: data.status == status,
                count: runs.where((r) => r.status == status).length,
                onTap: () => cubit.filterStatus(status),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.columnSource,
          options: [
            all(data.sourceType == null, () => cubit.filterSourceType(null)),
            for (final type in {for (final r in runs) r.sourceType})
              AppFilterOption(
                label: SourceTypeLook.labelOf(type),
                leading: TypeBadge(look: SourceTypeLook.lookOf(type), size: 24),
                selected: data.sourceType == type,
                count: runs.where((r) => r.sourceType == type).length,
                onTap: () => cubit.filterSourceType(type),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.columnDestination,
          options: [
            all(
              data.destinationType == null,
              () => cubit.filterDestinationType(null),
            ),
            for (final type in {for (final r in runs) r.destinationType})
              AppFilterOption(
                label: DestinationTypeLook.labelOf(type),
                leading: TypeBadge(
                  look: DestinationTypeLook.lookOf(type),
                  size: 24,
                ),
                selected: data.destinationType == type,
                count: runs.where((r) => r.destinationType == type).length,
                onTap: () => cubit.filterDestinationType(type),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCells(RunModel run) {
    final t = app.intl.runs;
    final open = _open.contains(run.id);
    final figures = TextStyle(
      fontSize: 14,
      color: app.colors.neutral.grey3,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget named(TypeLook look, String name) => Row(
      children: [
        TypeBadge(look: look, size: 24),
        const SizedBox(width: 8),
        Flexible(
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    final size = run.sizeBytes;
    return [
      IconButton(
        tooltip: open ? t.hideDetail : t.showDetail,
        onPressed: () => _toggle(run),
        icon: Transform.rotate(
          angle: open ? math.pi / 2 : 0,
          child: app.assets.icons.actions.chevron.build(
            size: 16,
            color: app.colors.neutral.grey3,
          ),
        ),
      ),
      RunStatusLabel(run.status),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggle(run),
            child: Text(
              run.configName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            run.manual ? t.manual : t.scheduled,
            style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
          ),
        ],
      ),
      named(SourceTypeLook.lookOf(run.sourceType), run.sourceName),
      named(
        DestinationTypeLook.lookOf(run.destinationType),
        run.destinationName,
      ),
      AppDateTime(time: run.startedAt, alignment: CrossAxisAlignment.start),
      Text(durationOf(run.duration), style: figures),
      Text(
        size == null ? '—' : app.storageFormatter.formatSize(size),
        style: figures,
      ),
    ];
  }

  /// `—` while it runs, `42 s`, `3 min 5 s`, `1 h 2 min`
  static String durationOf(Duration? d) {
    if (d == null) return '—';
    if (d.inMinutes == 0) return '${d.inSeconds} s';
    if (d.inHours == 0) return '${d.inMinutes} min ${d.inSeconds % 60} s';
    return '${d.inHours} h ${d.inMinutes % 60} min';
  }
}
