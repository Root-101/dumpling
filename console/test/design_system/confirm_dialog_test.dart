import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'A confirmation as tall as its text: a long one never overflows',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeConfig.theme,
          home: const Scaffold(),
        ),
      );
      ConfirmDialog.show(
        title: 'Delete the destination feather?',
        // longer than the one that overflowed the dialog of fixed height
        description: List.filled(
          4,
          "It isn't used by any backup. The files already in the bucket stay there.",
        ).join(' '),
        confirmTitle: 'Delete',
        confirmColor: app.colors.primary.errorAction,
        confirmAction: () {},
      );
      await tester.pumpAndSettle();

      // an overflow would have failed the pump; the buttons are inside it
      expect(find.text('Delete the destination feather?'), findsOneWidget);
      final dialog = tester.getRect(find.byType(Dialog));
      for (final button in ['Cancel', 'Delete']) {
        expect(dialog.contains(tester.getCenter(find.text(button))), isTrue);
      }
    },
  );
}
