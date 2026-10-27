import 'package:console/app_exporter.dart';

class ConfigRepo {
  final ConfigClient _client;

  ConfigRepo(this._client);

  Future<List<ConfigModel>> list({
    required String workspace,
    String? token,
  }) async {
    try {
      final response = await _client.list(workspace: workspace, token: token);
      return response.map((e) => e.toModel()).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  /// Saves [config] as it is, out of the canvas (Backups). Empty schedule,
  /// compression or object key: the defaults of the workspace
  Future<void> update({
    required String workspace,
    required BackupConfig config,
    String? token,
  }) async {
    try {
      await _client.update(
        workspace: workspace,
        id: config.id,
        body: {
          'name': config.name.trim(),
          'source_id': config.sourceId,
          'destination_id': config.destinationId,
          'folder': config.folderId,
          'schedule': config.schedule,
          'compression': config.compression,
          'object_key': config.objectKey,
          'enabled': config.enabled,
        },
        token: token,
      );
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
}

extension ConfigResponseMapping on ConfigResponse {
  ConfigModel toModel() {
    return ConfigModel(
      id: id,
      name: name,
      sourceId: sourceId,
      destinationId: destinationId,
      folder: folder,
      schedule: schedule,
      enabled: enabled,
      nextRun: nextRun,
      lastRun: lastRun,
    );
  }
}
