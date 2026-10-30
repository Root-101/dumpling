import 'package:console/app_exporter.dart';

class SourcesInit {
  static Future init() async {
    SourceClient client = SourceClient(app.di.find());
    app.di.put(client);

    SourceRepo repo = SourceRepo(client);
    app.di.put(repo);

    SourceCubit cubit = SourceCubit(repo, app.di.find(), app.di.find());
    app.di.put(cubit);
  }
}
