import 'package:console/app_exporter.dart';

class BackupsInit {
  static Future init() async {
    BackupsCubit cubit = BackupsCubit(
      app.di.find(),
      app.di.find(),
      app.di.find(),
      app.di.find(),
    );
    app.di.put(cubit);
  }
}
