import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FeaturesInit {
  static Future<void> init() async {
    FlutterSecureStorage storage = const FlutterSecureStorage(
      webOptions: WebOptions(publicKey: 'dumpling'),
    );
    app.di.put(storage);

    Dio dio = Dio()
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..options.headers = {Headers.contentTypeHeader: Headers.jsonContentType};
    useBrowserHttpAdapter(dio);
    dio.interceptors
      // The service answers its errors in the console's language
      ..add(
        LanguageHeaderInterceptor(
          languageCode: () => AppIntl.current.languageCode,
        ),
      )
      ..add(BrowserTimeoutInterceptor())
      ..add(
        InterceptorsWrapper(
          onError: (DioException e, ErrorInterceptorHandler handler) async {
            // A wrong password at login is a 401 too, but there is no session
            // to expire then
            final auth = app.di.find<AuthCubit>();
            if (e.response?.statusCode == 401 && auth.auth != null) {
              auth.expire();
            }
            return handler.next(e);
          },
        ),
      );
    app.di.put(dio);

    await AuthInit.init();
    await LanguageInit.init();
    // Each feature only builds its client, repo and cubits: in parallel
    await Future.wait([
      WorkspacesInit.init(),
      ConfigsInit.init(),
      SourcesInit.init(),
      DestinationsInit.init(),
      CanvasInit.init(),
      RunsInit.init(),
      BackupsInit.init(),
      ApiKeysInit.init(),
    ]);

    // Listen for logout to reset other cubits
    app.di.find<AuthCubit>().stream.listen((state) async {
      if (state is AuthLoggedOutState) {
        await _resetCubits();
      }
      if (state is AuthExpiredState) {
        SessionExpiredDialog.navigator.open();
      }
    });
  }

  static Future<void> _resetCubits() async {
    app.di.find<WorkspacesCubit>().reset();
    app.di.find<SourcesCubit>().reset();
    app.di.find<DestinationsCubit>().reset();
    app.di.find<CanvasCubit>().reset();
    app.di.find<RunsCubit>().reset();
    app.di.find<BackupsCubit>().reset();
    app.di.find<ApiKeysCubit>().reset();
    app.di.find<AuthCubit>().reset();
  }

  static List<BlocProvider> blocProviders = [
    // AUTH
    BlocProvider<AuthCubit>(create: (context) => app.di.find<AuthCubit>()),
    // LANGUAGE
    BlocProvider<LanguageCubit>(
      create: (context) => app.di.find<LanguageCubit>(),
    ),
    // WORKSPACES: the rail shows the current one on every screen
    BlocProvider<WorkspacesCubit>(
      create: (context) => app.di.find<WorkspacesCubit>(),
    ),
    // SOURCES: of the open workspace
    BlocProvider<SourcesCubit>(
      create: (context) => app.di.find<SourcesCubit>(),
    ),
    // DESTINATIONS: of the open workspace
    BlocProvider<DestinationsCubit>(
      create: (context) => app.di.find<DestinationsCubit>(),
    ),
    // CANVAS: of the open workspace
    BlocProvider<CanvasCubit>(create: (context) => app.di.find<CanvasCubit>()),
    // RUNS: the run log of the open workspace
    BlocProvider<RunsCubit>(create: (context) => app.di.find<RunsCubit>()),
    // BACKUPS: the home of the open workspace
    BlocProvider<BackupsCubit>(
      create: (context) => app.di.find<BackupsCubit>(),
    ),
    // API KEYS: of the open workspace
    BlocProvider<ApiKeysCubit>(
      create: (context) => app.di.find<ApiKeysCubit>(),
    ),
  ];
}
