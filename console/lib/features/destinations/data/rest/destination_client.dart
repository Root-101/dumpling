import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class DestinationClient extends BaseClient {
  /// A test starts and aborts an upload in every folder: longer than other
  /// requests
  static const Duration testTimeout = Duration(seconds: 90);

  DestinationClient(super.dio);

  String _destinationsUrl(String workspace) =>
      '$baseUrl/workspaces/$workspace/destinations';

  /// Every type, the ones not available yet too
  Future<List<DestinationTypeResponse>> types({String? token}) async {
    Response rawResponse = await dio.get(
      '$baseUrl/destination-types',
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => DestinationTypeResponse.fromJson(e))
        .toList();
  }

  Future<List<DestinationResponse>> list({
    required String workspace,
    String? token,
  }) async {
    Response rawResponse = await dio.get(
      _destinationsUrl(workspace),
      options: options(token: token),
    );
    return (rawResponse.data as List)
        .map((e) => DestinationResponse.fromJson(e))
        .toList();
  }

  Future<DestinationResponse> create({
    required String workspace,
    required DestinationRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      _destinationsUrl(workspace),
      data: request.toJson(),
      options: options(token: token),
    );
    return DestinationResponse.fromJson(rawResponse.data);
  }

  /// Replaces the destination and its folders; without a secret key it keeps
  /// the saved one
  Future<DestinationResponse> update({
    required String workspace,
    required String id,
    required DestinationRequest request,
    String? token,
  }) async {
    Response rawResponse = await dio.put(
      '${_destinationsUrl(workspace)}/$id',
      data: request.toJson(),
      options: options(token: token),
    );
    return DestinationResponse.fromJson(rawResponse.data);
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    await dio.delete(
      '${_destinationsUrl(workspace)}/$id',
      options: options(token: token),
    );
  }

  /// Tests the form before saving it; [destinationId] (editing) fills in the
  /// saved secret key when the form has none
  Future<ConnectionCheckResponse> testUnsaved({
    required String workspace,
    required DestinationRequest request,
    String? destinationId,
    String? token,
  }) async {
    Response rawResponse = await dio.post(
      '${_destinationsUrl(workspace)}/test',
      data: request.toJson(),
      queryParameters: {'destination': ?destinationId},
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
      '${_destinationsUrl(workspace)}/$id/test',
      options: options(token: token).copyWith(receiveTimeout: testTimeout),
    );
    return ConnectionCheckResponse.fromJson(rawResponse.data);
  }
}

//---------- DESTINATION REQUEST ----------
class DestinationRequest {
  final String name;
  final String type;

  /// The fields of the type: for S3 `endpoint`, `region`, `bucket`,
  /// `access_key_id`, `secret_access_key` and `path_style`
  final Map<String, dynamic> settings;

  /// None: the bucket root is the only connection point
  final List<String> folders;

  DestinationRequest({
    required this.name,
    required this.type,
    required this.settings,
    required this.folders,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'settings': settings,
      'folders': folders,
    };
  }
}

//---------- DESTINATION RESPONSE ----------
class DestinationResponse {
  final String id;
  final String name;
  final String type;

  /// Without the secret key: the API never returns it
  final Map<String, dynamic> settings;
  final List<String> folders;
  final ConnectionCheckResponse? lastCheck;

  DestinationResponse({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    required this.folders,
    required this.lastCheck,
  });

  factory DestinationResponse.fromJson(Map<String, dynamic> json) {
    return DestinationResponse(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      settings: json['settings'],
      folders: (json['folders'] as List).cast<String>(),
      lastCheck: json['last_check'] == null
          ? null
          : ConnectionCheckResponse.fromJson(json['last_check']),
    );
  }
}

//---------- DESTINATION TYPE RESPONSE ----------
class DestinationTypeResponse {
  final String type;
  final bool enabled;

  DestinationTypeResponse({required this.type, required this.enabled});

  factory DestinationTypeResponse.fromJson(Map<String, dynamic> json) {
    return DestinationTypeResponse(
      type: json['type'],
      enabled: json['enabled'],
    );
  }
}
