import 'package:service/dumpling.dart';

class RunController {
  final RunService runService;

  RunController() : runService = RunService();

  /// `?source_type=postgres&destination_type=s3&status=failed&config=cfg_…`
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
      configId: request.queryParam<String>('config'),
    );
    return ResponseEntity.ok(body: runs);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final run = await runService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.ok(body: run);
  }

  /// 202: the run goes on in the background; its id is in the answer.
  Future<ResponseEntity> runNow(RequestEntity request) async {
    final run = await runService.runNow(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity(202, body: run);
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
