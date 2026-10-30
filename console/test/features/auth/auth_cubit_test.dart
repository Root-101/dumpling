import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements AuthRepo {}

void main() {
  late _MockRepo repo;

  setUpAll(() => registerFallbackValue(session()));

  setUp(() {
    repo = _MockRepo();
    when(() => repo.save(any())).thenAnswer((_) async {});
    when(() => repo.clear()).thenAnswer((_) async {});
  });

  Future<AuthCubit> signedIn() async {
    when(() => repo.login(username: 'admin', password: 'right'))
        .thenAnswer((_) async => session());
    final cubit = AuthCubit(repo);
    await cubit.login(username: 'admin', password: 'right');
    return cubit;
  }

  test(
    'A refused token expires the session once and keeps the screen',
    () async {
      final cubit = await signedIn();
      final states = <AuthState>[];
      cubit.stream.listen(states.add);

      cubit
        ..expire()
        ..expire(); // every request after it fails the same way
      await pumpEventQueue();
      expect(states.whereType<AuthExpiredState>(), hasLength(1));
      expect(cubit.expired, isTrue);
      expect(cubit.auth, isNotNull); // the router does not leave the screen
      expect(cubit.username, 'admin');
    },
  );

  test(
    'A wrong password in the dialog keeps it; the right one ends it',
    () async {
      final cubit = await signedIn()
        ..expire();
      when(() => repo.login(username: 'admin', password: 'wrong')).thenThrow(
        GlobalException(type: GlobalExceptionType.auth, message: 'Wrong'),
      );

      await cubit.login(username: 'admin', password: 'wrong');
      expect(cubit.state, isA<AuthProcessingErrorState>());
      expect(cubit.auth, isNotNull);
      expect(cubit.expired, isTrue);

      await cubit.login(username: 'admin', password: 'right');
      expect(cubit.state, isA<AuthProcessingOKState>());
      expect(cubit.expired, isFalse);
    },
  );

  test('Without a session a 401 expires nothing', () {
    final cubit = AuthCubit(repo)..expire();
    expect(cubit.expired, isFalse);
  });
}
