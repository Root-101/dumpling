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
}

extension ConfigResponseMapping on ConfigResponse {
  ConfigModel toModel() {
    return ConfigModel(
      id: id,
      name: name,
      sourceId: sourceId,
      destinationId: destinationId,
      folder: folder,
    );
  }
}
