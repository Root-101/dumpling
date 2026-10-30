import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo repo;
  AuthModel? _auth;

  /// Typed at the last login, only in memory: the session expired dialog
  /// fills it in
  String? _username;

  bool _expired = false;

  AuthCubit(this.repo) : super(AuthInitialState());

  AuthModel? get auth => _auth;

  String? get username => _username;

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
    emit(AuthProcessInProgressState());
    _username = username;
    try {
      _auth = await repo.login(username: username, password: password);
      await repo.save(_auth!);
      _expired = false;
      emit(AuthProcessingOKState());
    } catch (e) {
      // an expired session keeps its screen, so the dialog can try again
      emit(AuthProcessingErrorState(ExceptionConverter.parse(e)));
    }
  }

  /// A `401` with a session open; once, though every request after it fails
  /// the same way
  void expire() {
    if (_auth == null || _expired) return;
    _expired = true;
    repo.clear();
    emit(AuthExpiredState());
  }

  void logout() {
    _auth = null;
    _expired = false;
    repo.clear();
    emit(AuthLogoutState());
  }

  void reset() {
    _auth = null;
    _expired = false;
    repo.clear();
    emit(AuthInitialState());
  }
}

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthProcessInProgressState extends AuthState {}

class AuthProcessingOKState extends AuthState {}

class AuthProcessingErrorState extends AuthState {
  /// [GlobalExceptionType.auth]: a wrong username or password; anything else
  /// (too many attempts, no connection) only has its message
  final GlobalException exception;

  AuthProcessingErrorState(this.exception);
}

class AuthLogoutState extends AuthState {}

class AuthExpiredState extends AuthState {}
