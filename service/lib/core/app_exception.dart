import 'package:service/dumpling.dart';

/// A business error: its [ErrorCode] (the `code` member of the Problem
/// Details) and the message in the language of the request (`detail`).
class AppException extends ApiException {
  final ErrorCode errorCode;

  AppException(
    this.errorCode,
    String detail, {
    Map<String, Object?> extensions = const {},
    super.headers,
  }) : super(
         errorCode.status,
         detail: detail,
         extensions: {...extensions, 'code': errorCode.code},
       );
}
