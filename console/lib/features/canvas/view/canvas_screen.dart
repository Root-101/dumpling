import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class CanvasScreenNavigator {
  String get name => RouteNames.canvas;

  String get path => RouteNames.canvas;

  Widget builder(BuildContext context, GoRouterState state) {
    return CanvasScreen(workspace: state.pathParameters[RouteNames.slugParam]!);
  }
}

/// The canvas of a workspace: its sources, destinations and the configs
/// between them, edited here and saved whole
class CanvasScreen extends StatefulWidget {
  static final CanvasScreenNavigator navigator = CanvasScreenNavigator();

  final String workspace;

  const CanvasScreen({required this.workspace, super.key});

  @override
  State<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends State<CanvasScreen> {
  late final CanvasCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = context.read<CanvasCubit>();
    cubit.load(widget.workspace);
  }

  @override
  void didUpdateWidget(covariant CanvasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.workspace != widget.workspace) cubit.load(widget.workspace);
  }

  void _onState(BuildContext context, CanvasState state) {
    if (state is CanvasProcessInProgressState) {
      app.loading.show();
    } else {
      app.loading.hide();
    }
    if (state is CanvasProcessingOKState) {
      app.snack.showSuccess(
        message: app.intl.canvas.saved,
        context: app.context,
      );
    }
    if (state is CanvasTestedState) {
      final failed = state.checks.where((c) => !c.ok);
      if (state.checks.isEmpty) {
        app.snack.showError(
          message: app.intl.canvas.testRun.nothing,
          context: app.context,
        );
      } else if (failed.isEmpty) {
        app.snack.showSuccess(
          message: app.intl.canvas.testRun.ok(n: state.checks.length),
          context: app.context,
        );
      } else {
        app.snack.showError(
          message: app.intl.canvas.testRun.failed(
            list: [
              for (final c in failed)
                '${c.name}: ${c.error ?? ConnectionStatusLabel.labelOf(c.check)}',
            ].join(' · '),
          ),
          context: app.context,
        );
      }
    }
    if (state is CanvasRunFinishedState) {
      final run = state.run;
      if (run.status == RunStatus.success) {
        app.snack.showSuccess(
          message: app.intl.canvas.run.done(
            name: state.configName,
            size: StorageFormatter().formatSize(run.sizeBytes ?? 0),
          ),
          context: app.context,
        );
      } else {
        app.snack.showError(
          message: app.intl.canvas.run.failed(
            name: state.configName,
            error: run.error ?? '',
          ),
          context: app.context,
        );
      }
    }
    if (state is CanvasProcessingErrorState) {
      app.snack.showError(message: state.message, context: app.context);
    }
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
            title: app.intl.nav.canvas,
            workspace: workspaceName,
            description: app.intl.canvas.description,
            actions: [
              BlocBuilder<CanvasCubit, CanvasState>(
                builder: (context, state) => Tooltip(
                  message: app.intl.canvas.testRun.help,
                  child: PrimaryButton.secondary(
                    onPressed: state.data.loaded ? cubit.testRun : null,
                    title: app.intl.canvas.testRun.button,
                    h: 40,
                    w: 120,
                  ),
                ),
              ),
              BlocBuilder<CanvasCubit, CanvasState>(
                builder: (context, state) => PrimaryButton.primary(
                  onPressed: state.data.loaded ? cubit.save : null,
                  title: app.intl.canvas.save,
                  color: app.colors.primary.primaryAction,
                  h: 40,
                  w: 150,
                ),
              ),
            ],
          ),
          Expanded(
            child: PagePanel(
              child: BlocConsumer<CanvasCubit, CanvasState>(
                listener: _onState,
                // the editor keeps its viewport: only built again when the
                // canvas of another workspace is loaded
                buildWhen: (a, b) =>
                    a.data.loaded != b.data.loaded ||
                    a.data.workspace != b.data.workspace ||
                    (b is CanvasLoadingErrorState) !=
                        (a is CanvasLoadingErrorState),
                builder: (context, state) {
                  if (!state.data.loaded) {
                    return state is CanvasLoadingErrorState
                        ? ErrorPage.of(state.exception, onRetry: cubit.reload)
                        : const LoadingPage();
                  }
                  return CanvasEditor(key: ValueKey(state.data.workspace));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
