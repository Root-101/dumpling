import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class BackupsScreenNavigator {
  String get name => RouteNames.backups;

  String get path => RouteNames.backups;

  Widget builder(BuildContext context, GoRouterState state) {
    return BackupsScreen(
      workspace: state.pathParameters[RouteNames.slugParam]!,
    );
  }
}

/// The home of a workspace: how its backups are doing, and when each one
/// ran and runs next
class BackupsScreen extends StatefulWidget {
  static final BackupsScreenNavigator navigator = BackupsScreenNavigator();

  final String workspace;

  const BackupsScreen({required this.workspace, super.key});

  static Color colorOf(BackupHealth health) => switch (health) {
    BackupHealth.healthy => app.colors.status.success,
    BackupHealth.failing => app.colors.status.error,
    BackupHealth.running => app.colors.status.running,
    BackupHealth.neverRan || BackupHealth.paused => app.colors.status.pending,
  };

  static String labelOf(BackupHealth health) => switch (health) {
    BackupHealth.healthy => app.intl.backups.healthy,
    BackupHealth.failing => app.intl.backups.failing,
    BackupHealth.running => app.intl.canvas.runStatus.running,
    BackupHealth.neverRan => app.intl.canvas.neverRun,
    BackupHealth.paused => app.intl.backups.paused,
  };

  @override
  State<BackupsScreen> createState() => _BackupsScreenState();
}

class _BackupsScreenState extends State<BackupsScreen> {
  late final BackupCubit cubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cubit = context.read<BackupCubit>();
    _load();
  }

  @override
  void didUpdateWidget(covariant BackupsScreen oldWidget) {
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

  void _open(String section) =>
      RouteNames.openWorkspace(widget.workspace, section: section);

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
            title: app.intl.backups.title,
            description: app.intl.backups.description(workspace: workspaceName),
            actions: [
              PrimaryButton.primary(
                onPressed: () => _open(RouteNames.canvas),
                title: app.intl.backups.openEditor,
                color: app.colors.primary.primaryAction,
                h: 40,
                w: 190,
              ),
            ],
          ),
          Expanded(
            child: BlocConsumer<BackupCubit, BackupState>(
              listener: _onState,
              builder: (context, state) {
                if (!state.data.loaded) {
                  return state is BackupLoadingErrorState
                      ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                      : const LoadingPage();
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: app.dimensions.padding.xxl,
                    vertical: app.dimensions.padding.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummary(state.data),
                      SizedBox(height: app.dimensions.padding.l),
                      _buildTable(state.data),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, BackupState state) {
    if (state is BackupRunFinishedState) {
      final run = state.run;
      if (run.status == RunStatus.success) {
        app.snack.showSuccess(
          message: app.intl.canvas.run.done(
            name: state.name,
            size: app.storageFormatter.formatSize(run.sizeBytes ?? 0),
          ),
          context: app.context,
        );
      } else {
        app.snack.showError(
          message: app.intl.canvas.run.failed(
            name: state.name,
            error: run.error ?? '',
          ),
          context: app.context,
        );
      }
    }
    if (state is BackupProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
  }

  Widget _buildSummary(BackupData data) {
    final t = app.intl.backups;
    final next = data.next;
    final failing = data.count(BackupHealth.failing);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SummaryCard(
            label: t.healthy,
            value: '${data.count(BackupHealth.healthy)}',
            sub: t.ofTotal(n: data.backups.length),
            color: app.colors.status.success,
            onTap: () => cubit.filterHealth(BackupHealth.healthy),
          ),
        ),
        SizedBox(width: app.dimensions.padding.m),
        Expanded(
          child: _SummaryCard(
            label: t.failing,
            value: '$failing',
            sub: failing == 0 ? t.noFailures : t.seeFailing,
            color: failing == 0
                ? app.colors.neutral.grey3
                : app.colors.status.error,
            onTap: () => cubit.filterHealth(BackupHealth.failing),
          ),
        ),
        SizedBox(width: app.dimensions.padding.m),
        Expanded(
          child: _SummaryCard(
            label: t.nextRun,
            value: next == null
                ? '—'
                : app.intl.time.utc(
                    time: app.dateFormatter.time.format(
                      next.config.nextRun!.toUtc(),
                    ),
                  ),
            sub: next?.config.name ?? t.nothingScheduled,
            color: app.colors.text.primary,
            onTap: () => cubit.sort(BackupSort.nextRun),
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BackupData data) {
    final t = app.intl.backups;
    return AppSimpleTable(
      minWidth: 900,
      toolbar: Row(
        children: [
          Expanded(
            child: AppTextSearchField(
              controller: _searchController,
              hint: t.search,
              // filters the backups already loaded: no wait
              delay: 0,
              onSearch: cubit.search,
            ),
          ),
          app.dimensions.padding.sm.gap(),
          _buildFilter(data),
        ],
      ),
      columns: [
        AppTableColumn(t.columnStatus, flex: 8),
        AppTableColumn(t.columnBackup, flex: 13),
        AppTableColumn(t.columnRoute, flex: 16),
        AppTableColumn(t.columnLastRun, flex: 12),
        AppTableColumn(t.columnNextRun, flex: 11),
        const AppTableColumn.actions(width: 52),
      ],
      rows: [
        for (final backup in data.visible)
          AppTableRow(_buildCells(backup), minHeight: 64),
      ],
      placeholder: data.backups.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.workspaces.noBackups,
              description: t.emptyDescription,
              action: t.openEditor,
              onPressed: () => _open(RouteNames.canvas),
            )
          : data.visible.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.common.noMatches,
              action: app.intl.common.clearSearch,
              onPressed: _clearFilters,
            )
          : null,
    );
  }

  Widget _buildFilter(BackupData data) {
    final t = app.intl.backups;
    return AppFilterButton(
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: app.intl.common.shownOf(
        shown: data.visible.length,
        total: data.backups.length,
      ),
      groups: [
        AppFilterGroup(
          title: t.columnStatus,
          options: [
            AppFilterOption(
              label: app.intl.common.all,
              selected: data.health == null,
              count: data.backups.length,
              onTap: () => cubit.filterHealth(null),
            ),
            for (final health in BackupHealth.values)
              AppFilterOption(
                label: BackupsScreen.labelOf(health),
                selected: data.health == health,
                count: data.count(health),
                onTap: () => cubit.filterHealth(health),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.sortBy,
          options: [
            for (final sort in BackupSort.values)
              AppFilterOption(
                label: switch (sort) {
                  BackupSort.name => t.sortName,
                  BackupSort.lastRun => t.sortLastRun,
                  BackupSort.nextRun => t.sortNextRun,
                },
                selected: data.sort == sort,
                onTap: () => cubit.sort(sort),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildCells(BackupRow backup) {
    final t = app.intl.backups;
    final c = backup.config;
    final health = backup.health;
    final color = BackupsScreen.colorOf(health);
    final muted = TextStyle(fontSize: 12, color: app.colors.neutral.grey4);
    final schedule = c.schedule;
    final last = c.lastRun;
    final next = c.nextRun;
    final folder = c.folderId;
    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              BackupsScreen.labelOf(health),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            schedule == null
                ? app.intl.canvas.workspaceDefault
                : '${Frequency.of(schedule).label} · $schedule',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TypeBadge(
                look: SourceTypeLook.lookOf(backup.source.type),
                size: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${backup.source.name} → ${backup.destination.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '/${folder ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted.copyWith(fontFamily: AppText.monoFamily),
          ),
        ],
      ),
      if (last == null)
        Text(app.intl.canvas.neverRun, style: muted)
      else
        Tooltip(
          // why it failed, on hover
          message: last.error ?? '',
          child: AppDateTime(
            time: last.startedAt,
            alignment: CrossAxisAlignment.start,
            label: (time) => [
              time,
              if (last.sizeBytes case final size?
                  when last.status == RunStatus.success)
                app.storageFormatter.formatSize(size),
            ].join(' · '),
          ),
        ),
      if (next == null)
        Text(c.enabled ? '—' : t.paused, style: muted)
      else
        AppDateTime(time: next, alignment: CrossAxisAlignment.start),
      AppRowMenu(
        tooltip: app.intl.common.optionsFor(name: c.name),
        items: [
          AppRowMenuItem(
            label: app.intl.canvas.run.button,
            icon: app.assets.icons.actions.test,
            enabled: health != BackupHealth.running,
            onTap: () => cubit.runNow(backup),
          ),
          AppRowMenuItem(
            label: t.openEditor,
            icon: app.assets.icons.actions.edit,
            onTap: () => _open(RouteNames.canvas),
          ),
          AppRowMenuItem(
            label: t.seeRuns,
            icon: app.assets.icons.actions.chevron,
            onTap: () => _open(RouteNames.runs),
          ),
        ],
      ),
    ];
  }
}

/// A number of the summary; a tap filters or sorts the table by it
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = app.dimensions.border.borderRadius.m;
    return Material(
      color: app.colors.primary.background2,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(app.dimensions.padding.l),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: app.colors.neutral.grey5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: app.colors.neutral.grey3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: app.colors.neutral.grey4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
