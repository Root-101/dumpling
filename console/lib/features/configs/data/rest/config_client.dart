import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class ConfigClient extends BaseClient {
  ConfigClient(super.dio);

  String _configsUrl(String workspace) =>
      '$baseUrl/workspaces/$workspace/configs';

  Future<List<ConfigResponse>> list({
    required String workspace,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _configsUrl(workspace),
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => ConfigResponse.fromJson(e))
        .toList();
  }
}

//---------- CONFIG RESPONSE ----------
class ConfigResponse {
  final String id;
  final String name;
  final String sourceId;
  final String destinationId;
  final String? folder;

  ConfigResponse({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    required this.folder,
  });

  factory ConfigResponse.fromJson(Map<String, dynamic> json) {
    return ConfigResponse(
      id: json['id'],
      name: json['name'],
      sourceId: json['source_id'],
      destinationId: json['destination_id'],
      folder: json['folder'],
    );
  }
}
