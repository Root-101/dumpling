// ignore_for_file: non_constant_identifier_names
import 'dart:js_interop';

import 'package:web/web.dart' as web;

@JS('window.env')
external EnvConfig? get env;

@JS()
@staticInterop
class EnvConfig {}

extension EnvConfigExtension on EnvConfig {
  external String? get SERVICE_URL;
}

class Environment {
  /// `SERVICE_URL` of `web/env.js` when the console runs apart (local); without
  /// it, the origin of the page: in the release the service serves the console
  static String get serviceUrl {
    final url = env?.SERVICE_URL;
    if (url == null || url.isEmpty) return web.window.location.origin;
    return url.startsWith('http') ? url : 'https://$url';
  }
}
