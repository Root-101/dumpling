import 'package:console/app_exporter.dart';

class ConfigsInit {
  static Future init() async {
    ConfigClient client = ConfigClient(app.di.find());
    app.di.put(client);

    ConfigRepo repo = ConfigRepo(client);
    app.di.put(repo);
  }
}
