import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// The screens of a workspace that aren't built yet: each one has its route,
/// so the rail and the links already work
class SectionScreen extends StatelessWidget {
  static const List<String> sections = [RouteNames.settings];

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
    final workspace = context.select<WorkspaceCubit, String?>(
      (c) => c.state.data.current?.name,
    );
    return ColoredBox(
      color: app.colors.primary.background2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: titleOf(section),
            workspace: workspace,
            description: section == RouteNames.settings
                ? app.intl.nav.settingsDescription
                : null,
          ),
          Expanded(
            child: PagePanel(
              child: NoDataPage(
                title: titleOf(section),
                description: app.intl.nav.comingSoon,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
