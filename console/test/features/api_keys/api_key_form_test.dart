import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements ApiKeyRepo {}

class _MockConfigs extends Mock implements ConfigRepo {}

class _MockSources extends Mock implements SourceRepo {}

class _MockDestinations extends Mock implements DestinationRepo {}

class _MockAuth extends Mock implements AuthCubit {}

void main() {
  Future<void> pumpForm(WidgetTester tester, double width) async {
    final repo = _MockRepo();
    final configs = _MockConfigs();
    final sources = _MockSources();
    final destinations = _MockDestinations();
    final auth = _MockAuth();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => []);
    when(() => configs.list(workspace: 'production', token: 'jwt')).thenAnswer(
      // an id as long as a real one (in the tests each letter is a square)
      (_) async => [config('orders-database-01', 'bucket')],
    );
    when(() => sources.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [source('orders-database-01')]);
    when(() => destinations.list(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => [destination('bucket')]);
    final cubit = ApiKeyCubit(repo, configs, sources, destinations, auth);
    await cubit.load('production');

    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeConfig.theme,
        home: const Scaffold(),
      ),
    );
    ApiKeyForm.open(
      cubit,
      key: ApiKeyModel(
        id: 'key_deploy',
        name: 'deploy',
        permissions: ApiKeyPermissions.templates[ApiKeyAccess.run]!,
        configIds: const ['cfg_orders'],
        createdAt: DateTime.utc(2026, 10, 2),
      ),
    );
    await tester.pumpAndSettle();
  }

  double widthOfChip(WidgetTester tester) => tester
      .getSize(
        find
            .ancestor(
              of: find.byType(AppCopyId).first,
              matching: find.byType(InkWell),
            )
            .first,
      )
      .width;

  testWidgets('The configs go in two columns in a wide dialog', (tester) async {
    await pumpForm(tester, 1440);
    // 760 of the dialog, 24 of padding on each side and 8 between columns
    expect(widthOfChip(tester), closeTo((760 - 48 - 8) / 2, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('In a narrow window each config takes a whole row and fits', (
    tester,
  ) async {
    await pumpForm(tester, 560);
    // the margins of the dialog, its close button and its padding
    expect(widthOfChip(tester), closeTo(560 - 32 - 28 - 48, 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('A name cut to fit has the whole of it in a tooltip', (
    tester,
  ) async {
    await pumpForm(tester, 1440);
    expect(find.byTooltip('orders-database-01'), findsOneWidget);
    expect(find.byTooltip('orders-database-01-db → bucket'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
