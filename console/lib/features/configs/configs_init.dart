import 'package:console/app_exporter.dart';

class ConfigsInit {
  static Future init() async {
    ConfigsClient client = ConfigsClient(app.di.find());
    app.di.put(client);

    ConfigsRepo repo = ConfigsRepo(client: client);
    app.di.put(repo);
  }
}
