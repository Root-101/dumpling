import 'package:console/app_exporter.dart';

class DestinationRepo {
  final DestinationClient _client;

  DestinationRepo(this._client);

  Future<List<DestinationTypeModel>> types({String? token}) async {
    try {
      final response = await _client.types(token: token);
      return response
          .map((e) => DestinationTypeModel(type: e.type, enabled: e.enabled))
          .toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<List<DestinationModel>> list({
    required String workspace,
    String? token,
  }) async {
    try {
      final response = await _client.list(workspace: workspace, token: token);
      return response.map((e) => e.toModel()).toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  /// Creates the destination, or replaces [id] when editing
  Future<DestinationModel> save({
    required String workspace,
    required DestinationDraft draft,
    String? id,
    String? token,
  }) async {
    try {
      final request = draft.toRequest();
      final response = id == null
          ? await _client.create(
              workspace: workspace,
              request: request,
              token: token,
            )
          : await _client.update(
              workspace: workspace,
              id: id,
              request: request,
              token: token,
            );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<void> delete({
    required String workspace,
    required String id,
    String? token,
  }) async {
    try {
      await _client.delete(workspace: workspace, id: id, token: token);
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<ConnectionCheckModel> testUnsaved({
    required String workspace,
    required DestinationDraft draft,
    String? destinationId,
    String? token,
  }) async {
    try {
      final response = await _client.testUnsaved(
        workspace: workspace,
        request: draft.toRequest(),
        destinationId: destinationId,
        token: token,
      );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<ConnectionCheckModel> testSaved({
    required String workspace,
    required String id,
    String? token,
  }) async {
    try {
      final response = await _client.testSaved(
        workspace: workspace,
        id: id,
        token: token,
      );
      return response.toModel();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }
}

extension DestinationResponseMapping on DestinationResponse {
  DestinationModel toModel() {
    final s = settings;
    return DestinationModel(
      id: id,
      name: name,
      type: type,
      s3: type == DestinationTypes.s3
          ? S3SettingsModel(
              endpoint: s['endpoint'],
              region: s['region'],
              bucket: s['bucket'],
              accessKeyId: s['access_key_id'],
              pathStyle: s['path_style'] ?? false,
            )
          : null,
      folders: folders,
      lastCheck: lastCheck?.toModel(),
    );
  }
}

extension DestinationDraftMapping on DestinationDraft {
  DestinationRequest toRequest() {
    return DestinationRequest(
      name: name,
      type: type,
      settings: {
        'endpoint': endpoint,
        if (region.isNotEmpty) 'region': region,
        'bucket': bucket,
        'access_key_id': accessKeyId,
        if (secretKey != null && secretKey!.isNotEmpty)
          'secret_access_key': secretKey,
        'path_style': pathStyle,
      },
      folders: folders,
    );
  }
}
