import 'package:console/app_exporter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';

class WorkspaceRepo {
  static const String _lastKey = 'workspaces.last';

  final WorkspaceClient _client;
  final FlutterSecureStorage storage;

  WorkspaceRepo(this._client, {required this.storage});

  Future<List<WorkspaceModel>> list({String? token}) async {
    try {
      final response = await _client.list(token: token);
      return response.map((e) => e.toModel()).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<WorkspaceModel> create({
    required WorkspaceDraft draft,
    String? token,
  }) async {
    try {
      final response = await _client.create(
        request: draft.toRequest(),
        token: token,
      );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  /// The workspace opened last, so the rail keeps showing it on the list of
  /// workspaces and after a reload
  Future<void> saveLast(String slug) async {
    try {
      await storage.write(key: _lastKey, value: slug);
    } catch (_) {}
  }

  Future<String?> loadLast() async {
    try {
      return await storage.read(key: _lastKey);
    } catch (_) {
      return null;
    }
  }
}

extension WorkspaceResponseMapping on WorkspaceResponse {
  WorkspaceModel toModel() {
    return WorkspaceModel(
      slug: slug,
      name: name,
      description: description,
      color: color == null ? null : Color(color!),
      stats: stats == null
          ? null
          : WorkspaceStatsModel(
              sources: stats!.sources,
              destinations: stats!.destinations,
              configs: stats!.configs,
              failing: stats!.failing,
              running: stats!.running,
              lastRunAt: stats!.lastRunAt,
              preview: stats!.preview,
            ),
    );
  }
}

extension WorkspaceDraftMapping on WorkspaceDraft {
  WorkspaceRequest toRequest() {
    return WorkspaceRequest(
      name: name,
      description: description,
      color: color?.toARGB32(),
    );
  }
}
