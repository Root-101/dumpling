import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo repo;
  AuthModel? _auth;

  AuthCubit(this.repo) : super(AuthInitialState());

  AuthModel? get auth => _auth;

  /// Picks up the session saved by a previous login, before the router decides
  /// whether to show the login
  Future<void> restore() async {
    _auth = await repo.restore();
  }

  void login({required String username, required String password}) async {
    emit(AuthProcessInProgressState());
    try {
      _auth = await repo.login(username: username, password: password);
      await repo.save(_auth!);
      emit(AuthProcessingOKState());
    } catch (e) {
      _auth = null;
      emit(AuthProcessingErrorState(ExceptionConverter.parse(e)));
    }
  }

  void logout() {
    _auth = null;
    repo.clear();
    emit(AuthLogoutState());
  }

  void reset() {
    _auth = null;
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
