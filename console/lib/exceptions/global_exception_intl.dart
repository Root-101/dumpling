import 'package:console/app_exporter.dart';

extension GlobalExceptionIntl on GlobalException {
  /// The text to show, in the current language: [GlobalException.message]
  /// when it comes from the service, otherwise translated by its code
  String get intlMessage => switch (code) {
    GlobalExceptionCode.custom => message,
    GlobalExceptionCode.cancelled => app.intl.errors.requestCancelled,
    GlobalExceptionCode.receiveTimeout => app.intl.errors.receiveTimeout,
    GlobalExceptionCode.sendTimeout => app.intl.errors.sendTimeout,
    GlobalExceptionCode.badCertificate => app.intl.errors.badCertificate,
    // Dumpling is self-hosted: what failed is the service, not the internet
    GlobalExceptionCode.noConnection => app.intl.errors.offline(
      url: Environment.serviceUrl,
    ),
    GlobalExceptionCode.validation => app.intl.errors.validation,
    GlobalExceptionCode.serverError => app.intl.errors.server,
    GlobalExceptionCode.unknown => app.intl.errors.unknown,
  };
}
