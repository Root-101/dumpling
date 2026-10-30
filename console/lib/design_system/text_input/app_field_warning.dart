import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Under a field: a value that is allowed but worth changing. It never blocks
/// saving, unlike an error
class AppFieldWarning extends StatelessWidget {
  final String text;

  const AppFieldWarning(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = app.colors.status.warning;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.warning_amber_rounded, size: 14, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: app.textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
