import 'dart:convert';

import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState>
    with GlobalEventBusCommunication<AuthState> {
  final AuthRepo repo;
  AuthModel? _auth;

  /// Typed at the last login, only in memory: the session expired dialog
  /// fills it in (after a reload, [username] reads it from the token)
  String? _username;

  bool _expired = false;

  AuthCubit({required this.repo}) : super(const AuthInitialState());

  AuthModel? get auth => _auth;

  String? get username => _username ?? subjectOf(_auth?.accessToken);

  /// Who [token] belongs to (its `sub`); null when it isn't a JWT
  static String? subjectOf(String? token) {
    final parts = token?.split('.');
    if (parts == null || parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return (jsonDecode(payload) as Map<String, dynamic>)['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// The service refused the token: until a new login the screen stays,
  /// under the session expired dialog
  bool get expired => _expired;

  /// Picks up the session saved by a previous login, before the router decides
  /// whether to show the login
  Future<void> restore() async {
    _auth = await repo.restore();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(const AuthLoggingInState());
    _username = username;
    try {
      _auth = await repo.login(username: username, password: password);
      await repo.save(_auth!);
      _expired = false;
      emit(const AuthLoggedInOkState());
    } on Exception catch (e) {
      // an expired session keeps its screen, so the dialog can try again
      emit(AuthLoggingInErrorState(ExceptionConverter.parse(e)));
    }
  }

  /// A `401` with a session open; once, though every request after it fails
  /// the same way
  void expire() {
    if (_auth == null || _expired) return;
    _expired = true;
    repo.clear();
    emit(const AuthExpiredState());
  }

  void logout() {
    _auth = null;
    _expired = false;
    repo.clear();
    emit(const AuthLoggedOutState());
  }

  void reset() {
    _auth = null;
    _expired = false;
    repo.clear();
    emit(const AuthInitialState());
  }
}

abstract class AuthState {
  const AuthState();
}

final class AuthInitialState extends AuthState {
  const AuthInitialState();
}

//----------------- login -----------------\\
abstract class AuthLoginState extends AuthState {
  const AuthLoginState();
}

final class AuthLoggingInState extends AuthLoginState {
  const AuthLoggingInState();
}

/// Public contract: the list of workspaces reloads on it (after an expired
/// session it may have failed with the old token)
final class AuthLoggedInOkState extends AuthLoginState {
  const AuthLoggedInOkState();
}

final class AuthLoggingInErrorState extends AuthLoginState {
  /// [GlobalExceptionType.auth]: a wrong username or password; anything else
  /// (too many attempts, no connection) only has its message
  final GlobalException exception;

  const AuthLoggingInErrorState(this.exception);
}

//----------------- the session ends -----------------\\
final class AuthLoggedOutState extends AuthState {
  const AuthLoggedOutState();
}

/// The service refused the token: the session expired dialog asks again
final class AuthExpiredState extends AuthState {
  const AuthExpiredState();
}
