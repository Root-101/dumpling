import 'package:console/app_exporter.dart';

class ApiKeysInit {
  static Future init() async {
    ApiKeysClient client = ApiKeysClient(app.di.find());
    app.di.put(client);

    ApiKeysRepo repo = ApiKeysRepo(client);
    app.di.put(repo);

    ApiKeysCubit cubit = ApiKeysCubit(
      auth: app.di.find(),
      repo: repo,
      configs: app.di.find(),
      sources: app.di.find(),
      destinations: app.di.find(),
    );
    app.di.put(cubit);
  }
}
