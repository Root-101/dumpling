import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class ApiKeyClient extends BaseClient {
  ApiKeyClient(super.dio);

  String _keysUrl(String workspace) => '$baseUrl/workspaces/$workspace/keys';

  Future<List<Map<String, dynamic>>> list({
    required String workspace,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _keysUrl(workspace),
      options: options(token: token),
    );
    return (rawResponse.data as List).cast<Map<String, dynamic>>();
  }

  /// The answer has the key in `key`: the only time it comes
  Future<Map<String, dynamic>> create({
    required String workspace,
    required Map<String, dynamic> request,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      _keysUrl(workspace),
      data: request,
      options: options(token: token),
    );
    return rawResponse.data;
  }

  Future<Map<String, dynamic>> update({
    required String workspace,
    required String id,
    required Map<String, dynamic> request,
    String? token,
  }) async {
    Response rawResponse = await dio.put(
      '${_keysUrl(workspace)}/$id',
      data: request,
      options: options(token: token),
    );
    return rawResponse.data;
  }

  /// Saves the order of every key of [workspace], as [ids] list them
  Future<void> reorder({
    required String workspace,
    required List<String> ids,
    String? token,
  }) async {
    await dio.put(
      '${_keysUrl(workspace)}/order',
      data: {'ids': ids},
      options: options(token: token),
    );
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    await dio.delete(
      '${_keysUrl(workspace)}/$id',
      options: options(token: token),
    );
  }
}
