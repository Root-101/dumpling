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

/// The run log of a workspace: every run, newest first, grouped by day (UTC);
/// a run opens in a dialog with its steps and its log
class RunsScreen extends StatefulWidget {
  static final RunsScreenNavigator navigator = RunsScreenNavigator();

  final String workspace;

  const RunsScreen({required this.workspace, super.key});

  /// `—` while it runs, `0.4 s`, `42 s`, `3 min 5 s`, `1 h 2 min`
  static String durationOf(Duration? d) {
    if (d == null) return '—';
    // a step under a second
    if (d.inSeconds == 0) {
      return '${(d.inMilliseconds / 1000).toStringAsFixed(1)} s';
    }
    if (d.inMinutes == 0) return '${d.inSeconds} s';
    if (d.inHours == 0) return '${d.inMinutes} min ${d.inSeconds % 60} s';
    return '${d.inHours} h ${d.inMinutes % 60} min';
  }

  @override
  State<RunsScreen> createState() => _RunsScreenState();
}

class _RunsScreenState extends State<RunsScreen> {
  late final RunCubit cubit;
  final _searchController = TextEditingController();

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
    cubit
      ..load(widget.workspace)
      ..clearFilters();
  }

  void _clearFilters() {
    _searchController.clear();
    cubit.clearFilters();
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
            title: app.intl.runs.title,
            workspace: workspaceName,
            description: app.intl.runs.description,
            actions: [
              BlocBuilder<RunCubit, RunState>(
                builder: (context, state) => AppRefreshButton(
                  onPressed: cubit.reload,
                  loading:
                      state is RunLoadingInProgressState && state.data.loaded,
                ),
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
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
                        ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                        : const LoadingPage();
                  }
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: app.dimensions.padding.xxl,
                      vertical: app.dimensions.padding.xl,
                    ),
                    child: _buildList(state.data),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(RunData data) {
    final t = app.intl.runs;
    final colors = app.colors;
    final divider = BorderSide(
      color: colors.neutral.white.withValues(alpha: 0.06),
    );
    final placeholder = data.runs.isEmpty
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
        : null;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.m,
        border: Border.all(color: colors.neutral.grey5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: app.dimensions.padding.m,
              vertical: app.dimensions.padding.sm,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.neutral.grey5.withValues(alpha: 0.6),
                ),
              ),
            ),
            child: Row(
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
          ),
          for (final (day, runs) in byDay(data.visibleRuns)) ...[
            _DayHeader(day: day, runs: runs, divider: divider),
            for (final run in runs) _RunRow(run: run, divider: divider),
          ],
          ?placeholder,
          // the service sends the 200 newest
          if (data.runs.length >= 200)
            Padding(
              padding: EdgeInsets.all(app.dimensions.padding.l),
              child: Text(
                t.newestOnly,
                style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
              ),
            ),
        ],
      ),
    );
  }

  /// The runs (newest first) by the UTC day they started
  static List<(DateTime, List<RunModel>)> byDay(List<RunModel> runs) {
    final days = <(DateTime, List<RunModel>)>[];
    for (final run in runs) {
      final at = run.startedAt.toUtc();
      final day = DateTime.utc(at.year, at.month, at.day);
      if (days.isEmpty || days.last.$1 != day) days.add((day, []));
      days.last.$2.add(run);
    }
    return days;
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
}

/// A day of the log: its date (today, yesterday) and how its runs ended
class _DayHeader extends StatelessWidget {
  final DateTime day;
  final List<RunModel> runs;
  final BorderSide divider;

  const _DayHeader({
    required this.day,
    required this.runs,
    required this.divider,
  });

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final date = app.dateFormatter.day.format(day);
    final title = switch (today.difference(day).inDays) {
      0 => t.today(date: date),
      1 => t.yesterday(date: date),
      _ => t.day(date: date),
    };
    final ok = runs.where((r) => r.status == RunStatus.success).length;
    final failed = runs.where((r) => r.status == RunStatus.failed).length;
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.primary.backgroundForm,
        border: Border(bottom: divider),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.neutral.grey2,
            ),
          ),
          10.gap(),
          Expanded(
            child: Text(
              [
                if (ok > 0) t.succeeded(n: ok),
                if (failed > 0) t.failedCount(n: failed),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
            ),
          ),
        ],
      ),
    );
  }
}

/// A run: its status, config, source → destination and how it went; why it
/// ran, when, and the button that opens it
class _RunRow extends StatelessWidget {
  final RunModel run;
  final BorderSide divider;

  const _RunRow({required this.run, required this.divider});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final size = run.sizeBytes;
    final detail = switch (run.status) {
      RunStatus.success => t.savedIn(
        size: app.storageFormatter.formatSize(size ?? 0),
        duration: RunsScreen.durationOf(run.duration),
      ),
      RunStatus.failed => run.error ?? '—',
      RunStatus.running =>
        size != null && size > 0
            ? t.soFar(size: app.storageFormatter.formatSize(size))
            : t.inProgress,
    };
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: divider)),
      child: Row(
        children: [
          RunStatusIcon(run.status),
          14.gap(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        run.configName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    8.gap(),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${run.sourceName} → ${run.destinationName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.mono.copyWith(
                          fontSize: 12,
                          color: colors.neutral.grey3,
                        ),
                      ),
                    ),
                  ],
                ),
                2.gap(),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: run.status == RunStatus.failed
                        ? colors.status.error
                        : colors.neutral.grey4,
                  ),
                ),
              ],
            ),
          ),
          14.gap(),
          SizedBox(
            width: 90,
            child: Text(
              run.manual ? t.manual : t.scheduled,
              style: TextStyle(fontSize: 11, color: colors.neutral.grey4),
            ),
          ),
          SizedBox(
            width: 170,
            child: AppDateTime(
              time: run.startedAt,
              style: TextStyle(
                fontSize: 13,
                color: colors.neutral.grey3,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => RunDialog.open(run),
                child: Text(
                  t.viewRun,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary.primaryFaded,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
