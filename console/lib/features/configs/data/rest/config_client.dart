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

  /// Replaces config [id] with [body] (all its fields)
  Future<void> update({
    required String workspace,
    required String id,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    await dio.put(
      '${_configsUrl(workspace)}/$id',
      data: body,
      options: options(token: token),
    );
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    await dio.delete(
      '${_configsUrl(workspace)}/$id',
      options: options(token: token),
    );
  }
}

//---------- CONFIG RESPONSE ----------
class ConfigResponse {
  final String id;
  final String name;
  final String sourceId;
  final String destinationId;
  final String? folder;
  final String schedule;
  final bool enabled;
  final DateTime? nextRun;
  final RunModel? lastRun;

  ConfigResponse({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    required this.folder,
    required this.schedule,
    required this.enabled,
    required this.nextRun,
    required this.lastRun,
  });

  factory ConfigResponse.fromJson(Map<String, dynamic> json) {
    return ConfigResponse(
      id: json['id'],
      name: json['name'],
      sourceId: json['source_id'],
      destinationId: json['destination_id'],
      folder: json['folder'],
      schedule: json['schedule'] ?? '',
      enabled: json['enabled'] ?? true,
      nextRun: json['next_run'] == null
          ? null
          : DateTime.parse(json['next_run']),
      lastRun: json['last_run'] == null
          ? null
          : RunModel.fromJson(json['last_run']),
    );
  }
}
