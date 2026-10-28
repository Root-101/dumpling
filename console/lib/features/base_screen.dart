import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Base screen with the navigation rail. The URL says where it is: the
/// workspace (`/workspaces/{slug}/…`) becomes the current one and its section
/// is the selected item
class BaseScreen extends StatefulWidget {
  final GoRouterState state;
  final Widget child;

  const BaseScreen({required this.state, required this.child, super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late final WorkspaceCubit _workspaces;

  /// `/workspaces/{slug}/{section}`: the slug and the section, when inside a
  /// workspace
  String? get _slug => widget.state.pathParameters[RouteNames.slugParam];

  String? get _section {
    final segments = widget.state.uri.pathSegments;
    return segments.length > 2 ? segments[2] : null;
  }

  @override
  void initState() {
    super.initState();
    _workspaces = context.read<WorkspaceCubit>();
    if (!_workspaces.state.data.loaded) _workspaces.load();
    _follow();
  }

  @override
  void didUpdateWidget(covariant BaseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _follow();
  }

  /// The workspace of the URL is the current one. After the frame: the rail
  /// that listens to it may be building
  void _follow() {
    final slug = _slug;
    if (slug == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _workspaces.select(slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app.colors.primary.background2,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<WorkspaceCubit, WorkspaceState>(
            builder: (context, state) => _Rail(
              current: state.data.current,
              section: _section,
              onWorkspaces: _slug == null,
            ),
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  final WorkspaceModel? current;

  /// The selected item, inside a workspace
  final String? section;

  /// On the list of workspaces: the switcher is the selected item
  final bool onWorkspaces;

  const _Rail({
    required this.current,
    required this.section,
    required this.onWorkspaces,
  });

  @override
  Widget build(BuildContext context) {
    final icons = app.assets.icons;
    final workspace = current;
    Widget item(String name, String tooltip, SvgAsset icon, {Widget? badge}) =>
        RailButton(
          tooltip: tooltip,
          selected: section == name,
          badge: badge,
          onPressed: workspace == null
              ? null
              : (_) => RouteNames.openWorkspace(workspace.slug, section: name),
          icon: (color) => icon.build(size: 20, color: color),
        );
    final failing = workspace?.stats?.failing ?? 0;
    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: app.colors.primary.background2,
      child: Column(
        spacing: app.dimensions.padding.s,
        children: [
          _WorkspaceSwitcher(workspace: workspace, selected: onWorkspaces),
          if (workspace != null) ...[
            item(
              RouteNames.backups,
              app.intl.nav.backups,
              icons.navigation.backups,
            ),
            item(
              RouteNames.canvas,
              app.intl.nav.canvas,
              icons.navigation.pipeline,
            ),
            item(
              RouteNames.sources,
              app.intl.nav.sources,
              icons.nodes.database,
            ),
            item(
              RouteNames.destinations,
              app.intl.nav.destinations,
              icons.nodes.bucket,
            ),
            item(
              RouteNames.runs,
              failing > 0
                  ? '${app.intl.nav.runs} · ${app.intl.nav.failedRuns(count: failing)}'
                  : app.intl.nav.runs,
              icons.navigation.events,
              badge: failing > 0 ? RailBadge(count: failing) : null,
            ),
          ],
          const Spacer(),
          const LanguageWidget(),
          RailButton(
            tooltip: app.intl.nav.logout,
            // the logout resets the canvas before the router could ask
            onPressed: (_) async {
              final auth = context.read<AuthCubit>();
              if (await CanvasScreen.confirmLeave()) auth.logout();
            },
            icon: (color) => icons.actions.logout.build(size: 20, color: color),
          ),
        ],
      ),
    );
  }
}

/// The current workspace's avatar; it opens the list of workspaces. Without
/// one yet (none opened), the list's icon
class _WorkspaceSwitcher extends StatelessWidget {
  final WorkspaceModel? workspace;
  final bool selected;

  const _WorkspaceSwitcher({required this.workspace, required this.selected});

  @override
  Widget build(BuildContext context) {
    final current = workspace;
    if (current == null) {
      return RailButton(
        tooltip: app.intl.nav.workspaces,
        selected: selected,
        onPressed: (_) => app.navigator.go(RouteNames.workspaces),
        icon: (color) =>
            app.assets.icons.navigation.pipeline.build(size: 20, color: color),
      );
    }
    final radius = BorderRadius.circular(10);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Tooltip(
        message: app.intl.nav.switchWorkspace(name: current.name),
        child: AppFocusRing(
          borderRadius: radius,
          child: Material(
            color: app.colors.neutral.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: selected
                  ? BorderSide(color: app.colors.primary.primaryFaded, width: 2)
                  : BorderSide(color: app.colors.neutral.grey5),
            ),
            child: InkWell(
              borderRadius: radius,
              onTap: () => app.navigator.go(RouteNames.workspaces),
              child: SizedBox.square(
                dimension: RailButton.size,
                child: Center(
                  child: WorkspaceAvatar(
                    initial: current.initial,
                    color: current.color,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
