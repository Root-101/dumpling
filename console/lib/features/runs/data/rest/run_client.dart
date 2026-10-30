import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class RunClient extends BaseClient {
  RunClient(super.dio);

  String _runsUrl(String workspace) => '$baseUrl/workspaces/$workspace/runs';

  /// The newest runs of [workspace] (200 at most, or [limit]), without their
  /// log; with [configId], only the ones of that config
  Future<List<Map<String, dynamic>>> list({
    required String workspace,
    String? configId,
    int? limit,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _runsUrl(workspace),
      queryParameters: {'config': ?configId, 'limit': ?limit},
      options: options(token: token),
    );
    return (rawResponse.data as List).cast<Map<String, dynamic>>();
  }

  /// One run with its log
  Future<Map<String, dynamic>> get({
    required String workspace,
    required String id,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      '${_runsUrl(workspace)}/$id',
      options: options(token: token),
    );
    return rawResponse.data;
  }
}
