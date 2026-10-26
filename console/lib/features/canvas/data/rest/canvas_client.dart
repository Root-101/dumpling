import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class CanvasClient extends BaseClient {
  CanvasClient(super.dio);

  String _canvasUrl(String workspace) =>
      '$baseUrl/workspaces/$workspace/canvas';

  Future<CanvasResponse> get({required String workspace, String? token}) async {
    Response rawResponse = await dio.get(
      _canvasUrl(workspace),
      options: options(token: token),
    );
    return CanvasResponse.fromJson(rawResponse.data);
  }

  /// Replaces the whole canvas: what [request] leaves out is deleted
  Future<CanvasResponse> save({
    required String workspace,
    required CanvasRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.put(
      _canvasUrl(workspace),
      data: request.toJson(),
      options: options(token: token),
    );
    return CanvasResponse.fromJson(rawResponse.data);
  }
}

//---------- CANVAS REQUEST ----------
/// Each node is the body of its own create / update plus `id` (a saved one or
/// `new_…`) and `position` (null: off the canvas)
class CanvasRequest {
  final List<Map<String, dynamic>> sources;
  final List<Map<String, dynamic>> destinations;
  final List<Map<String, dynamic>> configs;

  CanvasRequest({
    required this.sources,
    required this.destinations,
    required this.configs,
  });

  Map<String, dynamic> toJson() {
    return {
      'sources': sources,
      'destinations': destinations,
      'configs': configs,
    };
  }
}

//---------- CANVAS RESPONSE ----------
class CanvasResponse {
  /// Each one with its `position` (null: off the canvas)
  final List<Map<String, dynamic>> sources;
  final List<Map<String, dynamic>> destinations;
  final List<Map<String, dynamic>> configs;

  /// After a save: the id each `new_` node got
  final Map<String, String> ids;

  CanvasResponse({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.ids,
  });

  factory CanvasResponse.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> nodes(String name) =>
        (json[name] as List).cast<Map<String, dynamic>>();
    return CanvasResponse(
      sources: nodes('sources'),
      destinations: nodes('destinations'),
      configs: nodes('configs'),
      ids: (json['ids'] as Map? ?? const {}).cast<String, String>(),
    );
  }
}
