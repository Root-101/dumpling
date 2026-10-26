import 'package:console/app_exporter.dart';

class RunRepo {
  final RunClient _client;

  RunRepo(this._client);

  Future<List<RunModel>> list({
    required String workspace,
    String? token,
  }) async {
    try {
      final response = await _client.list(workspace: workspace, token: token);
      return response.map(RunModel.fromJson).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<RunModel> get({
    required String workspace,
    required String id,
    String? token,
  }) async {
    try {
      final response = await _client.get(
        workspace: workspace,
        id: id,
        token: token,
      );
      return RunModel.fromJson(response);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }
}
