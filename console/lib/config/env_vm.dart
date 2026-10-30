/// Outside the browser there is no `window.env`: `--dart-define`s or the local
/// default
class Environment {
  static String get serviceUrl => const String.fromEnvironment(
    'SERVICE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
