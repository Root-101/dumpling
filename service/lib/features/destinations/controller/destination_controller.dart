import 'package:service/dumpling.dart';

class DestinationController {
  final DestinationService destinationService;

  DestinationController() : destinationService = di.find();

  /// Every type, the disabled ones too (the console shows them as soon).
  Future<ResponseEntity> types(RequestEntity request) async {
    return ResponseEntity.ok(body: DestinationType.values);
  }

  Future<ResponseEntity> list(RequestEntity request) async {
    final destinations = await destinationService.list(
      request.pathParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: destinations);
  }

  Future<ResponseEntity> reorder(RequestEntity request) async {
    final body = await request.body<OrderRequest>();

    final items = await destinationService.reorder(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: items);
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final destination = await destinationService.get(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('destination'),
    );
    return ResponseEntity.ok(body: destination);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final destination = await destinationService.create(
      request.pathParam<String>('workspace'),
      body,
    );
    return created(request, destination.id, destination);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final destination = await destinationService.update(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('destination'),
      body,
    );
    return ResponseEntity.ok(body: destination);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await destinationService.delete(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('destination'),
    );
    return ResponseEntity.noContent();
  }

  /// The connection of the form, before saving; `?destination=` reuses the
  /// stored secret key of the destination being edited.
  Future<ResponseEntity> testUnsaved(RequestEntity request) async {
    final body = await request.body<DestinationRequest>();

    final check = await destinationService.testUnsaved(
      request.pathParam<String>('workspace'),
      body,
      destinationId: request.queryParam<String>('destination'),
    );
    return ResponseEntity.ok(body: check);
  }

  Future<ResponseEntity> testSaved(RequestEntity request) async {
    final check = await destinationService.testSaved(
      request.pathParam<String>('workspace'),
      request.pathParam<String>('destination'),
    );
    return ResponseEntity.ok(body: check);
  }
}
