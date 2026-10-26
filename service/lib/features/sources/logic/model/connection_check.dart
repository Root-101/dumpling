/// What a connection test found. The console writes the text in its language
/// from these fields; [message] is the raw error of the server or the network.
enum CheckStatus {
  /// Connected, and the dump tool can back it up
  connected,

  /// Connected, but the server is newer than the dump tool
  incompatible,

  /// Connected, but the dump tool is not installed where the service runs
  toolMissing,

  /// Could not connect or sign in
  failed,
}

class ConnectionCheck {
  final CheckStatus status;

  /// The version the server reports (`16.4`), when it answered.
  final String? serverVersion;

  /// The version of the dump tool (`pg_dump 18.0`), when it is installed.
  final String? toolVersion;

  final String? message;
  final int durationMs;
  final DateTime checkedAt;

  ConnectionCheck({
    required this.status,
    this.serverVersion,
    this.toolVersion,
    this.message,
    required this.durationMs,
    required this.checkedAt,
  });

  factory ConnectionCheck.fromJson(Map<String, dynamic> json) =>
      ConnectionCheck(
        status: CheckStatus.values.byName(json['status'] as String),
        serverVersion: json['server_version'] as String?,
        toolVersion: json['tool_version'] as String?,
        message: json['message'] as String?,
        durationMs: json['duration_ms'] as int,
        checkedAt: DateTime.parse(json['checked_at'] as String),
      );

  Map<String, Object?> toJson() => {
    'status': status.name,
    'server_version': serverVersion,
    'tool_version': toolVersion,
    'message': message,
    'duration_ms': durationMs,
    'checked_at': checkedAt.toUtc().toIso8601String(),
  };
}
