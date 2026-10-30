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

  /// As tall as the screen, but 32 above and below, whatever the step;
  /// otherwise as tall as the step up to 800
  final bool fullHeight;

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
    this.fullHeight = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    final line = BorderSide(color: colors.neutral.grey5.withValues(alpha: 0.5));
    final content = Column(
      mainAxisSize: fullHeight ? MainAxisSize.max : MainAxisSize.min,
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
          fit: fullHeight ? FlexFit.tight : FlexFit.loose,
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
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: fullHeight ? 32 : 48,
        ),
        child: AppDialogFrame(
          color: colors.primary.backgroundForm,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width,
              maxHeight: fullHeight ? double.infinity : 800,
            ),
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

/// What the steps before chose, at the top of a step: [items] in a row of
/// [slots] cells, the ones left over empty so each keeps its width
class StepSummary extends StatelessWidget {
  final List<(String label, String value)> items;
  final int slots;

  const StepSummary(this.items, {this.slots = 3, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: app.dimensions.padding.sm,
      children: [
        for (var i = 0; i < slots; i++)
          Expanded(
            child: i < items.length
                ? SummaryCell(label: items[i].$1, value: items[i].$2)
                : const SizedBox(),
          ),
      ],
    );
  }
}

/// A value with its label, in monospace: *Host · pg-billing.internal*
class SummaryCell extends StatelessWidget {
  final String label;
  final String value;

  const SummaryCell({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: app.colors.primary.background2,
        borderRadius: app.dimensions.border.borderRadius.s,
        border: Border.all(
          color: app.colors.neutral.grey5.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: app.colors.neutral.grey4),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppText.monoFamily,
              fontSize: 12,
              color: app.colors.neutral.grey2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Line between the [StepSummary] and the step, across the dialog's padding
class StepDivider extends StatelessWidget {
  const StepDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: app.dimensions.padding.xl),
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          height: 1,
          child: OverflowBox(
            // the 20 of padding of the body on each side
            minWidth: constraints.maxWidth + 40,
            maxWidth: constraints.maxWidth + 40,
            child: ColoredBox(
              color: app.colors.neutral.grey5.withValues(alpha: 0.5),
            ),
          ),
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
