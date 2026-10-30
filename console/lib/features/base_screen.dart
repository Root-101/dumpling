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

class _Rail extends StatefulWidget {
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
  State<_Rail> createState() => _RailState();
}

class _RailState extends State<_Rail> {
  /// Expanded, each item shows its name next to its icon
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final icons = app.assets.icons;
    final workspace = widget.current;
    final expanded = _expanded;
    // [label]: the name when it isn't the whole tooltip (its badge says the rest)
    Widget item(
      String name,
      String tooltip,
      SvgAsset icon, {
      Widget? badge,
      String? label,
    }) => RailButton(
      tooltip: tooltip,
      label: expanded ? label ?? tooltip : null,
      selected: widget.section == name,
      badge: badge,
      onPressed: workspace == null
          ? null
          : (_) => RouteNames.openWorkspace(workspace.slug, section: name),
      icon: (color) => icon.build(size: 20, color: color),
    );
    final divider = Padding(
      padding: EdgeInsets.symmetric(horizontal: expanded ? 0 : 8),
      child: Container(
        height: 1,
        color: app.colors.neutral.grey5.withValues(alpha: 0.6),
      ),
    );
    final failing = workspace?.stats?.failing ?? 0;
    return Stack(
      children: [
        Container(
          width: expanded ? 220 : 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          color: app.colors.primary.background2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: app.dimensions.padding.s,
            children: [
              _WorkspaceSwitcher(
                workspace: workspace,
                selected: widget.onWorkspaces,
                expanded: expanded,
              ),
              if (workspace != null) ...[
                item(
                  RouteNames.backups,
                  app.intl.nav.backups,
                  icons.nodes.clock,
                ),
                item(
                  RouteNames.canvas,
                  app.intl.nav.canvas,
                  icons.navigation.pipeline,
                ),
                divider,
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
                divider,
                item(
                  RouteNames.runs,
                  failing > 0
                      ? '${app.intl.nav.runs} · ${app.intl.nav.failedRuns(count: failing)}'
                      : app.intl.nav.runs,
                  icons.navigation.events,
                  badge: failing > 0 ? RailBadge(count: failing) : null,
                  label: app.intl.nav.runs,
                ),
              ],
              const Spacer(),
              LanguageWidget(expanded: expanded),
              RailButton(
                tooltip: app.intl.nav.logout,
                label: expanded ? app.intl.nav.logout : null,
                // the logout resets the canvas before the router could ask
                onPressed: (_) async {
                  final auth = context.read<AuthCubit>();
                  if (await CanvasScreen.confirmLeave()) auth.logout();
                },
                icon: (color) =>
                    icons.actions.logout.build(size: 20, color: color),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          // a little under the middle, away from the items
          child: Align(
            alignment: const Alignment(0, 0.2),
            child: _RailNotch(
              expanded: expanded,
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tab on the middle of the rail's edge, inside it so it covers nothing of
/// the page: it expands and collapses the rail, away from the items so a
/// slip doesn't fold it
class _RailNotch extends StatelessWidget {
  final bool expanded;
  final VoidCallback onPressed;

  const _RailNotch({required this.expanded, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    const radius = BorderRadius.horizontal(left: Radius.circular(8));
    final side = BorderSide(
      color: colors.neutral.grey5.withValues(alpha: 0.75),
    );
    return Tooltip(
      message: expanded ? app.intl.nav.collapse : app.intl.nav.expand,
      child: Semantics(
        button: true,
        expanded: expanded,
        child: Material(
          color: colors.primary.background2,
          shape: RoundedRectangleBorder(borderRadius: radius, side: side),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            hoverColor: colors.surface.control,
            child: SizedBox(
              width: 14,
              height: 48,
              child: Center(
                child: RotatedBox(
                  quarterTurns: expanded ? 2 : 0,
                  child: app.assets.icons.actions.chevron.build(
                    size: 10,
                    color: colors.neutral.grey4,
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

/// The current workspace's avatar; it opens the list of workspaces. Without
/// one yet (none opened), the list's icon
class _WorkspaceSwitcher extends StatelessWidget {
  final WorkspaceModel? workspace;
  final bool selected;

  /// In the expanded rail: the avatar with the workspace's name
  final bool expanded;

  const _WorkspaceSwitcher({
    required this.workspace,
    required this.selected,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final current = workspace;
    if (current == null) {
      return RailButton(
        tooltip: app.intl.nav.workspaces,
        label: expanded ? app.intl.nav.workspaces : null,
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
              child: SizedBox(
                height: RailButton.size,
                child: Row(
                  mainAxisAlignment: expanded
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (expanded) const SizedBox(width: 6),
                    WorkspaceAvatar(
                      initial: current.initial,
                      color: current.color,
                      size: 30,
                    ),
                    if (expanded) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          current.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
