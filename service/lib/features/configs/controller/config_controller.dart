import 'package:service/dumpling.dart';

class ConfigController {
  final ConfigService configService;

  ConfigController() : configService = ConfigService();

  Future<ResponseEntity> list(RequestEntity request) async {
    final configs = await configService.list(
      request.pathParams['slug']!,
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: configs);
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();

    final items = await configService.reorder(
      request.pathParams['slug']!,
      body,
    );
    return ResponseEntity.ok(body: items);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final config = await configService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: config);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<ConfigRequest>();

    final config = await configService.create(
      request.pathParams['slug']!,
      body,
    );
    return ResponseEntity(201, body: config);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    _reach(request);
    final body = await request.body<ConfigRequest>();

    final config = await configService.update(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      body,
    );
    return ResponseEntity.ok(body: config);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    _reach(request);
    await configService.delete(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.noContent();
  }

  /// A config an API key limited to others doesn't reach is not found.
  static void _reach(RequestEntity request) {
    final only = ApiKeyPrincipal.configsOf(request);
    final id = request.pathParams['id']!;
    if (only != null && !only.contains(id)) {
      throw NotFoundException(detail: intl.errors.configs.notFound(id: id));
    }
  }
}
