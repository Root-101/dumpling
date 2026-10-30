import 'package:console/app_exporter.dart';

class RunsInit {
  static Future init() async {
    RunClient client = RunClient(app.di.find());
    app.di.put(client);

    RunRepo repo = RunRepo(client);
    app.di.put(repo);

    RunCubit cubit = RunCubit(repo, app.di.find());
    app.di.put(cubit);
  }
}
