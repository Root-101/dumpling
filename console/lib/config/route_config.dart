import 'package:console/app_exporter.dart';
import 'package:go_router/go_router.dart';

class RouteConfig {
  RouteConfig._();

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: 'pipeline',
        path: '/',
        builder: (context, state) => const PipelineScreen(),
      ),
    ],
  );
}
