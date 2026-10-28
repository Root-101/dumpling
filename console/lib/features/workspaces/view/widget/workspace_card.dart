import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A workspace in the list: a sketch of its canvas, what it has, whether its
/// backups are healthy and when it last ran, with its canvas and its settings
class WorkspaceCard extends StatefulWidget {
  final WorkspaceModel workspace;

  /// The one open last: it gets a border and the main button
  final bool current;

  const WorkspaceCard({
    required this.workspace,
    required this.current,
    super.key,
  });

  @override
  State<WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<WorkspaceCard> {
  bool _hovered = false;

  WorkspaceModel get _workspace => widget.workspace;

  WorkspaceStatsModel get _stats =>
      _workspace.stats ??
      const WorkspaceStatsModel(
        sources: 0,
        destinations: 0,
        configs: 0,
        failing: 0,
        running: 0,
      );

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final radius = app.dimensions.border.borderRadius.m;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: colors.primary.background2,
          borderRadius: radius,
          border: widget.current
              ? Border.all(color: colors.primary.primaryFaded, width: 2)
              : Border.all(
                  color: _hovered ? colors.neutral.grey4 : colors.neutral.grey5,
                ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreview(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTitle(),
                  app.dimensions.padding.sm.gap(),
                  _buildCounts(),
                  app.dimensions.padding.sm.gap(),
                  _buildHealth(),
                ],
              ),
            ),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final border = app.colors.neutral.grey5.withValues(alpha: 0.6);
    return Container(
      height: WorkspacePreviewPainter.height,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: CustomPaint(
        // the grid of the canvas, smaller like the preview
        painter: GridLinePainter(
          spacing: 12,
          color: app.colors.primary.primaryFaded.withValues(alpha: 0.05),
        ),
        foregroundPainter: WorkspacePreviewPainter(links: _stats.preview),
      ),
    );
  }

  Widget _buildTitle() {
    final description = _workspace.description;
    return Row(
      children: [
        WorkspaceAvatar(initial: _workspace.initial, color: _workspace.color),
        app.dimensions.padding.sm.gap(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _workspace.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.current) ...[
                    app.dimensions.padding.s.gap(),
                    const _CurrentBadge(),
                  ],
                ],
              ),
              if (description != null && description.isNotEmpty)
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: app.colors.neutral.grey4,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounts() {
    Widget count(int value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: app.colors.neutral.grey4),
          ),
        ],
      ),
    );
    return Row(
      children: [
        count(_stats.sources, app.intl.workspaces.sources),
        count(_stats.destinations, app.intl.workspaces.destinations),
        count(_stats.configs, app.intl.workspaces.backups),
      ],
    );
  }

  Widget _buildHealth() {
    final colors = app.colors;
    final (String text, Color color) = _stats.configs == 0
        ? (app.intl.workspaces.noBackups, colors.neutral.grey4)
        : _stats.failing > 0
        ? (
            app.intl.workspaces.failing(count: _stats.failing),
            colors.status.error,
          )
        : (app.intl.workspaces.healthy, colors.status.success);
    final lastRun = _stats.lastRunAt;
    final activityStyle = TextStyle(fontSize: 12, color: colors.neutral.grey3);
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        app.dimensions.padding.s.gap(),
        // short (`2 failing`, `No backups yet`): whole, the time takes the rest
        Text(text, style: TextStyle(fontSize: 12, color: color)),
        app.dimensions.padding.m.gap(),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _stats.running > 0
                ? Text(app.intl.workspaces.running, style: activityStyle)
                : lastRun != null
                ? AppDateTime(
                    time: lastRun,
                    label: (time) => app.intl.workspaces.lastRun(time: time),
                  )
                : Text(
                    app.intl.workspaces.noRuns,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: activityStyle,
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    final slug = _workspace.slug;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: app.colors.neutral.grey5.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton.primary(
              onPressed: () =>
                  RouteNames.openWorkspace(slug, section: RouteNames.canvas),
              title: widget.current
                  ? app.intl.workspaces.openCanvas
                  : app.intl.workspaces.switchAndOpen,
              icon: app.assets.icons.navigation.pipeline,
              color: widget.current
                  ? app.colors.primary.primaryAction
                  : app.colors.surface.control,
              h: 38,
            ),
          ),
          app.dimensions.padding.s.gap(),
          _SettingsButton(workspace: _workspace),
        ],
      ),
    );
  }
}

/// Opens [WorkspaceSettings]: a bordered square with the icon
class _SettingsButton extends StatelessWidget {
  final WorkspaceModel workspace;

  const _SettingsButton({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final radius = app.dimensions.border.borderRadius.s;
    return Tooltip(
      message: app.intl.workspaces.settingsOf(name: workspace.name),
      child: Material(
        color: app.colors.surface.control,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: app.colors.neutral.grey5),
        ),
        child: InkWell(
          borderRadius: radius,
          mouseCursor: SystemMouseCursors.click,
          onTap: () => WorkspaceSettings.open(context, workspace),
          child: SizedBox.square(
            dimension: 38,
            child: Center(
              child: app.assets.icons.navigation.settings.build(
                size: 18,
                color: app.colors.neutral.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: app.colors.primary.primaryFaded.withValues(alpha: 0.2),
        borderRadius: app.dimensions.border.borderRadius.xs,
      ),
      child: Text(
        app.intl.workspaces.current,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: app.colors.primary.primaryLight,
        ),
      ),
    );
  }
}
