import 'package:service/dumpling.dart';

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
      'expire_at': expireAt.toJsonDate(),
    };
  }
}
