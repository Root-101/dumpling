import 'package:console/app_exporter.dart';

class DestinationsInit {
  static Future init() async {
    DestinationClient client = DestinationClient(app.di.find());
    app.di.put(client);

    DestinationRepo repo = DestinationRepo(client);
    app.di.put(repo);

    DestinationCubit cubit = DestinationCubit(
      repo,
      app.di.find(),
      app.di.find(),
    );
    app.di.put(cubit);
  }
}
