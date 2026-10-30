import 'package:service/dumpling.dart';

class DestinationController {
  final DestinationService destinationService;

  DestinationController() : destinationService = DestinationService();

  /// Every type, the disabled ones too (the console shows them as soon).
  Future<ResponseEntity> types(RequestEntity request) async {
    return ResponseEntity.ok(body: DestinationType.values);
  }

  Future<ResponseEntity> list(RequestEntity request) async {
    final destinations = await destinationService.list(
      request.pathParams['slug']!,
    );
    return ResponseEntity.ok(body: destinations);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final destination = await destinationService.get(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.ok(body: destination);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final destination = await destinationService.create(
      request.pathParams['slug']!,
      body,
    );
    return ResponseEntity(201, body: destination);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final destination = await destinationService.update(
      request.pathParams['slug']!,
      request.pathParams['id']!,
      body,
    );
    return ResponseEntity.ok(body: destination);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await destinationService.delete(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.noContent();
  }

  /// The connection of the form, before saving; `?destination=` reuses the
  /// stored secret key of the destination being edited.
  Future<ResponseEntity> testUnsaved(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final check = await destinationService.testUnsaved(
      request.pathParams['slug']!,
      body,
      destinationId: request.queryParam<String>('destination'),
    );
    return ResponseEntity.ok(body: check);
  }

  Future<ResponseEntity> testSaved(RequestEntity request) async {
    final check = await destinationService.testSaved(
      request.pathParams['slug']!,
      request.pathParams['id']!,
    );
    return ResponseEntity.ok(body: check);
  }
}
