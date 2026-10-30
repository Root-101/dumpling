import 'package:console/app_exporter.dart';

class WorkspacesInit {
  static Future init() async {
    WorkspaceClient client = WorkspaceClient(app.di.find());
    app.di.put(client);

    WorkspaceRepo repo = WorkspaceRepo(client, storage: app.di.find());
    app.di.put(repo);

    // App-wide: the rail shows the current workspace on every screen
    WorkspaceCubit cubit = WorkspaceCubit(repo, app.di.find());
    await cubit.restore();
    app.di.put(cubit);
  }
}
