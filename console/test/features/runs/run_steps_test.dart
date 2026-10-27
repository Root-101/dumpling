import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

/// [RunModel.steps], read from the lines the service writes
void main() {
  final t0 = DateTime.utc(2026, 10, 20, 2);
  RunModel run(RunStatus status, Map<int, String> log, {int? size}) => RunModel(
    id: 'r1',
    configId: 'c1',
    configName: 'Nightly',
    sourceName: 'shop',
    sourceType: 'postgres',
    destinationName: 'feather',
    destinationType: 's3',
    trigger: 'schedule',
    status: status,
    startedAt: t0,
    sizeBytes: size,
    log: [
      for (final MapEntry(key: ms, value: m) in log.entries)
        RunLogLine(t0.add(Duration(milliseconds: ms)), m),
    ],
  );
  List<RunStepState> states(RunModel r) => [for (final s in r.steps) s.state];

  test('success: both done, with how long each took', () {
    final steps = run(RunStatus.success, {
      0: 'Checking the connection to shop',
      400: 'Connected: 18.6, pg_dump 18.2',
      500: 'Dumping into feather: s3://backups/x.dump.gz (gzip)',
      5500: 'Uploaded 10 bytes in 5 s',
    }).steps;
    expect(
      [for (final s in steps) s.state],
      [RunStepState.done, RunStepState.done],
    );
    expect(steps[0].duration, const Duration(milliseconds: 400));
    expect(steps[1].duration, const Duration(seconds: 5));
  });

  test('failed before connecting: the dump is skipped', () {
    final r = run(RunStatus.failed, {
      0: 'Checking the connection to shop',
      2000: 'Failed: timeout',
    });
    expect(states(r), [RunStepState.failed, RunStepState.skipped]);
    expect(r.steps.first.duration, const Duration(seconds: 2));
  });

  test('failed while dumping: connect done, dump failed', () {
    final r = run(RunStatus.failed, {
      0: 'Checking the connection to shop',
      300: 'Connected: 18.6',
      400: 'Dumping into feather: s3://backups/x',
      900: 'Failed: pg_dump exited with code 1',
    });
    expect(states(r), [RunStepState.done, RunStepState.failed]);
  });

  test('running: no log yet, the bytes tell how far it got', () {
    expect(states(run(RunStatus.running, {})), [
      RunStepState.running,
      RunStepState.waiting,
    ]);
    expect(states(run(RunStatus.running, {}, size: 1024)), [
      RunStepState.done,
      RunStepState.running,
    ]);
  });

  test('a run of a deleted config comes without config_id', () {
    final r = RunModel.fromJson({
      'id': 'r1',
      'config_id': null,
      'config_name': 'shop',
      'source_name': 'shop',
      'source_type': 'postgres',
      'destination_name': 'feather',
      'destination_type': 's3',
      'trigger': 'manual',
      'status': 'success',
      'started_at': '2026-10-27T04:25:31Z',
    });
    expect((r.configId, r.configName), (null, 'shop'));
  });
}
