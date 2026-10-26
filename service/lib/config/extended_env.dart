import 'package:service/dumpling.dart';

// The names of the variables, each one written only here
const String _adminUser = 'DUMPLING_ADMIN_USER';
const String _adminPassword = 'DUMPLING_ADMIN_PASSWORD';
const String _jwtSecret = 'JWT_SECRET';
const String _secretsEncryptionKey = 'SECRETS_ENCRYPTION_KEY';
const String _dataPath = 'DATA_PATH';
const String _port = 'PORT';
const String _pgDumpPath = 'PG_DUMP_PATH';
const String _trustedProxies = 'TRUSTED_PROXIES';
const String _rateLimitRequests = 'RATE_LIMIT_REQUESTS';
const String _rateLimitWindowSeconds = 'RATE_LIMIT_WINDOW_SECONDS';
const String _loginMaxFailures = 'LOGIN_MAX_FAILURES';
const String _loginLockSeconds = 'LOGIN_LOCK_SECONDS';
const String _loginFailureDelayMs = 'LOGIN_FAILURE_DELAY_MS';
const String _logLevel = 'LOG_LEVEL';
const String _logFormat = 'LOG_FORMAT';

/// The variables the service can't start without.
const List<String> requiredEnvVariables = [
  _adminUser,
  _adminPassword,
  _jwtSecret,
  _secretsEncryptionKey,
];

/// The length below which a secret is too easy to guess: the start-up warns
/// about it but still starts.
const Map<String, int> recommendedSecretLengths = {
  _adminPassword: 12,
  _jwtSecret: 32,
  _secretsEncryptionKey: 32,
};

extension ExtendedEnv on Env {
  /// The secrets shorter than [recommendedSecretLengths].
  List<String> get shortSecrets => [
    for (final MapEntry(key: name, value: min)
        in recommendedSecretLengths.entries)
      if ((find<String>(name) ?? '').length < min) name,
  ];

  /// The only user: the admin that signs in to the console.
  String get adminUser => require<String>(_adminUser);

  String get adminPassword => require<String>(_adminPassword);

  String get jwtSecret => require<String>(_jwtSecret);

  /// Encrypts the credentials of the sources and destinations in the database
  /// (see [SecretCipher]). Changing it makes every stored credential unreadable.
  String get secretsEncryptionKey => require<String>(_secretsEncryptionKey);

  /// The port of the API and the console: 8080 unless another is given.
  int get port => find<int>(_port) ?? 8080;

  /// The `pg_dump` the service runs: the one in the `PATH` unless another is
  /// given. Its version decides which servers it can dump (its own or older).
  String get pgDumpPath => find<String>(_pgDumpPath) ?? 'pg_dump';

  /// Folder of the SQLite database: `data` next to the service in
  /// development, the volume (`/data`) in the image.
  String get dataPath => find<String>(_dataPath) ?? 'data';

  /// Proxies of your own in front of the service that add their entry to
  /// `X-Forwarded-For` (`ServerConfig.trustedProxies`); with 0 (the default)
  /// the connection's IP is used.
  int get trustedProxies => find<int>(_trustedProxies) ?? 0;

  /// Requests per IP in each [rateLimitWindowSeconds] window (general limit);
  /// 0 disables it. Only the console calls the service, a few requests per
  /// screen: far above any legitimate use.
  int get rateLimitRequests => find<int>(_rateLimitRequests) ?? 600;

  /// Seconds of the general limit's window.
  int get rateLimitWindowSeconds => find<int>(_rateLimitWindowSeconds) ?? 60;

  /// Failed logins in a row that lock an IP.
  int get loginMaxFailures => find<int>(_loginMaxFailures) ?? 10;

  /// Seconds an IP stays locked after [loginMaxFailures] failures.
  int get loginLockSeconds => find<int>(_loginLockSeconds) ?? 15 * 60;

  /// Milliseconds to wait before answering a failed login.
  int get loginFailureDelayMs => find<int>(_loginFailureDelayMs) ?? 1000;

  /// The logger of the service: `LOG_FORMAT=json` writes one JSON object per
  /// line (for a log collector), anything else readable lines; `LOG_LEVEL`
  /// (`debug`, `info`, `warning`, `error`) is `info` by default.
  WinterLogger get serviceLogger {
    final level = findEnum(_logLevel, LogLevel.values) ?? LogLevel.info;
    return find<String>(_logFormat) == 'json'
        ? JsonLogger(minLevel: level)
        : ConsoleLogger(minLevel: level);
  }
}
