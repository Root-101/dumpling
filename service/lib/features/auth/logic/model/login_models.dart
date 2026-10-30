import 'package:service/dumpling.dart';

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      username: json.field<String>('username'),
      password: json.field<String>('password'),
    );
  }
}

class LoginResponse {
  final String accessToken;
  final int expiresIn;
  final DateTime expireAt;

  LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.expireAt,
  });

  Map<String, Object?> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
      'expire_at': expireAt.millisecondsSinceEpoch,
    };
  }
}

/// Who is signed in, and until when: the console asks it on start to know if
/// its stored token still works.
class SessionResponse {
  final String username;
  final DateTime expireAt;

  SessionResponse({required this.username, required this.expireAt});

  Map<String, Object?> toJson() {
    return {'username': username, 'expire_at': expireAt.millisecondsSinceEpoch};
  }
}
