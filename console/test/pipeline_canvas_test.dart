import 'package:console/app_exporter.dart';
import 'package:flutter/gestures.dart';
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

  testWidgets('only Space + drag pans; keys zoom, reset and close the config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    final node = find.text('orders-db');
    final before = tester.getTopLeft(node);
    // a plain drag on the background does nothing
    await tester.dragFrom(
      world(tester, const Offset(300, 700)),
      const Offset(50, 20),
    );
    await tester.pump();
    expect(tester.getTopLeft(node), before);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
    await tester.dragFrom(
      world(tester, const Offset(300, 700)),
      const Offset(50, 20),
    );
    await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(tester.getTopLeft(node), before + const Offset(50, 20));

    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pump();
    expect(tester.getTopLeft(node), before);

    await tester.sendKeyEvent(LogicalKeyboardKey.equal);
    await tester.pump();
    expect(find.text('120%'), findsOneWidget);

    // shortcuts are a popover, closed at start
    expect(find.byType(ShortcutsPanel), findsNothing);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(find.byType(ShortcutsPanel), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(cubit.state.selectedId, isNull);
  });

  testWidgets(
    'a clicked wire is removed with Delete; a source wire dropped on a config attaches it',
    (tester) async {
      final cubit = await pump(tester);
      final s = cubit.state;
      final (a, b) = PipelineGeometry.wireEnds(
        s,
        s.config('j2')!,
        WireEnd.source,
      )!;
      await tester.tapAt(world(tester, PipelineGeometry.curveAt(a, b, 0.5)));
      await tester.pump();
      expect(find.byTooltip('Remove connection (Del)'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(cubit.state.config('j2')!.sourceId, isNull);
      expect(find.byTooltip('Remove connection (Del)'), findsNothing);

      // drop the users-db wire on the orphan config
      final from = PipelineGeometry.sourceOut(s.source('users')!);
      final to = s.config('j2')!.pos + const Offset(120, 40);
      final gesture = await tester.startGesture(world(tester, from));
      await gesture.moveTo(world(tester, (from + to) / 2));
      await gesture.moveTo(world(tester, to));
      await gesture.up();
      await tester.pump();
      expect(cubit.state.config('j2')!.sourceId, 'users');
      expect(cubit.state.configs.length, s.configs.length);
    },
  );

  testWidgets(
    'right click: add on empty space, delete on a node; orphans warn',
    (tester) async {
      final cubit = await pump(tester);
      expect(find.byType(OrphansWarning), findsNothing);

      // empty space: add a database right there
      const spot = Offset(300, 640);
      await tester.tapAt(world(tester, spot), buttons: kSecondaryButton);
      await tester.pump();
      expect(find.text('Add destination'), findsOneWidget);
      await tester.tap(find.text('Add database'));
      await tester.pump();
      final added = cubit.state.sources.last;
      expect(added.id, 'billing');
      expect(added.pos, spot);
      expect(find.text('Add database'), findsNothing);
      // a source no config uses is an orphan
      expect(find.text('1 unconnected item'), findsOneWidget);

      // on a node: delete it; its config stays, orphan
      final media = cubit.state.source('media')!;
      await tester.tapAt(
        world(tester, media.pos + const Offset(60, 60)),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.tap(find.text('Delete database'));
      await tester.pump();
      expect(cubit.state.source('media'), isNull);
      expect(cubit.state.config('j3')!.sourceId, isNull);
      // billing-db, j3 and cold-archive (its only flow is broken)
      expect(find.text('3 unconnected items'), findsOneWidget);
    },
  );

  testWidgets('a click on empty space clears the selection', (tester) async {
    final cubit = await pump(tester);
    expect(cubit.state.selectedId, 'j1');
    await tester.tapAt(world(tester, const Offset(300, 700)));
    await tester.pump();
    expect(cubit.state.selectedId, isNull);
  });
}
