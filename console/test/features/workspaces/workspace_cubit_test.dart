import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements WorkspaceRepo {}

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

  group('WorkspaceCubit', () {
    blocTest<WorkspaceCubit, WorkspaceState>(
      'Loads the list with the token and finds the current one in it',
      setUp: () {
        when(() => repo.loadLast()).thenAnswer((_) async => 'staging');
        when(() => repo.list(token: 'jwt')).thenAnswer(
          (_) async => [workspace('production'), workspace('staging')],
        );
      },
      build: () => WorkspaceCubit(repo, auth),
      act: (cubit) async {
        await cubit.restore();
        await cubit.load();
      },
      skip: 2,
      expect: () => [
        isA<WorkspaceLoadingSuccessState>()
            .having((s) => s.data.loaded, 'loaded', true)
            .having((s) => s.data.current?.slug, 'current', 'staging'),
      ],
    );

    blocTest<WorkspaceCubit, WorkspaceState>(
      'Remembers the workspace the URL opens',
      build: () => WorkspaceCubit(repo, auth),
      act: (cubit) => cubit
        ..select('production')
        // the same one again changes nothing
        ..select('production'),
      expect: () => [
        isA<WorkspaceLoadingSuccessState>().having(
          (s) => s.data.currentSlug,
          'slug',
          'production',
        ),
      ],
      verify: (_) => verify(() => repo.saveLast('production')).called(1),
    );

    blocTest<WorkspaceCubit, WorkspaceState>(
      'Keeps what it had when the list fails',
      setUp: () =>
          when(() => repo.list(token: 'jwt')).thenThrow(apiError('down')),
      build: () => WorkspaceCubit(repo, auth),
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<WorkspaceLoadingInProgressState>(),
        isA<WorkspaceLoadingErrorState>()
            .having((s) => s.exception.message, 'message', 'down')
            .having((s) => s.data.loaded, 'loaded', false),
      ],
    );
  });
}
