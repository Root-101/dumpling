import 'package:service/dumpling.dart';

class CanvasController {
  final CanvasService canvasService;

  CanvasController() : canvasService = CanvasService();

  Future<ResponseEntity> get(RequestEntity request) async {
    final canvas = await canvasService.get(request.pathParams['slug']!);
    return ResponseEntity.ok(body: canvas);
  }

  Future<ResponseEntity> save(RequestEntity request) async {
    final body = await request.body<CanvasRequest>();

    final canvas = await canvasService.save(request.pathParams['slug']!, body);
    return ResponseEntity.ok(body: canvas);
  }
}
