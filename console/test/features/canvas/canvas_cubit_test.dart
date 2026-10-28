import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements CanvasRepo {}

class _MockAuth extends Mock implements AuthCubit {}

class _MockSources extends Mock implements SourceRepo {}

class _MockDestinations extends Mock implements DestinationRepo {}

void main() {
  // the texts of a new config come from app.intl, which reads the navigator
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockRepo repo;
  late _MockSources sources;
  late _MockDestinations destinations;
  late _MockAuth auth;

  setUpAll(() {
    registerFallbackValue(const CanvasData.empty());
    registerFallbackValue(const DestinationDraft(name: '', type: ''));
  });

  setUp(() {
    repo = _MockRepo();
    sources = _MockSources();
    destinations = _MockDestinations();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.get(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => demoCanvas());
  });

  /// The cubit with [demoCanvas] loaded
  Future<CanvasCubit> loaded() async {
    final cubit = CanvasCubit(repo, sources, destinations, auth);
    await cubit.load('production');
    return cubit;
  }

  test('the nodes without position wait off the canvas', () async {
    final s = (await loaded()).state.data;
    expect(s.loaded, isTrue);
    expect(s.sources.map((x) => x.id), ['orders', 'users', 'media']);
    expect(s.sourcePool.map((x) => x.id), ['billing']);
    expect(s.destinationPool.map((x) => x.id), ['br']);
  });

  test('a load that fails keeps what there was and says why', () async {
    when(() => repo.get(workspace: 'production', token: 'jwt'))
        .thenThrow(apiError('down'));
    final cubit = CanvasCubit(repo, sources, destinations, auth);
    await cubit.load('production');
    expect(cubit.state, isA<CanvasLoadingErrorState>());
    expect(cubit.state.data.loaded, isFalse);
  });

  test('a drop on a folder row targets that folder, on a bucket without folders its root', () async {
    final s = (await loaded()).state.data;
    final bb = s.destination('bb')!;
    // second folder row of bb: its port is at y + 87 + 40
    expect(
      CanvasGeometry.hit(s.destinations, bb.pos + const Offset(10, 127)),
      const DropTarget('bb', 'users'),
    );
    expect(
      CanvasGeometry.destinationPort(bb, 'users'),
      bb.pos + const Offset(0, 127),
    );
    final ca = s.destination('ca')!;
    expect(
      CanvasGeometry.hit(s.destinations, ca.pos + const Offset(-20, 40)),
      const DropTarget('ca', null),
    );
    expect(CanvasGeometry.hit(s.destinations, const Offset(0, 0)), isNull);
  });

  test(
    'a second wire to the same place puts its config below the first',
    () async {
      final cubit = await loaded()
        ..connect('users', const DropTarget('ca', null))
        ..connect('users', const DropTarget('ca', null));
      final made = cubit.state.data.configs
          .where((c) => c.id.startsWith(CanvasCubit.newPrefix))
          .map(CanvasGeometry.configRect)
          .toList();
      expect(made, hasLength(2));
      expect(made.first.overlaps(made.last), isFalse);
    },
  );

  test('connect creates a selected config with the defaults of the workspace; any config can be deleted', () async {
    final cubit = await loaded();
    cubit.connect('users', const DropTarget('ca', null));
    final created = cubit.state.data.selected!;
    expect(created.id, startsWith(CanvasCubit.newPrefix));
    expect(created.sourceId, 'users');
    expect(
      (created.schedule, created.compression, created.objectKey),
      (null, null, null),
    );

    cubit.deleteConfig('j3'); // media is left an orphan
    expect(cubit.state.data.configs.any((c) => c.id == 'j3'), isFalse);
    expect(cubit.state.data.source('media'), isNotNull);

    cubit.deleteConfig(created.id);
    expect(cubit.state.data.configs.any((c) => c.id == created.id), isFalse);
    expect(cubit.state.data.selectedId, isNull);
  });

  test('relink moves a config to another destination', () async {
    final cubit = (await loaded())..relink('j1', const DropTarget('ca', null));
    final j1 = cubit.state.data.config('j1')!;
    expect((j1.destinationId, j1.folderId), ('ca', null));
  });

  test('disconnect leaves orphans; attachSource reconnects', () async {
    final cubit = (await loaded())
      ..disconnect('j1', WireEnd.source)
      ..disconnect('j2', WireEnd.destination);
    final s = cubit.state.data;
    final j1 = s.config('j1')!;
    final j2 = s.config('j2')!;
    expect(j1.sourceId, isNull);
    expect((j2.destinationId, j2.folderId), (null, null));
    expect(CanvasGeometry.wireEnds(s, j1, WireEnd.source), isNull);

    cubit.attachSource('users', 'j1');
    expect(cubit.state.data.config('j1')!.sourceId, 'users');
  });

  test(
    'removing a source or destination leaves its configs as orphans',
    () async {
      final cubit = await loaded();
      expect(cubit.state.data.orphans, 0);
      cubit.removeSource('media'); // j3 loses its source
      var s = cubit.state.data;
      expect(s.config('j3')!.sourceId, isNull);
      expect(s.sourcePool.last.id, 'media');
      expect(s.orphans, 1);
      // ca is amber: its only config is not a complete flow any more
      expect(s.destinationOrphan('ca'), isTrue);

      cubit.removeDestination('ca'); // j3 loses its destination too
      s = cubit.state.data;
      expect(s.config('j3')!.destinationId, isNull);
      expect(s.destinationPool.last.id, 'ca');
      expect(s.orphans, 1);

      cubit.deleteConfig('j3');
      expect(cubit.state.data.orphans, 0);
    },
  );

  test(
    'only complete flows are kept: a broken chain is orphan end to end',
    () async {
      final cubit = (await loaded())..disconnect('j1', WireEnd.destination);
      final s = cubit.state.data;
      expect(CanvasData.configOrphan(s.config('j1')!), isTrue);
      expect(s.sourceOrphan('orders'), isTrue); // its only config is broken
      expect(s.destinationOrphan('bb'), isFalse); // j2 still completes it
      expect(s.orphans, 1);
    },
  );

  test('the frequency keeps the time of the schedule', () async {
    final cubit = (await loaded())..select('j2');
    cubit.setFrequency(Frequency.weekly);
    expect(cubit.state.data.config('j2')!.schedule, '30 2 * * 0');
    cubit.setFrequency(Frequency.hourly);
    expect(cubit.state.data.config('j2')!.schedule, '30 * * * *');
    expect(Frequency.of('30 * * * *'), Frequency.hourly);
    expect(Frequency.of('*/5 * * * *'), Frequency.cron);
    cubit.setObjectKey('  ');
    expect(cubit.state.data.config('j2')!.objectKey, isNull);
  });

  test('a click on a wire picks it', () async {
    final s = (await loaded()).state.data;
    final j1 = s.config('j1')!;
    final (a, b) = CanvasGeometry.wireEnds(s, j1, WireEnd.destination)!;
    final mid = CanvasGeometry.curveAt(a, b, 0.5);
    expect(CanvasGeometry.hitWire(s, mid + const Offset(0, 3), 6), (
      'j1',
      WireEnd.destination,
    ));
    expect(CanvasGeometry.hitWire(s, const Offset(300, 700), 6), isNull);
  });

  test(
    'the save sends every source and destination, but only complete configs',
    () async {
      final cubit = (await loaded())
        ..disconnect('j1', WireEnd.destination)
        ..removeSource('media')
        ..addDestination('br', const Offset(760, 700));
      final request = cubit.state.data.toRequest().toJson();
      final sources = request['sources'] as List;
      expect(
        [for (final s in sources) '${s['id']} ${s['position']}'],
        [
          'orders {x: 40.0, y: 130.0}',
          'users {x: 40.0, y: 300.0}',
          'billing null',
          'media null',
        ],
      );
      // never a password: the service keeps the saved one
      expect(
        (sources.first['settings'] as Map).containsKey('password'),
        isFalse,
      );
      expect(
        [for (final d in request['destinations'] as List) d['id']],
        ['bb', 'ca', 'br'],
      );
      expect([for (final c in request['configs'] as List) c['id']], ['j2']);
    },
  );

  test(
    'a new config leaves out what takes the default of the workspace',
    () async {
      final cubit = (await loaded())
        ..connect('billing', const DropTarget('ca', null)) // off the canvas
        ..addSource('billing')
        ..connect('billing', const DropTarget('bb', 'orders'));
      final configs = cubit.state.data.toRequest().toJson()['configs'] as List;
      final created = configs.last as Map;
      expect(created['folder'], 'orders');
      expect(created.containsKey('schedule'), isFalse);
      expect(created.containsKey('object_key'), isFalse);
      expect(configs.length, 4);
    },
  );

  test(
    'only an edit not saved is a change; undoing it or saving leaves none',
    () async {
      final cubit = await loaded();
      final at = cubit.state.data.source('orders')!.pos;
      expect(cubit.dirty, isFalse);
      cubit.select('orders'); // not an edit
      expect(cubit.dirty, isFalse);

      cubit.move(NodeKind.source, 'orders', at + const Offset(40, 0));
      expect(cubit.dirty, isTrue);
      cubit.move(NodeKind.source, 'orders', at);
      expect(cubit.dirty, isFalse);

      cubit.move(NodeKind.source, 'orders', at + const Offset(40, 0));
      when(
        () => repo.save(
          workspace: 'production',
          data: any(named: 'data'),
          token: 'jwt',
        ),
      ).thenAnswer((i) async {
        final d = i.namedArguments[#data] as CanvasData;
        return CanvasModel(
          sources: d.sources,
          sourcePool: d.sourcePool,
          destinations: d.destinations,
          destinationPool: d.destinationPool,
          configs: d.configs,
          ids: const {},
        );
      });
      await cubit.save();
      expect(cubit.dirty, isFalse);
    },
  );

  test('after a save the selection follows the id the config got', () async {
    final cubit = (await loaded())
      ..connect('users', const DropTarget('ca', null));
    final created = cubit.state.data.selectedId!;
    final saved = demoCanvas();
    when(
      () => repo.save(
        workspace: 'production',
        data: any(named: 'data'),
        token: 'jwt',
      ),
    ).thenAnswer(
      (_) async => CanvasModel(
        sources: saved.sources,
        sourcePool: saved.sourcePool,
        destinations: saved.destinations,
        destinationPool: saved.destinationPool,
        configs: [
          ...saved.configs,
          const BackupConfig(
            id: 'cfg_new',
            sourceId: 'users',
            destinationId: 'ca',
            folderId: null,
            pos: Offset(400, 400),
            name: 'New config',
            schedule: '0 3 * * *',
          ),
        ],
        ids: {created: 'cfg_new'},
      ),
    );
    await cubit.save();
    expect(cubit.state, isA<CanvasProcessingOKState>());
    expect(cubit.state.data.selectedId, 'cfg_new');
    expect(cubit.state.data.config('cfg_new')!.schedule, '0 3 * * *');
  });

  test('a save that fails keeps the edits and says why', () async {
    final cubit = (await loaded())..removeSource('media');
    when(
      () => repo.save(
        workspace: 'production',
        data: any(named: 'data'),
        token: 'jwt',
      ),
    ).thenThrow(apiError('invalid'));
    await cubit.save();
    expect(
      cubit.state,
      isA<CanvasProcessingErrorState>().having(
        (s) => s.message,
        'message',
        'invalid',
      ),
    );
    expect(cubit.state.data.source('media'), isNull);
  });

  test(
    'the first folder of a bucket disconnects the configs on its root',
    () async {
      final cubit = (await loaded())..addFolder('ca', 'media');
      var s = cubit.state.data;
      expect(s.destination('ca')!.folders, ['media']);
      expect(s.config('j3')!.destinationId, isNull);

      cubit.addFolder('bb', 'billing'); // bb has folders: nothing moves
      s = cubit.state.data;
      expect(s.destination('bb')!.folders, ['orders', 'users', 'billing']);
      expect(s.config('j1')!.destinationId, 'bb');
      final bb = (s.toRequest().toJson()['destinations'] as List).first;
      expect(bb['folders'], ['orders', 'users', 'billing']);
    },
  );

  test('a test run checks what a complete flow uses, the folders not saved yet too', () async {
    final now = DateTime.utc(2026, 10, 26);
    when(
      () => sources.testSaved(
        workspace: 'production',
        id: any(named: 'id'),
        token: 'jwt',
      ),
    ).thenAnswer(
      (_) async =>
          ConnectionCheckModel(status: CheckStatus.connected, checkedAt: now),
    );
    when(
      () => destinations.testUnsaved(
        workspace: 'production',
        draft: any(named: 'draft'),
        destinationId: any(named: 'destinationId'),
        token: 'jwt',
      ),
    ).thenAnswer((i) async {
      final draft = i.namedArguments[#draft] as DestinationDraft;
      if (draft.bucket == 'ca') throw apiError('AccessDenied');
      return ConnectionCheckModel(
        status: CheckStatus.connected,
        checkedAt: now,
      );
    });
    final cubit = (await loaded())
      ..disconnect('j2', WireEnd.source) // users is left out
      ..addFolder('bb', 'billing');
    await cubit.testRun();

    final state = cubit.state as CanvasTestedState;
    expect(
      [for (final c in state.checks) (c.name, c.ok, c.error)],
      [
        ('orders-db', true, null),
        ('media-db', true, null),
        ('bb', true, null),
        ('ca', false, 'AccessDenied'),
      ],
    );
    final bb =
        verify(
              () => destinations.testUnsaved(
                workspace: 'production',
                draft: captureAny(named: 'draft'),
                destinationId: 'bb',
                token: 'jwt',
              ),
            ).captured.single
            as DestinationDraft;
    expect(bb.folders, ['orders', 'users', 'billing']);
    expect(bb.secretKey, isNull);
  });

  LastRun run(RunStatus status, {int? size, String? error}) => LastRun(
    id: 'run_1',
    status: status,
    startedAt: DateTime.utc(2026, 10, 26, 3),
    sizeBytes: size,
    error: error,
  );

  test(
    'run now follows the run until it ends, without moving the selection',
    () async {
      final cubit = CanvasCubit(
        repo,
        sources,
        destinations,
        auth,
        pollEvery: Duration.zero,
      );
      await cubit.load('production');
      cubit.select('j2');
      when(
        () =>
            repo.runNow(workspace: 'production', configId: 'j1', token: 'jwt'),
      ).thenAnswer((_) async => run(RunStatus.running));
      final answers = [
        run(RunStatus.running),
        run(RunStatus.success, size: 2048),
      ];
      when(() => repo.run(workspace: 'production', id: 'run_1', token: 'jwt'))
          .thenAnswer((_) async => answers.removeAt(0));

      final seen = <RunStatus?>[];
      final sub = cubit.stream.listen(
        (s) => seen.add(s.data.config('j1')!.lastRun?.status),
      );
      await cubit.runNow('j1');
      await sub.cancel();

      expect(seen.first, RunStatus.running);
      expect(
        cubit.state,
        isA<CanvasRunFinishedState>()
            .having((s) => s.configName, 'name', 'Nightly full')
            .having((s) => s.run.sizeBytes, 'size', 2048),
      );
      expect(cubit.state.data.config('j1')!.lastRun!.status, RunStatus.success);
      expect(cubit.state.data.selectedId, 'j2');
    },
  );

  test('run now while one is running says why', () async {
    final cubit = await loaded();
    when(
      () => repo.runNow(workspace: 'production', configId: 'j1', token: 'jwt'),
    ).thenThrow(apiError('A run of this config is already in progress'));
    await cubit.runNow('j1');
    expect(cubit.state, isA<CanvasProcessingErrorState>());
    expect(cubit.state.data.config('j1')!.lastRun, isNull);
  });

  test('the panel edits name, schedule, compression and enabled; the save sends them', () async {
    final cubit = (await loaded())..select('j1');
    cubit
      ..setName('Hourly orders')
      ..setSchedule('  15 * * * * ')
      ..setCompression('none')
      ..setEnabled(false)
      ..setObjectKey('{db}/{yyyy}');
    final j1 = cubit.state.data.config('j1')!;
    expect(j1.name, 'Hourly orders');
    expect(j1.schedule, '15 * * * *');
    expect(Frequency.of(j1.schedule!), Frequency.hourly);
    expect((j1.compression, j1.enabled, j1.nextRun), ('none', false, null));
    final sent =
        (cubit.state.data.toRequest().toJson()['configs'] as List).first as Map;
    expect(
      [sent['name'], sent['schedule'], sent['compression'], sent['enabled']],
      ['Hourly orders', '15 * * * *', 'none', false],
    );
    expect(sent['object_key'], '{db}/{yyyy}');
  });

  test('the rules of a config are those of the service', () {
    expect(ConfigRules.name('  '), isNotNull);
    expect(ConfigRules.name('Nightly'), isNull);
    expect(ConfigRules.cron(null), isNull); // the default of the workspace
    expect(ConfigRules.cron('0 2 * * *'), isNull);
    expect(ConfigRules.cron('*/15 1-5 * * MON'), isNull);
    expect(ConfigRules.cron('0 2 * *'), isNotNull);
    expect(ConfigRules.cron(''), isNotNull);
    expect(ConfigRules.objectKey('{db}/{yyyy}-{MM}'), isNull);
    expect(ConfigRules.objectKey('/{db}'), isNotNull);
    expect(ConfigRules.objectKey('{db}/backup.sql.gz'), isNotNull);
    expect(ConfigRules.extension(sourceNode('orders'), 'gzip'), '.dump.gz');
    expect(
      ConfigRules.extension(
        const SourceNode(
          id: 'x',
          name: 'x',
          type: SourceTypes.postgres,
          settings: {'dump_format': 'plain'},
        ),
        'none',
      ),
      '.sql',
    );
    // the custom format is compressed already; plain SQL is worth gzip
    final plain = const SourceNode(
      id: 'x',
      name: 'x',
      type: SourceTypes.postgres,
      settings: {'dump_format': 'plain'},
    );
    expect(ConfigRules.doubleCompression(sourceNode('orders'), 'gzip'), isTrue);
    expect(
      ConfigRules.doubleCompression(sourceNode('orders'), 'none'),
      isFalse,
    );
    expect(ConfigRules.doubleCompression(plain, 'gzip'), isFalse);
  });

  test('a save the service rejects names the config of each error', () async {
    final cubit = (await loaded())..disconnect('j1', WireEnd.source);
    when(
      () => repo.save(
        workspace: 'production',
        data: any(named: 'data'),
        token: 'jwt',
      ),
    ).thenThrow(
      GlobalException(
        type: GlobalExceptionType.validation,
        message: 'Validation error',
        // j1 is left out of the request: configs[0] is j2
        data: [
          ValidationError(
            source: 'configs[0].schedule',
            code: null,
            message: 'Not a valid cron expression',
          ),
        ],
      ),
    );
    await cubit.save();
    expect(
      (cubit.state as CanvasProcessingErrorState).message,
      'Nightly: Not a valid cron expression',
    );
  });
}
