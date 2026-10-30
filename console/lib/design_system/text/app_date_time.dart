import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A time in UTC, the one the service runs on, with the local one smaller
/// under it. [label] wraps the UTC one (`Last run {time}`)
class AppDateTime extends StatelessWidget {
  final DateTime time;
  final String Function(String time)? label;
  final CrossAxisAlignment alignment;
  final TextStyle? style;

  const AppDateTime({
    required this.time,
    this.label,
    this.alignment = CrossAxisAlignment.end,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final format = app.dateFormatter.time;
    final utc = app.intl.time.utc(time: format.format(time.toUtc()));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        Text(
          label?.call(utc) ?? utc,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ?? TextStyle(fontSize: 12, color: app.colors.neutral.grey3),
        ),
        Text(
          app.intl.time.local(time: format.format(time.toLocal())),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: app.colors.neutral.grey4),
        ),
      ],
    );
  }
}
