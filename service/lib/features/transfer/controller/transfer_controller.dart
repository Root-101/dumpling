import 'package:service/dumpling.dart';

class TransferController {
  final TransferService transferService;

  TransferController() : transferService = TransferService();

  /// `?workspace=<slug>` exports that one; without it, all of them.
  Future<ResponseEntity> export(RequestEntity request) async {
    final file = await transferService.export(
      slug: request.queryParam<String>('workspace'),
    );
    return ResponseEntity.ok(body: file);
  }

  Future<ResponseEntity> import(RequestEntity request) async {
    final body = await request.body<ImportRequest>();

    final workspaces = await transferService.import(body);
    return ResponseEntity(201, body: workspaces);
  }
}
