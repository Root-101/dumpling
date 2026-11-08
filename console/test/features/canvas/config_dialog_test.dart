import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/fixtures.dart';

void main() {
  const cron = '0 2 * * *';

  Future<void> pumpDialog(WidgetTester tester, {required bool enabled}) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeConfig.theme,
        home: const Scaffold(),
      ),
    );
    ConfigDialog.open(
      config: BackupConfig(
        id: 'cfg_nightly',
        sourceId: 'orders',
        destinationId: 'bucket',
        folderId: null,
        pos: Offset.zero,
        name: 'Nightly',
        schedule: cron,
        compression: 'gzip',
        objectKey: '{db}/{run_id}',
        enabled: enabled,
      ),
      source: sourceNode('orders'),
      destination: destinationNode('bucket'),
      onSave: (_) async => null,
    );
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
    await tester.pumpAndSettle();
  }

  testWidgets('A disabled config says so instead of its cron', (tester) async {
    await pumpDialog(tester, enabled: false);

    await next(tester); // Output
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.textContaining(cron), findsNothing);

    await next(tester); // Review
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Disabled'), findsOneWidget);
    expect(find.text('Frequency'), findsNothing);
    expect(find.text(cron), findsNothing);
  });

  testWidgets('An enabled config shows its frequency and cron', (tester) async {
    await pumpDialog(tester, enabled: true);

    await next(tester); // Output
    expect(find.text('Disabled'), findsNothing);
    expect(find.textContaining(cron), findsOneWidget);

    await next(tester); // Review
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text(cron), findsOneWidget);
    expect(find.text('Disabled'), findsNothing);
  });
}
