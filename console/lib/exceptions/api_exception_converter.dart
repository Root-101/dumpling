import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class ApiExceptionConverter {
  static GlobalException parse(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return GlobalException(
          type: GlobalExceptionType.general,
          message: app.intl.errors.requestCancelled,
        );
      case DioExceptionType.connectionTimeout:
        return GlobalException(
          type: GlobalExceptionType.offline,
          message: app.intl.errors.connectionTimeout,
        );
      case DioExceptionType.transformTimeout:
        return GlobalException(
          type: GlobalExceptionType.offline,
          message: app.intl.errors.noConnection,
        );
      case DioExceptionType.unknown:
        return GlobalException(
          type: GlobalExceptionType.offline,
          message: app.intl.errors.noConnection,
        );
      case DioExceptionType.receiveTimeout:
        return GlobalException(
          type: GlobalExceptionType.general,
          message: app.intl.errors.receiveTimeout,
        );
      case DioExceptionType.sendTimeout:
        return GlobalException(
          type: GlobalExceptionType.general,
          message: app.intl.errors.sendTimeout,
        );
      case DioExceptionType.badCertificate:
        return GlobalException(
          type: GlobalExceptionType.general,
          message: app.intl.errors.badCertificate,
        );
      case DioExceptionType.connectionError:
        // the service is down or unreachable (its errors, 401 too, come
        // with CORS headers, so they are bad responses)
        return GlobalException(
          type: GlobalExceptionType.offline,
          message: app.intl.errors.noConnection,
        );
      case DioExceptionType.badResponse:
        return _parseBadResponse(error);
    }
  }

  static GlobalException _parseBadResponse(DioException error) {
    if (error.response!.statusCode == 422) {
      return GlobalException(
        type: GlobalExceptionType.validation,
        message: app.intl.errors.validation,
        // A Problem Details with the list in `violations`
        data: ((error.response!.data as Map)['violations'] as List<dynamic>)
            .map(
              (json) => ValidationError.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
      );
    } else if (error.response!.statusCode == 401) {
      // A wrong username or password, or a session that expired
      return GlobalException(
        type: GlobalExceptionType.auth,
        message: _message(error.response!.data),
        data: error.response!.data,
      );
    } else if (error.response!.statusCode == 404) {
      return GlobalException(
        type: GlobalExceptionType.notFound,
        message: _message(error.response!.data),
        data: error.response!.data,
      );
    } else if (error.response!.statusCode == 409) {
      return GlobalException(
        type: GlobalExceptionType.conflict,
        message: _message(error.response!.data),
        data: error.response!.data,
      );
    } else if (error.response!.statusCode! >= 500) {
      return GlobalException(
        type: GlobalExceptionType.general,
        message: app.intl.errors.server,
        data: error.response!.data,
      );
    } else {
      return GlobalException(
        type: GlobalExceptionType.general,
        message: _message(error.response!.data),
        data: error.response!.data,
      );
    }
  }

  /// Every error of the service is a Problem Details (RFC 9457): the text for
  /// the user is its `detail`.
  /// Without one, its `title` (the status); anything else as plain text
  static String _message(dynamic data) {
    if (data is Map) {
      for (final key in const ['detail', 'title']) {
        if (data[key] is String) return data[key] as String;
      }
    }
    return data?.toString() ?? '';
  }
}
