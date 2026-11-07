import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

class ApiKeyService {
  final ApiKeyTableRepo repo;
  final ConfigTableRepo configs;
  final WorkspaceService workspaces;

  ApiKeyService()
    : repo = ApiKeyTableRepo(di.find()),
      configs = ConfigTableRepo(di.find()),
      workspaces = WorkspaceService();

  /// A key used again within this time doesn't write its last use: one write
  /// a minute at most, however often a script calls.
  static const Duration touchEvery = Duration(minutes: 1);

  Future<List<ApiKeyModel>> list(String workspace) async {
    await workspaces.get(workspace);
    final last = await repo.lastRuns(workspace);
    return [
      for (final row in await repo.getAll(workspace))
        ApiKeyModel(row, lastRun: last[row.id]),
    ];
  }

  /// The new key, with its whole text in `key`: the only time it is shown.
  Future<ApiKeyModel> create(String workspace, ApiKeyRequest request) async {
    await workspaces.get(workspace);
    final configIds = await _configIds(workspace, request);
    final id = Secrets.newId(ApiKeyToken.idPrefix);
    final secret = ApiKeyToken.newSecret();
    await repo.insert(
      ApiKeyTableCompanion.insert(
        id: id,
        workspaceSlug: workspace,
        name: request.trimmedName,
        secretHash: ApiKeyToken.hash(secret),
        permissions: jsonEncode(request.cleanPermissions),
        configIds: Value(jsonEncode(configIds)),
      ),
    );
    logger.info('API key created', fields: {'workspace': workspace, 'key': id});
    return ApiKeyModel(
      (await repo.get(workspace, id))!,
      key: ApiKeyToken.of(id, secret),
    );
  }

  Future<ApiKeyModel> update(
    String workspace,
    String id,
    ApiKeyRequest request,
  ) async {
    await _row(workspace, id);
    final configIds = await _configIds(workspace, request);
    await repo.update(
      id,
      ApiKeyTableCompanion(
        name: Value(request.trimmedName),
        permissions: Value(jsonEncode(request.cleanPermissions)),
        configIds: Value(jsonEncode(configIds)),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
    logger.info('API key changed', fields: {'workspace': workspace, 'key': id});
    final last = await repo.lastRuns(workspace);
    return ApiKeyModel((await repo.get(workspace, id))!, lastRun: last[id]);
  }

  /// Whatever uses it gets a 401 from the next request; its runs stay.
  Future<void> delete(String workspace, String id) async {
    await _row(workspace, id);
    await repo.delete(id);
    logger.info('API key deleted', fields: {'workspace': workspace, 'key': id});
  }

  Future<List<ApiKeyModel>> reorder(
    String workspace,
    OrderRequest request,
  ) async {
    await workspaces.get(workspace);
    final saved = [for (final row in await repo.getAll(workspace)) row.id];
    await repo.reorder(request.idsOf(saved));
    logger.info('API keys reordered', fields: {'workspace': workspace});
    return list(workspace);
  }

  /// The key of [id] and [secret] when they match one, as who makes the
  /// request; null otherwise. The hashes compare in constant time.
  Future<(ApiKeyPrincipal, Set<String>)?> authenticate(
    String id,
    String secret,
  ) async {
    final row = await repo.byId(id);
    if (row == null || !_same(ApiKeyToken.hash(secret), row.secretHash)) {
      return null;
    }
    final now = DateTime.now().toUtc();
    final used = row.lastUsedAt;
    if (used == null || now.difference(used) >= touchEvery) {
      await repo.update(id, ApiKeyTableCompanion(lastUsedAt: Value(now)));
    }
    final model = ApiKeyModel(row);
    final configIds = model.configIds;
    return (
      ApiKeyPrincipal(
        id: row.id,
        name: row.name,
        workspace: row.workspaceSlug,
        configs: configIds.isEmpty ? null : configIds.toSet(),
      ),
      // Never more than a key may have, whatever is stored
      model.permissions.where(Permissions.grantable.contains).toSet(),
    );
  }

  Future<ApiKeyTableData> _row(String workspace, String id) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null) {
      throw NotFoundException(detail: intl.errors.apiKeys.notFound(id: id));
    }
    return row;
  }

  /// The configs of [request], once checked they are of [workspace]: a 422
  /// on `config_ids` otherwise.
  Future<List<String>> _configIds(
    String workspace,
    ApiKeyRequest request,
  ) async {
    final ids = request.cleanConfigIds;
    if (ids.isEmpty) return ids;
    final saved = {for (final c in await configs.getAll(workspace)) c.id};
    (ConstraintValidatorContext()
          ..field('config_ids', ids).custom(
            (_) => saved.containsAll(ids)
                ? null
                : intl.errors.validations.unknownConfig,
          ))
        .throwOnFailure();
    return ids;
  }

  static bool _same(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
