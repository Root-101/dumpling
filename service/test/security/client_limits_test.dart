@TestOn('vm')
library;

import 'dart:convert';
import 'dart:io';

import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../support/test_server.dart';

void main() {
  final server = TestServer(port: 8189);

  setUpAll(() async {
    Dumpling.requestTimeout = const Duration(seconds: 2);
    await server.start();
  });
  tearDownAll(server.stop);

  test('Should cut a login whose body never arrives', () async {
    final socket = await Socket.connect(InternetAddress.loopbackIPv4, 8189);
    addTearDown(socket.destroy);
    socket.write(
      'POST /api/auth/login HTTP/1.1\r\n'
      'Host: localhost\r\n'
      'Content-Type: application/json\r\n'
      'Content-Length: 1000\r\n\r\n{',
    );
    final answer = await utf8.decoder
        .bind(socket)
        .join()
        .timeout(const Duration(seconds: 10));
    expect(answer, startsWith('HTTP/1.1 503'));
  });

  test('Should trust X-Forwarded-For only from private addresses', () {
    bool private(String ip) => isPrivateAddress(InternetAddress(ip));
    for (final ip in [
      '127.0.0.1',
      '10.1.2.3',
      '172.17.0.1',
      '192.168.1.10',
      '169.254.0.1',
      '::1',
      'fd12::1',
      'fe80::1',
      '::ffff:192.168.0.2',
    ]) {
      expect(private(ip), isTrue, reason: ip);
    }
    for (final ip in [
      '8.8.8.8',
      '172.32.0.1',
      '11.0.0.1',
      '2001:db8::1',
      '::ffff:8.8.8.8',
    ]) {
      expect(private(ip), isFalse, reason: ip);
    }
  });
}
