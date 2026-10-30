import 'package:flutter/foundation.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class RunsScreenNavigator {
  String get name => RouteNames.runs;

  String get path => RouteNames.runs;

  Widget builder(BuildContext context, GoRouterState state) {
    return RunsScreen(
      workspace: state.pathParameters[RouteNames.slugParam]!,
      openId: state.pathParameters[RouteNames.idParam],
      filters: state.uri.queryParameters,
    );
  }
}

/// The run log of a workspace: every run, newest first, grouped by day (UTC);
/// a run opens in a dialog with its steps and its log
class RunsScreen extends StatefulWidget {
  static final RunsScreenNavigator navigator = RunsScreenNavigator();

  final String workspace;

  /// The run whose dialog the URL opens (`runs/{id}`)
  final String? openId;

  /// The filters of the URL: `?status=failed&source=postgres&destination=s3`
  final Map<String, String> filters;

  const RunsScreen({
    required this.workspace,
    this.openId,
    this.filters = const {},
    super.key,
  });

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

class _RunsScreenState extends State<RunsScreen> with UrlDialog {
  late final RunCubit cubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = context.read<RunCubit>();
    _load();
    // a list loaded already changes no state
    WidgetsBinding.instance.addPostFrameCallback((_) => _followUrl());
  }

  @override
  void didUpdateWidget(covariant RunsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace != widget.workspace) {
      _load();
    } else if (!mapEquals(oldWidget.filters, widget.filters)) {
      _applyFilters();
    }
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
    _applyFilters();
  }

  void _clearFilters() {
    _searchController.clear();
    cubit.clearFilters();
    _go(const {});
  }

  static const String _status = 'status';
  static const String _source = 'source';
  static const String _destination = 'destination';

  /// The URL has the filters, so the log can be reloaded or shared filtered
  void _filter(String key, String? value) => _go(
    {...widget.filters}
      ..remove(key)
      ..addAll({key: ?value}),
  );

  void _go(Map<String, String> filters) => app.navigator.go(
    RouteNames.runs,
    pathParameters: {RouteNames.slugParam: widget.workspace},
    queryParameters: filters,
  );

  /// An unknown value is no filter
  void _applyFilters() {
    final f = widget.filters;
    cubit
      ..filterStatus(RunStatus.values.asNameMap()[f[_status]])
      ..filterSourceType(f[_source])
      ..filterDestinationType(f[_destination]);
  }

  /// The run of the URL over the log, once it is loaded
  void _followUrl() {
    final data = cubit.state.data;
    if (!data.loaded || data.workspace != widget.workspace) return;
    followUrl(
      widget.openId,
      show: (id) async {
        final run = await cubit.find(widget.workspace, id);
        if (run == null) return false;
        await RunDialog.open(run);
        return true;
      },
      leave: () => _go(widget.filters),
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
                  _followUrl();
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
                        : _buildSkeleton();
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
    return _panel(
      Row(
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
      [
        for (final (day, runs) in byDay(data.visibleRuns)) ...[
          _DayHeader(day: day, runs: runs, divider: divider),
          for (final run in runs)
            _RunRow(
              run: run,
              divider: divider,
              workspace: widget.workspace,
              filters: widget.filters,
            ),
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
    );
  }

  /// The log's box: [toolbar] on top, then [children]
  Widget _panel(Widget toolbar, List<Widget> children) {
    final colors = app.colors;
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
            child: toolbar,
          ),
          ...children,
        ],
      ),
    );
  }

  /// While they load: two days of runs, in blocks
  Widget _buildSkeleton() {
    final divider = BorderSide(
      color: app.colors.neutral.white.withValues(alpha: 0.06),
    );
    Widget row(double f) => Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: divider)),
      child: Row(
        children: [
          const AppSkeleton(width: 24, height: 24, radius: 12),
          14.gap(),
          Expanded(child: AppSkeleton.lines(f, 0.38)),
          14.gap(),
          const SizedBox(
            width: 90,
            child: AppSkeleton(width: 58, height: 10, dim: true),
          ),
          SizedBox(width: 170, child: AppSkeleton.lines(0.7, 0.56)),
          const SizedBox(
            width: 110,
            child: Align(
              alignment: Alignment.centerRight,
              child: AppSkeleton(width: 72, height: 28, radius: 6, dim: true),
            ),
          ),
        ],
      ),
    );
    Widget day(double w) => Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: app.colors.primary.backgroundForm,
      child: Row(
        spacing: 10,
        children: [
          AppSkeleton(width: w, height: 10),
          const AppSkeleton(width: 70, height: 10, dim: true),
        ],
      ),
    );
    return AppShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: app.dimensions.padding.xxl,
          vertical: app.dimensions.padding.xl,
        ),
        child: _panel(AppSkeleton.toolbar(const [96]), [
          day(150),
          for (final f in const [0.62, 0.48, 0.7, 0.55]) row(f),
          day(170),
          for (final f in const [0.66, 0.5, 0.58]) row(f),
        ]),
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
            all(data.status == null, () => _filter(_status, null)),
            for (final status in RunStatus.values)
              AppFilterOption(
                label: RunStatusLabel.labelOf(status),
                selected: data.status == status,
                count: runs.where((r) => r.status == status).length,
                onTap: () => _filter(_status, status.name),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.columnSource,
          options: [
            all(data.sourceType == null, () => _filter(_source, null)),
            for (final type in {for (final r in runs) r.sourceType})
              AppFilterOption(
                label: SourceTypeLook.labelOf(type),
                leading: TypeBadge(look: SourceTypeLook.lookOf(type), size: 24),
                selected: data.sourceType == type,
                count: runs.where((r) => r.sourceType == type).length,
                onTap: () => _filter(_source, type),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.columnDestination,
          options: [
            all(
              data.destinationType == null,
              () => _filter(_destination, null),
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
                onTap: () => _filter(_destination, type),
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
  final String workspace;
  final Map<String, String> filters;

  const _RunRow({
    required this.run,
    required this.divider,
    required this.workspace,
    required this.filters,
  });

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
                onPressed: () => RouteNames.openItem(
                  workspace,
                  RouteNames.run,
                  run.id,
                  query: filters,
                ),
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
