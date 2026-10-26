import 'package:console/app_exporter.dart';

/// A workspace with sensible defaults; each test changes only what it checks
WorkspaceModel workspace(
  String slug, {
  String? name,
  int configs = 0,
  int destinations = 0,
  int failing = 0,
  int running = 0,
  DateTime? lastRunAt,
}) => WorkspaceModel(
  slug: slug,
  name: name ?? slug,
  description: 'About $slug',
  stats: WorkspaceStatsModel(
    sources: configs,
    destinations: destinations,
    configs: configs,
    failing: failing,
    running: running,
    lastRunAt: lastRunAt,
  ),
);

const sourceTypes = [
  SourceTypeModel(type: SourceTypes.postgres, enabled: true),
  SourceTypeModel(type: 'mysql', enabled: false),
];

const destinationTypes = [
  DestinationTypeModel(type: DestinationTypes.s3, enabled: true),
  DestinationTypeModel(type: 'gdrive', enabled: false),
];

/// A PostgreSQL source whose id, name and database are [id]
SourceModel source(String id, {ConnectionCheckModel? lastCheck}) => SourceModel(
  id: id,
  name: '$id-db',
  type: SourceTypes.postgres,
  postgres: PostgresSettingsModel(
    host: '$id.internal',
    port: 5432,
    database: id,
    username: 'dumpling_backup',
    dumpFormat: PostgresSettingsModel.custom,
  ),
  lastCheck: lastCheck,
);

/// An S3 destination whose id, name and bucket are [id]
DestinationModel destination(
  String id, {
  List<String> folders = const [],
  ConnectionCheckModel? lastCheck,
}) => DestinationModel(
  id: id,
  name: id,
  type: DestinationTypes.s3,
  s3: S3SettingsModel(
    endpoint: 'https://s3.us-east-1.amazonaws.com',
    region: 'us-east-1',
    bucket: id,
    accessKeyId: 'AKIA',
    pathStyle: false,
  ),
  folders: folders,
  lastCheck: lastCheck,
);

/// A backup of [sourceId] into [destinationId]
ConfigModel config(String sourceId, String destinationId, {String? folder}) =>
    ConfigModel(
      id: 'cfg_$sourceId',
      name: sourceId,
      sourceId: sourceId,
      destinationId: destinationId,
      folder: folder,
    );

ConnectionCheckModel check(CheckStatus status) => ConnectionCheckModel(
  status: status,
  checkedAt: DateTime.utc(2026, 10, 20),
  serverVersion: '16.4',
  message: status == CheckStatus.failed ? 'connection refused' : null,
);

/// The session every cubit reads its token from
AuthModel session() => AuthModel(accessToken: 'jwt', expireAt: DateTime(2100));

/// An error as the repos throw it (already converted)
GlobalException apiError([String message = 'boom']) =>
    GlobalException(type: GlobalExceptionType.general, message: message);
