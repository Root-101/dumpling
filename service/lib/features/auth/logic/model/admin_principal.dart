import 'package:service/dumpling.dart';

/// The admin, signed in with a token: who, and until when (its `exp`).
class AdminPrincipal {
  final String username;
  final DateTime expireAt;

  const AdminPrincipal({required this.username, required this.expireAt});

  /// The admin of [request]; null for an API key or nobody.
  static AdminPrincipal? of(RequestEntity request) {
    final principal = request.securityContext.authentication?.principal;
    return principal is AdminPrincipal ? principal : null;
  }

  @override
  String toString() => username;
}
