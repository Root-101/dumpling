import 'dart:convert';

import 'package:service/dumpling.dart';

class DestinationService {
  static const String idPrefix = 'dst_';

  final DestinationTableRepo repo;
  final ConfigTableRepo configs;
  final WorkspaceService workspaces;
  final Secrets secrets;

  DestinationService()
    : repo = DestinationTableRepo(di.find()),
      configs = ConfigTableRepo(di.find()),
      workspaces = WorkspaceService(),
      secrets = Secrets();

  Future<List<DestinationModel>> list(String workspace) async {
    await workspaces.get(workspace);
    return (await repo.getAll(workspace))
        .map(DestinationModel.fromRow)
        .toList();
  }

  Future<DestinationModel> get(String workspace, String id) async =>
      DestinationModel.fromRow(await _row(workspace, id));

  Future<DestinationModel> create(
    String workspace,
    DestinationRequest request,
  ) async {
    await workspaces.get(workspace);
    final settings = request.settings!;
    final values = Secrets.require(settings.requiredSecrets, settings.secrets);

    final id = Secrets.newId(idPrefix);
    await repo.insert(
      id: id,
      workspace: workspace,
      name: request.trimmedName,
      type: request.destinationType!,
      settings: jsonEncode(settings),
      secretsEncrypted: secrets.encrypt(id, values),
      folders: request.cleanFolders,
    );
    logger.info(
      'Destination created',
      fields: {'workspace': workspace, 'destination': id},
    );
    return get(workspace, id);
  }

  /// Replaces the destination and its folders. A secret missing in [request]
  /// keeps the stored one, unless the type changes. A 409 when a config would
  /// lose where it writes: a folder removed, or the root once there are
  /// folders.
  Future<DestinationModel> update(
    String workspace,
    String id,
    DestinationRequest request,
  ) async {
    final row = await _row(workspace, id);
    final settings = request.settings!;
    final stored = _storedFor(row, request.destinationType);
    final values = Secrets.require(settings.requiredSecrets, {
      ...stored,
      ...settings.secrets,
    });
    await _checkTargets(id, request.cleanFolders);

    await repo.update(
      id: id,
      name: request.trimmedName,
      type: request.destinationType!,
      settings: jsonEncode(settings),
      secretsEncrypted: secrets.encrypt(id, values),
      folders: request.cleanFolders,
      connectionChanged: DestinationTableRepo.connectionChanged(
        row,
        type: request.destinationType!,
        settings: jsonEncode(settings),
        secrets: (stored, values),
        folders: request.cleanFolders,
      ),
    );
    logger.info(
      'Destination updated',
      fields: {'workspace': workspace, 'destination': id},
    );
    return get(workspace, id);
  }

  /// A 409 while a config writes to it: delete or move those configs first.
  Future<void> delete(String workspace, String id) async {
    await _row(workspace, id);
    final using = await configs.byDestination(id);
    if (using.isNotEmpty) {
      throw ConflictException(
        detail: intl.errors.destinations.inUse(configs: using.length),
      );
    }
    await repo.delete(id);
    logger.info(
      'Destination deleted',
      fields: {'workspace': workspace, 'destination': id},
    );
  }

  /// Tests the connection of the form before it is saved, in its folders.
  /// With [destinationId] (editing a saved one) its stored secrets fill the
  /// missing ones.
  Future<ConnectionCheck> testUnsaved(
    String workspace,
    DestinationRequest request, {
    String? destinationId,
  }) async {
    await workspaces.get(workspace);
    final settings = request.settings!;
    final stored = destinationId == null
        ? const <String, String>{}
        : _storedFor(
            await _row(workspace, destinationId),
            request.destinationType,
          );
    final values = Secrets.require(settings.requiredSecrets, {
      ...stored,
      ...settings.secrets,
    });
    return _driver(request.destinationType!)
        .testConnection(settings, values, request.cleanFolders);
  }

  /// Tests the saved connection in its folders and keeps the result as its
  /// last check.
  Future<ConnectionCheck> testSaved(String workspace, String id) async {
    final row = await _row(workspace, id);
    final destination = row.destination;
    final settings = DestinationSettings.fromJson(
      destination.type,
      jsonDecode(destination.settings) as Map<String, dynamic>,
    )!;
    final check = await _driver(destination.type).testConnection(
      settings,
      secrets.decrypt(destination.id, destination.secretsEncrypted),
      [for (final folder in row.folders) folder.path],
    );
    await repo.updateLastCheck(id: id, lastCheck: jsonEncode(check));
    return check;
  }

  Future<DestinationRow> _row(String workspace, String id) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null) {
      throw NotFoundException(
        detail: intl.errors.destinations.notFound(id: id),
      );
    }
    return row;
  }

  /// A 409 naming the first place a config writes to that [folders] would
  /// remove (the root, `/`, once there are folders).
  Future<void> _checkTargets(String id, List<String> folders) async {
    for (final config in await configs.byDestination(id)) {
      final kept = folders.isEmpty
          ? config.folder == null
          : folders.contains(config.folder);
      if (!kept) {
        throw ConflictException(
          detail: intl.errors.destinations.folderInUse(
            folder: config.folder ?? '/',
            config: config.name,
          ),
        );
      }
    }
  }

  /// The stored secrets of [row], if it is still of [type].
  Map<String, String> _storedFor(DestinationRow row, DestinationType? type) =>
      row.destination.type == type
      ? secrets.decrypt(row.destination.id, row.destination.secretsEncrypted)
      : const {};

  DestinationDriver _driver(DestinationType type) =>
      DestinationDriver.drivers[type]!;
}
