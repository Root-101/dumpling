import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// One of [values], side by side; null [value]: none of them (e.g. the
/// default of the workspace)
class AppSegmented<T> extends StatelessWidget {
  final List<T> values;
  final String Function(T value) labelOf;
  final T? value;
  final ValueChanged<T> onChanged;

  const AppSegmented({
    required this.values,
    required this.labelOf,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface.control,
        borderRadius: app.dimensions.radius.m,
      ),
      child: Row(
        children: [
          for (final f in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Semantics(
                  selected: f == value,
                  inMutuallyExclusiveGroup: true,
                  child: TextButton(
                    onPressed: () => onChanged(f),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: EdgeInsets.zero,
                      backgroundColor: f == value
                          ? colors.brand.primarySelected
                          : Colors.transparent,
                      foregroundColor: f == value
                          ? colors.text.primary
                          : colors.text.muted,
                      textStyle: TextStyle(
                        fontFamily: AppText.sans,
                        fontSize: 12,
                        fontWeight: f == value
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Text(labelOf(f)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
