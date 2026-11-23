import 'package:service/dumpling.dart';

class ConfigController {
  final ConfigService configService;

  ConfigController() : configService = di.find();

  Future<ResponseEntity> list(RequestEntity request) async {
    final configs = await configService.list(
      request.pathParam<String>('workspace'),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: configs);
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();

    final items = await configService.reorder(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: items);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final config = await configService.get(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('config'),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: config);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<ConfigRequest>();

    final config = await configService.create(
      request.pathParam<String>('workspace'),
      body,
    );
    return created(request, config.id, config);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final config = await configService.update(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('config'),
      await request.body<ConfigRequest>(),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.ok(body: config);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await configService.delete(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('config'),
      only: ApiKeyPrincipal.configsOf(request),
    );
    return ResponseEntity.noContent();
  }
}
