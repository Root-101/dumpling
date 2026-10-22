import 'package:console/app_exporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

// fvm flutter analyze
// fvm flutter build web   (the service serves console/build/web)
void main() {
  // so the .push method of go_router updates the URL
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();

  // the canvas has its own right-click menu
  if (kIsWeb) BrowserContextMenu.disableContextMenu();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Dumpling',
      theme: ThemeConfig.theme,
      routerConfig: RouteConfig.router,
    );
  }
}

AppGlobal app = AppGlobal();

class AppGlobal {
  static final AppGlobal _instance = AppGlobal._internal();

  AppGlobal._internal();

  factory AppGlobal() => _instance;

  AppColors colors = AppColors();

  AppDimensions dimensions = AppDimensions();

  AppAssets assets = AppAssets();
}
