/// What a connection test found, the same values as the service
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

/// The result of a connection test. The console writes the text from these
/// fields; [message] is the raw error of the server or the network
class ConnectionCheckModel {
  final CheckStatus status;

  /// `16.4`, when the server answered
  final String? serverVersion;

  /// `pg_dump 18.0`, when it is installed
  final String? toolVersion;
  final String? message;
  final DateTime checkedAt;

  const ConnectionCheckModel({
    required this.status,
    required this.checkedAt,
    this.serverVersion,
    this.toolVersion,
    this.message,
  });

  /// `16` of `16.4`
  String? get serverMajor => serverVersion?.split('.').first;
}
