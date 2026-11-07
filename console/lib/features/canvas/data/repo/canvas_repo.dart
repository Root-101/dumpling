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

  Future<LastRun> runNow({
    required String workspace,
    required String configId,
    String? token,
  }) async {
    try {
      final json = await _client.runNow(
        workspace: workspace,
        configId: configId,
        token: token,
      );
      return LastRun.fromJson(json);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<LastRun> run({
    required String workspace,
    required String id,
    String? token,
  }) async {
    try {
      final json = await _client.run(
        workspace: workspace,
        id: id,
        token: token,
      );
      return LastRun.fromJson(json);
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
        lastRun: last == null ? null : LastRun.fromJson(last),
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
      order: {
        for (final (i, s) in sources.indexed) s['id'] as String: i,
        for (final (i, d) in destinations.indexed) d['id'] as String: i,
      },
    );
  }
}

extension CanvasDataMapping on CanvasData {
  /// Every source and destination (those off the canvas without position,
  /// so they are kept) and only the complete configs: the service rejects
  /// an orphan one, and leaving it out deletes it
  CanvasRequest toRequest() {
    Map<String, double> position(Offset p) => {'x': p.dx, 'y': p.dy};
    // on the canvas or off it, each list keeps its order; new ones last
    List<(T, bool)> inOrder<T>(
      List<T> placed,
      List<T> pool,
      String Function(T) id,
    ) {
      final all = [
        for (final n in placed) (n, true),
        for (final n in pool) (n, false),
      ];
      int rank(int i) => order[id(all[i].$1)] ?? order.length + i;
      final indexes = [for (var i = 0; i < all.length; i++) i]
        ..sort((a, b) => rank(a).compareTo(rank(b)));
      return [for (final i in indexes) all[i]];
    }

    return CanvasRequest(
      sources: [
        for (final (s, placed) in inOrder(sources, sourcePool, (s) => s.id))
          {
            'id': s.id,
            'position': placed ? position(s.pos) : null,
            'name': s.name,
            'type': s.type,
            'settings': s.settings,
          },
      ],
      destinations: [
        for (final (d, placed) in inOrder(
          destinations,
          destinationPool,
          (d) => d.id,
        ))
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
