import 'package:console/app_exporter.dart';

class CanvasInit {
  static Future init() async {
    CanvasClient client = CanvasClient(app.di.find());
    app.di.put(client);

    CanvasRepo repo = CanvasRepo(client);
    app.di.put(repo);

    CanvasCubit cubit = CanvasCubit(
      auth: app.di.find(),
      repo: repo,
      sources: app.di.find(),
      destinations: app.di.find(),
    );
    app.di.put(cubit);
  }
}
