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

  Future<WorkspaceModel> update({
    required String slug,
    required WorkspaceDraft draft,
    String? token,
  }) async {
    try {
      final response = await _client.update(
        slug: slug,
        request: draft.toRequest(),
        token: token,
      );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<void> delete({required String slug, String? token}) async {
    try {
      await _client.delete(slug: slug, token: token);
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
      defaults: defaults == null
          ? null
          : (
              schedule: defaults!['schedule'] as String,
              compression: defaults!['compression'] as String,
              objectKey: defaults!['object_key'] as String,
            ),
      createdAt: createdAt,
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
      defaults: switch (defaults) {
        final d? => {
          'schedule': d.schedule,
          'compression': d.compression,
          'object_key': d.objectKey,
        },
        null => null,
      },
    );
  }
}
