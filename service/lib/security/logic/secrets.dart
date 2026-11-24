import 'dart:convert';
import 'dart:math';

import 'package:service/dumpling.dart';

/// The write-only values (passwords, secret keys) of sources and destinations:
/// one encrypted JSON per row, bound to its id.
class Secrets {
  static const String _idAlphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  static const int _idRandomLength = 16;
  static final Random _random = Random.secure();

  /// Compares [given] with [expected] without stopping at the first
  /// difference (nor at a different length): the time gives nothing away.
  static bool sameText(String given, String expected) {
    final a = utf8.encode(given);
    final b = utf8.encode(expected);
    var diff = a.length ^ b.length;
    for (var i = 0; i < b.length; i++) {
      diff |= (i < a.length ? a[i] : 0) ^ b[i];
    }
    return diff == 0;
  }

  final SecretCipher cipher;

  Secrets() : cipher = di.find();

  String encrypt(String id, Map<String, String> secrets) =>
      cipher.encrypt(jsonEncode(secrets), associatedData: id);

  Map<String, String> decrypt(String id, String stored) => (jsonDecode(
    cipher.decrypt(stored, associatedData: id),
  ) as Map<String, dynamic>).cast<String, String>();

  /// The stored secrets of row [id] for an edit, or none when they don't
  /// decrypt (`SECRETS_ENCRYPTION_KEY` changed): [require] then asks for them
  /// again (422) instead of every edit failing.
  Map<String, String> decryptOrNone(String id, String stored) {
    try {
      return decrypt(id, stored);
    } on Exception {
      return const {};
    }
  }

  /// The stored secrets of row [id], to fill the ones a request leaves out,
  /// only while they would go where they were saved for: [saved] is the
  /// stored settings (their JSON) and [target] the `target` of the request's.
  /// Another host, database, user or bucket gets none, so a [require] asks
  /// for them again (422): a stored password never goes to a server the
  /// request picks.
  Map<String, String> storedFor(
    String id,
    String encrypted, {
    required String saved,
    required Map<String, Object?> target,
  }) {
    final before = jsonDecode(saved) as Map<String, dynamic>;
    final same = target.entries.every(
      (e) => jsonEncode(before[e.key]) == jsonEncode(e.value),
    );
    return same ? decryptOrNone(id, encrypted) : const {};
  }

  /// [secrets], or a 422 naming each of [required] that is missing
  /// (`settings.password`, under [field]).
  static Map<String, String> require(
    List<String> required,
    Map<String, String> secrets, {
    String field = 'settings',
  }) {
    final context = ConstraintValidatorContext();
    for (final name in required) {
      context.field('$field.$name', secrets[name]).notNull();
    }
    context.throwOnFailure();
    return secrets;
  }

  /// Whether [a] and [b] hold the same secrets: their encrypted forms always
  /// differ (a random nonce each time), so only the plain ones compare.
  static bool same(Map<String, String> a, Map<String, String> b) =>
      a.length == b.length && a.entries.every((e) => b[e.key] == e.value);

  /// [prefix] and 16 random base32 characters (`src_k3x…`): no 0, 1, 8 or 9,
  /// which read like letters.
  static String newId(String prefix) =>
      prefix +
      String.fromCharCodes([
        for (var i = 0; i < _idRandomLength; i++)
          _idAlphabet.codeUnitAt(_random.nextInt(_idAlphabet.length)),
      ]);
}
