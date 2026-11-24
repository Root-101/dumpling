import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements LanguageRepo {}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late _MockRepo repo;

  setUp(() => repo = _MockRepo());
  tearDown(binding.platformDispatcher.clearLocaleTestValue);

  Future<String> startWith({required Locale browser, String? saved}) async {
    binding.platformDispatcher.localeTestValue = browser;
    when(() => repo.loadKey()).thenAnswer((_) async => saved);
    final cubit = LanguageCubit(repo: repo);
    await cubit.init();
    return cubit.state.current.key;
  }

  test(
    'Nothing chosen yet: the browser language when it is one of ours',
    () async {
      expect(await startWith(browser: const Locale('es', 'MX')), 'es');
      expect(await startWith(browser: const Locale('en', 'US')), 'en');
      expect(await startWith(browser: const Locale('fr')), 'en');
    },
  );

  test('The language chosen before wins over the browser', () async {
    expect(await startWith(saved: 'en', browser: const Locale('es')), 'en');
    expect(await startWith(saved: 'es', browser: const Locale('fr')), 'es');
  });
}
