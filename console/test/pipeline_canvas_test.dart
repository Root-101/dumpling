import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  // the real fonts, so text overflows are the ones of the browser
  setUpAll(() async {
    for (final (family, files) in [
      (
        'DMSans',
        [
          'DMSans/DMSans-Regular',
          'DMSans/DMSans-Medium',
          'DMSans/DMSans-SemiBold',
          'DMSans/DMSans-Bold',
        ],
      ),
      ('JetBrainsMono', ['JetBrainsMono/JetBrainsMono-Regular']),
    ]) {
      final loader = FontLoader(family);
      for (final f in files) {
        loader.addFont(rootBundle.load('assets/fonts/$f.ttf'));
      }
      await loader.load();
    }
  });

  Future<PipelineCubit> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(theme: ThemeConfig.theme, home: const PipelineScreen()),
    );
    return BlocProvider.of<PipelineCubit>(
      tester.element(find.byType(PipelineCanvas)),
    );
  }

  /// Global position of a world point (pan 0, zoom 1)
  Offset world(WidgetTester tester, Offset p) =>
      tester.getTopLeft(find.byType(PipelineCanvas)) + p;

  testWidgets('dragging a node moves it; a click selects its config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    final before = cubit.state.source('users')!.pos;
    await tester.dragFrom(
      world(tester, before + const Offset(60, 60)),
      const Offset(30, 40),
    );
    await tester.pump();
    expect(cubit.state.source('users')!.pos, before + const Offset(30, 40));

    await tester.tapAt(
      world(tester, cubit.state.source('users')!.pos + const Offset(60, 60)),
    );
    await tester.pump();
    expect(cubit.state.selectedId, 'j2');
  });

  testWidgets('a wire from a source port to a bucket creates a config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    final s = cubit.state;
    final from = PipelineGeometry.sourceOut(s.source('users')!);
    final to = s.destination('ca')!.pos + const Offset(100, 40);
    final gesture = await tester.startGesture(world(tester, from));
    await gesture.moveTo(world(tester, (from + to) / 2));
    await tester.pump();
    expect(find.text('Config is created here'), findsWidgets);
    await gesture.moveTo(world(tester, to));
    await tester.pump();
    expect(find.text('Release to create the config'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(cubit.state.configs.length, s.configs.length + 1);
    expect(cubit.state.selected!.destinationId, 'ca');
  });

  testWidgets(
    'dragging the background pans; keys zoom, reset and close the config',
    (tester) async {
      final cubit = await pump(tester);
      final node = find.text('orders-db');
      final before = tester.getTopLeft(node);
      await tester.dragFrom(
        world(tester, const Offset(300, 700)),
        const Offset(50, 20),
      );
      await tester.pump();
      expect(tester.getTopLeft(node), before + const Offset(50, 20));

      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      await tester.pump();
      expect(tester.getTopLeft(node), before);

      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.pump();
      expect(find.text('120%'), findsOneWidget);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(find.byType(ShortcutsPanel), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cubit.state.selectedId, isNull);
    },
  );
}
