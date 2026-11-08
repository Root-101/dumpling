import 'package:console/app_exporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An id (a slug, `cfg_…`, `run_…`) in monospace, selectable, with a button
/// that copies it: what the API asks for, without the browser's dev tools.
class AppCopyId extends StatelessWidget {
  final String id;

  /// What the button copies, for its tooltip and screen readers
  final String tooltip;
  final double fontSize;
  final Color? color;

  const AppCopyId({
    required this.id,
    required this.tooltip,
    this.fontSize = 12,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 2,
    children: [
      Flexible(
        child: SelectableText(
          id,
          maxLines: 1,
          style: AppText.mono.copyWith(
            fontSize: fontSize,
            color: color ?? app.colors.neutral.grey2,
          ),
        ),
      ),
      PrimaryButton.svgIcon(
        icon: app.assets.icons.actions.duplicate,
        tooltipMessage: tooltip,
        backgroundColor: app.colors.neutral.transparent,
        iconColor: app.colors.neutral.grey3,
        buttonSize: 30,
        iconSize: 13,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: id));
          app.snack.showSuccess(
            message: app.intl.common.copied,
            context: app.context,
          );
        },
      ),
    ],
  );
}
