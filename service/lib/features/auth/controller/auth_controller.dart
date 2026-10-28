import 'dart:convert';

import 'package:service/dumpling.dart';

class AuthController {
  /// A token lasts 12 hours and there is no refresh: then the console asks to
  /// sign in again.
  static const Duration tokenDuration = Duration(hours: 12);

  final JwtService jwtService;
  final LoginRateLimiter rateLimiter;

  AuthController() : jwtService = di.find(), rateLimiter = di.find();

  Future<ResponseEntity> login(RequestEntity request) async {
    // Per IP (an IPv6 by its /64), as the general limit; behind your own
    // proxies, see TRUSTED_PROXIES
    final client = clientIdOf(request);
    void checkLock() {
      final locked = rateLimiter.lockedFor(client);
      if (locked != null) {
        throw TooManyRequestsException(
          detail: intl.errors.auth.tooManyLoginAttempts,
          retryAfter: (locked.inMilliseconds / 1000).ceil(),
        );
      }
    }

    checkLock();
    try {
      final loginReq = await request.body<LoginRequest>();
      // Again once the body is read: requests that passed the first check
      // while their bodies were held back would each get a guess past the lock.
      // Nothing awaits from here to the count of the failure, so it is atomic
      checkLock();

      // Always both comparisons, without stopping at the first different
      // character: the response time gives nothing away
      final validUser = _sameText(loginReq.username, env.adminUser);
      final validPassword = _sameText(loginReq.password, env.adminPassword);
      if (!validUser || !validPassword) {
        // The IP, never what was typed
        logger.warning('Failed login', fields: {'client': client});
        await rateLimiter.failed(client);
        throw UnauthorizedException(
          detail: intl.errors.auth.invalidCredentials,
        );
      }
      rateLimiter.succeeded(client);

      final expireAt = DateTime.now().add(tokenDuration);
      final token = jwtService.generateToken({
        'sub': loginReq.username,
        // The admin can do everything
        'permissions': Permissions.all,
        'exp': expireAt.millisecondsSinceEpoch ~/ 1000,
      });

      return ResponseEntity.ok(
        body: LoginResponse(
          accessToken: token,
          expiresIn: tokenDuration.inMilliseconds,
          expireAt: expireAt,
        ),
      );
    } catch (e) {
      // A body that isn't the expected JSON keeps its 400 with the field
      if (e is ApiException || e is DeserializationException) rethrow;
      throw BadRequestException(detail: intl.errors.auth.invalidLoginRequest);
    }
  }

  Future<ResponseEntity> session(RequestEntity request) async {
    final token = request.headers[HttpHeader.authorization]!.substring(7);
    // Already verified by JwtFilter: only its claims are read here
    final payload = jwtService.verifyToken(token)!;
    return ResponseEntity.ok(
      body: SessionResponse(
        username: payload['sub'] as String,
        expireAt: DateTime.fromMillisecondsSinceEpoch(
          (payload['exp'] as int) * 1000,
        ),
      ),
    );
  }

  /// Compares without stopping at the first difference.
  static bool _sameText(String given, String expected) {
    final a = utf8.encode(given);
    final b = utf8.encode(expected);
    var diff = a.length ^ b.length;
    for (var i = 0; i < b.length; i++) {
      diff |= (i < a.length ? a[i] : 0) ^ b[i];
    }
    return diff == 0;
  }
}
