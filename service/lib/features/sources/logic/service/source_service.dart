import 'dart:convert';

import 'package:service/dumpling.dart';

class SourceService {
  static const String idPrefix = 'src_';

  final SourceTableRepo repo;
  final ConfigTableRepo configs;
  final WorkspaceService workspaces;
  final Secrets secrets;

  SourceService()
    : repo = SourceTableRepo(di.find()),
      configs = ConfigTableRepo(di.find()),
      workspaces = WorkspaceService(),
      secrets = Secrets();

  Future<List<SourceModel>> list(String workspace) async {
    await workspaces.get(workspace);
    return (await repo.getAll(workspace)).map(SourceModel.fromRow).toList();
  }

  Future<SourceModel> get(String workspace, String id) async =>
      SourceModel.fromRow(await _row(workspace, id));

  Future<SourceModel> create(String workspace, SourceRequest request) async {
    await workspaces.get(workspace);
    final settings = request.settings!;
    final values = Secrets.require(settings.requiredSecrets, settings.secrets);

    final id = Secrets.newId(idPrefix);
    await repo.insert(
      id: id,
      workspace: workspace,
      name: request.trimmedName,
      type: request.sourceType!,
      settings: jsonEncode(settings),
      secretsEncrypted: secrets.encrypt(id, values),
    );
    logger.info(
      'Source created',
      fields: {'workspace': workspace, 'source': id},
    );
    return get(workspace, id);
  }

  /// Replaces the source. A secret missing in [request] keeps the stored one,
  /// unless the type changes.
  Future<SourceModel> update(
    String workspace,
    String id,
    SourceRequest request,
  ) async {
    final row = await _row(workspace, id);
    final settings = request.settings!;
    final stored = row.type == request.sourceType
        ? _decrypt(row)
        : const <String, String>{};
    final values = Secrets.require(settings.requiredSecrets, {
      ...stored,
      ...settings.secrets,
    });

    await repo.update(
      id: id,
      name: request.trimmedName,
      type: request.sourceType!,
      settings: jsonEncode(settings),
      secretsEncrypted: secrets.encrypt(id, values),
    );
    logger.info(
      'Source updated',
      fields: {'workspace': workspace, 'source': id},
    );
    return get(workspace, id);
  }

  /// A 409 while a config dumps it: delete or move those configs first.
  Future<void> delete(String workspace, String id) async {
    await _row(workspace, id);
    final using = await configs.bySource(id);
    if (using.isNotEmpty) {
      throw ConflictException(
        detail: intl.errors.sources.inUse(configs: using.length),
      );
    }
    await repo.delete(id);
    logger.info(
      'Source deleted',
      fields: {'workspace': workspace, 'source': id},
    );
  }

  /// Tests the connection of the form before it is saved. With [sourceId]
  /// (editing a saved source) its stored secrets fill the missing ones.
  Future<ConnectionCheck> testUnsaved(
    String workspace,
    SourceRequest request, {
    String? sourceId,
  }) async {
    await workspaces.get(workspace);
    final settings = request.settings!;
    var stored = const <String, String>{};
    if (sourceId != null) {
      final row = await _row(workspace, sourceId);
      if (row.type == request.sourceType) stored = _decrypt(row);
    }
    final values = Secrets.require(settings.requiredSecrets, {
      ...stored,
      ...settings.secrets,
    });
    return _driver(request.sourceType!).testConnection(settings, values);
  }

  /// Tests the saved connection and keeps the result as its last check.
  Future<ConnectionCheck> testSaved(String workspace, String id) async {
    final row = await _row(workspace, id);
    final settings = SourceSettings.fromJson(
      row.type,
      jsonDecode(row.settings) as Map<String, dynamic>,
    )!;
    final check = await _driver(row.type)
        .testConnection(settings, _decrypt(row));
    await repo.updateLastCheck(id: id, lastCheck: jsonEncode(check));
    return check;
  }

  Future<SourceTableData> _row(String workspace, String id) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null) {
      throw NotFoundException(detail: intl.errors.sources.notFound(id: id));
    }
    return row;
  }

  SourceDriver _driver(SourceType type) => SourceDriver.drivers[type]!;

  Map<String, String> _decrypt(SourceTableData row) =>
      secrets.decrypt(row.id, row.secretsEncrypted);
}
