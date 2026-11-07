import 'package:service/dumpling.dart';

class ApiKeyController {
  final ApiKeyService apiKeyService;

  ApiKeyController() : apiKeyService = ApiKeyService();

  Future<ResponseEntity> list(RequestEntity request) async {
    final keys = await apiKeyService.list(request.pathParams['slug']!);
    return ResponseEntity.ok(body: keys);
  }

  /// 201 with the key in `key`: the only answer that has it.
  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<ApiKeyRequest>();
    final key = await apiKeyService.create(request.pathParams['slug']!, body);
    return ResponseEntity(201, body: key);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<ApiKeyRequest>();
    final key = await apiKeyService.update(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      body,
    );
    return ResponseEntity.ok(body: key);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await apiKeyService.delete(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.noContent();
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();
    final keys = await apiKeyService.reorder(request.pathParams['slug']!, body);
    return ResponseEntity.ok(body: keys);
  }
}
