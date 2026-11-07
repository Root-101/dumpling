import 'package:service/dumpling.dart';

/// For load balancers and container checks: no token, and nothing in the
/// answer but whether the service and its database respond.
class HealthController {
  final HealthRepo repo;

  HealthController() : repo = HealthRepo(di.find());

  Future<ResponseEntity> health(RequestEntity request) async {
    try {
      await repo.ping();
      return ResponseEntity.ok(body: {'status': 'up'});
    } catch (e, stackTrace) {
      logger.error('Health check failed', error: e, stackTrace: stackTrace);
      return ResponseEntity(503, body: {'status': 'down'});
    }
  }
}
