import 'package:service/dumpling.dart';

class WorkspaceController {
  final WorkspaceService workspaceService;

  WorkspaceController() : workspaceService = WorkspaceService();

  Future<ResponseEntity> list(RequestEntity request) async {
    return ResponseEntity.ok(body: await workspaceService.list());
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final workspace = await workspaceService.get(request.pathParams['slug']!);
    return ResponseEntity.ok(body: workspace);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<WorkspaceRequest>();

    final workspace = await workspaceService.create(body);
    return ResponseEntity(201, body: workspace);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<WorkspaceRequest>();

    final workspace = await workspaceService.update(
      request.pathParams['slug']!,
      body,
    );
    return ResponseEntity.ok(body: workspace);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await workspaceService.delete(request.pathParams['slug']!);
    return ResponseEntity.noContent();
  }
}
