import 'package:console/app_exporter.dart';

class SourceRepo {
  final SourceClient _client;

  SourceRepo(this._client);

  Future<List<SourceTypeModel>> types({String? token}) async {
    try {
      final response = await _client.types(token: token);
      return response
          .map((e) => SourceTypeModel(type: e.type, enabled: e.enabled))
          .toList();
    } catch (e) {
      throw ExceptionConverter.parse(e);
    }
  }

  Future<List<SourceModel>> list({
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

  /// Creates the source, or replaces [id] when editing
  Future<SourceModel> save({
    required String workspace,
    required SourceDraft draft,
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
    required SourceDraft draft,
    String? sourceId,
    String? token,
  }) async {
    try {
      final response = await _client.testUnsaved(
        workspace: workspace,
        request: draft.toRequest(),
        sourceId: sourceId,
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

extension SourceResponseMapping on SourceResponse {
  SourceModel toModel() {
    final s = settings;
    return SourceModel(
      id: id,
      name: name,
      type: type,
      postgres: type == SourceTypes.postgres
          ? PostgresSettingsModel(
              host: s['host'],
              port: s['port'],
              database: s['database'],
              username: s['username'],
              dumpFormat: s['dump_format'],
            )
          : null,
      lastCheck: lastCheck?.toModel(),
    );
  }
}

extension SourceDraftMapping on SourceDraft {
  SourceRequest toRequest() {
    final url = connectionUrl;
    return SourceRequest(
      name: name,
      type: type,
      settings: {
        if (url != null)
          'connection_url': url
        else ...{
          'host': host,
          'port': ?port,
          'database': database,
          'username': username,
        },
        if (password != null && password!.isNotEmpty) 'password': password,
        'dump_format': dumpFormat,
      },
    );
  }
}
