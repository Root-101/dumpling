import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart' show Offset;

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

/// A canvas node of a PostgreSQL source whose id and database are [id]
SourceNode sourceNode(String id, [Offset pos = Offset.zero]) => SourceNode(
  id: id,
  name: '$id-db',
  type: SourceTypes.postgres,
  settings: {
    'host': '$id.internal',
    'port': 5432,
    'database': id,
    'username': 'dumpling_backup',
    'dump_format': PostgresSettingsModel.custom,
  },
  pos: pos,
);

/// A canvas node of an S3 destination whose id, name and bucket are [id]
DestinationNode destinationNode(
  String id, {
  List<String> folders = const [],
  Offset pos = Offset.zero,
}) => DestinationNode(
  id: id,
  name: id,
  type: DestinationTypes.s3,
  settings: {
    'endpoint': 'https://s3.us-east-1.amazonaws.com',
    'region': 'us-east-1',
    'bucket': id,
    'access_key_id': 'AKIA',
    'path_style': false,
  },
  folders: folders,
  pos: pos,
);

/// Three complete flows: orders → j1 → bb/orders, users → j2 → bb/users and
/// media → j3 → the root of ca. Off the canvas: the source billing and the
/// destination br
CanvasModel demoCanvas() => CanvasModel(
  sources: [
    sourceNode('orders', const Offset(40, 130)),
    sourceNode('users', const Offset(40, 300)),
    sourceNode('media', const Offset(40, 470)),
  ],
  sourcePool: [sourceNode('billing')],
  destinations: [
    destinationNode(
      'bb',
      folders: ['orders', 'users'],
      pos: const Offset(760, 88),
    ),
    destinationNode('ca', pos: const Offset(760, 484)),
  ],
  destinationPool: [destinationNode('br')],
  configs: const [
    BackupConfig(
      id: 'j1',
      sourceId: 'orders',
      destinationId: 'bb',
      folderId: 'orders',
      pos: Offset(380, 98),
      name: 'Nightly full',
      schedule: '0 2 * * *',
      compression: 'gzip',
      objectKey: '{yyyy}/{MM}/{dd}',
    ),
    BackupConfig(
      id: 'j2',
      sourceId: 'users',
      destinationId: 'bb',
      folderId: 'users',
      pos: Offset(380, 268),
      name: 'Nightly',
      schedule: '30 2 * * *',
      compression: 'gzip',
      objectKey: '{yyyy}-{MM}-{dd}',
    ),
    BackupConfig(
      id: 'j3',
      sourceId: 'media',
      destinationId: 'ca',
      folderId: null,
      pos: Offset(380, 438),
      name: 'Weekly archive',
      schedule: '0 3 * * 0',
      compression: 'none',
      objectKey: '{db}/{yyyy}-{MM}-{dd}',
    ),
  ],
);

/// A run of the backup [config] that started on 20/Oct 02:14 UTC; [log]
/// makes it the detail
RunModel run(
  String id, {
  String config = 'Nightly orders',
  RunStatus status = RunStatus.success,
  String sourceType = 'postgres',
  String destinationType = 's3',
  List<String>? log,
}) {
  final started = DateTime.utc(2026, 10, 20, 2, 14);
  return RunModel(
    id: id,
    configId: 'cfg_$id',
    configName: config,
    sourceName: 'orders-db',
    sourceType: sourceType,
    destinationName: 'bucket',
    destinationType: destinationType,
    trigger: 'schedule',
    status: status,
    startedAt: started,
    finishedAt: status == RunStatus.running
        ? null
        : started.add(const Duration(minutes: 3, seconds: 5)),
    sizeBytes: status == RunStatus.success ? 5 * 1024 * 1024 : null,
    location: 's3://bucket/orders/$id.dump.gz',
    error: status == RunStatus.failed ? 'pg_dump: connection refused' : null,
    log: log == null ? null : [for (final m in log) RunLogLine(started, m)],
  );
}
