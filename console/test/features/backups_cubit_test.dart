import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/fixtures.dart';

class _MockRepo extends Mock implements CanvasRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  // the labels of the frequencies come from app.intl
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockRepo repo;
  late _MockAuth auth;

  setUp(() {
    repo = _MockRepo();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.get(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => backupCanvas());
  });

  Future<BackupCubit> loaded() async {
    final cubit = BackupCubit(repo, auth, pollEvery: Duration.zero);
    await cubit.load('production');
    return cubit;
  }

  List<String> visible(BackupCubit cubit) =>
      cubit.state.data.visible.map((b) => b.config.id).toList();

  test('the summary counts each health and finds the next run', () async {
    final data = (await loaded()).state.data;
    expect(data.backups.map((b) => b.health), [
      BackupHealth.healthy,
      BackupHealth.failing,
      BackupHealth.paused,
    ]);
    expect(data.backups.first.source.id, 'orders');
    expect(
      (data.count(BackupHealth.healthy), data.count(BackupHealth.failing)),
      (1, 1),
    );
    expect(data.next!.config.id, 'j1');
  });

  test('the filter, the search and the sort', () async {
    final cubit = await loaded();
    // by name: Nightly, Nightly full, Weekly archive
    expect(visible(cubit), ['j2', 'j1', 'j3']);
    cubit.sort(BackupSort.lastRun);
    expect(visible(cubit), ['j2', 'j1', 'j3']);
    cubit.sort(BackupSort.nextRun);
    expect(visible(cubit), ['j1', 'j2', 'j3']);

    cubit.filterHealth(BackupHealth.failing);
    expect(visible(cubit), ['j2']);
    cubit
      ..clearFilters()
      ..search('media');
    expect(visible(cubit), ['j3']);
  });

  test('Run now follows the run until it ends', () async {
    final started = DateTime.utc(2026, 10, 21);
    when(
      () => repo.runNow(workspace: 'production', configId: 'j2', token: 'jwt'),
    ).thenAnswer(
      (_) async =>
          LastRun(id: 'r9', status: RunStatus.running, startedAt: started),
    );
    when(() => repo.run(workspace: 'production', id: 'r9', token: 'jwt'))
        .thenAnswer(
          (_) async => LastRun(
            id: 'r9',
            status: RunStatus.success,
            startedAt: started,
            sizeBytes: 10,
          ),
        );
    final cubit = await loaded();
    final states = <BackupState>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.runNow(cubit.state.data.backups[1]);
    await sub.cancel();

    expect(states.first.data.backups[1].health, BackupHealth.running);
    expect(cubit.state, isA<BackupRunFinishedState>());
    expect(cubit.state.data.backups[1].health, BackupHealth.healthy);
  });
}
