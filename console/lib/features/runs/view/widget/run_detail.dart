import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// A run in a dialog: its status, config, source and destination; how it
/// ended (or a generic progress while it runs); when, how long, why and how
/// big; its steps and its log. It loads the detail (the log) when it opens
class RunDialog extends StatefulWidget {
  /// [workspace]: out of the run log (Backups)
  static void open(RunModel run, {String? workspace}) => app.dialog.open(
    dialog: RunDialog(run: run, workspace: workspace),
  );

  /// The run of the list; the detail replaces it once loaded
  final RunModel run;
  final String? workspace;

  const RunDialog({required this.run, this.workspace, super.key});

  @override
  State<RunDialog> createState() => _RunDialogState();
}

class _RunDialogState extends State<RunDialog> {
  @override
  void initState() {
    super.initState();
    context.read<RunCubit>().detail(widget.run, workspace: widget.workspace);
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.select<RunCubit, RunModel?>(
      (c) => c.state.data.details[widget.run.id],
    );
    final run = detail ?? widget.run;
    final colors = app.colors;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AppDialogFrame(
        color: colors.primary.backgroundForm,
        child: SizedBox(
          width: 920,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(run: run),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Result(run: run),
                      20.gap(),
                      _Meta(run: run),
                      22.gap(),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final steps = _Steps(run: run);
                          final log = _Log(run: run, loaded: detail != null);
                          // side by side when there is room
                          if (constraints.maxWidth < 640) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [steps, 22.gap(), log],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 280, child: steps),
                              24.gap(),
                              Expanded(child: log),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final RunModel run;

  const _Header({required this.run});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 24, 18),
      decoration: BoxDecoration(
        color: colors.surface.surface1,
        border: Border(
          bottom: BorderSide(
            color: colors.neutral.grey5.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RunStatusIcon(run.status, size: 40),
          14.gap(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RunStatusLabel(run.status),
                    10.gap(),
                    Flexible(
                      child: Text(
                        run.id,
                        maxLines: 1,
                        style: AppText.mono.copyWith(
                          fontSize: 12,
                          color: colors.neutral.grey4,
                        ),
                      ),
                    ),
                  ],
                ),
                4.gap(),
                Text(
                  run.configName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${run.sourceName} → ${run.destinationName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.mono.copyWith(
                    fontSize: 13,
                    color: colors.neutral.grey3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// How it ended: where the file went, the error, or a generic progress
class _Result extends StatelessWidget {
  final RunModel run;

  const _Result({required this.run});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final color = RunStatusLabel.colorOf(run.status);
    final size = run.sizeBytes;
    final (String title, Widget body) = switch (run.status) {
      RunStatus.success => (
        t.resultSuccess,
        Text(
          run.location ?? '—',
          style: AppText.mono.copyWith(
            fontSize: 12,
            color: colors.text.primary,
          ),
        ),
      ),
      RunStatus.failed => (
        t.resultFailed,
        Text(
          run.error ?? '—',
          style: AppText.mono.copyWith(
            fontSize: 12,
            color: colors.text.primary,
          ),
        ),
      ),
      // shortcut: no live progress (the service only stores the bytes so far),
      // a generic bar until the run updates come over a websocket (ROADMAP)
      RunStatus.running => (
        size != null && size > 0
            ? t.soFar(size: app.storageFormatter.formatSize(size))
            : t.inProgress,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            4.gap(),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.16),
              ),
            ),
            8.gap(),
            Text(
              t.resultRunning,
              style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
            ),
          ],
        ),
      ),
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: app.dimensions.border.borderRadius.s,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: 18,
            child: Center(child: RunStatusLabel.glyphOf(run.status, size: 14)),
          ),
          10.gap(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                2.gap(),
                body,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// When it started, how long it took, why it ran and how big it came out
class _Meta extends StatelessWidget {
  final RunModel run;

  const _Meta({required this.run});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final value = TextStyle(
      fontSize: 14,
      color: colors.text.primary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final size = run.sizeBytes;
    Widget item(String label, Widget child) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
          ),
          2.gap(),
          child,
        ],
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        item(
          t.columnStarted,
          AppDateTime(
            time: run.startedAt,
            alignment: CrossAxisAlignment.start,
            style: value,
          ),
        ),
        item(
          t.columnDuration,
          Text(RunsScreen.durationOf(run.duration), style: value),
        ),
        item(
          t.columnTrigger,
          Text(run.manual ? t.manual : t.scheduled, style: value),
        ),
        item(
          t.columnSize,
          Text(
            size == null ? '—' : app.storageFormatter.formatSize(size),
            style: value,
          ),
        ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  final RunModel run;

  const _Steps({required this.run});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final labels = [
      t.stepConnect(name: run.sourceName),
      t.stepDump(name: run.destinationName),
    ];
    final steps = run.steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // as tall as the title row of the log, so both titles line up
        SizedBox(
          height: 30,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _SectionTitle(t.steps),
          ),
        ),
        10.gap(),
        for (final (i, step) in steps.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    _StepDot(state: step.state),
                    // the line to the next step
                    Expanded(
                      child: Container(
                        width: 1,
                        constraints: const BoxConstraints(minHeight: 18),
                        color: i == steps.length - 1
                            ? colors.neutral.transparent
                            : colors.neutral.grey5,
                      ),
                    ),
                  ],
                ),
                12.gap(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 14,
                            color: _pending(step.state)
                                ? colors.neutral.grey4
                                : colors.text.primary,
                          ),
                        ),
                        if (_subOf(step) case final sub?)
                          Text(
                            sub,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.neutral.grey4,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static bool _pending(RunStepState state) =>
      state == RunStepState.waiting || state == RunStepState.skipped;

  static String? _subOf(RunStep step) => switch (step.state) {
    RunStepState.skipped => app.intl.runs.stepSkipped,
    RunStepState.waiting => app.intl.runs.stepWaiting,
    RunStepState.running => app.intl.runs.inProgress,
    _ => step.duration == null ? null : RunsScreen.durationOf(step.duration),
  };
}

class _StepDot extends StatelessWidget {
  final RunStepState state;

  const _StepDot({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    // a step looks like a run with its state
    final status = switch (state) {
      RunStepState.done => RunStatus.success,
      RunStepState.failed => RunStatus.failed,
      RunStepState.running => RunStatus.running,
      _ => null,
    };
    final color = status == null ? null : RunStatusLabel.colorOf(status);
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color?.withValues(alpha: 0.14),
        border: Border.all(color: color ?? colors.neutral.grey5),
      ),
      child: status == null ? null : RunStatusLabel.glyphOf(status, size: 12),
    );
  }
}

/// The log as the service wrote it, with its UTC times, and a button to copy
/// it
class _Log extends StatelessWidget {
  final RunModel run;
  final bool loaded;

  const _Log({required this.run, required this.loaded});

  @override
  Widget build(BuildContext context) {
    final t = app.intl.runs;
    final colors = app.colors;
    final mono = AppText.mono.copyWith(
      fontSize: 12,
      color: colors.neutral.grey2,
    );
    final log = run.log ?? const <RunLogLine>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 30,
          child: Row(
            children: [
              _SectionTitle(t.log),
              const Spacer(),
              if (log.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: run.logText));
                    app.snack.showSuccess(
                      message: t.logCopied,
                      context: app.context,
                    );
                  },
                  icon: app.assets.icons.actions.duplicate.build(
                    size: 14,
                    color: colors.neutral.grey3,
                  ),
                  label: Text(
                    t.copyLog,
                    style: TextStyle(fontSize: 12, color: colors.neutral.grey2),
                  ),
                ),
            ],
          ),
        ),
        8.gap(),
        Container(
          constraints: const BoxConstraints(minHeight: 120),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.background1,
            borderRadius: app.dimensions.border.borderRadius.s,
            border: Border.all(
              color: colors.neutral.grey5.withValues(alpha: 0.6),
            ),
          ),
          child: !loaded
              ? const Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : log.isEmpty
              // the service writes the log when the run ends
              ? Text(
                  run.status == RunStatus.running ? t.logWhenDone : t.noLog,
                  style: TextStyle(fontSize: 12, color: colors.neutral.grey3),
                )
              : Text.rich(
                  TextSpan(
                    children: [
                      for (final (i, line) in log.indexed)
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${app.dateFormatter.clock.format(line.at.toUtc())}  ',
                              style: mono.copyWith(color: colors.surface.wire),
                            ),
                            TextSpan(
                              text: line.message,
                              style: line.message.startsWith('Failed:')
                                  ? mono.copyWith(color: colors.status.error)
                                  : null,
                            ),
                            if (i < log.length - 1) const TextSpan(text: '\n'),
                          ],
                        ),
                    ],
                  ),
                  style: mono.copyWith(height: 20 / 12),
                ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: app.colors.primary.primaryFaded,
      ),
    );
  }
}
