import 'package:service/dumpling.dart';

/// Who is signed in, and until when: the console asks it on start to know if
/// its stored token still works.
class SessionResponse {
  final String username;
  final DateTime expireAt;

  SessionResponse({required this.username, required this.expireAt});

  Map<String, Object?> toJson() {
    return {'username': username, 'expire_at': expireAt.toJsonDate()};
  }
}
