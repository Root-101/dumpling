import 'package:console/app_exporter.dart';

class SourcesInit {
  static Future init() async {
    SourcesClient client = SourcesClient(app.di.find());
    app.di.put(client);

    SourcesRepo repo = SourcesRepo(client: client);
    app.di.put(repo);

    SourcesCubit cubit = SourcesCubit(
      auth: app.di.find(),
      repo: repo,
      configs: app.di.find(),
    );
    app.di.put(cubit);
  }
}
