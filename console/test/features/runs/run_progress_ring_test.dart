import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required bool reduceMotion}) =>
      tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduceMotion),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RunProgressRing(size: 22, color: Color(0xFFB4A8E6)),
            ),
          ),
        ),
      );

  testWidgets('The ring of a run in progress keeps moving', (tester) async {
    await pump(tester, reduceMotion: false);
    await tester.pump(const Duration(milliseconds: 800));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('With less motion asked, it stands still', (tester) async {
    await pump(tester, reduceMotion: true);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
