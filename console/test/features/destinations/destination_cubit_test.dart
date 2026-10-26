import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements DestinationRepo {}

class _MockConfigs extends Mock implements ConfigRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  late _MockRepo repo;
  late _MockConfigs configs;
  late _MockAuth auth;

  setUpAll(
    () => registerFallbackValue(const DestinationDraft(name: '', type: '')),
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

  group('DestinationCubit', () {
    blocTest<DestinationCubit, DestinationState>(
      'Counts the backups of each folder and of the root',
      build: () => DestinationCubit(repo, configs, auth),
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

    blocTest<DestinationCubit, DestinationState>(
      'Adding a folder sends the saved settings, its folders and no secret',
      setUp: () => when(
        () => repo.save(
          workspace: 'production',
          id: 'bucket',
          draft: any(named: 'draft'),
          token: 'jwt',
        ),
      ).thenAnswer((_) async => destination('bucket')),
      build: () => DestinationCubit(repo, configs, auth),
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
                as DestinationDraft;
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
}
