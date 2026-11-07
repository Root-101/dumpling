import 'package:console/app_exporter.dart';

class ApiKeyRepo {
  final ApiKeyClient _client;

  ApiKeyRepo(this._client);

  Future<List<ApiKeyModel>> list({
    required String workspace,
    String? token,
  }) async {
    try {
      final response = await _client.list(workspace: workspace, token: token);
      return response.map(apiKeyOf).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  /// Creates the key (its text comes in [ApiKeyModel.key]), or changes [id]
  Future<ApiKeyModel> save({
    required String workspace,
    required ApiKeyDraft draft,
    String? id,
    String? token,
  }) async {
    final request = {
      'name': draft.name,
      'permissions': draft.permissions,
      'config_ids': draft.configIds,
    };
    try {
      final response = id == null
          ? await _client.create(
              workspace: workspace,
              request: request,
              token: token,
            )
          : await _client.update(
              workspace: workspace,
              id: id,
              request: request,
              token: token,
            );
      return apiKeyOf(response);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<void> reorder({
    required String workspace,
    required List<String> ids,
    String? token,
  }) async {
    try {
      await _client.reorder(workspace: workspace, ids: ids, token: token);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    try {
      await _client.delete(workspace: workspace, id: id, token: token);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  static ApiKeyModel apiKeyOf(Map<String, dynamic> json) {
    final used = json['last_used_at'];
    final last = json['last_run'] as Map<String, dynamic>?;
    return ApiKeyModel(
      id: json['id'],
      name: json['name'],
      permissions: (json['permissions'] as List).cast<String>(),
      configIds: (json['config_ids'] as List).cast<String>(),
      createdAt: DateTime.parse(json['created_at']),
      lastUsedAt: used == null ? null : DateTime.parse(used),
      lastRun: last == null
          ? null
          : ApiKeyLastRun(
              configName: last['config_name'],
              label: last['label'],
            ),
      key: json['key'],
    );
  }
}
