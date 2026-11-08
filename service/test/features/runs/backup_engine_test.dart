@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:http/http.dart' as http;
import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/fake_s3.dart';
import '../../support/test_server.dart';

/// A PostgreSQL that dumps [data] without a server or pg_dump. With [failAt]
/// the dump breaks after that many bytes; with [hold] it waits for it first.
class FakeSourceDriver extends PostgresSourceDriver {
  List<int> data = utf8.encode('-- dump of orders\n' * 50);
  int? failAt;
  CheckStatus status = CheckStatus.connected;
  Completer<void>? hold;

  @override
  Future<ConnectionCheck> testConnection(
    SourceSettings settings,
    Map<String, String> secrets,
  ) async => ConnectionCheck(
    status: status,
    serverVersion: '16.4',
    toolVersion: 'pg_dump 18.0',
    message: status == CheckStatus.failed ? 'Connection refused' : null,
    durationMs: 1,
    checkedAt: DateTime.now().toUtc(),
  );

  @override
  Stream<List<int>> dump(
    SourceSettings settings,
    Map<String, String> secrets,
  ) async* {
    await hold?.future;
    for (var i = 0; i < data.length; i += 100) {
      if (failAt != null && i >= failAt!) {
        throw DumpException('pg_dump exited with code 1: connection lost');
      }
      yield data.sublist(i, i + 100 > data.length ? data.length : i + 100);
    }
  }
}

void main() {
  final server = TestServer(port: 8186);
  final s3 = FakeS3();
  final fake = FakeSourceDriver();
  final original = SourceDriver.drivers[SourceType.postgres]!;

  late String sourceId;
  late String destinationId;
  const base = '/api/workspaces/production';

  Map<String, String> jsonHeaders() => {
    ...server.auth(),
    'content-type': 'application/json',
  };

  Future<Map<String, dynamic>> post(String path, Object body) async {
    final response = await http.post(
      server.url(path),
      headers: jsonHeaders(),
      body: jsonEncode(body),
    );
    expect(response.statusCode, anyOf(200, 201, 202), reason: response.body);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getJson(String path) async => jsonDecode(
    (await http.get(server.url(path), headers: server.auth())).body,
  );

  Future<String> config({
    String name = 'Orders nightly',
    String compression = 'gzip',
    bool enabled = true,
  }) async => (await post('$base/configs', {
    'name': name,
    'source_id': sourceId,
    'destination_id': destinationId,
    'folder': 'orders',
    'compression': compression,
    'object_key': '{db}/{run_id}',
    'enabled': enabled,
  }))['id'];

  /// Runs [configId] now and waits for the run to end.
  Future<Map<String, dynamic>> runToEnd(String configId) async {
    final started = await post('$base/configs/$configId/run', {});
    expect(started['status'], 'running');
    expect(started['trigger'], 'manual');
    await di.find<BackupEngine>().idle();
    return getJson('$base/runs/${started['id']}');
  }

  setUpAll(() async {
    SourceDriver.drivers[SourceType.postgres] = fake;
    await s3.start();
    await server.start();
    await server.createWorkspace('Production');
    sourceId = (await post('$base/sources', {
      'name': 'orders-db',
      'type': 'postgres',
      'settings': {
        'host': 'pg.internal',
        'database': 'orders',
        'username': 'u',
        'password': 'p',
      },
    }))['id'];
    destinationId = (await post('$base/destinations', {
      'name': 'bucket-backups',
      'type': 's3',
      'settings': {
        'endpoint': s3.endpoint,
        'bucket': 'backups',
        'access_key_id': FakeS3.accessKeyId,
        'secret_access_key': FakeS3.secretAccessKey,
        'path_style': true,
      },
      'folders': ['orders'],
    }))['id'];
  });
  tearDownAll(() async {
    SourceDriver.drivers[SourceType.postgres] = original;
    await server.stop();
    await s3.stop();
  });
  setUp(() {
    s3.reset();
    fake
      ..failAt = null
      ..status = CheckStatus.connected
      ..hold = null;
  });

  group('BackupEngine', () {
    test('Should dump, gzip and upload a backup', () async {
      final id = await config();
      final run = await runToEnd(id);
      expect(run['status'], 'success', reason: '${run['log']}');
      expect(run['config_id'], id);
      expect(run['source_type'], 'postgres');
      expect(run['destination_type'], 's3');
      expect(run['location'], 'backups/orders/orders/${run['id']}.dump.gz');
      expect(run['finished_at'], isNotNull);
      // measured: the times are stored to the second, which made it 0
      expect(run['duration_ms'], allOf(greaterThan(0), lessThan(60000)));
      expect(run['error'], isNull);
      expect(
        (run['log'] as List).map((l) => l['message']).join('\n'),
        contains('Uploaded'),
      );

      // The config shows it as its last run, in the list and the detail
      expect((await getJson('$base/configs/$id'))['last_run']['id'], run['id']);
      final listed = await http.get(
        server.url('$base/configs'),
        headers: server.auth(),
      );
      final listedConfig = (jsonDecode(listed.body) as List).firstWhere(
        (c) => c['id'] == id,
      );
      expect(listedConfig['last_run']['status'], 'success');

      final object = s3.objects[run['location']]!;
      expect(run['size_bytes'], object.length);
      expect(gzip.decode(object), fake.data);
    });

    test('Should upload the plain dump without compression', () async {
      final run = await runToEnd(
        await config(name: 'Plain', compression: 'none'),
      );
      expect(run['location'], endsWith('.dump'));
      expect(s3.objects[run['location']], fake.data);
    });

    test('Should fail without leaving anything when the dump breaks', () async {
      fake.failAt = 300;
      final run = await runToEnd(await config(name: 'Breaks'));
      expect(run['status'], 'failed');
      expect(run['error'], contains('connection lost'));
      expect(s3.objects, isEmpty);
      expect(s3.openUploads, isEmpty);
    });

    test(
      'Should fail before dumping when the source does not connect',
      () async {
        fake.status = CheckStatus.failed;
        final run = await runToEnd(await config(name: 'Offline'));
        expect(run['status'], 'failed');
        expect(run['error'], 'Could not connect: Connection refused');
        expect(run['location'], isNull);
        expect(s3.requests, isEmpty);
      },
    );

    test(
      'Should queue a run asked for while its config runs, then start it',
      () async {
        final id = await config(name: 'Slow');
        fake.hold = Completer<void>();
        final first = await post('$base/configs/$id/run', {});
        final second = await post('$base/configs/$id/run', {'label': 'v1.4.2'});
        final third = await post('$base/configs/$id/run', {});
        expect(first['status'], 'running');
        expect(second['status'], 'queued');
        expect(second['label'], 'v1.4.2');
        expect(third['status'], 'queued');

        fake.hold!.complete();
        await di.find<BackupEngine>().idle();
        final runs = [
          for (final r in [first, second, third])
            await getJson('$base/runs/${r['id']}'),
        ];
        expect(runs.map((r) => r['status']), everyElement('success'));
        // One after the other, in the order they were asked for
        for (final (before, after) in [
          (runs[0], runs[1]),
          (runs[1], runs[2]),
        ]) {
          expect(
            DateTime.parse(after['started_at'])
                .isBefore(DateTime.parse(before['finished_at'])),
            isFalse,
          );
        }
      },
    );

    test('Should refuse a label that is not a short name (422)', () async {
      final id = await config(name: 'Labels');
      for (final label in ['has space', 'a/b', 'x' * 65]) {
        final response = await http.post(
          server.url('$base/configs/$id/run'),
          headers: jsonHeaders(),
          body: jsonEncode({'label': label}),
        );
        expect(response.statusCode, 422, reason: label);
        expect(response.body, contains('label'));
      }
    });

    test(
      'Should mark a run started with an API key, and find it by label',
      () async {
        final id = await config(name: 'Deploy');
        final key = await post('$base/keys', {
          'name': 'deploy-key',
          'permissions': ['config.run', 'run.get', 'run.list'],
          'config_ids': [id],
        });
        final started = jsonDecode(
          (await http.post(
            server.url('$base/configs/$id/run'),
            headers: {
              'authorization': 'Bearer ${key['key']}',
              'content-type': 'application/json',
            },
            body: jsonEncode({'label': 'release-42'}),
          )).body,
        );
        expect(started['trigger'], 'api');
        expect(started['key_id'], key['id']);
        expect(started['key_name'], 'deploy-key');
        expect(started['label'], 'release-42');
        await di.find<BackupEngine>().idle();

        final found = jsonDecode(
          (await http.get(
            server.url('$base/runs?label=release-42&trigger=api'),
            headers: server.auth(),
          )).body,
        ) as List;
        expect(found.single['id'], started['id']);

        // The key shows the last run it started
        final keys = jsonDecode(
          (await http.get(
            server.url('$base/keys'),
            headers: server.auth(),
          )).body,
        ) as List;
        final listed = keys.firstWhere((k) => k['id'] == key['id']);
        expect(listed['last_run']['label'], 'release-42');
        expect(listed['last_run']['config_name'], 'Deploy');
        expect(listed['last_used_at'], isNotNull);
      },
    );

    test('Should stream a run until it ends (SSE)', () async {
      RunService.eventsEvery = const Duration(milliseconds: 50);
      final id = await config(name: 'Followed');
      fake.hold = Completer<void>();
      final started = await post('$base/configs/$id/run', {});
      final request = http.Request(
        'GET',
        server.url('$base/runs/${started['id']}/events'),
      )..headers.addAll(server.auth());
      final response = await http.Client().send(request);
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], startsWith('text/event-stream'));
      final text = StringBuffer();
      final done = response.stream.transform(utf8.decoder).forEach(text.write);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      fake.hold!.complete();
      await done.timeout(const Duration(seconds: 10));

      final body = text.toString();
      expect(body, contains('event: run'));
      expect(body, contains('"status":"running"'));
      expect(body, contains('event: end'));
      final end = body.split('event: end').last;
      expect(end, contains('"status":"success"'));
      await di.find<BackupEngine>().idle();

      // A run that ended answers end at once
      final again = await http.get(
        server.url('$base/runs/${started['id']}/events'),
        headers: server.auth(),
      );
      expect(again.body, contains('event: end'));
      expect(again.body, isNot(contains('event: run')));
    });

    test('Should list the runs newest first, filtered', () async {
      final response = await http.get(
        server.url('$base/runs?status=failed&source_type=postgres'),
        headers: server.auth(),
      );
      final runs = jsonDecode(response.body) as List;
      expect(runs, isNotEmpty);
      expect(runs.every((r) => r['status'] == 'failed'), isTrue);
      expect(runs.first.containsKey('log'), isFalse);

      final invalid = await http.get(
        server.url('$base/runs?status=nope'),
        headers: server.auth(),
      );
      expect(invalid.statusCode, 400);

      // the last run of one config: what a row of Backups opens
      final configId = runs.first['config_id'];
      final last = jsonDecode(
        (await http.get(
          server.url('$base/runs?config=$configId&limit=1'),
          headers: server.auth(),
        )).body,
      ) as List;
      expect(last, hasLength(1));
      expect(last.single['config_id'], configId);
      for (final limit in ['0', '201', 'x']) {
        final bad = await http.get(
          server.url('$base/runs?limit=$limit'),
          headers: server.auth(),
        );
        expect(bad.statusCode, 400);
      }

      // The workspace counts the configs whose last run failed
      final workspaces = jsonDecode(
        (await http.get(
          server.url('/api/workspaces'),
          headers: server.auth(),
        )).body,
      ) as List;
      final stats = workspaces.single['stats'];
      expect(stats['sources'], 1);
      expect(stats['destinations'], 1);
      expect(stats['failing'], 2);
      expect(stats['running'], 0);
      expect(stats['last_run_at'], isNotNull);
      // and the sketch of its canvas: its first configs (3 at most), what
      // they connect, and the failing ones among them
      final preview = stats['preview'] as List;
      expect(stats['configs'], greaterThan(WorkspaceStats.previewConfigs));
      expect(preview, hasLength(WorkspaceStats.previewConfigs));
      expect({for (final l in preview) l['source']}, hasLength(1));
      expect(
        preview.where((l) => l['failing'] == true).length,
        lessThanOrEqualTo(stats['failing']),
      );
    });
  });

  group('Scheduling', () {
    Scheduler scheduler() => di.find<Scheduler>();

    test(
      'Should schedule each enabled config, and drop it when it goes',
      () async {
        final id = await config(name: 'Scheduled');
        final task = scheduler()[BackupEngine.taskName(id)];
        expect(task, isNotNull);
        expect(task!.nextRun, isNotNull);

        final disabled = await config(name: 'Disabled', enabled: false);
        expect(scheduler()[BackupEngine.taskName(disabled)], isNull);
        expect((await getJson('$base/configs/$disabled'))['last_run'], isNull);

        await http.delete(
          server.url('$base/configs/$id'),
          headers: server.auth(),
        );
        expect(scheduler()[BackupEngine.taskName(id)], isNull);
      },
    );

    test('Should fail the runs a stop left half done', () async {
      final db = di.find<AppDatabase>();
      // the multipart upload it had started
      final client = S3Client(
        endpoint: Uri.parse(s3.endpoint),
        region: FakeS3.region,
        bucket: 'backups',
        accessKeyId: FakeS3.accessKeyId,
        secretAccessKey: FakeS3.secretAccessKey,
        pathStyle: true,
      );
      final uploadId = await client.createMultipartUpload('orders/half.dump');
      expect(s3.openUploads, hasLength(1));
      await db
          .into(db.runTable)
          .insert(
            RunTableCompanion.insert(
              id: 'run_interrupted',
              workspaceSlug: 'production',
              configName: 'c',
              sourceName: 's',
              sourceType: SourceType.postgres,
              destinationName: 'd',
              destinationType: DestinationType.s3,
              trigger: RunTrigger.schedule,
              status: RunStatus.running,
              startedAt: DateTime.now().toUtc(),
              configId: const Value(null),
              pendingUpload: Value(
                jsonEncode({
                  'destination': destinationId,
                  'key': 'orders/half.dump',
                  'upload_id': uploadId,
                }),
              ),
            ),
          );
      // What a new start of the service does
      await BackupEngine().start();
      final run = await getJson('$base/runs/run_interrupted');
      expect(run['status'], 'failed');
      expect(run['error'], contains('Interrupted'));
      // A queued one too: nothing would start it any more
      await db
          .into(db.runTable)
          .insert(
            RunTableCompanion.insert(
              id: 'run_queued',
              workspaceSlug: 'production',
              configName: 'c',
              sourceName: 's',
              sourceType: SourceType.postgres,
              destinationName: 'd',
              destinationType: DestinationType.s3,
              trigger: RunTrigger.api,
              status: RunStatus.queued,
              startedAt: DateTime.now().toUtc(),
            ),
          );
      await BackupEngine().start();
      expect((await getJson('$base/runs/run_queued'))['status'], 'failed');
      // its parts are no longer billed
      expect(s3.openUploads, isEmpty);
      expect(s3.requests.last, startsWith('DELETE /backups/orders/half.dump'));
    });
  });

  group('PostgresSourceDriver.dump', () {
    test('Should end with an error when pg_dump is missing', () async {
      env.put('PG_DUMP_PATH', 'pg_dump_that_does_not_exist');
      final settings = PostgresSettings(
        host: 'h',
        database: 'd',
        username: 'u',
      );
      await expectLater(
        original.dump(settings, {'password': 'p'}).toList(),
        throwsA(isA<DumpException>()),
      );
    });
  });
}
