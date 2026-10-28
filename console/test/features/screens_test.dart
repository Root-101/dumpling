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

class _MockBackups extends MockCubit<BackupState> implements BackupCubit {}

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
  final backups = _MockBackups();
  final workspaceRepo = _MockRepo();
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
    whenListen(
      backups,
      const Stream<BackupState>.empty(),
      initialState: BackupLoadingSuccessState(
        data: const BackupData.empty('production').withCanvas(backupCanvas()),
      ),
    );
    when(() => backups.load(any())).thenAnswer((_) async {});
    when(() => backups.loadRecent(any())).thenAnswer((_) async {});
    registerFallbackValue(run('fallback'));
    when(() => runs.detail(any(), workspace: any(named: 'workspace')))
        .thenAnswer((_) async {});
    // the dialog of a URL takes the run of the log
    when(() => runs.find(any(), any())).thenAnswer(
      (i) async => runs.state.data.runs
          .where((r) => r.id == i.positionalArguments[1])
          .firstOrNull,
    );
    when(() => sources.load(any())).thenAnswer((_) async {});
    when(() => destinations.load(any())).thenAnswer((_) async {});
    when(() => workspaces.load()).thenAnswer((_) async {});
    when(() => auth.expired).thenReturn(false);
    when(() => workspaces.select(any())).thenReturn(null);
    app.di.put<AuthCubit>(auth);
    app.di.put<LanguageCubit>(language);
    app.di.put<WorkspaceCubit>(workspaces);
    app.di.put<SourceCubit>(sources);
    app.di.put<DestinationCubit>(destinations);
    app.di.put<RunCubit>(runs);
    app.di.put<BackupCubit>(backups);
    // the dialogs and drawers make their own cubit with them
    app.di.put<WorkspaceRepo>(workspaceRepo);
    registerFallbackValue(const WorkspaceDraft(name: 'fallback'));
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
          BlocProvider<BackupCubit>.value(value: backups),
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

    // created, it opens on its backups
    when(
      () => workspaceRepo.create(
        draft: any(named: 'draft'),
        token: any(named: 'token'),
      ),
    ).thenAnswer((_) async => const WorkspaceModel(slug: 'qa', name: 'QA'));
    when(() => backups.load(any())).thenAnswer((_) async {});
    await tester.enterText(find.byType(TextField).first, 'QA');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Create workspace'));
    await settle(tester);
    expect(
      RouteConfig.router.routerDelegate.currentConfiguration.uri.path,
      '/workspaces/qa/backups',
    );
  });

  testWidgets('The settings of a workspace edit it and keep its defaults', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    when(
      () => workspaceRepo.update(
        slug: any(named: 'slug'),
        draft: any(named: 'draft'),
        token: any(named: 'token'),
      ),
    ).thenAnswer(
      (_) async => const WorkspaceModel(slug: 'staging', name: 'QA'),
    );
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces');
    await settle(tester);

    // the card has no Backups button nor menu: its settings
    expect(find.widgetWithText(PrimaryButton, 'Backups'), findsNothing);
    await tester.tap(find.byTooltip('Settings for Staging'));
    await settle(tester);
    expect(find.text('WORKSPACE SETTINGS'), findsOneWidget);
    expect(find.text('Defaults for new configs'), findsOneWidget);
    expect(find.text('Danger zone'), findsOneWidget);

    // Edit, and a new name in the header as it is typed
    await tester.tap(find.widgetWithText(PrimaryButton, 'Edit'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).first, 'QA');
    await settle(tester);
    expect(find.text('You have unsaved changes'), findsOneWidget);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Save changes'));
    await settle(tester);

    // the update sends the defaults too: the service replaces everything
    final draft =
        verify(
              () => workspaceRepo.update(
                slug: 'staging',
                draft: captureAny(named: 'draft'),
                token: any(named: 'token'),
              ),
            ).captured.single
            as WorkspaceDraft;
    expect(draft.name, 'QA');
    expect(draft.description, 'About staging');
    expect(draft.defaults, WorkspaceSettings.fallbackDefaults);
    expect(find.text('Saved'), findsOneWidget);

    // deleting asks for the name
    await tester.tap(find.text('Danger zone'));
    await settle(tester);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Delete workspace'));
    await settle(tester);
    expect(find.text('Delete “QA”?'), findsOneWidget);
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
    verify(() => workspaces.select('production')).called(greaterThan(0));

    // the summary and the table of its backups, as in the design
    expect(find.text('Healthy'), findsOneWidget);
    expect(
      find.textContaining('last run succeeded', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Next backup in'), findsOneWidget);
    expect(find.text('Next backup'), findsOneWidget);
    expect(find.text('orders-db'), findsWidgets);
    expect(find.text('Nightly full'), findsOneWidget);
    expect(find.text('0 2 * * *'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Never run'), findsOneWidget);
    expect(find.text('20/Oct 02:14 AM UTC'), findsOneWidget);
    expect(find.text('5.00 MB'), findsOneWidget);
    expect(find.text('pg_dump: connection refused'), findsOneWidget);
    expect(find.textContaining('Sort: '), findsOneWidget);
    verify(() => backups.load('production')).called(greaterThan(0));

    // a row opens its recent runs
    await tester.tap(find.text('Nightly full'));
    await settle(tester);
    verify(() => backups.loadRecent('j1')).called(1);
    expect(find.text('RECENT RUNS'), findsOneWidget);

    // its menu edits the config in the dialog of the canvas
    await tester.tap(find.byTooltip('More actions for orders-db').first);
    await settle(tester);
    expect(find.text('Delete backup'), findsOneWidget);
    await tester.tap(find.text('Edit config').last);
    await settle(tester);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    expect(find.text('Config name'), findsOneWidget);
  });

  testWidgets(
    'Sources: usage, status, a locked delete, grid, detail and the form in steps',
    (tester) async {
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
      expect(
        find.text('Used by 2 backups. Remove them first.'),
        findsOneWidget,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);

      // the same sources as cards
      await tester.tap(find.byTooltip('Grid'));
      await settle(tester);
      expect(find.text('2 backups'), findsOneWidget);

      // its detail in a dialog: the backups that dump it
      await tester.tap(find.text('orders-db'));
      await settle(tester);
      expect(
        find.text('A PostgreSQL database this workspace backs up.'),
        findsOne,
      );
      expect(find.text('BACKUPS USING THIS SOURCE'), findsOneWidget);
      expect(find.text('Not run yet'), findsNWidgets(2));
      expect(find.text('Edit connection'), findsOneWidget);
      await tester.tap(find.byTooltip('Close').last);
      await settle(tester);

      // the form: type, connection, then the summary with the test
      await tester.tap(find.widgetWithText(PrimaryButton, 'New source'));
      await settle(tester);
      expect(find.text('Connect what you want to back up.'), findsOneWidget);
      expect(find.text('What do you want to back up?'), findsOneWidget);
      expect(find.text('Soon'), findsOneWidget);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
      await settle(tester);
      expect(find.text('Step 2 of 3'), findsOneWidget);

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

      final name = find.ancestor(
        of: find.text('e.g. orders-db'),
        matching: find.byType(TextField),
      );
      const longName =
          'Long names are cut on the canvas: a shorter one reads better.';
      await tester.enterText(name, 'billing-database-primary');
      await settle(tester);
      expect(find.text(longName), findsOneWidget); // a warning, it goes on
      await tester.enterText(name, 'billing-db');
      await settle(tester);
      expect(find.text(longName), findsNothing);
      await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
      await settle(tester);
      expect(find.text('Check and save'), findsOneWidget);
      expect(find.text('pg-billing.internal:5432'), findsOneWidget);
      expect(find.text('Dump format'), findsOneWidget);
      expect(find.text('Not tested yet'), findsOneWidget);
    },
  );

  testWidgets('A source opens from its URL, and leaving it closes it', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    String path() =>
        RouteConfig.router.routerDelegate.currentConfiguration.uri.path;
    const about = 'A PostgreSQL database this workspace backs up.';
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces/production/sources/orders');
    await settle(tester);
    expect(find.text(about), findsOneWidget);

    // the browser's back: the list without its dialog
    RouteConfig.router.go('/workspaces/production/sources');
    await settle(tester);
    expect(find.text(about), findsNothing);
    expect(find.text('orders-db'), findsOneWidget);

    // an id that is not there: a notice, and the list
    RouteConfig.router.go('/workspaces/production/sources/gone');
    await settle(tester);
    expect(find.text('This page does not exist.'), findsOneWidget);
    expect(path(), '/workspaces/production/sources');
  });

  testWidgets('The run log takes its filters from the URL', (tester) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go(
      '/workspaces/production/runs?status=failed&source=postgres&destination=nope',
    );
    await settle(tester);
    verify(() => runs.filterStatus(RunStatus.failed)).called(greaterThan(0));
    verify(() => runs.filterSourceType('postgres')).called(greaterThan(0));
    verify(() => runs.filterDestinationType('nope')).called(greaterThan(0));
  });

  testWidgets('Destinations: folders open under the row, grid, detail and '
      'the form in steps', (tester) async {
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

    // the same destination as a card
    await tester.tap(find.byTooltip('Grid'));
    await settle(tester);
    expect(find.text('Show the folders of bucket'), findsNothing);
    expect(find.text('2 backups'), findsOneWidget);

    // its detail in a dialog: who writes to each folder
    await tester.tap(find.text('bucket'));
    await settle(tester);
    expect(find.text('A bucket this workspace writes backups to.'), findsOne);
    expect(find.text('Written by'), findsOneWidget);
    expect(find.text('orders, orders'), findsOneWidget);
    expect(find.text('Edit connection'), findsOneWidget);
    await tester.tap(find.byTooltip('Close').last);
    await settle(tester);

    // the form: type, then the connection, which Next checks
    await tester.tap(find.widgetWithText(PrimaryButton, 'New destination'));
    await settle(tester);
    expect(find.text('Where should backups go?'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
    await settle(tester);
    expect(find.text('Path-style addressing'), findsOneWidget);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Next'));
    await settle(tester);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('Required'), findsWidgets);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Back'));
    await settle(tester);
    expect(find.text('Where should backups go?'), findsOneWidget);
  });

  testWidgets('Run log: the runs by day, and a run opens in a dialog', (
    tester,
  ) async {
    when(() => auth.auth).thenReturn(session());
    await pumpApp(tester);
    RouteConfig.router.go('/workspaces/production/runs');
    await settle(tester);

    expect(find.text('Hourly users'), findsOneWidget);
    expect(find.textContaining('Tue 20 Oct (UTC)'), findsOneWidget);
    expect(find.text('1 succeeded · 1 failed'), findsOneWidget);
    expect(find.text('5.00 MB in 3 min 5 s'), findsOneWidget);
    expect(find.text('pg_dump: connection refused'), findsOneWidget);
    expect(find.text('By schedule'), findsNWidgets(2));
    verify(() => runs.load('production')).called(greaterThan(0));

    await tester.tap(find.text('View run').first);
    await settle(tester);
    verify(() => runs.detail(any(), workspace: any(named: 'workspace')))
        .called(1);
    expect(find.text('The backup failed'), findsOneWidget);
    expect(find.text('Connect to orders-db'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
    expect(
      find.textContaining('Failed: boom', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Copy log'), findsOneWidget);
  });
}
