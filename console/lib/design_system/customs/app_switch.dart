import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A settings row: title, help and a switch on the right
class AppSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final VoidCallback onChanged;

  const AppSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Semantics(
      toggled: value,
      child: InkWell(
        onTap: onChanged,
        borderRadius: app.dimensions.radius.s,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: colors.text.subtle),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 34,
                height: 20,
                padding: const EdgeInsets.all(3),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: value
                      ? colors.brand.primaryAction
                      : colors.surface.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.text.primary,
                    shape: BoxShape.circle,
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
