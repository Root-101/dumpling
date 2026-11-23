import 'package:service/dumpling.dart';

class ApiKeyController {
  final ApiKeyService apiKeyService;

  ApiKeyController() : apiKeyService = di.find();

  Future<ResponseEntity> list(RequestEntity request) async {
    final keys = await apiKeyService.list(
      request.pathParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: keys);
  }

  /// 201 with the key in `key`: the only answer that has it.
  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<ApiKeyRequest>();
    final key = await apiKeyService.create(
      request.pathParam<String>('workspace'),
      body,
    );
    return created(request, key.id, key);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<ApiKeyRequest>();
    final key = await apiKeyService.update(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('key'),
      body,
    );
    return ResponseEntity.ok(body: key);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await apiKeyService.delete(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('key'),
    );
    return ResponseEntity.noContent();
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();
    final keys = await apiKeyService.reorder(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: keys);
  }
}
