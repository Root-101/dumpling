import 'package:service/dumpling.dart';

class RunService {
  final RunTableRepo repo;
  final ConfigTableRepo configs;
  final WorkspaceService workspaces;
  final BackupEngine engine;

  RunService()
    : repo = RunTableRepo(di.find()),
      configs = ConfigTableRepo(di.find()),
      workspaces = WorkspaceService(),
      engine = di.find();

  /// The most runs a list answers.
  static const int maxRuns = 200;

  /// The runs of [workspace], newest first, filtered by what is given, at
  /// most [limit].
  Future<List<RunModel>> list(
    String workspace, {
    SourceType? sourceType,
    DestinationType? destinationType,
    RunStatus? status,
    String? configId,
    int limit = maxRuns,
  }) async {
    await workspaces.get(workspace);
    final rows = await repo.getAll(
      workspace,
      sourceType: sourceType,
      destinationType: destinationType,
      status: status,
      configId: configId,
      limit: limit,
    );
    return [for (final row in rows) RunModel(row)];
  }

  Future<RunModel> get(String workspace, String id) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null) {
      throw NotFoundException(detail: intl.errors.runs.notFound(id: id));
    }
    return RunModel(row, withLog: true);
  }

  /// Runs [configId] now, whether it is enabled or not.
  Future<RunModel> runNow(String workspace, String configId) async {
    await workspaces.get(workspace);
    final config = await configs.get(workspace, configId);
    if (config == null) {
      throw NotFoundException(
        detail: intl.errors.configs.notFound(id: configId),
      );
    }
    return RunModel(await engine.runNow(config));
  }
}
