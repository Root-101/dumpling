import 'package:console/app_exporter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockRepo extends Mock implements CanvasRepo {}

class _MockAuth extends Mock implements AuthCubit {}

class _MockSources extends Mock implements SourceRepo {}

class _MockDestinations extends Mock implements DestinationRepo {}

class _MockWorkspaces extends Mock implements WorkspaceCubit {}

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

  /// The editor with [demoCanvas] loaded
  Future<CanvasCubit> pump(WidgetTester tester, [CanvasModel? canvas]) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _MockRepo();
    final auth = _MockAuth();
    final sources = _MockSources();
    final destinations = _MockDestinations();
    when(() => auth.auth).thenReturn(session());
    when(() => repo.get(workspace: 'production', token: 'jwt'))
        .thenAnswer((_) async => canvas ?? demoCanvas());
    // the open workspace: a wire dropped on a bucket takes its defaults
    final workspaces = _MockWorkspaces();
    when(() => workspaces.state).thenReturn(
      WorkspaceLoadingSuccessState(
        data: const WorkspaceData.empty()
            .withList([
              const WorkspaceModel(
                slug: 'production',
                name: 'Production',
                defaults: (
                  schedule: '0 4 * * *',
                  compression: 'none',
                  objectKey: '{source}/{date}',
                ),
              ),
            ])
            .withCurrent('production'),
      ),
    );
    app.di.put<WorkspaceCubit>(workspaces);
    final cubit = CanvasCubit(repo, sources, destinations, auth);
    await cubit.load('production');
    await tester.pumpWidget(
      MaterialApp(
        // the dialogs and buttons of the app read it
        navigatorKey: navigatorKey,
        theme: ThemeConfig.theme,
        home: BlocProvider.value(
          value: cubit,
          // a config opens in its dialog, over the editor
          // at the origin, so world() maps the nodes as they are
          child: const Scaffold(body: CanvasEditor(center: false)),
        ),
      ),
    );
    return cubit;
  }

  /// Global position of a world point (pan 0, zoom 1)
  Offset world(WidgetTester tester, Offset p) =>
      tester.getTopLeft(find.byType(CanvasEditor)) + p;

  testWidgets('dragging a node moves it; a click selects its config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    final before = cubit.state.data.source('users')!.pos;
    await tester.dragFrom(
      world(tester, before + const Offset(60, 60)),
      const Offset(30, 40),
    );
    await tester.pump();
    expect(
      cubit.state.data.source('users')!.pos,
      before + const Offset(30, 40),
    );

    await tester.tapAt(
      world(
        tester,
        cubit.state.data.source('users')!.pos + const Offset(60, 60),
      ),
    );
    await tester.pump();
    expect(cubit.state.data.selectedId, 'j2');

    // a click that shakes 1 px moves nothing: no edit to save
    final moved = cubit.state.data.source('users')!.pos;
    await tester.dragFrom(
      world(tester, moved + const Offset(60, 60)),
      const Offset(1, 0),
    );
    await tester.pump();
    expect(cubit.state.data.source('users')!.pos, moved);
  });

  testWidgets('a wire from a source port to a bucket creates a config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    final s = cubit.state.data;
    final from = CanvasGeometry.sourceOut(s.source('users')!);
    final to = s.destination('ca')!.pos + const Offset(100, 40);
    final gesture = await tester.startGesture(world(tester, from));
    await gesture.moveTo(world(tester, from + const Offset(20, 0)));
    await tester.pump();
    await gesture.moveTo(world(tester, from + const Offset(160, 420)));
    await tester.pump();
    // over empty space, the box of the config to be, halfway along the wire
    expect(find.text('Config is created here'), findsOneWidget);
    await gesture.moveTo(world(tester, to));
    await tester.pump();
    expect(find.text('Release to create the config'), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(cubit.state.data.configs.length, s.configs.length + 1);
    expect(cubit.state.data.selected!.destinationId, 'ca');
    // with the schedule of the workspace, so its dialog shows it
    expect(cubit.state.data.selected!.schedule, '0 4 * * *');
  });

  testWidgets('only Space + drag pans; keys zoom, reset and close the config', (
    tester,
  ) async {
    final cubit = await pump(tester);
    cubit.select('j1');
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
    expect(cubit.state.data.selectedId, isNull);
  });

  testWidgets(
    'a clicked wire is removed with Delete; a source wire dropped on a config attaches it',
    (tester) async {
      final cubit = await pump(tester);
      final s = cubit.state.data;
      final (a, b) = CanvasGeometry.wireEnds(
        s,
        s.config('j2')!,
        WireEnd.source,
      )!;
      await tester.tapAt(world(tester, CanvasGeometry.curveAt(a, b, 0.5)));
      await tester.pump();
      expect(find.byTooltip('Remove connection (Del)'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(cubit.state.data.config('j2')!.sourceId, isNull);
      expect(find.byTooltip('Remove connection (Del)'), findsNothing);

      // drop the users-db wire on the orphan config
      final from = CanvasGeometry.sourceOut(s.source('users')!);
      final to = s.config('j2')!.pos + const Offset(120, 40);
      final gesture = await tester.startGesture(world(tester, from));
      await gesture.moveTo(world(tester, (from + to) / 2));
      await gesture.moveTo(world(tester, to));
      await gesture.up();
      await tester.pump();
      expect(cubit.state.data.config('j2')!.sourceId, 'users');
      expect(cubit.state.data.configs.length, s.configs.length);
    },
  );

  testWidgets(
    'right click: add from the pool on empty space, remove on a node; orphan configs warn',
    (tester) async {
      final cubit = await pump(tester);
      expect(find.byType(OrphansWarning), findsNothing);

      // empty space: add a source of the pool right there
      const spot = Offset(300, 640);
      await tester.tapAt(world(tester, spot), buttons: kSecondaryButton);
      await tester.pump();
      expect(find.text('br'), findsOneWidget);
      await tester.tap(find.text('billing-db'));
      await tester.pump();
      final added = cubit.state.data.sources.last;
      expect(added.id, 'billing');
      expect(added.pos, spot);
      expect(cubit.state.data.sourcePool, isEmpty);
      // a source without config is amber, but a save keeps it
      expect(find.byType(OrphansWarning), findsNothing);

      // on a node: take it off the canvas; its config stays, orphan
      final media = cubit.state.data.source('media')!;
      await tester.tapAt(
        world(tester, media.pos + const Offset(60, 60)),
        buttons: kSecondaryButton,
      );
      await tester.pump();
      await tester.tap(find.text('Remove from canvas'));
      await tester.pump();
      expect(cubit.state.data.source('media'), isNull);
      expect(cubit.state.data.sourcePool.single.id, 'media');
      expect(cubit.state.data.config('j3')!.sourceId, isNull);
      expect(find.text('1 incomplete config'), findsOneWidget);
    },
  );

  testWidgets('the toolbar adds what is off the canvas', (tester) async {
    final cubit = await pump(tester);
    await tester.tap(find.text('Destination'));
    await tester.pump();
    await tester.tap(find.text('br'));
    await tester.pump();
    expect(cubit.state.data.destination('br'), isNotNull);
    expect(find.text('br'), findsOneWidget); // the node, the menu is closed

    await tester.tap(find.text('Destination'));
    await tester.pump();
    expect(find.text('Every destination is on the canvas'), findsOneWidget);
  });

  testWidgets('a click on empty space clears the selection', (tester) async {
    final cubit = (await pump(tester))..select('j1');
    await tester.pump();
    await tester.tapAt(world(tester, const Offset(300, 700)));
    await tester.pump();
    expect(cubit.state.data.selectedId, isNull);
  });

  testWidgets(
    'a folder is added from its bucket, checked like the Destinations screen',
    (tester) async {
      final cubit = await pump(tester);
      final ca = cubit.state.data.destination('ca')!;
      // the button of ca is the second one: bb comes first
      await tester.tap(find.text('+ Add folder').last);
      // the wires animate forever: no pumpAndSettle
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Add a folder to ca'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Bad Name');
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(
        find.text('Lowercase letters, digits, - . _ and / between them'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), '/media/');
      await tester.tap(find.text('Add'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Add a folder to ca'), findsNothing);
      expect(cubit.state.data.destination('ca')!.folders, ['media']);
      expect(ca.folders, isEmpty);
      expect(find.text('/media'), findsOneWidget);
    },
  );

  testWidgets(
    'a click selects a config; its edit opens the dialog in steps, Save '
    'changes applies it',
    (tester) async {
      final cubit = await pump(tester);
      Future<void> settle() async {
        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.tapAt(
        world(
          tester,
          cubit.state.data.config('j1')!.pos + const Offset(40, 20),
        ),
      );
      await settle();
      expect(cubit.state.data.selectedId, 'j1');
      expect(find.text('Step 1 of 3'), findsNothing);
      expect(find.byTooltip('Run now'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit config'));
      await settle();
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.widgetWithText(TextField, '0 2 * * *'), findsOneWidget);

      // the frequency rewrites the cron field, in the dialog only
      await tester.tap(find.widgetWithText(TextButton, 'Weekly'));
      await tester.pump();
      expect(find.widgetWithText(TextField, '0 2 * * 0'), findsOneWidget);
      expect(cubit.state.data.config('j1')!.schedule, '0 2 * * *');
      // emptied, it is the default of the workspace again: not an error
      await tester.enterText(find.widgetWithText(TextField, '0 2 * * 0'), '');
      await tester.pump();
      expect(
        find.text(
          'Not a valid cron expression (minute hour day month weekday)',
        ),
        findsNothing,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nightly full'),
        'Orders',
      );
      await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
      await tester.pump();

      // an extension in the key is refused, and Next waits for it
      expect(find.text('Step 2 of 3'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, '{yyyy}/{MM}/{dd}'),
        '{db}/{yyyy}.sql',
      );
      await tester.pump();
      expect(
        find.text(
          'Leave out the extension: it is added from the dump format and the compression',
        ),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextField, '{db}/{yyyy}.sql'),
        '{db}/{yyyy}',
      );
      await tester.tap(find.widgetWithText(TextButton, 'None'));
      await tester.pump();
      await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
      await tester.pump();

      // the review has it all, and Save changes applies it to the canvas
      expect(find.text('Step 3 of 3'), findsOneWidget);
      expect(find.text('NEXT RUN WRITES'), findsOneWidget);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Save changes'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final c = cubit.state.data.config('j1')!;
      expect(
        (c.name, c.schedule, c.objectKey, c.compression),
        ('Orders', null, '{db}/{yyyy}', 'none'),
      );
    },
  );

  testWidgets('an empty workspace shows the guide until its first config', (
    tester,
  ) async {
    final demo = demoCanvas();
    final cubit = await pump(
      tester,
      CanvasModel(
        sources: const [],
        sourcePool: demo.sourcePool,
        destinations: const [],
        destinationPool: demo.destinationPool,
        configs: const [],
      ),
    );
    expect(find.byType(CanvasGuide), findsOneWidget);
    expect(find.text('YOUR FIRST BACKUP'), findsOneWidget);

    await tester.tap(find.text('Place billing-db'));
    await tester.pump();
    expect(cubit.state.data.source('billing'), isNotNull);
    await tester.tap(find.text('Place br'));
    await tester.pump();
    expect(cubit.state.data.destination('br'), isNotNull);
    expect(find.byType(CanvasGuide), findsOneWidget); // connect them is left

    cubit.connect('billing', const DropTarget('br', null));
    await tester.pump();
    expect(find.byType(CanvasGuide), findsNothing);
  });

  testWidgets('with nothing to place, the guide sends to create it', (
    tester,
  ) async {
    await pump(
      tester,
      const CanvasModel(
        sources: [],
        sourcePool: [],
        destinations: [],
        destinationPool: [],
        configs: [],
      ),
    );
    expect(find.text('Create one'), findsNWidgets(2));
  });
}
