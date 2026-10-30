import 'package:console/app_exporter.dart';
import 'package:dio/dio.dart';

class AuthClient extends BaseClient {
  AuthClient(super.dio);

  Future<LoginResponse> login(LoginRequest request) async {
    Response rawResponse = await dio.post(
      '$baseUrl/auth/login',
      data: request.toJson(),
      options: options(),
    );

    return LoginResponse.fromJson(rawResponse.data);
  }
}

//---------- LOGIN REQUEST ----------
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

//---------- LOGIN RESPONSE ----------
class LoginResponse {
  final String accessToken;
  final int expiresIn;
  final DateTime expireAt;

  LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.expireAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      expireAt: DateTime.fromMillisecondsSinceEpoch(json['expire_at']),
    );
  }
}
