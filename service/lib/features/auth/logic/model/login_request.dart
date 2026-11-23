import 'package:service/dumpling.dart';

/// Body of the sign-in.
class LoginRequest implements Validatable {
  final String? username;
  final String? password;

  LoginRequest({this.username, this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
    username: json.field<String?>('username'),
    password: json.field<String?>('password'),
  );

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field('username', username).notNull()
    ..field('password', password).notNull();
}
