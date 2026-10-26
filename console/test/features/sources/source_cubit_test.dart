import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements SourceRepo {}

class _MockConfigs extends Mock implements ConfigRepo {}

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

  group('SourceCubit', () {
    blocTest<SourceCubit, SourceState>(
      'Counts the backups of each source',
      build: () => SourceCubit(repo, configs, auth),
      act: (cubit) => cubit.load('production'),
      skip: 1,
      expect: () => [
        isA<SourceLoadingSuccessState>()
            .having((s) => s.data.usage, 'usage', {'orders': 2, 'users': 1})
            .having((s) => s.data.visibleSources.length, 'visible', 2),
      ],
    );

    blocTest<SourceCubit, SourceState>(
      'Searches by host and filters by type over what is loaded',
      build: () => SourceCubit(repo, configs, auth),
      act: (cubit) async {
        await cubit.load('production');
        cubit
          ..search('USERS.internal')
          ..filterType('mysql');
      },
      skip: 2,
      expect: () => [
        isA<SourceLoadingSuccessState>().having(
          (s) => s.data.visibleSources.map((s) => s.id),
          'search',
          ['users'],
        ),
        isA<SourceLoadingSuccessState>()
            .having((s) => s.data.visibleSources, 'filter', isEmpty)
            .having((s) => s.data.activeFilters, 'active', 1),
      ],
    );

    blocTest<SourceCubit, SourceState>(
      'A test marks the row while it runs and keeps what it found',
      setUp: () => when(
        () =>
            repo.testSaved(workspace: 'production', id: 'orders', token: 'jwt'),
      ).thenAnswer((_) async => check(CheckStatus.failed)),
      build: () => SourceCubit(repo, configs, auth),
      act: (cubit) async {
        await cubit.load('production');
        await cubit.test(source('orders'));
      },
      skip: 2,
      expect: () => [
        isA<SourceLoadingSuccessState>().having(
          (s) => s.data.testing,
          'testing',
          {'orders'},
        ),
        isA<SourceProcessingOKState>()
            .having((s) => s.data.testing, 'testing', isEmpty)
            .having(
              (s) => s.data.sources.first.lastCheck?.status,
              'check',
              CheckStatus.failed,
            ),
      ],
    );

    blocTest<SourceCubit, SourceState>(
      'Another workspace starts from empty',
      build: () => SourceCubit(repo, configs, auth),
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
        isA<SourceLoadingInProgressState>()
            .having((s) => s.data.loaded, 'loaded', false)
            .having((s) => s.data.sources, 'sources', isEmpty),
        isA<SourceLoadingSuccessState>().having(
          (s) => s.data.workspace,
          'workspace',
          'staging',
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
        {'connection_url': 'postgresql://u:p@h/db', 'dump_format': 'custom'},
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
        },
      );
    });
  });
}
