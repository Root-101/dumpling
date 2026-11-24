import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements WorkspacesRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  late _MockRepo repo;
  late _MockAuth auth;

  setUp(() {
    repo = _MockRepo();
    auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.saveLast(any())).thenAnswer((_) async {});
  });

  group('WorkspacesCubit', () {
    test('Loads the list again when a workspace changes elsewhere', () async {
      when(
        () => repo.list(token: 'jwt'),
      ).thenAnswer((_) async => [workspace('production')]);
      final cubit = WorkspacesCubit(auth: auth, repo: repo);
      addTearDown(cubit.close);
      // saved, deleted or imported in their dialogs
      GlobalEventBus()
        ..fire(WorkspaceFormProcessingOKState(workspace('production')))
        ..fire(WorkspaceFormDeletedOkState(workspace('staging')))
        ..fire(const WorkspaceTransferImportedOkState([]))
        // the canvas saved: its counts may have changed
        ..fire(const CanvasSavedOkState(data: CanvasData.empty()));
      await Future<void>.delayed(Duration.zero);
      verify(() => repo.list(token: 'jwt')).called(4);
    });

    blocTest<WorkspacesCubit, WorkspacesState>(
      'Loads the list with the token and finds the current one in it',
      setUp: () {
        when(() => repo.loadLast()).thenAnswer((_) async => 'staging');
        when(() => repo.list(token: 'jwt')).thenAnswer(
          (_) async => [workspace('production'), workspace('staging')],
        );
      },
      build: () => WorkspacesCubit(auth: auth, repo: repo),
      act: (cubit) async {
        await cubit.restore();
        await cubit.load();
      },
      skip: 2,
      expect: () => [
        isA<WorkspacesSearchOkState>()
            .having((s) => s.data.loaded, 'loaded', true)
            .having((s) => s.data.current?.slug, 'current', 'staging'),
      ],
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'Remembers the workspace the URL opens',
      build: () => WorkspacesCubit(auth: auth, repo: repo),
      act: (cubit) => cubit
        ..select('production')
        // the same one again changes nothing
        ..select('production'),
      expect: () => [
        isA<WorkspacesSearchOkState>().having(
          (s) => s.data.currentSlug,
          'slug',
          'production',
        ),
      ],
      verify: (_) => verify(() => repo.saveLast('production')).called(1),
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'Keeps what it had when the list fails',
      setUp: () =>
          when(() => repo.list(token: 'jwt')).thenThrow(apiError('down')),
      build: () => WorkspacesCubit(auth: auth, repo: repo),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<WorkspacesSearchingState>(),
        isA<WorkspacesSearchErrorState>()
            .having((s) => s.exception.message, 'message', 'down')
            .having((s) => s.data.loaded, 'loaded', false),
      ],
    );
  });
}
