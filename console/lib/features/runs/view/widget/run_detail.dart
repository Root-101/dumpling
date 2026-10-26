import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Under a row of the run log: where the file went, the error and the log of
/// [run] (null while it loads), with a button to copy the log
class RunDetail extends StatelessWidget {
  final RunModel? run;

  const RunDetail({required this.run, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final t = app.intl.runs;
    final run = this.run;
    final padding = EdgeInsets.fromLTRB(
      56,
      app.dimensions.padding.xs,
      app.dimensions.padding.l,
      app.dimensions.padding.l,
    );
    if (run == null) {
      return Padding(
        padding: padding,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    final label = TextStyle(fontSize: 12, color: colors.neutral.grey3);
    final mono = AppText.mono.copyWith(
      fontSize: 12,
      color: colors.text.primary,
    );
    final log = run.log ?? const <RunLogLine>[];
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.location, style: label),
          const SizedBox(height: 4),
          SelectableText(run.location ?? '—', style: mono),
          if (run.error case final error?) ...[
            const SizedBox(height: 12),
            Text(t.error, style: label),
            const SizedBox(height: 4),
            SelectableText(
              error,
              style: mono.copyWith(color: colors.status.error),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(t.log, style: label),
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
                  label: Text(t.copyLog, style: label),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(app.dimensions.padding.sm),
            decoration: BoxDecoration(
              color: colors.surface.surface1,
              borderRadius: app.dimensions.radius.s,
              border: Border.all(color: colors.surface.border),
            ),
            child: log.isEmpty
                // the service writes the log when the run ends
                ? Text(
                    run.status == RunStatus.running ? t.logWhenDone : t.noLog,
                    style: label,
                  )
                : SelectableText.rich(
                    TextSpan(
                      children: [
                        for (final (i, line) in log.indexed)
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    '${app.dateFormatter.clock.format(line.at.toUtc())}  ',
                                style: mono.copyWith(
                                  color: colors.neutral.grey4,
                                ),
                              ),
                              TextSpan(text: line.message),
                              if (i < log.length - 1)
                                const TextSpan(text: '\n'),
                            ],
                          ),
                      ],
                    ),
                    style: mono.copyWith(height: 1.6),
                  ),
          ),
        ],
      ),
    );
  }
}
