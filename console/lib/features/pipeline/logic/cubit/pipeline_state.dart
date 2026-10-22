import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class PipelineState {
  final List<SourceNode> sources;
  final List<BackupConfig> configs;
  final List<DestinationNode> destinations;
  final String? selectedId;

  /// To make unique ids of new configs and folders
  final int seq;

  /// What the toolbar adds next (the PoC has no forms to create them)
  final List<SourceNode> sourcePool;
  final List<DestinationNode> destinationPool;

  const PipelineState({
    required this.sources,
    required this.configs,
    required this.destinations,
    required this.sourcePool,
    required this.destinationPool,
    this.selectedId,
    this.seq = 1,
  });

  BackupConfig? get selected {
    for (final c in configs) {
      if (c.id == selectedId) return c;
    }
    return null;
  }

  SourceNode? source(String id) => _find(sources, id, (s) => s.id);

  DestinationNode? destination(String id) =>
      _find(destinations, id, (d) => d.id);

  /// A source always keeps at least one config
  bool canDelete(BackupConfig c) =>
      configs.where((x) => x.sourceId == c.sourceId).length > 1;

  static T? _find<T>(List<T> list, String id, String Function(T) idOf) {
    for (final x in list) {
      if (idOf(x) == id) return x;
    }
    return null;
  }

  PipelineState copyWith({
    List<SourceNode>? sources,
    List<BackupConfig>? configs,
    List<DestinationNode>? destinations,
    String? Function()? selectedId,
    int? seq,
    List<SourceNode>? sourcePool,
    List<DestinationNode>? destinationPool,
  }) => PipelineState(
    sources: sources ?? this.sources,
    configs: configs ?? this.configs,
    destinations: destinations ?? this.destinations,
    selectedId: selectedId != null ? selectedId() : this.selectedId,
    seq: seq ?? this.seq,
    sourcePool: sourcePool ?? this.sourcePool,
    destinationPool: destinationPool ?? this.destinationPool,
  );

  /// The default pipeline of the proof of concept
  factory PipelineState.demo() => const PipelineState(
    selectedId: 'j1',
    sources: [
      SourceNode(
        id: 'orders',
        name: 'orders-db',
        engine: 'PostgreSQL 16',
        size: '12.4 GB',
        abbr: 'PG',
        pos: Offset(40, 130),
      ),
      SourceNode(
        id: 'users',
        name: 'users-db',
        engine: 'PostgreSQL 15',
        size: '3.1 GB',
        abbr: 'PG',
        pos: Offset(40, 300),
      ),
      SourceNode(
        id: 'media',
        name: 'media-assets',
        engine: 'S3 · MinIO',
        size: '9.6 GB',
        abbr: 'S3',
        pos: Offset(40, 470),
      ),
    ],
    destinations: [
      DestinationNode(
        id: 'bb',
        bucket: 'bucket-backups',
        provider: 'AWS S3 · us-east-1',
        pos: Offset(760, 88),
        folders: [
          DestinationFolder(id: 'orders', path: '/orders', meta: '30 kept'),
          DestinationFolder(id: 'users', path: '/users', meta: '14 d'),
        ],
      ),
      DestinationNode(
        id: 'ca',
        bucket: 'cold-archive',
        provider: 'Cloudflare R2 · auto',
        pos: Offset(760, 484),
      ),
    ],
    configs: [
      BackupConfig(
        id: 'j1',
        sourceId: 'orders',
        destinationId: 'bb',
        folderId: 'orders',
        pos: Offset(380, 98),
        name: 'Nightly full',
        frequency: Frequency.daily,
        time: '02:00',
        cron: '0 2 * * *',
        human: 'Every day at 02:00',
        last: '20/Oct 02:06 · 1.8 GB',
        lastStatus: RunStatus.success,
        next: '21/Oct 02:00',
        nextIn: 'in 12 h',
        objectKey: '{yyyy}/{MM}/{dd}.dump.gz',
        compression: 'gzip · level 6',
        retention: 'Last 30',
      ),
      BackupConfig(
        id: 'j2',
        sourceId: 'users',
        destinationId: 'bb',
        folderId: 'users',
        pos: Offset(380, 268),
        name: 'Nightly',
        frequency: Frequency.daily,
        time: '02:30',
        cron: '30 2 * * *',
        human: 'Every day at 02:30',
        last: '20/Oct 02:31 · timeout',
        lastStatus: RunStatus.failed,
        next: '21/Oct 02:30',
        nextIn: 'in 13 h',
        objectKey: '{yyyy-MM-dd}.sql.zst',
        compression: 'zstd · level 3',
        retention: '14 days',
      ),
      BackupConfig(
        id: 'j3',
        sourceId: 'media',
        destinationId: 'ca',
        folderId: null,
        pos: Offset(380, 438),
        name: 'Weekly archive',
        frequency: Frequency.weekly,
        time: '03:00',
        cron: '0 3 * * 0',
        human: 'Sundays at 03:00',
        last: '18/Oct 03:41 · 9.6 GB',
        lastStatus: RunStatus.success,
        next: '25/Oct 03:00',
        nextIn: 'in 5 d',
        objectKey: 'media-assets-{yyyy}-W{ww}.tar.zst',
        compression: 'zstd · level 3',
        retention: '1 year',
      ),
    ],
    sourcePool: [
      SourceNode(
        id: 'billing',
        name: 'billing-db',
        engine: 'PostgreSQL 15',
        size: '860 MB',
        abbr: 'PG',
      ),
      SourceNode(
        id: 'inventory',
        name: 'inventory-db',
        engine: 'MySQL 8.4',
        size: '2.2 GB',
        abbr: 'MY',
      ),
      SourceNode(
        id: 'logs',
        name: 'app-logs',
        engine: 'S3 · AWS',
        size: '3.4 GB',
        abbr: 'S3',
      ),
    ],
    destinationPool: [
      DestinationNode(
        id: 'br',
        bucket: 'backups-replica',
        provider: 'MinIO · on-prem',
      ),
      DestinationNode(
        id: 'la',
        bucket: 'logs-archive',
        provider: 'AWS S3 · eu-west-1',
      ),
    ],
  );
}
