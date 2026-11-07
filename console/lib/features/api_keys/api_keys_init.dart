import 'package:console/app_exporter.dart';

class ApiKeysInit {
  static Future init() async {
    ApiKeyClient client = ApiKeyClient(app.di.find());
    app.di.put(client);

    ApiKeyRepo repo = ApiKeyRepo(client);
    app.di.put(repo);

    ApiKeyCubit cubit = ApiKeyCubit(
      repo,
      app.di.find(),
      app.di.find(),
      app.di.find(),
    );
    app.di.put(cubit);
  }
}
