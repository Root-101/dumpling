import 'package:service/dumpling.dart';

/// Authenticates a request made with an API key, after [JwtFilter]: `Bearer
/// dmp_…`, or Basic auth with the key id as the user and its secret as the
/// password. A wrong key counts as a failed login of its IP (the same wait and
/// lock), so keys can't be guessed faster than the password.
class ApiKeyFilter extends Filter {
  static final ApiKeyFilter _instance = ApiKeyFilter._();

  late final ApiKeyService keys;
  late final LoginRateLimiter rateLimiter;

  ApiKeyFilter._() {
    keys = ApiKeyService();
    rateLimiter = di.find();
  }

  factory ApiKeyFilter() => _instance;

  @override
  Future<ResponseEntity> doFilter(
    RequestEntity request,
    FilterChain chain,
  ) async {
    final header = request.headers[HttpHeader.authorization];
    final credentials = header == null
        ? null
        : header.startsWith('Bearer ')
        ? ApiKeyToken.parse(header.substring(7))
        : header.startsWith('Basic ')
        ? ApiKeyToken.parseBasic(header.substring(6))
        : null;
    if (credentials == null) return chain.doFilter(request);

    final client = clientIdOf(request);
    final locked = rateLimiter.lockedFor(client);
    if (locked != null) {
      throw TooManyRequestsException(
        detail: intl.errors.auth.tooManyLoginAttempts,
        retryAfter: (locked.inMilliseconds / 1000).ceil(),
      );
    }
    final (id, secret) = credentials;
    final found = await keys.authenticate(id, secret);
    if (found == null) {
      // The IP and the id it tried, never the secret
      logger.warning('Wrong API key', fields: {'client': client, 'key': id});
      await rateLimiter.failed(client);
      request.securityContext.clear();
    } else {
      final (principal, permissions) = found;
      request.securityContext.setAuthentication(
        Authentication<Object>(principal: principal, permissions: permissions),
      );
    }
    return chain.doFilter(request);
  }

  /// Only while the request is not authenticated yet, as [JwtFilter].
  @override
  bool shouldFilter(RequestEntity request) {
    return !request.securityContext.isAuthenticated;
  }

  @override
  String toString() {
    return 'ApiKeyFilter()';
  }
}
