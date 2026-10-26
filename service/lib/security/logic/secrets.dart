import 'dart:convert';
import 'dart:math';

import 'package:service/dumpling.dart';

/// The write-only values (passwords, secret keys) of sources and destinations:
/// one encrypted JSON per row, bound to its id.
class Secrets {
  static const String _idAlphabet = 'abcdefghijklmnopqrstuvwxyz234567';
  static const int _idRandomLength = 16;
  static final Random _random = Random.secure();

  final SecretCipher cipher;

  Secrets() : cipher = di.find();

  String encrypt(String id, Map<String, String> secrets) =>
      cipher.encrypt(jsonEncode(secrets), associatedData: id);

  Map<String, String> decrypt(String id, String stored) => (jsonDecode(
    cipher.decrypt(stored, associatedData: id),
  ) as Map<String, dynamic>).cast<String, String>();

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

  /// [prefix] and 16 random base32 characters (`src_k3x…`): no 0, 1, 8 or 9,
  /// which read like letters.
  static String newId(String prefix) =>
      prefix +
      String.fromCharCodes([
        for (var i = 0; i < _idRandomLength; i++)
          _idAlphabet.codeUnitAt(_random.nextInt(_idAlphabet.length)),
      ]);
}
