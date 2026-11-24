import 'package:console/app_exporter.dart';

class RunsInit {
  static Future init() async {
    RunsClient client = RunsClient(app.di.find());
    app.di.put(client);

    RunsRepo repo = RunsRepo(client);
    app.di.put(repo);

    RunsCubit cubit = RunsCubit(repo, app.di.find());
    app.di.put(cubit);
  }
}
