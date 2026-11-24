import 'package:console/app_exporter.dart';

/// A bucket backups are written to. Each of its [folders] is a connection
/// point on the canvas; with none, the bucket root is. [s3] is null for a
/// type this console can't read the settings of
class DestinationModel {
  final String id;
  final String name;
  final String type;
  final S3SettingsModel? s3;

  /// Without slashes around them (`orders`, `eu/billing`)
  final List<String> folders;

  /// Null until its connection is tested the first time
  final ConnectionCheckModel? lastCheck;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.type,
    this.s3,
    this.folders = const [],
    this.lastCheck,
  });

  DestinationModel withCheck(ConnectionCheckModel check) => DestinationModel(
    id: id,
    name: name,
    type: type,
    s3: s3,
    folders: folders,
    lastCheck: check,
  );

  DestinationModel withFolders(List<String> folders) => DestinationModel(
    id: id,
    name: name,
    type: type,
    s3: s3,
    folders: folders,
    lastCheck: lastCheck,
  );
}
