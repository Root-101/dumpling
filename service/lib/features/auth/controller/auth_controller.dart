import 'package:service/dumpling.dart';

class AuthController {
  final AuthService authService;

  AuthController() : authService = di.find();

  /// Per client IP (an IPv6 by its /64), as the general limit; behind your
  /// own proxies, see TRUSTED_PROXIES.
  Future<ResponseEntity> login(RequestEntity request) async =>
      ResponseEntity.ok(
        body: await authService.login(
          clientIdOf(request),
          () => request.body<LoginRequest>(),
        ),
      );

  /// Who is signed in and until when; only the admin's token reaches it.
  Future<ResponseEntity> session(RequestEntity request) async {
    final admin = AdminPrincipal.of(request)!;
    return ResponseEntity.ok(
      body: SessionResponse(username: admin.username, expireAt: admin.expireAt),
    );
  }
}
