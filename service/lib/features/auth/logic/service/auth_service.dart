import 'package:service/dumpling.dart';

/// The sign-in of the admin: the credentials of the env, the lock after too
/// many failures and the token.
class AuthService {
  /// A token lasts 12 hours and there is no refresh: then the console asks to
  /// sign in again.
  static const Duration tokenDuration = Duration(hours: 12);

  final JwtService jwtService;
  final LoginRateLimiter rateLimiter;

  AuthService() : jwtService = di.find(), rateLimiter = di.find();

  /// Signs [client] in with the body [read] gives. The lock is checked before
  /// reading it and again after: requests that passed the first check while
  /// their bodies were held back would each get a guess past the lock.
  Future<LoginResponse> login(
    String client,
    Future<LoginRequest> Function() read,
  ) async {
    _checkLock(client);
    final request = await read();
    // Nothing awaits from here to the count of the failure: it is atomic
    _checkLock(client);

    // Always both comparisons, without stopping at the first different
    // character: the response time gives nothing away
    final validUser = Secrets.sameText(request.username!, env.adminUser);
    final validPassword = Secrets.sameText(
      request.password!,
      env.adminPassword,
    );
    if (!validUser || !validPassword) {
      // The client, never what was typed
      logger.warning('Failed login', fields: {'client': client});
      await rateLimiter.failed(client);
      throw AppException(
        ErrorCode.authInvalidCredentials,
        intl.errors.auth.invalidCredentials,
      );
    }
    rateLimiter.succeeded(client);

    final expireAt = utcNow().add(tokenDuration);
    final token = jwtService.generateToken({
      'sub': request.username,
      // The admin can do everything
      'permissions': Permissions.all,
      'exp': expireAt.millisecondsSinceEpoch ~/ 1000,
    });
    return LoginResponse(
      accessToken: token,
      expiresIn: tokenDuration.inMilliseconds,
      expireAt: expireAt,
    );
  }

  void _checkLock(String client) {
    final locked = rateLimiter.lockedFor(client);
    if (locked != null) {
      throw AppException(
        ErrorCode.authTooManyLoginAttempts,
        intl.errors.auth.tooManyLoginAttempts,
        headers: {'Retry-After': '${(locked.inMilliseconds / 1000).ceil()}'},
      );
    }
  }
}
