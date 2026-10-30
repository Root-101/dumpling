import 'package:console/app_exporter.dart';

class CanvasInit {
  static Future init() async {
    CanvasClient client = CanvasClient(app.di.find());
    app.di.put(client);

    CanvasRepo repo = CanvasRepo(client);
    app.di.put(repo);

    CanvasCubit cubit = CanvasCubit(
      repo,
      app.di.find(),
      app.di.find(),
      app.di.find(),
    );
    app.di.put(cubit);
  }
}
