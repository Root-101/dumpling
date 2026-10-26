import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class WorkspacesScreenNavigator {
  String get name => RouteNames.workspaces;

  String get path => '/workspaces';

  Widget builder(BuildContext context, GoRouterState state) {
    return const WorkspacesScreen();
  }
}

/// Every workspace as a card, the current one first in its place, and the
/// way to create one
class WorkspacesScreen extends StatefulWidget {
  static final WorkspacesScreenNavigator navigator =
      WorkspacesScreenNavigator();

  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  late final WorkspaceCubit cubit;

  @override
  void initState() {
    super.initState();
    // the counts of the cards change while away from here
    cubit = context.read<WorkspaceCubit>()..load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: app.intl.workspaces.title,
            description: app.intl.workspaces.description,
            actions: [
              PrimaryButton.primary(
                onPressed: () => WorkspaceForm.open(context),
                title: app.intl.workspaces.create,
                icon: app.assets.icons.actions.add,
                color: app.colors.primary.primaryAction,
                h: 40,
                w: 180,
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
              builder: (context, state) {
                if (!state.data.loaded) {
                  return state is WorkspaceLoadingErrorState
                      ? ErrorPage.of(state.exception, onRetry: cubit.load)
                      : const LoadingPage();
                }
                return _buildGrid(state.data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(WorkspaceData data) {
    final gap = app.dimensions.padding.l;
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = app.dimensions.padding.xxl;
        final width = constraints.maxWidth - 2 * padding;
        final columns = width >= 1000
            ? 3
            : width >= 640
            ? 2
            : 1;
        final cardWidth = (width - gap * (columns - 1)) / columns;
        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final workspace in data.workspaces)
                SizedBox(
                  width: cardWidth,
                  child: WorkspaceCard(
                    workspace: workspace,
                    current: workspace.slug == data.currentSlug,
                  ),
                ),
              SizedBox(
                width: cardWidth,
                child: _NewWorkspaceTile(
                  onPressed: () => WorkspaceForm.open(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The dotted card at the end of the list that creates a workspace
class _NewWorkspaceTile extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewWorkspaceTile({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = app.dimensions.border.borderRadius.m;
    return AppFocusRing(
      borderRadius: radius,
      child: Material(
        color: app.colors.neutral.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: DashedBorder(
            color: app.colors.neutral.grey5,
            radius: 12,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 330),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: app.colors.surface.control,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: app.assets.icons.actions.add.build(
                        size: 20,
                        color: app.colors.neutral.grey2,
                      ),
                    ),
                    app.dimensions.padding.sm.gap(),
                    Text(
                      app.intl.workspaces.create,
                      style: TextStyle(
                        fontSize: 14,
                        color: app.colors.neutral.grey3,
                      ),
                    ),
                    app.dimensions.padding.sm.gap(),
                    SizedBox(
                      width: 240,
                      child: Text(
                        app.intl.workspaces.createHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: app.colors.neutral.grey4,
                        ),
                      ),
                    ),
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
