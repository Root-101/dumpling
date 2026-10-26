import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

class CanvasRepo {
  final CanvasClient _client;

  CanvasRepo(this._client);

  Future<CanvasModel> get({required String workspace, String? token}) async {
    try {
      final response = await _client.get(workspace: workspace, token: token);
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<CanvasModel> save({
    required String workspace,
    required CanvasData data,
    String? token,
  }) async {
    try {
      final response = await _client.save(
        workspace: workspace,
        request: data.toRequest(),
        token: token,
      );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }
}

extension CanvasResponseMapping on CanvasResponse {
  CanvasModel toModel() {
    Offset? position(Map<String, dynamic> json) {
      final p = json['position'];
      return p == null
          ? null
          : Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble());
    }

    SourceNode source(Map<String, dynamic> json) => SourceNode(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      settings: json['settings'],
      pos: position(json) ?? Offset.zero,
    );

    DestinationNode destination(Map<String, dynamic> json) => DestinationNode(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      settings: json['settings'],
      folders: (json['folders'] as List).cast<String>(),
      pos: position(json) ?? Offset.zero,
    );

    BackupConfig config(Map<String, dynamic> json) {
      final last = json['last_run'];
      final next = json['next_run'];
      return BackupConfig(
        id: json['id'],
        sourceId: json['source_id'],
        destinationId: json['destination_id'],
        folderId: json['folder'],
        // shortcut: a config the service has without position (created
        // through the API) lands at the origin; place it between its ends if
        // that ever happens outside tests
        pos: position(json) ?? Offset.zero,
        name: json['name'],
        schedule: json['schedule'],
        compression: json['compression'],
        objectKey: json['object_key'],
        enabled: json['enabled'],
        nextRun: next == null ? null : DateTime.parse(next),
        lastRun: last == null
            ? null
            : LastRun(
                status: RunStatus.values.byName(last['status']),
                startedAt: DateTime.parse(last['started_at']),
                sizeBytes: last['size_bytes'],
                error: last['error'],
              ),
      );
    }

    final placed = <String>{
      for (final node in [...sources, ...destinations])
        if (node['position'] != null) node['id'],
    };
    return CanvasModel(
      sources: [
        for (final s in sources)
          if (placed.contains(s['id'])) source(s),
      ],
      sourcePool: [
        for (final s in sources)
          if (!placed.contains(s['id'])) source(s),
      ],
      destinations: [
        for (final d in destinations)
          if (placed.contains(d['id'])) destination(d),
      ],
      destinationPool: [
        for (final d in destinations)
          if (!placed.contains(d['id'])) destination(d),
      ],
      configs: configs.map(config).toList(),
      ids: ids,
    );
  }
}

extension CanvasDataMapping on CanvasData {
  /// Every source and destination (those off the canvas without position,
  /// so they are kept) and only the complete configs: the service rejects
  /// an orphan one, and leaving it out deletes it
  CanvasRequest toRequest() {
    Map<String, double> position(Offset p) => {'x': p.dx, 'y': p.dy};
    return CanvasRequest(
      sources: [
        for (final (s, placed) in [
          for (final s in sources) (s, true),
          for (final s in sourcePool) (s, false),
        ])
          {
            'id': s.id,
            'position': placed ? position(s.pos) : null,
            'name': s.name,
            'type': s.type,
            'settings': s.settings,
          },
      ],
      destinations: [
        for (final (d, placed) in [
          for (final d in destinations) (d, true),
          for (final d in destinationPool) (d, false),
        ])
          {
            'id': d.id,
            'position': placed ? position(d.pos) : null,
            'name': d.name,
            'type': d.type,
            'settings': d.settings,
            'folders': d.folders,
          },
      ],
      configs: [
        for (final c in configs)
          if (!CanvasData.configOrphan(c))
            {
              'id': c.id,
              'position': position(c.pos),
              'name': c.name,
              'source_id': c.sourceId,
              'destination_id': c.destinationId,
              'folder': c.folderId,
              'schedule': ?c.schedule,
              'compression': ?c.compression,
              'object_key': ?c.objectKey,
              'enabled': c.enabled,
            },
      ],
    );
  }
}
