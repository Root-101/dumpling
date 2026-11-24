import 'package:console/app_exporter.dart';

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
