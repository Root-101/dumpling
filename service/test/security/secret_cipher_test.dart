import 'package:service/dumpling.dart';
import 'package:test/test.dart';

void main() {
  final cipher = SecretCipher('a-long-random-passphrase');
  const secret = 'u8Zq3vN1xK7pR2mT9wY4bC6dF0hJ5sL8aE1gQ3iV';

  test('Should decrypt what it encrypted', () {
    final stored = cipher.encrypt(secret, associatedData: 'src_aaaa');
    expect(stored, isNot(contains(secret)));
    expect(cipher.decrypt(stored, associatedData: 'src_aaaa'), secret);
  });

  test('Should use a new nonce every time', () {
    expect(
      cipher.encrypt(secret, associatedData: 'src_aaaa'),
      isNot(cipher.encrypt(secret, associatedData: 'src_aaaa')),
    );
  });

  test('Should fail with another row id', () {
    final stored = cipher.encrypt(secret, associatedData: 'src_aaaa');
    expect(
      () => cipher.decrypt(stored, associatedData: 'src_bbbb'),
      throwsA(anything),
    );
  });

  test('Should fail with another passphrase', () {
    final stored = cipher.encrypt(secret, associatedData: 'src_aaaa');
    expect(
      () => SecretCipher('other').decrypt(stored, associatedData: 'src_aaaa'),
      throwsA(anything),
    );
  });

  test('Should fail when the stored value was altered', () {
    final stored = cipher.encrypt(secret, associatedData: 'src_aaaa');
    final altered =
        '${stored.substring(0, 20)}${stored[20] == 'A' ? 'B' : 'A'}'
        '${stored.substring(21)}';
    expect(
      () => cipher.decrypt(altered, associatedData: 'src_aaaa'),
      throwsA(anything),
    );
  });
}
