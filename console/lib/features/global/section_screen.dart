import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// The screens of a workspace that aren't built yet: each one has its route,
/// so the rail and the links already work
class SectionScreen extends StatelessWidget {
  static const List<String> sections = [
    RouteNames.backups,
    RouteNames.runs,
    RouteNames.settings,
  ];

  final String section;

  const SectionScreen({required this.section, super.key});

  static String titleOf(String section) => switch (section) {
    RouteNames.backups => app.intl.nav.backups,
    RouteNames.canvas => app.intl.nav.canvas,
    RouteNames.sources => app.intl.nav.sources,
    RouteNames.destinations => app.intl.nav.destinations,
    RouteNames.runs => app.intl.nav.runs,
    _ => app.intl.nav.settings,
  };

  @override
  Widget build(BuildContext context) {
    return NoDataPage(
      title: titleOf(section),
      description: app.intl.nav.comingSoon,
    );
  }
}
