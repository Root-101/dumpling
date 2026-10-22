import 'dart:io';
import 'dart:math';

import 'package:winter/winter.dart';

ObjectMapper objectMapper() => ObjectMapper(
  serializers: [
    Serializer<ScheduledTask>(
      (object) => {
        'name': object.name,
        'isRunning': object.isRunning,
        'lastRun': object.lastRun,
        'nextRun': object.nextRun,
      },
    ),
  ],
);

String? _findWebBuildDir() {
  const candidatePaths = [
    '../console/build/web',
    'console/build/web',
    'build/web',
  ];
  for (final path in candidatePaths) {
    final dir = Directory(path);
    if (dir.existsSync()) {
      print('Serving static files from: ${dir.absolute.path}');
      return path;
    }
  }
  print('No static web build directory found.');
  return null;
}

void main() async {
  final Scheduler scheduler = Scheduler();
  scheduler.cron(
    '0 3 * * *',
    utc: true,
    name: 'nightly-report',
    task: () {
      print('DB dump at ${DateTime.now()}');
    },
  );

  Winter.context.setUp(objectMapper: objectMapper());

  final webDir = _findWebBuildDir();
  final StaticFiles? staticFiles =
      webDir != null ? StaticFiles(webDir) : null;

  await Winter.start(
    router: WinterRouter(
      routes: [
        Route.parent(
          path: '/api',
          routes: [
            Route.get(
              path: '/tasks',
              handler: (request) => ResponseEntity.ok(body: scheduler.tasks),
            ),
            Route.get(
              path: '/tasks/add',
              handler: (request) {
                scheduler.cron(
                  '0 3 * * *',
                  utc: true,
                  name: 'dump-${Random().nextInt(100)}',
                  task: () {
                    print('DB dump 2 at ${DateTime.now()}');
                  },
                );
                return ResponseEntity.ok(body: scheduler.tasks);
              },
            ),
            Route.get(
              path: '/tasks/delete/{task-name}',
              handler: (request) {
                ScheduledTask? task =
                    scheduler[request.pathParams['task-name']!];
                if (task == null) {
                  throw NotFoundException();
                }
                task.cancel();
                return ResponseEntity.ok(body: scheduler.tasks);
              },
            ),
          ],
        ),
        if (staticFiles != null)
          Route.get(
            path: '/{path|.*}',
            handler: (request) async {
              final path = request.pathParams['path'] ?? '';
              try {
                return await staticFiles.serve(request, path);
              } on NotFoundException {
                return await staticFiles.serve(request, 'index.html');
              }
            },
          ),
      ],
    ),
    scheduler: scheduler,
  );
}

