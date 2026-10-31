import 'package:console/app_exporter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' as old;
import 'package:flutter/services.dart' show BrowserContextMenu;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final String loadingOverlayGlobalId = 'app-global-loading';

/// The Material texts that `material_ui` widgets read; the app's own come from
/// `context.intl` (slang). Every MaterialApp uses these (app and splash)
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  ...GlobalMaterialLocalizations.delegates,
];

// generate code
// fvm dart run slang

// fvm flutter analyze
// fvm flutter run -d chrome --web-port=8081
// fvm flutter build web   (the service serves console/build/web)
class Init {
  Init._();

  static final instance = Init._();

  Future initialize() async {
    await FeaturesInit.init();
  }
}

void main() {
  // so the .push method of go_router updates the URL
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();
  // the right click is the canvas's own menu, not the browser's
  if (kIsWeb) BrowserContextMenu.disableContextMenu();

  runApp(
    FutureBuilder(
      future: Init.instance.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiBlocProvider(
            providers: [...FeaturesInit.blocProviders],
            child: const App(),
          );
        } else {
          return const SplashScreen();
        }
      },
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageListener(
      onLanguageChangeBuilder: (locale) {
        Size size = MediaQuery.of(context).size;
        if (size.width < 800 || size.height < 400) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeConfig.theme,
            locale: locale,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: appSupportedLocales,
            builder: (context, child) => Scaffold(
              body: Center(child: Text(context.intl.app.needMoreSpace)),
            ),
          );
        } else {
          return MaterialApp.router(
            builder: (BuildContext context, Widget? child) {
              // DateFormat uses it: dates follow the app's language
              Intl.defaultLocale = Localizations.localeOf(context)
                  .toLanguageTag();
              return LoadingOverlay(
                id: loadingOverlayGlobalId,
                overlayWidgetBuilder: LoadingOverlayStyles.global,
                child: MaterialUiCompatibilityBridge(
                  child: old.Material(
                    type: old.MaterialType.transparency,
                    child: child!,
                  ),
                ),
              );
            },
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.intl.app.name,
            theme: ThemeConfig.theme,
            locale: locale,
            routerConfig: RouteConfig.router,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: appSupportedLocales,
          );
        }
      },
    );
  }
}

AppGlobal app = AppGlobal();

class AppGlobal {
  static final AppGlobal _instance = AppGlobal._internal();

  AppGlobal._internal();

  factory AppGlobal() => _instance;

  /// The version shown under the login (the `version` of pubspec.yaml)
  static const String version = '0.1.0-rc.6';

  BuildContext get context => navigatorKey.currentContext!;

  ThemeData get theme => Theme.of(context);

  TextTheme get textTheme => theme.textTheme;

  /// Texts of the app's language; without a navigator yet (or in tests), those
  /// of `Intl.defaultLocale`, English by default
  AppMessages get intl {
    final context = navigatorKey.currentContext;
    if (context != null) return context.intl;
    return messagesOf(Locale(Intl.defaultLocale ?? 'en'));
  }

  LoadingOverlayController loading = LoadingOverlayController();

  DI di = DI();

  NavigatorHelper navigator = NavigatorHelper();

  AppDimensions dimensions = AppDimensions();

  AppColors colors = AppColors();

  AppAssets assets = AppAssets();

  DateFormatter dateFormatter = DateFormatter();

  StorageFormatter storageFormatter = StorageFormatter();

  SnackBarAdapter snack = SnackBarAdapter();

  DialogHelper dialog = DialogHelper();

  MediaQueryData get mediaQuery => MediaQuery.of(context);
}
