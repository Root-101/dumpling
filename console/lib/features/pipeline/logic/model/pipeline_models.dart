import 'package:material_ui/material_ui.dart';

enum NodeKind { source, config, destination }

enum RunStatus { success, failed, pending }

enum Frequency {
  hourly('Hourly'),
  daily('Daily'),
  weekly('Weekly'),
  cron('Cron');

  final String label;

  const Frequency(this.label);
}

/// A database to back up
class SourceNode {
  final String id;
  final String name;
  final String engine;
  final String size;

  /// Shown in the chip when there is no logo (PG, MY, S3...)
  final String abbr;
  final Offset pos;

  const SourceNode({
    required this.id,
    required this.name,
    required this.engine,
    required this.size,
    required this.abbr,
    this.pos = Offset.zero,
  });

  SourceNode copyWith({Offset? pos}) => SourceNode(
    id: id,
    name: name,
    engine: engine,
    size: size,
    abbr: abbr,
    pos: pos ?? this.pos,
  );
}

class DestinationFolder {
  final String id;
  final String path;
  final String meta;

  const DestinationFolder({
    required this.id,
    required this.path,
    required this.meta,
  });
}

/// A bucket. Without folders a config writes to its root
class DestinationNode {
  final String id;
  final String bucket;
  final String provider;
  final List<DestinationFolder> folders;
  final Offset pos;

  const DestinationNode({
    required this.id,
    required this.bucket,
    required this.provider,
    this.folders = const [],
    this.pos = Offset.zero,
  });

  DestinationNode copyWith({Offset? pos, List<DestinationFolder>? folders}) =>
      DestinationNode(
        id: id,
        bucket: bucket,
        provider: provider,
        folders: folders ?? this.folders,
        pos: pos ?? this.pos,
      );
}

/// One connection source → destination (folder), with its schedule
class BackupConfig {
  final String id;
  final String sourceId;
  final String destinationId;

  /// null: the root of the bucket
  final String? folderId;
  final Offset pos;
  final String name;
  final Frequency frequency;
  final String time;
  final String cron;
  final String human;
  final String last;
  final RunStatus lastStatus;
  final String next;
  final String nextIn;
  final String objectKey;
  final String compression;
  final String retention;

  const BackupConfig({
    required this.id,
    required this.sourceId,
    required this.destinationId,
    required this.folderId,
    required this.pos,
    required this.name,
    required this.frequency,
    required this.time,
    required this.cron,
    required this.human,
    required this.last,
    required this.lastStatus,
    required this.next,
    required this.nextIn,
    required this.objectKey,
    required this.compression,
    required this.retention,
  });

  BackupConfig copyWith({
    Offset? pos,
    String? destinationId,
    String? Function()? folderId,
    Frequency? frequency,
    String? cron,
    String? human,
    String? next,
    String? nextIn,
    String? objectKey,
  }) => BackupConfig(
    id: id,
    sourceId: sourceId,
    destinationId: destinationId ?? this.destinationId,
    folderId: folderId != null ? folderId() : this.folderId,
    pos: pos ?? this.pos,
    name: name,
    frequency: frequency ?? this.frequency,
    time: time,
    cron: cron ?? this.cron,
    human: human ?? this.human,
    last: last,
    lastStatus: lastStatus,
    next: next ?? this.next,
    nextIn: nextIn ?? this.nextIn,
    objectKey: objectKey ?? this.objectKey,
    compression: compression,
    retention: retention,
  );
}

/// Where a wire was dropped
class DropTarget {
  final String destinationId;
  final String? folderId;

  const DropTarget(this.destinationId, this.folderId);

  @override
  bool operator ==(Object other) =>
      other is DropTarget &&
      other.destinationId == destinationId &&
      other.folderId == folderId;

  @override
  int get hashCode => Object.hash(destinationId, folderId);
}
