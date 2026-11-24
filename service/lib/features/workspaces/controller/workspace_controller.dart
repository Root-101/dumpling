import 'package:service/dumpling.dart';

class WorkspaceController {
  final WorkspaceService workspaceService;

  WorkspaceController() : workspaceService = di.find();

  Future<ResponseEntity> list(RequestEntity request) async {
    return ResponseEntity.ok(body: await workspaceService.list());
  }

  Future<ResponseEntity> get(RequestEntity request) async {
    final workspace = await workspaceService.get(
      request.pathParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: workspace);
  }

  Future<ResponseEntity> create(RequestEntity request) async {
    final body = await request.body<WorkspaceRequest>();

    final workspace = await workspaceService.create(body);
    return created(request, workspace.slug, workspace);
  }

  Future<ResponseEntity> update(RequestEntity request) async {
    final body = await request.body<WorkspaceRequest>();

    final workspace = await workspaceService.update(
      request.pathParam<String>('workspace'),
      body,
    );
    return ResponseEntity.ok(body: workspace);
  }

  Future<ResponseEntity> delete(RequestEntity request) async {
    await workspaceService.delete(request.pathParam<String>('workspace'));
    return ResponseEntity.noContent();
  }
}
