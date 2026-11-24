import 'package:console/app_exporter.dart';

class SourcesInit {
  static Future init() async {
    SourcesClient client = SourcesClient(app.di.find());
    app.di.put(client);

    SourcesRepo repo = SourcesRepo(client);
    app.di.put(repo);

    SourcesCubit cubit = SourcesCubit(repo, app.di.find(), app.di.find());
    app.di.put(cubit);
  }
}
