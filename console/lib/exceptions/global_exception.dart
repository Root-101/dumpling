enum GlobalExceptionType {
  general,
  auth,
  validation,
  conflict,

  /// A 404: what was asked for (a workspace, a run…) does not exist
  notFound,

  /// The service could not be reached
  offline,
}

class GlobalException<T> implements Exception {
  final GlobalExceptionType type;
  final String message;
  final T? data;

  GlobalException({required this.type, required this.message, this.data});

  @override
  String toString() {
    return 'GlobalException{type: $type, message: $message, data: $data}';
  }
}
