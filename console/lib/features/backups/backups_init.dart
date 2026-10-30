import 'package:console/app_exporter.dart';

class BackupsInit {
  static Future init() async {
    BackupCubit cubit = BackupCubit(
      app.di.find(),
      app.di.find(),
      app.di.find(),
      app.di.find(),
    );
    app.di.put(cubit);
  }
}
