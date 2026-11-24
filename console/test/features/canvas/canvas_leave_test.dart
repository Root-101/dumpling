import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size;
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

class _MockLanguage extends MockCubit<LanguageState> implements LanguageCubit {}

class _MockWorkspaces extends MockCubit<WorkspacesState>
    implements WorkspacesCubit {}

class _MockCanvas extends MockCubit<CanvasState> implements CanvasCubit {}

class _MockBackups extends MockCubit<BackupsState> implements BackupsCubit {}

/// Leaving the canvas with edits not saved, by the rail or by signing out:
/// it asks first, and Discard drops the edits
void main() {
  final auth = _MockAuth();
  final language = _MockLanguage();
  final workspaces = _MockWorkspaces();
  final canvas = _MockCanvas();
  final backups = _MockBackups();
  final english = LanguageModel(
    icon: app.assets.icons.language.en,
    key: 'en',
    name: 'English',
  );

  setUpAll(() {
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitialState(),
    );
    whenListen(
      language,
      const Stream<LanguageState>.empty(),
      initialState: LanguageChangedState(
        current: english,
        allLanguages: [english],
      ),
    );
    whenListen(
      workspaces,
      const Stream<WorkspacesState>.empty(),
      initialState: WorkspacesSearchOkState(
        data: const WorkspacesData.empty()
            .withList([workspace('production', name: 'Production')])
            .withCurrent('production'),
      ),
    );
    whenListen(
      canvas,
      const Stream<CanvasState>.empty(),
      initialState: const CanvasInitialState(),
    );
    whenListen(
      backups,
      const Stream<BackupsState>.empty(),
      initialState: BackupsSearchOkState(
        data: const BackupsData.empty('production').withCanvas(backupCanvas()),
      ),
    );
    when(() => auth.auth).thenReturn(session());
    when(() => auth.expired).thenReturn(false);
    when(() => workspaces.load()).thenAnswer((_) async {});
    when(() => workspaces.select(any())).thenReturn(null);
    when(() => canvas.load(any())).thenAnswer((_) async {});
    when(() => backups.load(any())).thenAnswer((_) async {});
    when(() => backups.loadRecent(any())).thenAnswer((_) async {});
    // its countdown reloads the list while the page is still on its way out
    when(() => backups.reload()).thenAnswer((_) async {});
    app.di.put<AuthCubit>(auth);
    app.di.put<LanguageCubit>(language);
    app.di.put<WorkspacesCubit>(workspaces);
    app.di.put<CanvasCubit>(canvas);
    app.di.put<BackupsCubit>(backups);
  });

  setUp(() {
    clearInteractions(canvas);
    clearInteractions(auth);
    when(() => canvas.dirty).thenReturn(true);
  });

  /// Not `pumpAndSettle`: the flowing wires never settle
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openCanvas(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<LanguageCubit>.value(value: language),
          BlocProvider<WorkspacesCubit>.value(value: workspaces),
          BlocProvider<CanvasCubit>.value(value: canvas),
          BlocProvider<BackupsCubit>.value(value: backups),
        ],
        child: const App(),
      ),
    );
    await settle(tester);
    RouteConfig.router.go('/workspaces/production/canvas');
    await settle(tester);
    expect(find.byType(CanvasScreen), findsOneWidget);
  }

  testWidgets('Discard by the rail drops the edits', (tester) async {
    await openCanvas(tester);

    await tester.tap(find.byTooltip('Backups'));
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.byType(CanvasScreen), findsOneWidget);
    verifyNever(() => canvas.reset());

    await tester.tap(find.byTooltip('Backups'));
    await settle(tester);
    await tester.tap(find.text('Discard'));
    await settle(tester);
    verify(() => canvas.reset()).called(1);
    expect(find.byType(CanvasScreen), findsNothing);
  });

  testWidgets('Signing out asks first', (tester) async {
    await openCanvas(tester);

    await tester.tap(find.byTooltip('Sign out'));
    await settle(tester);
    expect(find.text('Discard the changes?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    verifyNever(() => auth.logout());

    await tester.tap(find.byTooltip('Sign out'));
    await settle(tester);
    await tester.tap(find.text('Discard'));
    await settle(tester);
    verify(() => canvas.reset()).called(1);
    verify(() => auth.logout()).called(1);
  });
}
