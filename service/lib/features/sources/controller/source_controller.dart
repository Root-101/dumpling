import 'package:service/dumpling.dart';

class SourceController {
  final SourceService sourceService;

  SourceController() : sourceService = di.find();

  /// Every type, the disabled ones too (the console shows them as soon).
  Future<ResponseEntity> types(RequestEntity request) async {
    return ResponseEntity.ok(body: SourceType.values);
  }

  Future<ResponseEntity> list(RequestEntity request) async {
    final sources = await sourceService.list(
      request.pathParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: sources);
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();

    final items = await sourceService.reorder(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: items);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final source = await sourceService.get(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('source'),
    );
    return ResponseEntity.ok(body: source);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final source = await sourceService.create(
      request.pathParam<String>('workspace'),
      body,
    );
    return created(request, source.id, source);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final source = await sourceService.update(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('source'),
      body,
    );
    return ResponseEntity.ok(body: source);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await sourceService.delete(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('source'),
    );
    return ResponseEntity.noContent();
  }

  /// The connection of the form, before saving; `?source=` reuses the stored
  /// password of the source being edited.
  Future<ResponseEntity> testUnsaved(RequestEntity request) async {
    final body = await request.body<SourceRequest>();

    final check = await sourceService.testUnsaved(
      request.pathParam<String>('workspace'),
      body,
      sourceId: request.queryParam<String>('source'),
    );
    return ResponseEntity.ok(body: check);
  }

  Future<ResponseEntity> testSaved(RequestEntity request) async {
    final check = await sourceService.testSaved(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('source'),
    );
    return ResponseEntity.ok(body: check);
  }
}
