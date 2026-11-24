import 'package:console/app_exporter.dart';

/// What kind of failure: decides where the console shows it.
enum GlobalExceptionType {
  general,
  auth,
  validation,
  conflict,

  /// A 404: what was asked for (a workspace, a run…) does not exist
  notFound,

  /// The service could not be reached
  offline,

  /// A 429: the sign-in is locked for a while; `data`, the [Duration] left
  tooManyRequests,
}

/// The cause without text, for [GlobalExceptionIntl.intlMessage] to say it in
/// the current language. [custom]: the `message` can be shown as it is (the
/// `detail` the service sent, already in the console's language); for the
/// rest `message` is only an English fallback for the logs.
enum GlobalExceptionCode {
  custom,
  cancelled,
  receiveTimeout,
  sendTimeout,
  badCertificate,

  /// The service could not be reached (down, wrong URL, timed out connecting)
  noConnection,
  validation,
  serverError,
  unknown,
}

class GlobalException<T> implements Exception {
  final GlobalExceptionType type;

  /// English fallback for the logs; shown only when [code] is
  /// [GlobalExceptionCode.custom] (the service's `detail`). Show
  /// [GlobalExceptionIntl.intlMessage].
  final String message;
  final T? data;
  final GlobalExceptionCode code;

  /// HTTP status, when the error is an answer of the service
  final int? statusCode;

  /// The stable `code` of the service's Problem Details (`sources.inUse`),
  /// the same in every language: what to compare to decide (see
  /// [ApiErrorCode]), never the text
  final String? errorCode;

  GlobalException({
    required this.type,
    required this.message,
    this.data,
    this.code = GlobalExceptionCode.custom,
    this.statusCode,
    this.errorCode,
  });

  /// The service answered with [apiCode]: in its `code`, or in one of the
  /// violations of a 422
  bool hasCode(String apiCode) =>
      errorCode == apiCode ||
      (data is List<ValidationError> &&
          (data as List<ValidationError>).any(
            (error) => error.code == apiCode,
          ));

  @override
  String toString() {
    return 'GlobalException{type: $type, code: $code, statusCode: $statusCode, errorCode: $errorCode, message: $message, data: $data}';
  }
}
