import 'package:service/dumpling.dart';

/// `disable` sends the data in clear; `require` encrypts it without checking
/// the certificate (like `sslmode=require` of libpq).
enum PostgresSslMode { disable, require }

/// `custom` is `pg_dump -Fc` (compressed, for `pg_restore`); `plain` is SQL.
enum PostgresDumpFormat { custom, plain }

/// The connection of a PostgreSQL source, by fields or by a connection URL
/// (`postgresql://user:password@host:5432/database`): a field given apart wins
/// over the one of the URL.
class PostgresSettings implements SourceSettings {
  static const int defaultPort = 5432;
  static const String passwordKey = 'password';
  static const String connectionUrlKey = 'connection_url';

  final String? host;
  final int? port;
  final String? database;
  final String? username;
  final String? password;
  final String? dumpFormat;

  /// The URL as it came, only to name it in a violation.
  final String? connectionUrl;
  final bool invalidUrl;

  PostgresSettings({
    this.host,
    this.port,
    this.database,
    this.username,
    this.password,
    this.dumpFormat,
    this.connectionUrl,
    this.invalidUrl = false,
  });

  factory PostgresSettings.fromJson(Map<String, dynamic> json) {
    final url = json.field<String?>(connectionUrlKey);
    final parsed = url == null ? null : parseUrl(url);
    return PostgresSettings(
      host: json.field<String?>('host') ?? parsed?.host,
      port: json.field<int?>('port') ?? parsed?.port,
      database: json.field<String?>('database') ?? parsed?.database,
      username: json.field<String?>('username') ?? parsed?.username,
      password: json.field<String?>(passwordKey) ?? parsed?.password,
      dumpFormat: json.field<String?>('dump_format'),
      connectionUrl: url,
      invalidUrl: url != null && parsed == null,
    );
  }

  /// `postgresql://` or `postgres://`, each part percent-decoded; null when it
  /// isn't one. The parts it lacks stay null (the port: the default one).
  static ({
    String? host,
    int? port,
    String? database,
    String? username,
    String? password,
  })?
  parseUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        !const ['postgresql', 'postgres'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      return null;
    }
    final colon = uri.userInfo.indexOf(':');
    String? part(String value) =>
        value.isEmpty ? null : Uri.decodeComponent(value);
    return (
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      database: part(uri.path.replaceFirst('/', '')),
      username: part(
        colon < 0 ? uri.userInfo : uri.userInfo.substring(0, colon),
      ),
      password: colon < 0 ? null : part(uri.userInfo.substring(colon + 1)),
    );
  }

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field(
      connectionUrlKey,
      connectionUrl,
      sensitive: true,
    ).custom((_) => invalidUrl ? intl.errors.validations.postgresUrl : null)
    ..field('host', host?.trim()).notNull().size(min: 1, max: 255)
    ..field('port', port).min(1).max(65535)
    ..field('database', database?.trim()).notNull().size(min: 1, max: 63)
    ..field('username', username?.trim()).notNull().size(min: 1, max: 63)
    ..field(passwordKey, password, sensitive: true).size(min: 1, max: 1024)
    ..field('dump_format', dumpFormat).isEnum(PostgresDumpFormat.values);

  int get portOrDefault => port ?? defaultPort;

  // shortcut: always without SSL, and not in the API; in 0.2.0 it becomes a
  // `ssl_mode` setting of the source
  PostgresSslMode get ssl => PostgresSslMode.disable;

  PostgresDumpFormat get format => dumpFormat == null
      ? PostgresDumpFormat.custom
      : PostgresDumpFormat.values.byName(dumpFormat!);

  /// Always the fields, never the URL (it would carry the password).
  @override
  Map<String, Object?> toJson() => {
    'host': host!.trim(),
    'port': portOrDefault,
    'database': database!.trim(),
    'username': username!.trim(),
    'dump_format': format.name,
  };

  @override
  Map<String, String> get secrets => {passwordKey: ?password};

  @override
  List<String> get requiredSecrets => const [passwordKey];
}
