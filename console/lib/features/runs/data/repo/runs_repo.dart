import 'package:console/app_exporter.dart';

class RunsRepo {
  final RunsClient client;

  RunsRepo({required this.client});

  Future<List<RunModel>> list({
    required String workspace,
    String? configId,
    int? limit,
    String? token,
  }) async {
    try {
      final response = await client.list(
        workspace: workspace,
        configId: configId,
        limit: limit,
        token: token,
      );
      return response.map(RunModel.fromJson).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<RunModel> runAgain({
    required String workspace,
    required String configId,
    String? token,
  }) async {
    try {
      final response = await client.runAgain(
        workspace: workspace,
        configId: configId,
        token: token,
      );
      return RunModel.fromJson(response);
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
      final response = await client.get(
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
