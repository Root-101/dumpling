import 'package:console/app_exporter.dart';

class BackupsInit {
  static Future init() async {
    BackupsCubit cubit = BackupsCubit(
      auth: app.di.find(),
      repo: app.di.find(),
      configs: app.di.find(),
      runs: app.di.find(),
    );
    app.di.put(cubit);
  }
}
