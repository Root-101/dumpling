import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Dialog of a form in steps: icon, title and close at the top, the numbered
/// [steps] under them (done ones with a check), the [child] of the [current]
/// step in the middle and, at the bottom, *Step n of m* and the [actions].
/// The caller keeps the step and rebuilds it with the next one
class StepsDialogTemplate extends StatelessWidget {
  /// Completes when it closes. [dialog] builds a [StepsDialogTemplate]
  static Future<void> show({required Widget dialog, BuildContext? context}) {
    return showGeneralDialog(
      context: context ?? app.context,
      barrierDismissible: true,
      barrierLabel: app.intl.common.close,
      barrierColor: const Color(0xFF08070C).withValues(alpha: 0.62),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  final String title;
  final String description;
  final SvgAsset icon;
  final List<String> steps;

  /// Index in [steps]
  final int current;
  final Widget child;
  final List<Widget> actions;

  /// Set apart on the left of the footer, e.g. *Delete config*
  final Widget? footerLeading;

  /// Id of its [LoadingOverlay], to cover it while the form saves
  final Object? loadingId;
  final double width;

  const StepsDialogTemplate({
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.current,
    required this.child,
    required this.actions,
    this.footerLeading,
    this.loadingId,
    this.width = 720,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final line = BorderSide(color: colors.neutral.grey5.withValues(alpha: 0.5));
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: BoxDecoration(
            color: colors.primary.background2,
            border: Border(
              bottom: BorderSide(
                color: colors.neutral.grey5.withValues(alpha: 0.25),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.primaryFaded.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: icon.build(size: 20, color: colors.primary.primaryFaded),
              ),
              12.gap(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 28 / 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(border: Border(bottom: line)),
          child: Row(
            children: [
              for (final (i, label) in steps.indexed)
                _buildStep(i, label, last: i == steps.length - 1),
            ],
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: child,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: colors.primary.background2,
            border: Border(top: line),
          ),
          child: Row(
            spacing: app.dimensions.padding.sm,
            children: [
              ?footerLeading,
              Expanded(
                child: Text(
                  app.intl.common.stepOf(n: current + 1, total: steps.length),
                  textAlign: footerLeading == null
                      ? TextAlign.start
                      : TextAlign.end,
                  style: TextStyle(fontSize: 12, color: colors.neutral.grey4),
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ],
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: AppDialogFrame(
          color: colors.primary.backgroundForm,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width, maxHeight: 800),
            child: loadingId == null
                ? content
                : LoadingOverlay(
                    id: loadingId,
                    overlayWidgetBuilder: LoadingOverlayStyles.form,
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int i, String label, {required bool last}) {
    final colors = app.colors;
    final done = i < current;
    final on = i == current;
    final faded = colors.primary.primaryFaded;
    final step = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on
                ? colors.primary.primaryAction
                : done
                ? faded.withValues(alpha: 0.16)
                : colors.neutral.transparent,
            border: Border.all(
              color: done || on ? faded : colors.neutral.grey5,
            ),
          ),
          child: done
              ? app.assets.icons.actions.check.build(
                  size: 12,
                  color: colors.primary.primaryLight,
                )
              : Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: on ? colors.neutral.white : colors.neutral.grey4,
                  ),
                ),
        ),
        10.gap(),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on
                  ? colors.neutral.white
                  : done
                  ? colors.text.brand
                  : colors.neutral.grey4,
            ),
          ),
        ),
      ],
    );
    if (last) return step;
    return Expanded(
      child: Semantics(
        selected: on,
        child: Row(
          children: [
            // the label as wide as it is (long ones end in …), the line
            // takes the rest, up to the next step
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: step,
            ),
            10.gap(),
            Expanded(
              child: Container(
                height: 1,
                color: done ? faded : colors.neutral.grey5,
              ),
            ),
            10.gap(),
          ],
        ),
      ),
    );
  }
}

/// The question a step answers, at the top of it: *Where should backups go?*
class StepTitle extends StatelessWidget {
  final String text;

  const StepTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    );
  }
}
