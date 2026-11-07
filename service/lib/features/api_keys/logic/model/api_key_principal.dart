import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:service/dumpling.dart';

/// Who makes a request with an API key: the key, its workspace and the
/// configs it is limited to. The admin's principal is its name instead.
class ApiKeyPrincipal {
  final String id;
  final String name;
  final String workspace;

  /// Null when it reaches every config of the workspace.
  final Set<String>? configs;

  const ApiKeyPrincipal({
    required this.id,
    required this.name,
    required this.workspace,
    this.configs,
  });

  /// The key of [request], if it was made with one.
  static ApiKeyPrincipal? of(RequestEntity request) {
    final principal = request.securityContext.authentication?.principal;
    return principal is ApiKeyPrincipal ? principal : null;
  }

  /// The configs [request] may reach: null for all of them (the admin, or a
  /// key without a limit).
  static Set<String>? configsOf(RequestEntity request) => of(request)?.configs;

  @override
  String toString() => id;
}

/// The text of a key: `dmp_<the random part of its id>_<secret>`. Bearer
/// sends it whole; Basic auth sends the id (`key_…`) as the user and the
/// secret as the password.
abstract final class ApiKeyToken {
  static const String prefix = 'dmp_';
  static const String idPrefix = 'key_';
  static const int _secretLength = 32;
  static const String _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _random = Random.secure();

  /// A new secret: 32 characters of 62, about 190 bits.
  static String newSecret() => String.fromCharCodes([
    for (var i = 0; i < _secretLength; i++)
      _alphabet.codeUnitAt(_random.nextInt(_alphabet.length)),
  ]);

  static String of(String id, String secret) =>
      '$prefix${id.substring(idPrefix.length)}_$secret';

  static String hash(String secret) =>
      sha256.convert(utf8.encode(secret)).toString();

  /// The id and secret of a Bearer [token], or null if it isn't a key.
  static (String, String)? parse(String token) {
    if (!token.startsWith(prefix)) return null;
    final rest = token.substring(prefix.length);
    final cut = rest.indexOf('_');
    if (cut <= 0 || cut == rest.length - 1) return null;
    return ('$idPrefix${rest.substring(0, cut)}', rest.substring(cut + 1));
  }

  /// The id and secret of a Basic `Authorization` value, or null.
  static (String, String)? parseBasic(String encoded) {
    try {
      final plain = utf8.decode(base64.decode(encoded.trim()));
      final cut = plain.indexOf(':');
      if (cut <= 0) return null;
      final id = plain.substring(0, cut);
      if (!id.startsWith(idPrefix)) return null;
      return (id, plain.substring(cut + 1));
    } on FormatException {
      return null;
    }
  }
}
