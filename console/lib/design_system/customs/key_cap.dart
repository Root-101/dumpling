import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A keyboard key in the shortcuts help
class KeyCap extends StatelessWidget {
  final String label;

  const KeyCap(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: app.colors.surface.control,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.mono.copyWith(
          fontSize: 11,
          color: app.colors.text.secondary,
        ),
      ),
    );
  }
}
