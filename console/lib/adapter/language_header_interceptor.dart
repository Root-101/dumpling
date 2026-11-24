import 'package:dio/dio.dart';

/// Sends the language of the console on every request (`Accept-Language`):
/// the service answers its errors in it. It understands `es` and `en`; any
/// other gets English.
class LanguageHeaderInterceptor extends Interceptor {
  /// Code of the current language (`es`, `en`), read on every request
  final String Function() languageCode;

  LanguageHeaderInterceptor({required this.languageCode});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Accept-Language'] = languageCode();
    handler.next(options);
  }
}
