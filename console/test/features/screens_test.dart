import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size;
import 'package:mocktail/mocktail.dart';

import '../support/fixtures.dart';

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

class _MockLanguage extends MockCubit<LanguageState> implements LanguageCubit {}

class _MockRepo extends Mock implements WorkspaceRepo {}

class _MockWorkspaces extends MockCubit<WorkspaceState>
    implements WorkspaceCubit {}

/// The app as `main` runs it, at the size of a laptop screen, with the cubits
/// the router and the rail read in DI. A layout that overflows fails the test
void main() {
  final auth = _MockAuth();
  final language = _MockLanguage();
  final workspaces = _MockWorkspaces();
  final authStates = StreamController<AuthState>.broadcast();

  final english = LanguageModel(
    icon: app.assets.icons.language.en,
    key: 'en',
    name: 'English',
  );

  setUpAll(() {
    whenListen(auth, authStates.stream, initialState: AuthInitialState());
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
      const Stream<WorkspaceState>.empty(),
      initialState: WorkspaceLoadingSuccessState(
        data: const WorkspaceData.empty()
            .withList([
              workspace(
                'production',
                name: 'Production',
                configs: 3,
                destinations: 2,
                failing: 2,
                lastRunAt: DateTime.utc(2026, 10, 20, 2, 14),
              ),
              workspace('staging', name: 'Staging'),
            ])
            .withCurrent('production'),
      ),
    );
    when(() => workspaces.load()).thenAnswer((_) async {});
    when(() => workspaces.select(any())).thenReturn(null);
    app.di.put<AuthCubit>(auth);
    app.di.put<LanguageCubit>(language);
    app.di.put<WorkspaceCubit>(workspaces);
    // the dialog of a new workspace makes its own cubit with it
    app.di.put<WorkspaceRepo>(_MockRepo());
  });

  tearDownAll(authStates.close);

  /// The frames of a navigation or a dialog. Not `pumpAndSettle`: the cursor
  /// of a focused field blinks forever
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<LanguageCubit>.value(value: language),
          BlocProvider<WorkspaceCubit>.value(value: workspaces),
        ],
        child: const App(),
      ),
    );
    await settle(tester);
  }

  testWidgets('Without a session, the login asks for both fields', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(null);
    await pumpApp(tester);

    expect(find.text('Manage your database backups.'), findsOneWidget);
    expect(
      find.textContaining('DUMPLING_ADMIN_USER', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
    await settle(tester);
    expect(find.text('Required'), findsNWidgets(2));

    // A wrong password shows what the service said, with what to do
    authStates.add(
      AuthProcessingErrorState(
        GlobalException(
          type: GlobalExceptionType.auth,
          message: 'Wrong username or password',
        ),
      ),
    );
    await settle(tester);
    expect(find.text('Wrong username or password'), findsOneWidget);
    expect(find.text('Check both and try again.'), findsOneWidget);
  });

  testWidgets('The workspaces show their health, and the dialog opens', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces');
    await settle(tester);

    expect(find.text('Production'), findsOneWidget);
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('2 failing'), findsOneWidget);
    expect(find.text('Last run 20/Oct 02:14 AM UTC'), findsOneWidget);
    expect(find.text('No backups yet'), findsOneWidget);
    expect(find.text('Switch & open canvas'), findsOneWidget);
    // the failing configs on the run log of the rail
    expect(find.widgetWithText(RailBadge, '2'), findsOneWidget);

    await tester.tap(
      find.text('A fresh canvas for another environment, client or project.'),
    );
    await settle(tester);
    expect(find.text('Create workspace'), findsOneWidget);
    expect(
      find.text('A new workspace starts with an empty canvas.'),
      findsOneWidget,
    );
  });

  testWidgets('A workspace opens on its backups and becomes the current one', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces/production');
    await settle(tester);

    expect(
      RouteConfig.router.routerDelegate.currentConfiguration.uri.path,
      '/workspaces/production/backups',
    );
    expect(find.text('This screen comes next.'), findsOneWidget);
    verify(() => workspaces.select('production')).called(greaterThan(0));
  });
}
