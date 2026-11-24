import 'package:console/app_exporter.dart';

class RunsInit {
  static Future init() async {
    RunsClient client = RunsClient(app.di.find());
    app.di.put(client);

    RunsRepo repo = RunsRepo(client);
    app.di.put(repo);

    RunsCubit cubit = RunsCubit(auth: app.di.find(), repo: repo);
    app.di.put(cubit);
  }
}
