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
/// config at a time: a run asked for while one is in progress waits its turn
/// (queued); a scheduled one is skipped.
class BackupEngine {
  final Scheduler scheduler;
  final ConfigTableRepo configs;
  final SourceTableRepo sources;
  final DestinationTableRepo destinations;
  final RunTableRepo runs;
  final Secrets secrets;

  /// The configs with a run in progress.
  final Set<String> _active = {};

  /// The runs asked for while their config was busy, in order, by config:
  /// each the row being written, so the run that ends can't miss it.
  final Map<String, List<Future<RunTableData>>> _queue = {};

  /// The runs started now or from the queue (a scheduled one is awaited by
  /// its task).
  final Set<Future<void>> _manual = {};

  BackupEngine()
    : scheduler = di.find(),
      configs = ConfigTableRepo(di.find()),
      sources = SourceTableRepo(di.find()),
      destinations = DestinationTableRepo(di.find()),
      runs = RunTableRepo(di.find()),
      secrets = Secrets();

  static String taskName(String configId) => 'config:$configId';

  /// On start: the runs a stop left half done are failed, their uploads
  /// aborted, and every enabled config gets its task.
  Future<void> start() async {
    for (final run in await runs.running()) {
      if (run.pendingUpload != null) await _abortPending(run);
    }
    final interrupted = await runs.failUnfinished(
      'Interrupted: the service stopped before the run ended',
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

  /// Starts a run of [config] now and returns it: running, or queued when
  /// one of [config] is in progress (it starts once that one and those queued
  /// before it end). With [key], it was asked for with that API key.
  Future<RunTableData> runNow(
    ConfigTableData config, {
    String? label,
    ApiKeyPrincipal? key,
  }) async {
    final trigger = key == null ? RunTrigger.manual : RunTrigger.api;
    if (!_active.add(config.id)) {
      final queued = _begin(
        config,
        trigger,
        status: RunStatus.queued,
        label: label,
        key: key,
      );
      (_queue[config.id] ??= []).add(queued);
      return queued;
    }
    final RunTableData run;
    try {
      run = await _begin(config, trigger, label: label, key: key);
    } catch (_) {
      _next(config.id);
      rethrow;
    }
    _track(_execute(config, run));
    return run;
  }

  /// Waits for the runs started now, and those queued, to end (the tests).
  Future<void> idle() async {
    while (_manual.isNotEmpty) {
      await Future.wait([..._manual]);
    }
  }

  void _track(Future<void> execution) {
    _manual.add(execution);
    unawaited(execution.whenComplete(() => _manual.remove(execution)));
  }

  /// The run of [configId] ended: the next one queued starts, or the config
  /// is free.
  void _next(String configId) {
    final queue = _queue[configId];
    if (queue == null || queue.isEmpty) {
      _queue.remove(configId);
      _active.remove(configId);
      return;
    }
    final pending = queue.removeAt(0);
    _track(_startQueued(configId, pending));
  }

  Future<void> _startQueued(
    String configId,
    Future<RunTableData> pending,
  ) async {
    final RunTableData queued;
    try {
      queued = await pending;
    } catch (_) {
      // Its row was never written: the request got the error
      return _next(configId);
    }
    final config = await configs.byId(configId);
    final now = DateTime.now().toUtc();
    if (config == null) {
      await runs.update(
        queued.id,
        RunTableCompanion(
          status: const Value(RunStatus.failed),
          error: const Value('The config was deleted before the run started'),
          finishedAt: Value(now),
        ),
      );
      return _next(configId);
    }
    await runs.update(
      queued.id,
      RunTableCompanion(
        status: const Value(RunStatus.running),
        startedAt: Value(now),
      ),
    );
    logger.info(
      'Queued run started',
      fields: {'config': configId, 'run': queued.id},
    );
    await _execute(
      config,
      queued.copyWith(status: RunStatus.running, startedAt: now),
    );
  }

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
      _next(configId);
      rethrow;
    }
  }

  /// The row of a new run, with the names and types it uses.
  Future<RunTableData> _begin(
    ConfigTableData config,
    RunTrigger trigger, {
    RunStatus status = RunStatus.running,
    String? label,
    ApiKeyPrincipal? key,
  }) async {
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
        status: status,
        label: Value(label),
        keyId: Value(key?.id),
        keyName: Value(key?.name),
        startedAt: DateTime.now().toUtc(),
      ),
    );
    logger.info(
      status == RunStatus.queued ? 'Run queued' : 'Run started',
      fields: {
        'config': config.id,
        'run': id,
        'trigger': trigger.name,
        'key': ?key?.id,
        'label': ?label,
      },
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
        onPending: (pending) => unawaited(
          runs.update(
            run.id,
            RunTableCompanion(
              pendingUpload: Value(
                jsonEncode({'destination': destination.id, ...pending}),
              ),
            ),
          ),
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
          durationMs: Value(watch.elapsedMilliseconds),
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
      // Kept in every run that fails, and its text may come from a server
      final error = clipText('$e');
      write('Failed: $error');
      await runs.update(
        run.id,
        RunTableCompanion(
          status: const Value(RunStatus.failed),
          error: Value(error),
          log: Value(logJson()),
          finishedAt: Value(DateTime.now().toUtc()),
          durationMs: Value(watch.elapsedMilliseconds),
        ),
      );
      logger.warning('Run failed', fields: {'run': run.id, 'error': error});
    } finally {
      _next(config.id);
    }
  }

  /// Aborts the upload [run] left half done: its parts are billed until then.
  /// A failure only logs: a lifecycle rule of the bucket is the fallback.
  Future<void> _abortPending(RunTableData run) async {
    try {
      final pending = (jsonDecode(run.pendingUpload!) as Map<String, dynamic>)
          .cast<String, String>();
      final destination = (await destinations.get(
        run.workspaceSlug,
        pending['destination']!,
      ))?.destination;
      // Deleted since, with its credentials
      if (destination == null) return;
      await DestinationDriver.drivers[destination.type]!.abortPending(
        DestinationSettings.fromJson(
          destination.type,
          jsonDecode(destination.settings) as Map<String, dynamic>,
        )!,
        secrets.decrypt(destination.id, destination.secretsEncrypted),
        pending,
      );
      logger.info(
        'Aborted the upload of an interrupted run',
        fields: {'run': run.id},
      );
    } catch (e) {
      logger.warning(
        'Could not abort the upload of an interrupted run',
        fields: {'run': run.id, 'error': '$e'},
      );
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
