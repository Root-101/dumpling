import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements SourcesRepo {}

class _MockConfigs extends Mock implements ConfigsRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  late _MockRepo repo;
  late _MockConfigs configs;
  late _MockAuth auth;

  setUp(() {
    repo = _MockRepo();
    configs = _MockConfigs();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.types(token: 'jwt')).thenAnswer((_) async => sourceTypes);
    when(() => repo.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [source('orders'), source('users')]);
    when(() => configs.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        config('orders', 'bucket'),
        config('orders', 'bucket'),
        config('users', 'bucket'),
      ],
    );
  });

  group('SourcesCubit', () {
    blocTest<SourcesCubit, SourcesState>(
      'Counts the backups of each source',
      build: () => SourcesCubit(repo, configs, auth),
      act: (cubit) => cubit.load('production'),
      skip: 1,
      expect: () => [
        isA<SourcesLoadingSuccessState>()
            .having((s) => s.data.usage, 'usage', {'orders': 2, 'users': 1})
            .having((s) => s.data.visibleSources.length, 'visible', 2),
      ],
    );

    blocTest<SourcesCubit, SourcesState>(
      'Searches by host and filters by type over what is loaded',
      build: () => SourcesCubit(repo, configs, auth),
      act: (cubit) async {
        await cubit.load('production');
        cubit
          ..search('USERS.internal')
          ..filterType('mysql');
      },
      skip: 2,
      expect: () => [
        isA<SourcesLoadingSuccessState>().having(
          (s) => s.data.visibleSources.map((s) => s.id),
          'search',
          ['users'],
        ),
        isA<SourcesLoadingSuccessState>()
            .having((s) => s.data.visibleSources, 'filter', isEmpty)
            .having((s) => s.data.activeFilters, 'active', 1),
      ],
    );

    blocTest<SourcesCubit, SourcesState>(
      'A test marks the row while it runs and keeps what it found',
      setUp: () => when(
        () =>
            repo.testSaved(workspace: 'production', id: 'orders', token: 'jwt'),
      ).thenAnswer((_) async => check(CheckStatus.failed)),
      build: () => SourcesCubit(repo, configs, auth),
      act: (cubit) async {
        await cubit.load('production');
        await cubit.test(source('orders'));
      },
      skip: 2,
      expect: () => [
        isA<SourcesLoadingSuccessState>().having(
          (s) => s.data.testing,
          'testing',
          {'orders'},
        ),
        isA<SourcesProcessingOKState>()
            .having((s) => s.data.testing, 'testing', isEmpty)
            .having(
              (s) => s.data.sources.first.lastCheck?.status,
              'check',
              CheckStatus.failed,
            ),
      ],
    );

    blocTest<SourcesCubit, SourcesState>(
      'Another workspace starts from empty',
      build: () => SourcesCubit(repo, configs, auth),
      act: (cubit) async {
        await cubit.load('production');
        when(() => repo.list(workspace: 'staging', token: 'jwt'))
            .thenAnswer((_) async => []);
        when(() => configs.list(workspace: 'staging', token: 'jwt'))
            .thenAnswer((_) async => []);
        await cubit.load('staging');
      },
      skip: 2,
      expect: () => [
        isA<SourcesLoadingInProgressState>()
            .having((s) => s.data.loaded, 'loaded', false)
            .having((s) => s.data.sources, 'sources', isEmpty),
        isA<SourcesLoadingSuccessState>().having(
          (s) => s.data.workspace,
          'workspace',
          'staging',
        ),
      ],
    );
  });

  group('SourceFormCubit', () {
    const draft = SourceDraft(
      name: 'orders',
      type: SourceTypes.postgres,
      connectionUrl: 'postgresql://u:p@h/db',
    );

    blocTest<SourceFormCubit, SourceFormState>(
      'A new source tested in the form is tested again once saved',
      setUp: () {
        registerFallbackValue(draft);
        when(
          () => repo.save(
            workspace: 'production',
            draft: any(named: 'draft'),
            token: 'jwt',
          ),
        ).thenAnswer((_) async => source('orders'));
        when(
          () => repo.testSaved(
            workspace: 'production',
            id: 'orders',
            token: 'jwt',
          ),
        ).thenAnswer((_) async => check(CheckStatus.connected));
      },
      build: () => SourceFormCubit(repo, auth, workspace: 'production'),
      act: (cubit) => cubit.save(draft, tested: true),
      skip: 1,
      expect: () => [
        isA<SourceFormProcessingOKState>().having(
          (s) => s.source.lastCheck?.status,
          'check',
          CheckStatus.connected,
        ),
      ],
    );
  });

  group('SourceDraft', () {
    test('By URL it sends the URL; editing without a password keeps it', () {
      expect(
        const SourceDraft(
          name: 'orders',
          type: SourceTypes.postgres,
          connectionUrl: 'postgresql://u:p@h/db',
        ).toRequest().settings,
        {
          'connection_url': 'postgresql://u:p@h/db',
          'dump_format': 'custom',
          // TLS unless the admin turns it off
          'ssl_mode': 'require',
        },
      );
      expect(
        const SourceDraft(
          name: 'orders',
          type: SourceTypes.postgres,
          host: 'h',
          database: 'db',
          username: 'u',
          password: '',
        ).toRequest().settings,
        {
          'host': 'h',
          'database': 'db',
          'username': 'u',
          'dump_format': 'custom',
          'ssl_mode': 'require',
        },
      );
    });
  });

  group('SourcesCubit.reorder', () {
    List<String> ids(SourcesCubit cubit) => [
      for (final s in cubit.state.data.sources) s.id,
    ];

    test('Moves a source at once and saves the whole order', () async {
      when(
        () => repo.reorder(
          workspace: 'production',
          ids: ['users', 'orders'],
          token: 'jwt',
        ),
      ).thenAnswer((_) async {});
      final cubit = SourcesCubit(repo, configs, auth);
      await cubit.load('production');
      expect(cubit.state.data.filtered, isFalse);
      await cubit.reorder(1, 0);
      expect(ids(cubit), ['users', 'orders']);
      cubit.search('orders');
      expect(cubit.state.data.filtered, isTrue);
    });

    test('Puts it back when the service refuses it', () async {
      // the message of an unknown error comes from app.intl
      TestWidgetsFlutterBinding.ensureInitialized();
      when(
        () => repo.reorder(
          workspace: 'production',
          ids: ['users', 'orders'],
          token: 'jwt',
        ),
      ).thenThrow(Exception('down'));
      final cubit = SourcesCubit(repo, configs, auth);
      await cubit.load('production');
      await cubit.reorder(1, 0);
      expect(cubit.state, isA<SourcesProcessingErrorState>());
      expect(ids(cubit), ['orders', 'users']);
    });
  });
}
