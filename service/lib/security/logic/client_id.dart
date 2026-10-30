import 'dart:io';

import 'package:service/dumpling.dart';

/// The client of [request] for the login lock and the general limit, as
/// [defaultClientId] takes it, except that the `X-Forwarded-For` of
/// `TRUSTED_PROXIES` only counts when the connection comes from a private
/// address, where your proxy is: a client that reaches the port directly
/// from outside can't pick its own IP.
String clientIdOf(RequestEntity request) {
  final peer = request.connectionInfo?.remoteAddress;
  if (peer == null || isPrivateAddress(peer)) return defaultClientId(request);
  // The same id defaultClientId gives an address: an IPv6 by its /64
  final bytes = peer.rawAddress;
  if (bytes.length == 4 || _mapped(bytes)) return peer.address;
  final groups = [
    for (var i = 0; i < 8; i += 2)
      ((bytes[i] << 8) | bytes[i + 1]).toRadixString(16),
  ];
  return '${groups.join(':')}::/64';
}

/// Loopback, link-local, the IPv4 private ranges (`10/8`, `172.16/12`,
/// `192.168/16`) and IPv6 unique local (`fc00::/7`), IPv4-mapped too.
bool isPrivateAddress(InternetAddress address) {
  if (address.isLoopback || address.isLinkLocal) return true;
  final raw = address.rawAddress;
  final bytes = _mapped(raw) ? raw.sublist(12) : raw;
  if (bytes.length == 4) {
    return bytes[0] == 10 ||
        bytes[0] == 127 ||
        (bytes[0] == 172 && bytes[1] >= 16 && bytes[1] < 32) ||
        (bytes[0] == 192 && bytes[1] == 168) ||
        (bytes[0] == 169 && bytes[1] == 254);
  }
  return (bytes[0] & 0xFE) == 0xFC;
}

/// `::ffff:a.b.c.d`
bool _mapped(List<int> bytes) =>
    bytes.length == 16 &&
    bytes.take(10).every((b) => b == 0) &&
    bytes[10] == 0xFF &&
    bytes[11] == 0xFF;
