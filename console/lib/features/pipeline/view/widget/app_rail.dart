import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// Main navigation. In the PoC only the pipeline exists; the rest are inert
class AppRail extends StatelessWidget {
  const AppRail({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = app.colors;
    Widget item(
      AppIcons icon,
      String label, {
      bool active = false,
      int? badge,
    }) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          AppIconButton(
            size: 44,
            tooltip: label,
            background: active ? colors.brand.primarySelected : null,
            onPressed: () {},
            icon: AppIcon(
              icon,
              color: active ? colors.text.primary : colors.text.muted,
            ),
          ),
          if (badge != null)
            Positioned(
              right: 4,
              top: 4,
              child: IgnorePointer(
                child: Container(
                  constraints: const BoxConstraints(minWidth: 16),
                  height: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.brand.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.surface.background,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface.surface1,
        border: Border(right: BorderSide(color: colors.surface.border)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.brand.primary.withValues(alpha: 0.10),
              borderRadius: app.dimensions.radius.m,
            ),
            child: const DumplingLogo(),
          ),
          const SizedBox(height: 6),
          item(AppIcons.backups, 'Backups'),
          item(AppIcons.pipeline, 'Pipeline editor', active: true),
          item(AppIcons.database, 'Sources'),
          item(AppIcons.bucket, 'Destinations'),
          item(AppIcons.events, 'Events', badge: 2),
          const Spacer(),
          item(AppIcons.settings, 'Settings'),
        ],
      ),
    );
  }
}
