import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

/// A [DioException] as a [GlobalException]: the cause as a code (to be
/// translated by `intlMessage`), and for an answer of the service its status,
/// its stable `code` and its `detail` (already in the console's language).
class ApiExceptionConverter {
  static GlobalException parse(DioException error) => switch (error.type) {
    DioExceptionType.cancel => _of(
      GlobalExceptionType.general,
      GlobalExceptionCode.cancelled,
      'Request cancelled',
    ),
    // The service is down or unreachable (its errors, 401 too, come with CORS
    // headers, so they are bad responses)
    DioExceptionType.connectionTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.unknown ||
    DioExceptionType.connectionError => _of(
      GlobalExceptionType.offline,
      GlobalExceptionCode.noConnection,
      "Can't reach the service",
    ),
    DioExceptionType.receiveTimeout => _of(
      GlobalExceptionType.general,
      GlobalExceptionCode.receiveTimeout,
      'Receive timeout',
    ),
    DioExceptionType.sendTimeout => _of(
      GlobalExceptionType.general,
      GlobalExceptionCode.sendTimeout,
      'Send timeout',
    ),
    DioExceptionType.badCertificate => _of(
      GlobalExceptionType.general,
      GlobalExceptionCode.badCertificate,
      'Bad certificate',
    ),
    DioExceptionType.badResponse => _parseBadResponse(error),
  };

  static GlobalException _of(
    GlobalExceptionType type,
    GlobalExceptionCode code,
    String message,
  ) => GlobalException(type: type, code: code, message: message);

  static GlobalException _parseBadResponse(DioException error) {
    final response = error.response!;
    final status = response.statusCode!;
    final data = response.data;
    final errorCode = data is Map && data['code'] is String
        ? data['code'] as String
        : null;
    GlobalException answer(
      GlobalExceptionType type, {
      Object? payload,
      GlobalExceptionCode code = GlobalExceptionCode.custom,
      String? message,
    }) => GlobalException(
      type: type,
      code: code,
      message: message ?? _detail(data),
      data: payload ?? data,
      statusCode: status,
      errorCode: errorCode,
    );

    return switch (status) {
      // A Problem Details with the list in `violations`
      422 => answer(
        GlobalExceptionType.validation,
        code: GlobalExceptionCode.validation,
        message: 'Validation error',
        payload: ((data as Map)['violations'] as List<dynamic>)
            .map(
              (json) => ValidationError.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      ),
      // A wrong username or password, or a session that expired
      401 => answer(GlobalExceptionType.auth),
      // The sign-in locked after too many failures: how long, from Retry-After
      429 => answer(
        GlobalExceptionType.tooManyRequests,
        payload: switch (int.tryParse(
          response.headers.value('retry-after') ?? '',
        )) {
          final int seconds => Duration(seconds: seconds),
          null => null,
        },
      ),
      404 => answer(GlobalExceptionType.notFound),
      409 => answer(GlobalExceptionType.conflict),
      >= 500 => answer(
        GlobalExceptionType.general,
        code: GlobalExceptionCode.serverError,
        message: 'Server error',
      ),
      _ => answer(GlobalExceptionType.general),
    };
  }

  /// Every error of the service is a Problem Details (RFC 9457): the text for
  /// the user is its `detail`. Without one, its `title` (the status);
  /// anything else as plain text
  static String _detail(dynamic data) {
    if (data is Map) {
      for (final key in const ['detail', 'title']) {
        if (data[key] is String) return data[key] as String;
      }
    }
    return data?.toString() ?? '';
  }
}
