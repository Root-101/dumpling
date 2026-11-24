import 'package:service/dumpling.dart';

class CanvasController {
  final CanvasService canvasService;

  CanvasController() : canvasService = di.find();

  Future<ResponseEntity> get(RequestEntity request) async {
    final canvas = await canvasService.get(
      request.pathParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: canvas);
  }

  Future<ResponseEntity> save(RequestEntity request) async {
    final body = await request.body<CanvasRequest>();

    final canvas = await canvasService.save(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: canvas);
  }
}
