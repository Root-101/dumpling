/// What a PostgreSQL source connects to (never the password)
class PostgresSettingsModel {
  static const int defaultPort = 5432;
  static const String custom = 'custom';
  static const String plain = 'plain';
  static const String sslRequire = 'require';
  static const String sslDisable = 'disable';

  final String host;
  final int port;
  final String database;
  final String username;

  /// [custom] (`pg_dump -Fc`) or [plain] (SQL)
  final String dumpFormat;

  /// [sslRequire] (TLS, the default) or [sslDisable]
  final String sslMode;

  const PostgresSettingsModel({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.dumpFormat,
    this.sslMode = sslRequire,
  });

  /// `pg-prod-01.internal:5432/orders`
  String get address => '$host:$port/$database';
}
