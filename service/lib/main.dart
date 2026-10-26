import 'dart:io';

import 'dumpling.dart';

// Handy commands:
// - dependencies: fvm dart pub outdated / fvm dart pub upgrade --major-versions
// - analysis: fvm dart analyze
// - i18n messages: fvm dart run slang
void main() async {
  // .env (and .env.<WINTER_PROFILE>) under the variables of the process, for
  // local development; in a container only the process ones exist
  Winter.context.setUp(env: Env.load());
  await Dumpling.start(port: env.port);
}

class Dumpling {
  /// [database] lets the tests use an in-memory database instead of the file.
  static Future<void> start({int port = 8080, AppDatabase? database}) async {
    // Every missing variable in one error, before anything is created
    env.requireAll(requiredEnvVariables);

    //--------------- Context ---------------\\
    Winter.context.setUp(
      logger: env.serviceLogger,
      localeConfig: serviceLocales(),
    );
    // Only the name of the variable, never its value
    for (final name in env.shortSecrets) {
      logger.warning(
        '$name is shorter than ${recommendedSecretLengths[name]} characters: '
        'use a long random value',
        fields: {'variable': name},
      );
    }

    //--------------- OM ---------------\\
    om
      ..addDeserializer(Deserializer<LoginRequest>.json(LoginRequest.fromJson))
      ..addDeserializer(
        Deserializer<WorkspaceRequest>.json(WorkspaceRequest.fromJson),
      )
      ..addDeserializer(
        Deserializer<SourceRequest>.json(SourceRequest.fromJson),
      )
      ..addDeserializer(
        Deserializer<DestinationRequest>.json(DestinationRequest.fromJson),
      )
      ..addDeserializer(
        Deserializer<ConfigRequest>.json(ConfigRequest.fromJson),
      )
      ..addDeserializer(
        Deserializer<CanvasRequest>.json(CanvasRequest.fromJson),
      );

    //--------------- DB ---------------\\
    di.put<AppDatabase>(database ?? AppDatabase());

    //--------------- Credentials ---------------\\
    // Of sources and destinations, stored encrypted with SECRETS_ENCRYPTION_KEY
    di.put(SecretCipher(env.secretsEncryptionKey));

    //--------------- Backups ---------------\\
    // Each enabled config is a task on its cron; Winter starts the scheduler
    // once the port is open and waits for the runs on a graceful stop
    final scheduler = Scheduler();
    di.put(scheduler);
    final engine = BackupEngine();
    di.put(engine);
    await engine.start();

    //--------------- Auth ---------------\\
    di.put(JwtService());
    di.put(
      LoginRateLimiter(
        maxFailures: env.loginMaxFailures,
        lockDuration: Duration(seconds: env.loginLockSeconds),
        failureDelay: Duration(milliseconds: env.loginFailureDelayMs),
      ),
    );

    //--------------- Routes ---------------\\
    final staticFiles = _webBuild();
    final router = WinterRouter(
      config: RouterConfig(onLoadedRoutes: DefaultOnLoadedRoutes.log()),
      routes: [
        ApiController().routing,
        // The console, when its build is next to the service (the release
        // image); in development it runs on its own
        if (staticFiles != null)
          Route.get(
            path: '/{path|.*}',
            handler: (request) async {
              final path = request.pathParams['path'] ?? '';
              // An unknown route of the API is a 404, not the console
              if (path == 'api' || path.startsWith('api/')) {
                throw NotFoundException();
              }
              try {
                return await staticFiles.serve(request, path);
              } on NotFoundException {
                // Every route of the console works on reload
                return await staticFiles.serve(request, 'index.html');
              }
            },
          ),
      ],
    );

    await Winter.start(
      config: ServerConfig(
        port: port,
        // Behind your own proxies, clientIp and the scheme of requestedUri
        // come from their X-Forwarded-* (ignored without them)
        trustedProxies: env.trustedProxies > 0
            ? TrustedProxies(env.trustedProxies)
            : null,
      ),
      globalFilterConfig: FilterConfig([
        // First: stops a flood before reading bodies or checking tokens
        if (env.rateLimitRequests > 0)
          RateLimiterFilter(
            maxRequests: env.rateLimitRequests,
            window: Duration(seconds: env.rateLimitWindowSeconds),
          ),
        // Method, path, status and time of every request
        LoggingFilter(),
      ]),
      // In development the console runs on another origin; the token goes in
      // `Authorization`, never in a cookie, so any origin is fine
      securityConfig: SecurityConfig(cors: const CorsConfig()),
      router: router,
      scheduler: scheduler,
    );
  }

  static StaticFiles? _webBuild() {
    const candidatePaths = [
      '../console/build/web',
      'console/build/web',
      'build/web',
    ];
    for (final path in candidatePaths) {
      if (Directory(path).existsSync()) {
        logger.info(
          'Serving the console',
          fields: {'path': Directory(path).absolute.path},
        );
        return StaticFiles(path);
      }
    }
    return null;
  }
}
