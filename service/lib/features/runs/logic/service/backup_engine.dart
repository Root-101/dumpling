import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

/// A step of a run that can't go on (a connection that fails, a server newer
/// than the dump tool…).
class RunFailure implements Exception {
  final String message;

  RunFailure(this.message);

  @override
  String toString() => message;
}

/// Runs the backups: each enabled config is a task of the [Scheduler] on its
/// cron (UTC), and can also run now. A run streams from end to end: the dump
/// tool → gzip → the destination, part by part, never on disk. One run per
/// config at a time.
class BackupEngine {
  final Scheduler scheduler;
  final ConfigTableRepo configs;
  final SourceTableRepo sources;
  final DestinationTableRepo destinations;
  final RunTableRepo runs;
  final Secrets secrets;

  /// The configs with a run in progress.
  final Set<String> _active = {};

  /// The manual runs in progress (a scheduled one is awaited by its task).
  final Set<Future<void>> _manual = {};

  BackupEngine()
    : scheduler = di.find(),
      configs = ConfigTableRepo(di.find()),
      sources = SourceTableRepo(di.find()),
      destinations = DestinationTableRepo(di.find()),
      runs = RunTableRepo(di.find()),
      secrets = Secrets();

  static String taskName(String configId) => 'config:$configId';

  /// On start: the runs a stop left half done are failed, and every enabled
  /// config gets its task.
  Future<void> start() async {
    final interrupted = await runs.failRunning(
      'Interrupted: the service stopped during the run',
    );
    if (interrupted > 0) {
      logger.warning(
        'Runs interrupted by a stop marked as failed',
        fields: {'runs': interrupted},
      );
    }
    for (final config in await configs.getAllEnabled()) {
      schedule(config);
    }
  }

  /// (Re)places the task of [config]: none while it is disabled.
  void schedule(ConfigTableData config) {
    unschedule(config.id);
    if (!config.enabled) return;
    scheduler.cron(
      config.schedule,
      utc: true,
      name: taskName(config.id),
      task: () => _scheduled(config.id),
    );
  }

  void unschedule(String configId) => scheduler[taskName(configId)]?.cancel();

  /// Starts a run of [config] now and returns it, still running; a 409 when
  /// one is already in progress.
  Future<RunTableData> runNow(ConfigTableData config) async {
    if (!_active.add(config.id)) {
      throw ConflictException(detail: intl.errors.runs.alreadyRunning);
    }
    final RunTableData run;
    try {
      run = await _begin(config, RunTrigger.manual);
    } catch (_) {
      _active.remove(config.id);
      rethrow;
    }
    final execution = _execute(config, run);
    _manual.add(execution);
    unawaited(execution.whenComplete(() => _manual.remove(execution)));
    return run;
  }

  /// Waits for the manual runs in progress (the tests, a stop).
  Future<void> idle() => Future.wait([..._manual]);

  Future<void> _scheduled(String configId) async {
    final config = await configs.byId(configId);
    // Its workspace was deleted with it
    if (config == null) return unschedule(configId);
    if (!_active.add(configId)) {
      logger.warning(
        'Scheduled run skipped: the previous one is still running',
        fields: {'config': configId},
      );
      return;
    }
    try {
      await _execute(config, await _begin(config, RunTrigger.schedule));
    } catch (_) {
      _active.remove(configId);
      rethrow;
    }
  }

  /// The row of a new run, with the names and types it uses.
  Future<RunTableData> _begin(
    ConfigTableData config,
    RunTrigger trigger,
  ) async {
    final source = (await sources.get(config.workspaceSlug, config.sourceId))!;
    final destination = (await destinations.get(
      config.workspaceSlug,
      config.destinationId,
    ))!.destination;
    final id = Secrets.newId('run_');
    await runs.insert(
      RunTableCompanion.insert(
        id: id,
        workspaceSlug: config.workspaceSlug,
        configId: Value(config.id),
        configName: config.name,
        sourceName: source.name,
        sourceType: source.type,
        destinationName: destination.name,
        destinationType: destination.type,
        trigger: trigger,
        status: RunStatus.running,
        startedAt: DateTime.now().toUtc(),
      ),
    );
    logger.info(
      'Run started',
      fields: {'config': config.id, 'run': id, 'trigger': trigger.name},
    );
    return (await runs.get(config.workspaceSlug, id))!;
  }

  /// Never throws: the run ends as success or failed, with its log.
  Future<void> _execute(ConfigTableData config, RunTableData run) async {
    final log = <RunLogLine>[];
    final watch = Stopwatch()..start();
    void write(String message) =>
        log.add(RunLogLine(DateTime.now().toUtc(), message));
    String logJson() => jsonEncode(log);

    try {
      final source = (await sources.get(
        config.workspaceSlug,
        config.sourceId,
      ))!;
      final destination = (await destinations.get(
        config.workspaceSlug,
        config.destinationId,
      ))!.destination;
      final sourceSettings = SourceSettings.fromJson(
        source.type,
        jsonDecode(source.settings) as Map<String, dynamic>,
      )!;
      final destinationSettings = DestinationSettings.fromJson(
        destination.type,
        jsonDecode(destination.settings) as Map<String, dynamic>,
      )!;
      final sourceSecrets = secrets.decrypt(source.id, source.secretsEncrypted);
      final destinationSecrets = secrets.decrypt(
        destination.id,
        destination.secretsEncrypted,
      );
      final sourceDriver = SourceDriver.drivers[source.type]!;
      final destinationDriver = DestinationDriver.drivers[destination.type]!;

      write('Checking the connection to ${source.name}');
      final check = await sourceDriver.testConnection(
        sourceSettings,
        sourceSecrets,
      );
      if (check.status != CheckStatus.connected) {
        throw RunFailure(_describe(check));
      }
      write(
        'Connected: ${[?check.serverVersion, ?check.toolVersion].join(', ')}',
      );

      final gzipped = config.compression == Compression.gzip;
      final key = ObjectKey.render(
        config.objectKey,
        at: run.startedAt,
        database: sourceDriver.databaseName(sourceSettings),
        runId: run.id,
        extension:
            sourceDriver.extension(sourceSettings) + (gzipped ? '.gz' : ''),
      );
      final location = destinationDriver.location(
        destinationSettings,
        config.folder,
        key,
      );
      await runs.update(run.id, RunTableCompanion(location: Value(location)));
      write(
        'Dumping into ${destination.name}: $location'
        '${gzipped ? ' (gzip)' : ''}',
      );

      var data = sourceDriver.dump(sourceSettings, sourceSecrets);
      if (gzipped) data = data.transform(GZipCodec(level: 6).encoder);
      final size = await destinationDriver.upload(
        destinationSettings,
        destinationSecrets,
        config.folder,
        key,
        data,
        // The progress the console shows while it runs
        onProgress: (bytes) => unawaited(
          runs.update(run.id, RunTableCompanion(sizeBytes: Value(bytes))),
        ),
      );
      write('Uploaded $size bytes in ${watch.elapsed.inSeconds} s');

      await runs.update(
        run.id,
        RunTableCompanion(
          status: const Value(RunStatus.success),
          sizeBytes: Value(size),
          log: Value(logJson()),
          finishedAt: Value(DateTime.now().toUtc()),
        ),
      );
      logger.info('Run succeeded', fields: {'run': run.id, 'bytes': size});
    } catch (e, stackTrace) {
      // The expected failures say what happened; anything else is a bug
      final expected =
          e is RunFailure || e is DumpException || e is S3ClientException;
      if (!expected) {
        logger.error('Run failed', error: e, stackTrace: stackTrace);
      }
      write('Failed: $e');
      await runs.update(
        run.id,
        RunTableCompanion(
          status: const Value(RunStatus.failed),
          error: Value('$e'),
          log: Value(logJson()),
          finishedAt: Value(DateTime.now().toUtc()),
        ),
      );
      logger.warning('Run failed', fields: {'run': run.id, 'error': '$e'});
    } finally {
      _active.remove(config.id);
    }
  }

  static String _describe(ConnectionCheck check) => switch (check.status) {
    CheckStatus.incompatible =>
      'The server (${check.serverVersion}) is newer than ${check.toolVersion}: '
          'update the dump tool',
    CheckStatus.toolMissing => 'The dump tool is not installed',
    _ => 'Could not connect: ${check.message}',
  };
}
