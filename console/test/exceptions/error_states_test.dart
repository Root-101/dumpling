import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkspaces extends Mock implements WorkspacesCubit {}

void main() {
  // the messages come from app.intl, which reads the navigator
  TestWidgetsFlutterBinding.ensureInitialized();

  // the workspaces of the rail, none loaded: one for every page here
  final workspaces = _MockWorkspaces();
  when(() => workspaces.state).thenReturn(
    const WorkspacesLoadingInProgressState(data: WorkspacesData.empty()),
  );
  when(() => workspaces.load()).thenAnswer((_) async {});
  app.di.put<WorkspacesCubit>(workspaces);

  DioException response(int status, Object? data) {
    final request = RequestOptions(path: '/api/workspaces/gone/canvas');
    return DioException.badResponse(
      statusCode: status,
      requestOptions: request,
      response: Response(
        requestOptions: request,
        statusCode: status,
        data: data,
      ),
    );
  }

  test('a 404 is not found, with what the service said', () {
    final e = ExceptionConverter.parse(
      response(404, {
        'title': 'Not Found',
        'detail': 'The workspace "gone" does not exist.',
      }),
    );
    expect(e.type, GlobalExceptionType.notFound);
    expect(e.message, 'The workspace "gone" does not exist.');
  });

  test('a service that does not answer is offline; a 401 stays auth', () {
    final request = RequestOptions(path: '/api/auth/login');
    for (final type in [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.unknown,
    ]) {
      expect(
        ExceptionConverter.parse(
          DioException(requestOptions: request, type: type),
        ).type,
        GlobalExceptionType.offline,
      );
    }
    expect(
      ExceptionConverter.parse(response(401, {'detail': 'Wrong'})).type,
      GlobalExceptionType.auth,
    );
  });

  test('offline says which service, not the internet', () {
    final e = ExceptionConverter.parse(
      DioException(
        requestOptions: RequestOptions(path: '/api/auth/login'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(e.code, GlobalExceptionCode.noConnection);
    expect(e.intlMessage, startsWith("Can't reach the Dumpling service at "));
  });

  test('an answer of the service keeps its status, code and detail', () {
    final request = RequestOptions(
      path: '/api/workspaces/production/sources/x',
    );
    final e = ExceptionConverter.parse(
      DioException.badResponse(
        statusCode: 409,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 409,
          data: {
            'status': 409,
            'detail': 'Configs back up this source (1)',
            'code': 'sources.inUse',
          },
        ),
      ),
    );
    expect(e.statusCode, 409);
    expect(e.errorCode, 'sources.inUse');
    expect(e.hasCode('sources.inUse'), isTrue);
    expect(e.code, GlobalExceptionCode.custom);
    // the detail is shown as it came, in the console's language
    expect(e.intlMessage, 'Configs back up this source (1)');
  });

  test('a locked sign-in says how long it waits, from Retry-After', () {
    final request = RequestOptions(path: '/api/auth/login');
    final e = ExceptionConverter.parse(
      DioException.badResponse(
        statusCode: 429,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 429,
          data: {
            'detail': 'Too many failed sign-in attempts',
            'code': 'auth.tooManyLoginAttempts',
          },
          headers: Headers.fromMap({
            'retry-after': ['61'],
          }),
        ),
      ),
    );
    expect(e.type, GlobalExceptionType.tooManyRequests);
    expect(e.message, 'Too many failed sign-in attempts');
    expect(loginErrorHint(e), 'Try again in 2 minutes.');
    // without the header (or another origin that hides it), no hint
    expect(
      loginErrorHint(ExceptionConverter.parse(response(429, null))),
      isNull,
    );
    expect(
      loginErrorHint(
        ExceptionConverter.parse(
          response(401, {'code': ApiErrorCode.authInvalidCredentials}),
        ),
      ),
      'Check both and try again.',
    );
    // a 401 that isn't the sign-in's (an expired token) gets no hint
    expect(
      loginErrorHint(ExceptionConverter.parse(response(401, null))),
      isNull,
    );
  });

  Future<void> pump(WidgetTester tester, Widget page) =>
      tester.pumpWidget(MaterialApp(navigatorKey: navigatorKey, home: page));

  testWidgets('Not found takes back to the workspaces', (tester) async {
    await pump(
      tester,
      ErrorPage.of(
        GlobalException(
          type: GlobalExceptionType.notFound,
          message: 'The workspace "gone" does not exist.',
        ),
      ),
    );
    // the 404 of the design: no open workspace, so only the way back to them
    expect(find.text('404'), findsOneWidget);
    expect(find.text('This page doesn’t exist'), findsOneWidget);
    expect(find.text('Workspaces'), findsOneWidget);
    expect(find.text('Go to Backups'), findsNothing);
  });

  testWidgets('Connection lost names the service and tries again', (
    tester,
  ) async {
    var retried = 0;
    // the service went away before the workspaces of the rail loaded
    await pump(
      tester,
      ErrorPage.of(
        GlobalException(type: GlobalExceptionType.offline, message: ''),
        onRetry: () => retried++,
      ),
    );
    expect(find.text('Connection lost'), findsOneWidget);
    expect(find.textContaining(Environment.serviceUrl), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
    verify(() => workspaces.load()).called(1);
  });
}
