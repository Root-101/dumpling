import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class RunClient extends BaseClient {
  RunClient(super.dio);

  String _runsUrl(String workspace) => '$baseUrl/workspaces/$workspace/runs';

  /// The 200 newest runs of [workspace], without their log
  Future<List<Map<String, dynamic>>> list({
    required String workspace,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _runsUrl(workspace),
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
