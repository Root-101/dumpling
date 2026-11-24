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
      if (state is AuthLogoutState) {
        await _resetCubits();
      }
      if (state is AuthExpiredState) {
        SessionExpiredDialog.open();
      }
    });
  }

  static Future<void> _resetCubits() async {
    app.di.find<WorkspaceCubit>().reset();
    app.di.find<SourceCubit>().reset();
    app.di.find<DestinationCubit>().reset();
    app.di.find<CanvasCubit>().reset();
    app.di.find<RunCubit>().reset();
    app.di.find<BackupCubit>().reset();
    app.di.find<ApiKeyCubit>().reset();
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
    BlocProvider<WorkspaceCubit>(
      create: (context) => app.di.find<WorkspaceCubit>(),
    ),
    // SOURCES: of the open workspace
    BlocProvider<SourceCubit>(create: (context) => app.di.find<SourceCubit>()),
    // DESTINATIONS: of the open workspace
    BlocProvider<DestinationCubit>(
      create: (context) => app.di.find<DestinationCubit>(),
    ),
    // CANVAS: of the open workspace
    BlocProvider<CanvasCubit>(create: (context) => app.di.find<CanvasCubit>()),
    // RUNS: the run log of the open workspace
    BlocProvider<RunCubit>(create: (context) => app.di.find<RunCubit>()),
    // BACKUPS: the home of the open workspace
    BlocProvider<BackupCubit>(create: (context) => app.di.find<BackupCubit>()),
    // API KEYS: of the open workspace
    BlocProvider<ApiKeyCubit>(create: (context) => app.di.find<ApiKeyCubit>()),
  ];
}
