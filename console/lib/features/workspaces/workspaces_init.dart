import 'package:console/app_exporter.dart';

class WorkspacesInit {
  static Future init() async {
    WorkspacesClient client = WorkspacesClient(app.di.find());
    app.di.put(client);

    WorkspacesRepo repo = WorkspacesRepo(client, storage: app.di.find());
    app.di.put(repo);

    // App-wide: the rail shows the current workspace on every screen
    WorkspacesCubit cubit = WorkspacesCubit(auth: app.di.find(), repo: repo);
    await cubit.restore();
    app.di.put(cubit);
  }
}
