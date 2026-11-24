import 'package:dio/dio.dart';

/// In the browser the connect timer runs until the answer starts: a request
/// that waits longer for it (a connection test, whose own checks take up to
/// 10 s each) must not be cut as "offline" first. Its connect timeout becomes
/// its receive timeout when that is longer.
class BrowserTimeoutInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final receive = options.receiveTimeout;
    if (receive != null && receive > (options.connectTimeout ?? receive)) {
      options.connectTimeout = receive;
    }
    handler.next(options);
  }
}
