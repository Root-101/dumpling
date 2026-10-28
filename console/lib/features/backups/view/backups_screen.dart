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
/// ran and runs next. A row opens its recent runs; its menu edits the config
/// (the dialog of the canvas), runs it or deletes it
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

  /// As the run log says it: *Success*, *Failed*, *Running*
  static String labelOf(BackupHealth health) => switch (health) {
    BackupHealth.healthy => app.intl.canvas.runStatus.success,
    BackupHealth.failing => app.intl.canvas.runStatus.failed,
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

  /// The configs whose row is open
  final Set<String> _open = {};

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
    _open.clear();
    cubit
      ..load(widget.workspace)
      ..clearFilters();
  }

  void _clearFilters() {
    _searchController.clear();
    cubit.clearFilters();
  }

  void _openCanvas() =>
      RouteNames.openWorkspace(widget.workspace, section: RouteNames.canvas);

  /// The backups, and the recent runs of the ones open
  Future<void> _reload() async {
    await cubit.reload();
    for (final id in _open) {
      cubit.loadRecent(id);
    }
  }

  void _toggle(BackupRow backup) {
    final id = backup.config.id;
    final open = !_open.contains(id);
    setState(() => open ? _open.add(id) : _open.remove(id));
    // every time it opens: the runs may be new
    if (open) cubit.loadRecent(id);
  }

  void _edit(BackupRow backup) {
    ConfigDialog.open(
      config: backup.config,
      source: backup.source,
      destination: backup.destination,
      onSave: cubit.save,
      onDelete: () => _confirmDelete(backup),
    );
  }

  void _confirmDelete(BackupRow backup) {
    ConfirmDialog.show(
      title: app.intl.backups.deleteTitle(name: backup.config.name),
      description: app.intl.backups.deleteConfirm,
      confirmTitle: app.intl.common.delete,
      confirmColor: app.colors.primary.errorAction,
      confirmAction: () => cubit.delete(backup),
    );
  }

  /// The last run of [backup] as the run dialog takes it; the dialog loads
  /// the rest (its log)
  void _viewLastRun(BackupRow backup) {
    final last = backup.config.lastRun;
    if (last == null) return;
    RunDialog.open(
      RunModel(
        id: last.id,
        configId: backup.config.id,
        configName: backup.config.name,
        sourceName: backup.source.name,
        sourceType: backup.source.type,
        destinationName: backup.destination.name,
        destinationType: backup.destination.type,
        trigger: 'schedule',
        status: last.status,
        startedAt: last.startedAt,
        sizeBytes: last.sizeBytes,
        error: last.error,
      ),
      workspace: widget.workspace,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = app.intl.backups;
    final workspaceName = context.select<WorkspaceCubit, String>(
      (c) => c.state.data.current?.name ?? widget.workspace,
    );
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
              BlocBuilder<BackupCubit, BackupState>(
                builder: (context, state) => AppRefreshButton(
                  onPressed: _reload,
                  loading:
                      state is BackupLoadingInProgressState &&
                      state.data.loaded,
                ),
              ),
              PrimaryButton.primary(
                onPressed: _openCanvas,
                title: t.newBackup,
                icon: app.assets.icons.actions.add,
                color: app.colors.primary.primaryAction,
                h: 40,
                horizontalPadding: 18,
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
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
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, BackupState state) {
    if (state is BackupProcessInProgressState) {
      app.loading.show();
    } else {
      app.loading.hide();
    }
    if (state is BackupRunFinishedState) {
      final run = state.run;
      // the failing count of the rail comes from the list of workspaces
      app.di.find<WorkspaceCubit>().load();
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
    if (state is BackupSavedState) {
      app.snack.showSuccess(
        message: app.intl.backups.saved(name: state.name),
        context: app.context,
      );
    }
    if (state is BackupDeletedState) {
      app.snack.showSuccess(
        message: app.intl.backups.deleted(name: state.name),
        context: app.context,
      );
    }
    if (state is BackupProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
  }

  Widget _buildSummary(BackupData data) {
    final t = app.intl.backups;
    final next = data.next;
    final at = next?.config.nextRun;
    return Row(
      spacing: 12,
      children: [
        DetailStat(
          t.healthy,
          '${data.count(BackupHealth.healthy)}',
          t.healthySub,
        ),
        DetailStat(
          t.failing,
          '${data.count(BackupHealth.failing)}',
          t.failingSub,
        ),
        DetailStat(
          t.nextBackupIn,
          at == null ? '—' : _until(at),
          next == null ? t.nothingScheduled : next.source.name,
        ),
      ],
    );
  }

  /// `11 h 45 min`, never below a minute
  static String _until(DateTime at) {
    final d = at.difference(DateTime.now());
    return RunsScreen.durationOf(
      d.inMinutes < 1 ? const Duration(minutes: 1) : d,
    );
  }

  Widget _buildTable(BackupData data) {
    final t = app.intl.backups;
    final now = DateTime.now();
    final format = app.dateFormatter.time;
    return AppSimpleTable(
      minWidth: 1120,
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
          app.dimensions.padding.sm.gap(),
          _SortButton(value: data.sort, onChanged: cubit.sort),
        ],
      ),
      columns: [
        AppTableColumn(t.columnStatus, width: 120),
        AppTableColumn(t.columnSource, flex: 115),
        AppTableColumn(t.columnDestination, flex: 150),
        AppTableColumn(t.columnSchedule, flex: 100),
        AppTableColumn(
          [
            t.columnLastRun,
            if (data.sort == BackupSort.lastRun) '↓',
            if (data.sort == BackupSort.lastRunOldest) '↑',
          ].join(' '),
          flex: 125,
        ),
        AppTableColumn(
          [t.columnNextRun, if (data.sort == BackupSort.nextRun) '↑'].join(' '),
          flex: 100,
        ),
        const AppTableColumn.actions(width: 144),
      ],
      rows: [
        for (final backup in data.visible)
          AppTableRow(
            _buildCells(backup),
            minHeight: 64,
            onTap: () => _toggle(backup),
            background: _open.contains(backup.config.id)
                ? app.colors.surface.control.withValues(alpha: 0.35)
                : null,
            expanded: _open.contains(backup.config.id)
                ? _RecentRuns(
                    runs: data.recent[backup.config.id],
                    workspace: widget.workspace,
                    onEdit: () => _edit(backup),
                  )
                : null,
          ),
      ],
      hint: data.backups.isEmpty
          ? null
          : t.showing(shown: data.visible.length, total: data.backups.length),
      hintEnd: data.backups.isEmpty
          ? null
          : t.timesNote(
              utc: format.format(now.toUtc()),
              local: format.format(now),
            ),
      placeholder: data.backups.isEmpty
          ? AppTablePlaceholder(
              title: app.intl.workspaces.noBackups,
              description: t.emptyDescription,
              action: t.openEditor,
              onPressed: _openCanvas,
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
    final sources = {for (final b in data.backups) b.source.id: b.source};
    final destinations = {
      for (final b in data.backups) b.destination.id: b.destination,
    };
    return AppFilterButton(
      activeCount: data.activeFilters,
      onClear: _clearFilters,
      note: t.shown(shown: data.visible.length, total: data.backups.length),
      groups: [
        AppFilterGroup(
          title: t.columnSource,
          options: [
            AppFilterOption(
              label: t.allSources,
              selected: data.sourceId == null,
              count: data.backups.length,
              onTap: () => cubit.filterSource(null),
            ),
            for (final s in sources.values)
              AppFilterOption(
                label: s.name,
                leading: TypeBadge(look: s.look, size: 24),
                selected: data.sourceId == s.id,
                count: data.backups.where((b) => b.source.id == s.id).length,
                onTap: () => cubit.filterSource(s.id),
              ),
          ],
        ),
        AppFilterGroup(
          title: t.columnDestination,
          options: [
            AppFilterOption(
              label: t.allDestinations,
              selected: data.destinationId == null,
              count: data.backups.length,
              onTap: () => cubit.filterDestination(null),
            ),
            for (final d in destinations.values)
              AppFilterOption(
                label: d.name,
                leading: TypeBadge(
                  look: DestinationTypeLook.lookOf(d.type),
                  size: 24,
                ),
                selected: data.destinationId == d.id,
                count: data.backups
                    .where((b) => b.destination.id == d.id)
                    .length,
                onTap: () => cubit.filterDestination(d.id),
              ),
          ],
        ),
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
              if (data.count(health) > 0 || data.health == health)
                AppFilterOption(
                  label: BackupsScreen.labelOf(health),
                  leading: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: BackupsScreen.colorOf(health),
                      shape: BoxShape.circle,
                    ),
                  ),
                  selected: data.health == health,
                  count: data.count(health),
                  onTap: () => cubit.filterHealth(health),
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
    final colors = app.colors;
    final muted = TextStyle(fontSize: 12, color: colors.neutral.grey4);
    final small = TextStyle(fontSize: 11, color: colors.neutral.grey4);
    final schedule = c.schedule;
    final last = c.lastRun;
    final next = c.nextRun;
    final dest = backup.destination;
    final folder = c.folderId == null ? '' : FolderPath.show(c.folderId!);
    final region = dest.settings['region'];
    final open = _open.contains(c.id);
    final running = health == BackupHealth.running;
    return [
      _StatusChip(health: health),
      Row(
        children: [
          TypeBadge(look: backup.source.look),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  backup.source.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  c.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
              ],
            ),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${dest.bucket}$folder',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.mono.copyWith(fontSize: 12),
          ),
          Text(
            [
              dest.name,
              if (region is String && region.isNotEmpty) region,
            ].join(' · '),
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
          Text(
            schedule == null
                ? app.intl.canvas.workspaceDefault
                : c.enabled
                ? Frequency.of(schedule).label
                : t.paused,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (schedule != null)
            Text(schedule, style: AppText.mono.copyWith(fontSize: 11)),
        ],
      ),
      if (last == null)
        Text(app.intl.canvas.neverRun, style: muted)
      else
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDateTime(
              time: last.startedAt,
              alignment: CrossAxisAlignment.start,
              style: const TextStyle(
                fontSize: 13,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              switch (last.status) {
                RunStatus.success =>
                  last.sizeBytes == null
                      ? ''
                      : app.storageFormatter.formatSize(last.sizeBytes!),
                RunStatus.failed => last.error ?? '',
                RunStatus.running => t.startedAgo(
                  time: RunsScreen.durationOf(
                    DateTime.now().difference(last.startedAt),
                  ),
                ),
              },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: last.status == RunStatus.failed
                    ? colors.status.error
                    : colors.neutral.grey4,
              ),
            ),
          ],
        ),
      if (next == null)
        Text(c.enabled ? '—' : t.paused, style: muted)
      else
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppDateTime(
              time: next,
              alignment: CrossAxisAlignment.start,
              style: const TextStyle(
                fontSize: 13,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(t.inTime(time: _until(next)), style: small),
          ],
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 6,
        children: [
          PrimaryButton.svgIcon(
            icon: app.assets.icons.actions.play,
            tooltipMessage: t.runNowFor(name: backup.source.name),
            iconSize: 15,
            onPressed: running ? null : () => cubit.runNow(backup),
          ),
          // the chevron turned, so not svgIcon: same look as Run now
          Tooltip(
            message: open ? t.hideRuns : t.showRuns,
            child: PrimaryButton(
              onPressed: () => _toggle(backup),
              color: colors.primary.background3.withValues(alpha: 0.75),
              title: '',
              w: 36,
              h: 36,
              icon: Transform.rotate(
                angle: open ? -1.5708 : 1.5708,
                child: app.assets.icons.actions.chevron.build(
                  size: 15,
                  color: colors.neutral.grey2,
                ),
              ),
            ),
          ),
          AppRowMenu(
            tooltip: t.moreFor(name: backup.source.name),
            items: [
              AppRowMenuItem(
                label: t.viewLastRun,
                icon: app.assets.icons.actions.view,
                enabled: last != null,
                onTap: () => _viewLastRun(backup),
              ),
              AppRowMenuItem(
                label: t.editConfig,
                icon: app.assets.icons.actions.edit,
                onTap: () => _edit(backup),
              ),
              AppRowMenuItem(
                label: app.intl.canvas.run.button,
                icon: app.assets.icons.actions.play,
                enabled: !running,
                onTap: () => cubit.runNow(backup),
              ),
              AppRowMenuItem(
                label: t.deleteBackup,
                icon: app.assets.icons.actions.delete,
                danger: true,
                divided: true,
                onTap: () => _confirmDelete(backup),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

/// *Success*, *Failed*, *Running* (with the ring of the run log), *Never
/// run* or *Paused*, on its tint
class _StatusChip extends StatelessWidget {
  final BackupHealth health;

  const _StatusChip({required this.health});

  @override
  Widget build(BuildContext context) {
    final color = BackupsScreen.colorOf(health);
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          if (health == BackupHealth.running)
            RunProgressRing(size: 12, color: color)
          else
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          Flexible(
            child: Text(
              BackupsScreen.labelOf(health),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `Sort: Last backup` and its menu
class _SortButton extends StatelessWidget {
  final BackupSort value;
  final ValueChanged<BackupSort> onChanged;

  const _SortButton({required this.value, required this.onChanged});

  static (String, String) labelsOf(BackupSort sort) {
    final t = app.intl.backups;
    return switch (sort) {
      BackupSort.lastRun => (t.sortLast, t.sortLastSub),
      BackupSort.lastRunOldest => (t.sortLastOld, t.sortLastOldSub),
      BackupSort.nextRun => (t.sortNext, t.sortNextSub),
      BackupSort.name => (t.sortName, t.sortNameSub),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final t = app.intl.backups;
    return PopupMenuButton<BackupSort>(
      tooltip: t.sortBy,
      color: colors.primary.backgroundForm,
      elevation: 8,
      position: PopupMenuPosition.under,
      constraints: const BoxConstraints.tightFor(width: 260),
      menuPadding: const EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.neutral.grey5),
      ),
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(t.sortBy.toUpperCase(), style: DetailPanelTitle.style),
        ),
        for (final sort in BackupSort.values)
          PopupMenuItem(
            value: sort,
            height: 42,
            padding: EdgeInsets.zero,
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: sort == value
                    ? colors.primary.primaryLight.withValues(alpha: 0.14)
                    : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 14,
                    child: sort == value
                        ? app.assets.icons.actions.check.build(
                            size: 14,
                            color: colors.primary.primaryLight,
                          )
                        : null,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labelsOf(sort).$1,
                        style: TextStyle(
                          fontSize: 13,
                          color: sort == value
                              ? colors.neutral.white
                              : colors.neutral.grey2,
                        ),
                      ),
                      Text(
                        labelsOf(sort).$2,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.neutral.grey4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.only(left: 14, right: 12),
        decoration: BoxDecoration(
          color: colors.surface.control,
          borderRadius: app.dimensions.border.borderRadius.s,
          border: Border.all(color: colors.neutral.grey5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            app.assets.icons.actions.sort.build(
              size: 16,
              color: colors.neutral.white,
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${t.sort} ',
                    style: TextStyle(color: colors.neutral.grey3),
                  ),
                  TextSpan(text: labelsOf(value).$1),
                ],
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Transform.rotate(
              angle: 1.5708,
              child: app.assets.icons.actions.chevron.build(
                size: 14,
                color: colors.neutral.grey3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The newest runs of an open row: when (a link to its dialog), how it
/// ended, size, duration, why it ran and where the file went
class _RecentRuns extends StatelessWidget {
  /// Null while they load
  final List<RunModel>? runs;
  final String workspace;
  final VoidCallback onEdit;

  const _RecentRuns({
    required this.runs,
    required this.workspace,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final t = app.intl.backups;
    final colors = app.colors;
    final runs = this.runs;
    final divider = BorderSide(
      color: colors.neutral.white.withValues(alpha: 0.06),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(140, 4, 16, 16),
      color: colors.surface.control.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.recentRuns.toUpperCase(),
                    style: DetailPanelTitle.style.copyWith(fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: Text(
                    t.editConfig,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary.primaryFaded,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.primary.background2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.neutral.grey5.withValues(alpha: 0.7),
              ),
            ),
            child: runs == null
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : runs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      t.noRuns,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final (i, run) in runs.indexed)
                        Container(
                          decoration: BoxDecoration(
                            border: i == runs.length - 1
                                ? null
                                : Border(bottom: divider),
                          ),
                          child: _RunLine(run: run, workspace: workspace),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RunLine extends StatelessWidget {
  final RunModel run;
  final String workspace;

  const _RunLine({required this.run, required this.workspace});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.backups;
    final colors = app.colors;
    final color = RunStatusLabel.colorOf(run.status);
    final size = run.sizeBytes;
    final text = TextStyle(fontSize: 12, color: colors.neutral.grey2);
    void open() => RunDialog.open(run, workspace: workspace);
    final location = run.location?.replaceFirst('s3://', '');
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          spacing: 12,
          children: [
            SizedBox(
              width: 170,
              child: AppDateTime(
                time: run.startedAt,
                alignment: CrossAxisAlignment.start,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.neutral.grey1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Row(
                spacing: 6,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    RunStatusLabel.labelOf(run.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                size == null || run.status != RunStatus.success
                    ? (run.status == RunStatus.running ? '—' : '0 B')
                    : app.storageFormatter.formatSize(size),
                style: text,
              ),
            ),
            SizedBox(
              width: 70,
              child: Text(
                RunsScreen.durationOf(run.duration),
                style: text.copyWith(color: colors.neutral.grey4),
              ),
            ),
            SizedBox(
              width: 90,
              child: Text(
                run.manual ? t.manual : t.scheduled,
                style: text.copyWith(color: colors.neutral.grey3),
              ),
            ),
            Expanded(
              child: Text(
                run.status == RunStatus.success
                    ? location ?? '—'
                    : run.status == RunStatus.running
                    ? t.uploading
                    : t.noFile,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.mono.copyWith(
                  fontSize: 12,
                  color: run.status == RunStatus.success
                      ? colors.brand.accent
                      : colors.neutral.grey4,
                ),
              ),
            ),
            SizedBox(
              width: 110,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: open,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    fixedSize: const Size.fromHeight(28),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    foregroundColor: colors.neutral.grey2,
                    textStyle: const TextStyle(fontSize: 12),
                    side: BorderSide(color: colors.neutral.grey5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    run.status == RunStatus.failed ? t.viewLog : t.viewDetails,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
