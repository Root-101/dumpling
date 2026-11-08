import 'dart:async';

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

  /// How often [events] looks at the run.
  static Duration eventsEvery = const Duration(seconds: 1);

  /// The runs of [workspace], newest first, filtered by what is given, at
  /// most [limit]. With [only], just the runs of those configs (an API key
  /// limited to them).
  Future<List<RunModel>> list(
    String workspace, {
    SourceType? sourceType,
    DestinationType? destinationType,
    RunStatus? status,
    RunTrigger? trigger,
    String? label,
    String? configId,
    Set<String>? only,
    int limit = maxRuns,
  }) async {
    await workspaces.get(workspace);
    final rows = await repo.getAll(
      workspace,
      sourceType: sourceType,
      destinationType: destinationType,
      status: status,
      trigger: trigger,
      label: label,
      configId: configId,
      configIds: only,
      limit: limit,
    );
    return [for (final row in rows) RunModel(row)];
  }

  Future<RunModel> get(
    String workspace,
    String id, {
    Set<String>? only,
  }) async => RunModel(await _row(workspace, id, only), withLog: true);

  /// Runs [configId] now, whether it is enabled or not; queued when it is
  /// already running. With [key], asked for with that API key.
  Future<RunModel> runNow(
    String workspace,
    String configId, {
    String? label,
    ApiKeyPrincipal? key,
  }) async {
    await workspaces.get(workspace);
    final config = await configs.get(workspace, configId);
    final reached = key?.configs?.contains(configId) ?? true;
    if (config == null || !reached) {
      throw NotFoundException(
        detail: intl.errors.configs.notFound(id: configId),
      );
    }
    return RunModel(await engine.runNow(config, label: label, key: key));
  }

  /// The run [id] as it changes: an event `run` with it at once and on each
  /// change (status, bytes uploaded), and `end` with the run once it is no
  /// longer queued or running. A run that ended answers `end` at once.
  Future<Stream<ServerSentEvent>> events(
    String workspace,
    String id, {
    Set<String>? only,
  }) async {
    final first = await _row(workspace, id, only);
    late final StreamController<ServerSentEvent> controller;
    Timer? timer;
    RunTableData? sent;

    Future<void> push(RunTableData run) async {
      final ended =
          run.status != RunStatus.queued && run.status != RunStatus.running;
      if (ended) {
        timer?.cancel();
        controller.add(
          ServerSentEvent.json(RunModel(run, withLog: true), event: 'end'),
        );
        await controller.close();
      } else if (sent == null ||
          sent!.status != run.status ||
          sent!.sizeBytes != run.sizeBytes ||
          sent!.location != run.location) {
        controller.add(ServerSentEvent.json(RunModel(run), event: 'run'));
      }
      sent = run;
    }

    controller = StreamController<ServerSentEvent>(
      onListen: () {
        unawaited(push(first));
        timer = Timer.periodic(eventsEvery, (_) async {
          if (controller.isClosed) return;
          final run = await repo.get(workspace, id);
          if (run != null && !controller.isClosed) await push(run);
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  /// The run [id] of [workspace], when [only] (the configs of an API key)
  /// reaches it: a 404 otherwise, as one that doesn't exist.
  Future<RunTableData> _row(
    String workspace,
    String id,
    Set<String>? only,
  ) async {
    await workspaces.get(workspace);
    final row = await repo.get(workspace, id);
    if (row == null || (only != null && !only.contains(row.configId))) {
      throw NotFoundException(detail: intl.errors.runs.notFound(id: id));
    }
    return row;
  }
}
