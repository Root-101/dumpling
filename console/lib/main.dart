import 'package:console/app_exporter.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher, kIsWeb;
import 'package:flutter/material.dart' as old;
import 'package:flutter/services.dart' show BrowserContextMenu;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:material_ui/material_ui.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final String loadingOverlayGlobalId = 'app-global-loading';

// generate code
// fvm dart run slang

// fvm flutter analyze
// fvm flutter run -d chrome --web-port=8081
// fvm flutter build web   (the service serves console/build/web)
class Init {
  Init._();

  static final instance = Init._();

  /// The features, with the splash shown for at least a second meanwhile
  Future<void> initialize() async {
    await Future.wait([
      FeaturesInit.init(),
      Future<void>.delayed(const Duration(seconds: 1)),
    ]);
  }
}

void main() {
  // so the .push method of go_router updates the URL
  GoRouter.optionURLReflectsImperativeAPIs = true;

  WidgetsFlutterBinding.ensureInitialized();
  // Nothing unexpected goes unseen: to the browser console
  FlutterError.onError = (details) =>
      app.logger.e(details.exceptionAsString(), stackTrace: details.stack);
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    app.logger.e('Unhandled error', error: error, stackTrace: stackTrace);
    return true;
  };
  // Until the saved one loads: the browser's language, if it is one of ours
  AppIntl.current = AppIntl.resolve(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  );
  // the right click is the canvas's own menu, not the browser's
  if (kIsWeb) BrowserContextMenu.disableContextMenu();

  runApp(const Startup());
}

/// The splash while [Init] runs; the console once it is done, or what failed
/// with «Try again»
class Startup extends StatefulWidget {
  const Startup({super.key});

  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  late Future<void> _init = Init.instance.initialize();

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _init,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const SplashScreen();
      }
      if (snapshot.hasError) {
        app.logger.e(
          'The console could not start',
          error: snapshot.error,
          stackTrace: snapshot.stackTrace,
        );
        return InitErrorScreen(
          onRetry: () => setState(() => _init = Init.instance.initialize()),
        );
      }
      return MultiBlocProvider(
        providers: [...FeaturesInit.blocProviders],
        child: const App(),
      );
    },
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
            theme: AppTheme.dark,
            locale: locale,
            localizationsDelegates: AppIntl.delegates,
            supportedLocales: AppIntl.supportedLocales,
            builder: (context, child) =>
                Scaffold(body: Center(child: Text(app.intl.app.needMoreSpace))),
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
            onGenerateTitle: (context) => app.intl.app.name,
            theme: AppTheme.dark,
            locale: locale,
            routerConfig: RouteConfig.router,
            localizationsDelegates: AppIntl.delegates,
            supportedLocales: AppIntl.supportedLocales,
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
  static const String version = '0.1.7';

  BuildContext get context => navigatorKey.currentContext!;

  ThemeData get theme => Theme.of(context);

  TextTheme get textTheme => theme.textTheme;

  /// Texts of the current language (`AppIntl.current`, set by `LanguageCubit`)
  AppTexts get intl => AppIntl.texts;

  LoadingOverlayController loading = LoadingOverlayController();

  DI di = DI();

  NavigatorHelper navigator = NavigatorHelper();

  AppDimensions dimensions = AppDimensions();

  AppColors colors = AppColors();

  AppTextStyles styles = AppTextStyles();

  AppAssets assets = AppAssets();

  DateFormatter dateFormatter = DateFormatter();

  StorageFormatter storageFormatter = StorageFormatter();

  SnackBarAdapter snack = SnackBarAdapter();

  DialogHelper dialog = DialogHelper();

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  /// Unexpected errors and warnings, to the browser console
  Logger logger = Logger(printer: SimplePrinter(printTime: true));
}
