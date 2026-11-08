import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements RunRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  late _MockRepo repo;
  late _MockAuth auth;

  setUp(() {
    repo = _MockRepo();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        run('r3', status: RunStatus.running),
        run('r2', config: 'Hourly users', status: RunStatus.failed),
        run('r1', destinationType: 'local'),
      ],
    );
  });

  Future<RunCubit> loaded() async {
    final cubit = RunCubit(repo, auth);
    await cubit.load('production');
    return cubit;
  }

  test('the search and the filters narrow the runs loaded', () async {
    final cubit = await loaded();
    List<String> visible() =>
        cubit.state.data.visibleRuns.map((r) => r.id).toList();
    expect(visible(), ['r3', 'r2', 'r1']);

    cubit.filterStatus(RunStatus.failed);
    expect(visible(), ['r2']);
    cubit
      ..filterStatus(null)
      ..filterDestinationType('local');
    expect(visible(), ['r1']);
    expect(cubit.state.data.activeFilters, 1);

    cubit
      ..clearFilters()
      ..search('HOURLY');
    expect(visible(), ['r2']);
    cubit.clearFilters();
    expect((visible().length, cubit.state.data.activeFilters), (3, 0));
  });

  test('filters by who started a run and finds it by its label', () async {
    // startedBy reads the translations
    TestWidgetsFlutterBinding.ensureInitialized();
    when(() => repo.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        run('r4', status: RunStatus.queued, trigger: 'api', keyName: 'bot'),
        run('r3', trigger: 'api', label: 'v1.4.2', keyName: 'deploy-key'),
        run('r2', trigger: 'manual'),
        run('r1'),
      ],
    );
    final cubit = await loaded();
    List<String> visible() =>
        cubit.state.data.visibleRuns.map((r) => r.id).toList();

    cubit.filterTrigger('api');
    expect(visible(), ['r4', 'r3']);
    expect(cubit.state.data.activeFilters, 1);
    cubit
      ..clearFilters()
      ..search('v1.4');
    expect(visible(), ['r3']);
    cubit.search('deploy-key');
    expect(visible(), ['r3']);
    expect(
      cubit.state.data.visibleRuns.single.startedBy,
      contains('deploy-key'),
    );
  });

  test('a detail is kept until its run changes', () async {
    when(
      () => repo.get(
        workspace: 'production',
        id: any(named: 'id'),
        token: 'jwt',
      ),
    ).thenAnswer((i) async {
      final id = i.namedArguments[#id] as String;
      return run(
        id,
        status: id == 'r3' ? RunStatus.running : RunStatus.success,
        log: ['Connected'],
      );
    });
    final cubit = await loaded();
    await cubit.detail(cubit.state.data.runs[0]); // r3, running
    await cubit.detail(cubit.state.data.runs[2]); // r1
    expect(cubit.state.data.details.keys, {'r3', 'r1'});
    expect(cubit.state.data.details['r1']!.logText, contains('Connected'));

    // r3 ended: its detail (without log yet) is dropped, r1 stays
    when(
      () => repo.list(workspace: 'production', token: 'jwt'),
    ).thenAnswer((_) async => [run('r3'), run('r1', destinationType: 'local')]);
    await cubit.reload();
    expect(cubit.state.data.details.keys, {'r1'});
  });

  test('a detail that fails says why and keeps the list', () async {
    when(() => repo.get(workspace: 'production', id: 'r1', token: 'jwt'))
        .thenThrow(apiError('Not found'));
    final cubit = await loaded();
    await cubit.detail(cubit.state.data.runs[2]);
    expect(cubit.state, isA<RunProcessingErrorState>());
    expect((cubit.state as RunProcessingErrorState).message, 'Not found');
    expect(cubit.state.data.runs, hasLength(3));
  });
}
