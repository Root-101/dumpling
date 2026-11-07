import 'package:service/dumpling.dart';

class RunController {
  final RunService runService;

  RunController() : runService = RunService();

  /// `?source_type=postgres&destination_type=s3&status=failed&config=cfg_…`,
  /// `trigger=api`, `label=v1.4.2` and `limit` (1 to 200, the default), e.g.
  /// the last runs of one config
  Future<ResponseEntity> list(RequestEntity request) async {
    final runs = await runService.list(
      request.pathParams['slug']!,
      sourceType: _enum(request, 'source_type', SourceType.values),
      destinationType: _enum(
        request,
        'destination_type',
        DestinationType.values,
      ),
      status: _enum(request, 'status', RunStatus.values),
      trigger: _enum(request, 'trigger', RunTrigger.values),
      label: request.queryParam<String>('label'),
      configId: request.queryParam<String>('config'),
      only: ApiKeyPrincipal.configsOf(request),
      limit: _limit(request),
    );
    return ResponseEntity.ok(body: runs);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final run = await runService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: run);
  }

  /// 202: the run goes on in the background (or waits its turn, queued); its
  /// id is in the answer. The body is optional: `{"label": "v1.4.2"}`.
  Future<ResponseEntity> runNow(RequestEntity request) async {
    final body = await request.body<RunNowRequest?>();
    final run = await runService.runNow(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      label: body?.label,
      key: ApiKeyPrincipal.of(request),
    );
    return ResponseEntity(202, body: run);
  }

  /// Server-Sent Events of a run until it ends (see [RunService.events]).
  Future<ResponseEntity> events(RequestEntity request) async {
    final events = await runService.events(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.sse(events);
  }

  /// `limit`: from 1 to [RunService.maxRuns]; a 400 otherwise.
  static int _limit(RequestEntity request) {
    final raw = request.queryParam<String>('limit');
    if (raw == null) return RunService.maxRuns;
    final limit = int.tryParse(raw);
    if (limit == null || limit < 1 || limit > RunService.maxRuns) {
      throw BadRequestException(
        detail: intl.errors.runs.invalidLimit(max: RunService.maxRuns),
      );
    }
    return limit;
  }

  /// The value of the query parameter [name] among [values]; a 400 if it is
  /// none of them.
  static T? _enum<T extends Enum>(
    RequestEntity request,
    String name,
    List<T> values,
  ) {
    final raw = request.queryParam<String>(name);
    if (raw == null) return null;
    final value = values.asNameMap()[raw];
    if (value == null) {
      throw BadRequestException(
        detail: intl.errors.runs.invalidFilter(
          name: name,
          values: values.map((v) => v.name).join(', '),
        ),
      );
    }
    return value;
  }
}
