import 'package:service/dumpling.dart';

class SourceController {
  final SourceService sourceService;

  SourceController() : sourceService = SourceService();

  /// Every type, the disabled ones too (the console shows them as soon).
  Future<ResponseEntity> types(RequestEntity request) async {
    return ResponseEntity.ok(body: SourceType.values);
  }

  Future<ResponseEntity> list(RequestEntity request) async {
    final sources = await sourceService.list(request.pathParams['slug']!);
    return ResponseEntity.ok(body: sources);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final source = await sourceService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.ok(body: source);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final source = await sourceService.create(
      request.pathParams['slug']!,
      body,
    );
    return ResponseEntity(201, body: source);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final source = await sourceService.update(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      body,
    );
    return ResponseEntity.ok(body: source);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await sourceService.delete(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.noContent();
  }

  /// The connection of the form, before saving; `?source=` reuses the stored
  /// password of the source being edited.
  Future<ResponseEntity> testUnsaved(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final check = await sourceService.testUnsaved(
      request.pathParams['slug']!,
      body,
      sourceId: request.queryParam<String>('source'),
    );
    return ResponseEntity.ok(body: check);
  }

  Future<ResponseEntity> testSaved(RequestEntity request) async {
    final check = await sourceService.testSaved(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.ok(body: check);
  }
}
