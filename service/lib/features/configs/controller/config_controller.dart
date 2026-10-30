import 'package:service/dumpling.dart';

class ConfigController {
  final ConfigService configService;

  ConfigController() : configService = ConfigService();

  Future<ResponseEntity> list(RequestEntity request) async {
    final configs = await configService.list(request.pathParams['slug']!);
    return ResponseEntity.ok(body: configs);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final config = await configService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
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
    final body = await request.body<ConfigRequest>();

    final config = await configService.update(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      body,
    );
    return ResponseEntity.ok(body: config);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await configService.delete(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.noContent();
  }
}
