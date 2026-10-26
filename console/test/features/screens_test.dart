import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:console/app_exporter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show Size, TextField;
import 'package:mocktail/mocktail.dart';

import '../support/fixtures.dart';

class _MockAuth extends MockCubit<AuthState> implements AuthCubit {}

class _MockLanguage extends MockCubit<LanguageState> implements LanguageCubit {}

class _MockRepo extends Mock implements WorkspaceRepo {}

class _MockSourceRepo extends Mock implements SourceRepo {}

class _MockDestinationRepo extends Mock implements DestinationRepo {}

class _MockWorkspaces extends MockCubit<WorkspaceState>
    implements WorkspaceCubit {}

class _MockSources extends MockCubit<SourceState> implements SourceCubit {}

class _MockDestinations extends MockCubit<DestinationState>
    implements DestinationCubit {}

class _MockRuns extends MockCubit<RunState> implements RunCubit {}

/// The app as `main` runs it, at the size of a laptop screen, with the cubits
/// the router and the rail read in DI. A layout that overflows fails the test
void main() {
  final auth = _MockAuth();
  final language = _MockLanguage();
  final workspaces = _MockWorkspaces();
  final sources = _MockSources();
  final destinations = _MockDestinations();
  final runs = _MockRuns();
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
    whenListen(
      sources,
      const Stream<SourceState>.empty(),
      initialState: SourceLoadingSuccessState(
        data: const SourceData.empty('production').withList(
          sourceTypes,
          [
            source('orders', lastCheck: check(CheckStatus.connected)),
            source('users', lastCheck: check(CheckStatus.failed)),
          ],
          [config('orders', 'bucket'), config('orders', 'bucket')],
        ),
      ),
    );
    whenListen(
      destinations,
      const Stream<DestinationState>.empty(),
      initialState: DestinationLoadingSuccessState(
        data: const DestinationData.empty('production').withList(
          destinationTypes,
          [
            destination('bucket', folders: ['orders', 'users']),
          ],
          [
            config('orders', 'bucket', folder: 'orders'),
            config('orders', 'bucket', folder: 'orders'),
          ],
        ),
      ),
    );
    whenListen(
      runs,
      const Stream<RunState>.empty(),
      initialState: RunLoadingSuccessState(
        data: const RunData.empty('production')
            .withRuns([
              run('r2', status: RunStatus.failed),
              run('r1', config: 'Hourly users'),
            ])
            .withDetail(
              run(
                'r2',
                status: RunStatus.failed,
                log: ['Checking the connection to orders-db', 'Failed: boom'],
              ),
            ),
      ),
    );
    when(() => runs.load(any())).thenAnswer((_) async {});
    registerFallbackValue(run('fallback'));
    when(() => runs.detail(any())).thenAnswer((_) async {});
    when(() => sources.load(any())).thenAnswer((_) async {});
    when(() => destinations.load(any())).thenAnswer((_) async {});
    when(() => workspaces.load()).thenAnswer((_) async {});
    when(() => workspaces.select(any())).thenReturn(null);
    app.di.put<AuthCubit>(auth);
    app.di.put<LanguageCubit>(language);
    app.di.put<WorkspaceCubit>(workspaces);
    app.di.put<SourceCubit>(sources);
    app.di.put<DestinationCubit>(destinations);
    app.di.put<RunCubit>(runs);
    // the dialogs and drawers make their own cubit with them
    app.di.put<WorkspaceRepo>(_MockRepo());
    app.di.put<SourceRepo>(_MockSourceRepo());
    app.di.put<DestinationRepo>(_MockDestinationRepo());
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
          BlocProvider<SourceCubit>.value(value: sources),
          BlocProvider<DestinationCubit>.value(value: destinations),
          BlocProvider<RunCubit>.value(value: runs),
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

  testWidgets('Sources: usage, status, a locked delete and the drawer', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    // straight from its URL, like a reload of the page
    RouteConfig.router.go('/workspaces/production/sources');
    await pumpApp(tester);
    await settle(tester);

    expect(find.text('orders-db'), findsOneWidget);
    expect(find.text('PostgreSQL 16'), findsNWidgets(2));
    expect(find.text('orders.internal:5432/orders'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Unreachable'), findsOneWidget);
    verify(() => sources.load('production')).called(greaterThan(0));

    // used by 2 backups: it can't be deleted, and the menu says why
    await tester.tap(find.byTooltip('Options for orders-db'));
    await settle(tester);
    expect(find.text('Used by 2 backups. Remove them first.'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settle(tester);

    await tester.tap(find.widgetWithText(PrimaryButton, 'New source'));
    await settle(tester);
    expect(find.text('Connect what you want to back up.'), findsOneWidget);
    expect(find.text('02 CONNECTION'), findsOneWidget);
    expect(find.text('Soon'), findsOneWidget);
    expect(find.text('Not tested yet'), findsOneWidget);

    await tester.tap(find.text('Connection URL').first);
    await settle(tester);
    await tester.enterText(
      find.ancestor(
        of: find.text('postgresql://user:password@host:5432/database'),
        matching: find.byType(TextField),
      ),
      'postgresql://dumpling_backup:pw@pg-billing.internal/billing',
    );
    await settle(tester);
    expect(find.text('pg-billing.internal'), findsOneWidget);
    expect(find.text('5432'), findsOneWidget);
  });

  testWidgets('Destinations: folders open under the row, and the drawer', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces/production/destinations');
    await settle(tester);

    expect(find.text('bucket'), findsOneWidget);
    expect(find.text('2 folders'), findsOneWidget);
    expect(find.text('s3.us-east-1.amazonaws.com/bucket'), findsOneWidget);
    expect(find.text('Not tested'), findsOneWidget);

    await tester.tap(find.byTooltip('Show the folders of bucket'));
    await settle(tester);
    expect(find.text('/orders'), findsOneWidget);
    expect(find.text('2 backups'), findsOneWidget);
    expect(find.text('Not used yet'), findsOneWidget);
    expect(find.text('Add folder'), findsOneWidget);

    await tester.tap(find.widgetWithText(PrimaryButton, 'New destination'));
    await settle(tester);
    expect(find.text('03 FOLDERS'), findsOneWidget);
    expect(find.text('Path-style addressing'), findsOneWidget);
  });

  testWidgets('Run log: the runs, and a row opens on its log', (tester) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces/production/runs');
    await settle(tester);

    expect(find.text('Hourly users'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('3 min 5 s'), findsNWidgets(2));
    expect(find.text('5.00 MB'), findsOneWidget);
    verify(() => runs.load('production')).called(greaterThan(0));

    await tester.tap(find.byTooltip('Show the detail').first);
    await settle(tester);
    expect(find.text('s3://bucket/orders/r2.dump.gz'), findsOneWidget);
    expect(find.text('pg_dump: connection refused'), findsOneWidget);
    expect(
      find.textContaining('Failed: boom', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Copy log'), findsOneWidget);
  });
}
