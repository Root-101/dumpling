import 'package:service/dumpling.dart';

class RunController {
  final RunService runService;

  RunController() : runService = di.find();

  /// `?source_type=postgres&destination_type=s3&status=failed&config=cfg_…`,
  /// `trigger=api`, `label=v1.4.2` and `limit` (1 to 200, the default), e.g.
  /// the last runs of one config
  Future<ResponseEntity> list(RequestEntity request) async {
    final runs = await runService.list(
      request.pathParam<String>('workspace'),
      sourceType: request.queryParam('source_type', values: SourceType.values),
      destinationType: request.queryParam(
        'destination_type',
        values: DestinationType.values,
      ),
      status: request.queryParam('status', values: RunStatus.values),
      trigger: request.queryParam('trigger', values: RunTrigger.values),
      label: request.queryParam<String>('label'),
      configId: request.queryParam<String>('config'),
      only: ApiKeyPrincipal.configsOf(request),
      limit: request.queryParam<int>('limit') ?? RunService.maxRuns,
    );
    return ResponseEntity.ok(body: runs);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final run = await runService.get(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('run'),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: run);
  }

  /// 202: the run goes on in the background (or waits its turn, queued); its
  /// id is in the answer. The body is optional: `{"label": "v1.4.2"}`.
  Future<ResponseEntity> runNow(RequestEntity request) async {
    final body = await request.body<RunNowRequest?>();
    final run = await runService.runNow(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('config'),
      label: body?.label,
      key: ApiKeyPrincipal.of(request),
    );
    return ResponseEntity(202, body: run);
  }

  /// Server-Sent Events of a run until it ends (see [RunService.events]).
  Future<ResponseEntity> events(RequestEntity request) async {
    final events = await runService.events(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('run'),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.sse(events);
  }
}
