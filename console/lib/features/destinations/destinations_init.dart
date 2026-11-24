import 'package:console/app_exporter.dart';

class DestinationsInit {
  static Future init() async {
    DestinationsClient client = DestinationsClient(app.di.find());
    app.di.put(client);

    DestinationsRepo repo = DestinationsRepo(client);
    app.di.put(repo);

    DestinationsCubit cubit = DestinationsCubit(
      auth: app.di.find(),
      repo: repo,
      configs: app.di.find(),
    );
    app.di.put(cubit);
  }
}
