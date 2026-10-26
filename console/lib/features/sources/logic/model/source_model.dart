import 'package:console/app_exporter.dart';

/// The kinds of source the service knows. Only [postgres] works today; the
/// others show as coming soon
abstract class SourceTypes {
  static const String postgres = 'postgres';
}

/// What a PostgreSQL source connects to (never the password)
class PostgresSettingsModel {
  static const int defaultPort = 5432;
  static const String custom = 'custom';
  static const String plain = 'plain';

  final String host;
  final int port;
  final String database;
  final String username;

  /// [custom] (`pg_dump -Fc`) or [plain] (SQL)
  final String dumpFormat;

  const PostgresSettingsModel({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.dumpFormat,
  });

  /// `pg-prod-01.internal:5432/orders`
  String get address => '$host:$port/$database';
}

/// A database to back up. [postgres] is null for a type this console can't
/// read the settings of
class SourceModel {
  final String id;
  final String name;
  final String type;
  final PostgresSettingsModel? postgres;

  /// Null until its connection is tested the first time
  final ConnectionCheckModel? lastCheck;

  const SourceModel({
    required this.id,
    required this.name,
    required this.type,
    this.postgres,
    this.lastCheck,
  });

  SourceModel withCheck(ConnectionCheckModel check) => SourceModel(
    id: id,
    name: name,
    type: type,
    postgres: postgres,
    lastCheck: check,
  );
}

class SourceTypeModel {
  final String type;
  final bool enabled;

  const SourceTypeModel({required this.type, required this.enabled});
}

/// What the form sends. With [connectionUrl] the service reads the
/// connection from it; otherwise from the fields. An empty [password] keeps
/// the saved one when editing
class SourceDraft {
  final String name;
  final String type;
  final String? connectionUrl;
  final String host;
  final int? port;
  final String database;
  final String username;
  final String? password;
  final String dumpFormat;

  const SourceDraft({
    required this.name,
    required this.type,
    this.connectionUrl,
    this.host = '',
    this.port,
    this.database = '',
    this.username = '',
    this.password,
    this.dumpFormat = PostgresSettingsModel.custom,
  });
}
