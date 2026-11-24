import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements DestinationsRepo {}

class _MockConfigs extends Mock implements ConfigsRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  late _MockRepo repo;
  late _MockConfigs configs;
  late _MockAuth auth;

  setUpAll(
    () => registerFallbackValue(const DestinationFormModel(name: '', type: '')),
  );

  setUp(() {
    repo = _MockRepo();
    configs = _MockConfigs();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.types(token: 'jwt'))
        .thenAnswer((_) async => destinationTypes);
    when(() => repo.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        destination('bucket', folders: ['orders']),
      ],
    );
    when(() => configs.list(workspace: 'production', token: 'jwt')).thenAnswer(
      (_) async => [
        config('orders-db', 'bucket', folder: 'orders'),
        config('users-db', 'bucket', folder: 'orders'),
        config('auth-db', 'bucket'),
      ],
    );
  });

  group('DestinationsCubit', () {
    blocTest<DestinationsCubit, DestinationsState>(
      'Counts the backups of each folder and of the root',
      build: () => DestinationsCubit(auth: auth, repo: repo, configs: configs),
      act: (cubit) => cubit.load('production'),
      verify: (cubit) {
        final data = cubit.state.data;
        final bucket = data.destinations.single;
        expect(data.usageOf(bucket), 3);
        expect(data.folderUsageOf(bucket, 'orders'), 2);
        expect(data.folderUsageOf(bucket, null), 1);
        expect(data.folderUsageOf(bucket, 'users'), 0);
      },
    );

    blocTest<DestinationsCubit, DestinationsState>(
      'Adding a folder sends the saved settings, its folders and no secret',
      setUp: () => when(
        () => repo.save(
          workspace: 'production',
          id: 'bucket',
          draft: any(named: 'draft'),
          token: 'jwt',
        ),
      ).thenAnswer((_) async => destination('bucket')),
      build: () => DestinationsCubit(auth: auth, repo: repo, configs: configs),
      act: (cubit) async {
        await cubit.load('production');
        await cubit.addFolder(cubit.state.data.destinations.single, 'users');
      },
      verify: (_) {
        final draft =
            verify(
                  () => repo.save(
                    workspace: 'production',
                    id: 'bucket',
                    draft: captureAny(named: 'draft'),
                    token: 'jwt',
                  ),
                ).captured.single
                as DestinationFormModel;
        expect(draft.folders, ['orders', 'users']);
        expect(draft.bucket, 'bucket');
        expect(
          draft.toRequest().settings,
          isNot(contains('secret_access_key')),
        );
      },
    );
  });

  group('FolderPath', () {
    test('Cleans the slashes and follows the rules of the service', () {
      expect(FolderPath.clean(' /orders/ '), 'orders');
      expect(FolderPath.isValid('eu/billing'), isTrue);
      expect(FolderPath.isValid('Orders'), isFalse);
      expect(FolderPath.isValid('a/../b'), isFalse);
      expect(FolderPath.isValid('a//b'), isFalse);
    });
  });

  group('DestinationsCubit order', () {
    test('Moves a folder at once and saves the destination with it', () async {
      when(() => repo.list(workspace: 'production', token: 'jwt')).thenAnswer(
        (_) async => [
          destination('bucket', folders: ['orders', 'users']),
          destination('archive'),
        ],
      );
      when(
        () => repo.save(
          workspace: 'production',
          id: 'bucket',
          draft: any(named: 'draft'),
          token: 'jwt',
        ),
      ).thenAnswer(
        (_) async => destination('bucket', folders: ['users', 'orders']),
      );
      when(
        () => repo.reorder(
          workspace: 'production',
          ids: ['archive', 'bucket'],
          token: 'jwt',
        ),
      ).thenAnswer((_) async {});
      final cubit = DestinationsCubit(auth: auth, repo: repo, configs: configs);
      await cubit.load('production');

      await cubit.moveFolder(cubit.state.data.destinations.first, 1, 0);
      expect(cubit.state.data.destinations.first.folders, ['users', 'orders']);
      final draft =
          verify(
                () => repo.save(
                  workspace: 'production',
                  id: 'bucket',
                  draft: captureAny(named: 'draft'),
                  token: 'jwt',
                ),
              ).captured.single
              as DestinationFormModel;
      expect(draft.folders, ['users', 'orders']);

      await cubit.reorder(1, 0);
      expect(
        [for (final d in cubit.state.data.destinations) d.id],
        ['archive', 'bucket'],
      );
    });
  });
}
