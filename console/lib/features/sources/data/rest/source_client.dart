import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class SourceClient extends BaseClient {
  /// A test waits for the database to answer: longer than other requests
  static const Duration testTimeout = Duration(seconds: 90);

  SourceClient(super.dio);

  String _sourcesUrl(String workspace) =>
      '$baseUrl/workspaces/$workspace/sources';

  /// Every type, the ones not available yet too
  Future<List<SourceTypeResponse>> types({String? token}) async {
    Response rawResponse = await dio.get(
      '$baseUrl/source-types',
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => SourceTypeResponse.fromJson(e))
        .toList();
  }

  Future<List<SourceResponse>> list({
    required String workspace,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _sourcesUrl(workspace),
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => SourceResponse.fromJson(e))
        .toList();
  }

  Future<SourceResponse> create({
    required String workspace,
    required SourceRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      _sourcesUrl(workspace),
      data: request.toJson(),
      options: options(token: token),
    );
    return SourceResponse.fromJson(rawResponse.data);
  }

  /// Replaces the source; without a password it keeps the saved one
  Future<SourceResponse> update({
    required String workspace,
    required String id,
    required SourceRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.put(
      '${_sourcesUrl(workspace)}/$id',
      data: request.toJson(),
      options: options(token: token),
    );
    return SourceResponse.fromJson(rawResponse.data);
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    await dio.delete(
      '${_sourcesUrl(workspace)}/$id',
      options: options(token: token),
    );
  }

  /// Tests the form before saving it; [sourceId] (editing) fills in the saved
  /// password when the form has none
  Future<ConnectionCheckResponse> testUnsaved({
    required String workspace,
    required SourceRequest request,
    String? sourceId,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      '${_sourcesUrl(workspace)}/test',
      data: request.toJson(),
      queryParameters: {'source': ?sourceId},
      options: options(token: token).copyWith(receiveTimeout: testTimeout),
    );
    return ConnectionCheckResponse.fromJson(rawResponse.data);
  }

  /// Tests the saved connection; the service keeps it as its last test
  Future<ConnectionCheckResponse> testSaved({
    required String workspace,
    required String id,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      '${_sourcesUrl(workspace)}/$id/test',
      options: options(token: token).copyWith(receiveTimeout: testTimeout),
    );
    return ConnectionCheckResponse.fromJson(rawResponse.data);
  }
}

//---------- SOURCE REQUEST ----------
class SourceRequest {
  final String name;
  final String type;

  /// The fields of the type: for PostgreSQL `host`, `port`, `database`,
  /// `username`, `password` and `dump_format`, or `connection_url`
  final Map<String, dynamic> settings;

  SourceRequest({
    required this.name,
    required this.type,
    required this.settings,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'type': type, 'settings': settings};
  }
}

//---------- SOURCE RESPONSE ----------
class SourceResponse {
  final String id;
  final String name;
  final String type;

  /// Without the password: the API never returns it
  final Map<String, dynamic> settings;
  final ConnectionCheckResponse? lastCheck;

  SourceResponse({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    required this.lastCheck,
  });

  factory SourceResponse.fromJson(Map<String, dynamic> json) {
    return SourceResponse(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      settings: json['settings'],
      lastCheck: json['last_check'] == null
          ? null
          : ConnectionCheckResponse.fromJson(json['last_check']),
    );
  }
}

//---------- SOURCE TYPE RESPONSE ----------
class SourceTypeResponse {
  final String type;
  final bool enabled;

  SourceTypeResponse({required this.type, required this.enabled});

  factory SourceTypeResponse.fromJson(Map<String, dynamic> json) {
    return SourceTypeResponse(type: json['type'], enabled: json['enabled']);
  }
}
