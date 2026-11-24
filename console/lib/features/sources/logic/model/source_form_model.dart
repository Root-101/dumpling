import 'package:console/app_exporter.dart';

/// What the form sends. With [connectionUrl] the service reads the
/// connection from it; otherwise from the fields. An empty [password] keeps
/// the saved one when editing
class SourceFormModel {
  final String name;
  final String type;
  final String? connectionUrl;
  final String host;
  final int? port;
  final String database;
  final String username;
  final String? password;
  final String dumpFormat;
  final String sslMode;

  const SourceFormModel({
    required this.name,
    required this.type,
    this.connectionUrl,
    this.host = '',
    this.port,
    this.database = '',
    this.username = '',
    this.password,
    this.dumpFormat = PostgresSettingsModel.custom,
    this.sslMode = PostgresSettingsModel.sslRequire,
  });
}
