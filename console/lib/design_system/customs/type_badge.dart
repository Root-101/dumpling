import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The look of a kind of source or destination: its abbreviation and colors
class TypeLook {
  final String abbr;
  final Color color;

  const TypeLook(this.abbr, this.color);

  Color get tint => color.withValues(alpha: 0.16);
}

/// Square with the abbreviation of a type (`PG`, `S3`) on its tint
class TypeBadge extends StatelessWidget {
  final TypeLook look;
  final double size;

  const TypeBadge({required this.look, this.size = 30, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: look.tint,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Text(
        look.abbr,
        style: TextStyle(
          fontSize: size * 0.34,
          fontWeight: FontWeight.w700,
          color: look.color,
        ),
      ),
    );
  }
}

/// A type to pick in a form (`01 TYPE`): the selected one is outlined, one
/// not available yet is dimmed with *Soon*
class TypeTile extends StatelessWidget {
  final TypeLook look;
  final String label;
  final String sub;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const TypeTile({
    required this.look,
    required this.label,
    required this.sub,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final faded = app.colors.primary.primaryFaded;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AppFocusRing(
          borderRadius: radius,
          child: Material(
            color: selected
                ? faded.withValues(alpha: 0.10)
                : app.colors.primary.background2,
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: selected ? faded : app.colors.neutral.grey5,
                width: selected ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: radius,
              mouseCursor: enabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.forbidden,
              onTap: enabled ? onTap : null,
              // grows past the height of the design with a larger font
              child: Container(
                constraints: const BoxConstraints(minHeight: 84),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TypeBadge(look: look, size: 28),
                        const Spacer(),
                        if (!enabled || selected) _buildBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: app.colors.neutral.grey4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled
            ? app.colors.primary.primaryFaded.withValues(alpha: 0.2)
            : app.colors.surface.control,
        borderRadius: app.dimensions.border.borderRadius.xs,
      ),
      child: Text(
        enabled ? app.intl.common.selected : app.intl.common.soon,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: enabled
              ? app.colors.primary.primaryLight
              : app.colors.neutral.grey3,
        ),
      ),
    );
  }
}

/// Title of a section of a form drawer: `01 TYPE`
class FormSectionTitle extends StatelessWidget {
  final String text;

  const FormSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: app.colors.primary.primaryFaded,
      ),
    );
  }
}
