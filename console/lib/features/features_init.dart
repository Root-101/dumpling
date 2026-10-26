import 'dart:io';

import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class FeaturesInit {
  static Future<void> init() async {
    FlutterSecureStorage storage = const FlutterSecureStorage(
      webOptions: WebOptions(publicKey: 'dumpling'),
    );
    app.di.put(storage);

    Dio dio = Dio();
    dio
      ..options.connectTimeout = const Duration(seconds: 10)
      ..options.receiveTimeout = const Duration(seconds: 10)
      ..options.headers = {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
      };
    useBrowserHttpAdapter(dio);
    dio.interceptors.add(
      InterceptorsWrapper(
        // The service translates its error messages to the app's language
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          final language = Intl.defaultLocale;
          if (language != null) {
            options.headers[HttpHeaders.acceptLanguageHeader] = language;
          }
          return handler.next(options);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          // A wrong password at login is a 401 too, but there is no session
          // to close then
          final auth = app.di.find<AuthCubit>();
          if (e.response?.statusCode == 401 && auth.auth != null) {
            auth.logout();
          }
          return handler.next(e);
        },
      ),
    );
    app.di.put(dio);

    await AuthInit.init();
    await LanguageInit.init();
    await WorkspacesInit.init();

    // Listen for logout to reset other cubits
    app.di.find<AuthCubit>().stream.listen((state) async {
      if (state is AuthLogoutState) {
        await _resetCubits();
      }
    });
  }

  static Future<void> _resetCubits() async {
    app.di.find<WorkspaceCubit>().reset();
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
  ];
}
