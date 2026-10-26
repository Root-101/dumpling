import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

class ConfigService {
  static const String idPrefix = 'cfg_';

  final ConfigTableRepo repo;
  final SourceTableRepo sources;
  final DestinationTableRepo destinations;
  final WorkspaceService workspaces;
  final RunTableRepo runs;
  final BackupEngine engine;

  ConfigService()
    : repo = ConfigTableRepo(di.find()),
      sources = SourceTableRepo(di.find()),
      destinations = DestinationTableRepo(di.find()),
      workspaces = WorkspaceService(),
      runs = RunTableRepo(di.find()),
      engine = di.find();

  Future<List<ConfigModel>> list(String workspace) async {
    await workspaces.get(workspace);
    final last = await runs.lastByConfig(workspace);
    return [
      for (final row in await repo.getAll(workspace))
        ConfigModel.fromRow(row, lastRun: last[row.id]),
    ];
  }

  Future<ConfigModel> get(String workspace, String id) async {
    final row = await _row(workspace, id);
    final last = await runs.getAll(workspace, configId: id, limit: 1);
    return ConfigModel.fromRow(row, lastRun: last.firstOrNull);
  }

  Future<ConfigModel> create(String workspace, ConfigRequest request) async {
    final values = await _values(workspace, request);
    final id = Secrets.newId(idPrefix);
    await repo.insert(
      values.copyWith(id: Value(id), workspaceSlug: Value(workspace)),
    );
    engine.schedule((await repo.get(workspace, id))!);
    logger.info(
      'Config created',
      fields: {'workspace': workspace, 'config': id},
    );
    return get(workspace, id);
  }

  /// Replaces the config: a missing schedule, compression or object key goes
  /// back to the default of the workspace.
  Future<ConfigModel> update(
    String workspace,
    String id,
    ConfigRequest request,
  ) async {
    await _row(workspace, id);
    await repo.update(id, await _values(workspace, request));
    // A new schedule, or none once disabled
    engine.schedule((await repo.get(workspace, id))!);
    logger.info(
      'Config updated',
      fields: {'workspace': workspace, 'config': id},
    );
    return get(workspace, id);
  }

  Future<void> delete(String workspace, String id) async {
    await _row(workspace, id);
    engine.unschedule(id);
    await repo.delete(id);
    logger.info(
      'Config deleted',
      fields: {'workspace': workspace, 'config': id},
    );
  }

  /// What [request] stores, once its source, destination and folder are known
  /// to be of [workspace] (a 422 naming the field otherwise).
  Future<ConfigTableCompanion> _values(
    String workspace,
    ConfigRequest request,
  ) async {
    final defaults = (await workspaces.get(workspace)).defaults;
    final source = await sources.get(workspace, request.sourceId!);
    final destination = await destinations.get(
      workspace,
      request.destinationId!,
    );
    final folder = request.cleanFolder;
    final folders = [
      for (final f
          in destination?.folders ?? const <DestinationFolderTableData>[])
        f.path,
    ];

    final context = ConstraintValidatorContext()
      ..field('source_id', request.sourceId).custom(
        (_) => source == null ? intl.errors.validations.unknownSource : null,
      )
      ..field('destination_id', request.destinationId).custom(
        (_) => destination == null
            ? intl.errors.validations.unknownDestination
            : null,
      );
    if (destination != null) {
      // With folders, one of them; without, the root
      context
          .field('folder', folder)
          .custom((_) => ConfigRequest.folderError(folder, folders));
    }
    context.throwOnFailure();

    return request.values(
      defaults,
      sourceId: source!.id,
      destinationId: destination!.destination.id,
      folder: folder,
    );
  }

  Future<ConfigTableData> _row(String workspace, String id) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null) {
      throw NotFoundException(detail: intl.errors.configs.notFound(id: id));
    }
    return row;
  }
}
