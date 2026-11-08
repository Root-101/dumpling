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

  /// On a small tag of its own, the button inside (beside a title)
  final bool tag;

  /// A [tag] without its background, in the grey of what is secondary: for
  /// a line of a row that is already tinted
  final bool plain;

  const AppCopyId({
    required this.id,
    required this.tooltip,
    this.fontSize = 12,
    this.color,
    this.tag = false,
    this.plain = false,
    super.key,
  });

  void _copy() {
    Clipboard.setData(ClipboardData(text: id));
    app.snack.showSuccess(
      message: app.intl.common.copied,
      context: app.context,
    );
  }

  @override
  Widget build(BuildContext context) =>
      tag || plain ? _buildTag() : _buildLine();

  Widget _buildTag() => Container(
    height: plain ? 22 : 26,
    padding: plain ? null : const EdgeInsets.only(left: 8, right: 2),
    decoration: plain
        ? null
        : BoxDecoration(
            color: app.colors.surface.control,
            borderRadius: BorderRadius.circular(6),
          ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        // a SelectableText takes all the width it is offered: as wide as the id
        IntrinsicWidth(
          child: SelectableText(
            id,
            maxLines: 1,
            style: AppText.mono.copyWith(
              fontSize: fontSize,
              color:
                  color ??
                  (plain ? app.colors.neutral.grey4 : app.colors.text.brand),
            ),
          ),
        ),
        // PrimaryButton's padding doesn't fit in a tag
        Tooltip(
          message: tooltip,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _copy,
              borderRadius: BorderRadius.circular(5),
              child: SizedBox.square(
                dimension: 22,
                child: Center(
                  child: app.assets.icons.actions.duplicate.build(
                    size: 13,
                    color: plain
                        ? app.colors.neutral.grey4
                        : app.colors.neutral.grey3,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildLine() => Row(
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
        onPressed: _copy,
      ),
    ],
  );
}
