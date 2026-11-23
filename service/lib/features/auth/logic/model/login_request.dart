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
