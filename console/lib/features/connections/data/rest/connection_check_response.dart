import 'package:console/app_exporter.dart';

//---------- CONNECTION CHECK RESPONSE ----------
/// What a connection test of a source or a destination found
class ConnectionCheckResponse {
  final String status;
  final String? serverVersion;
  final String? toolVersion;
  final String? message;
  final int durationMs;
  final DateTime checkedAt;

  ConnectionCheckResponse({
    required this.status,
    required this.serverVersion,
    required this.toolVersion,
    required this.message,
    required this.durationMs,
    required this.checkedAt,
  });

  factory ConnectionCheckResponse.fromJson(Map<String, dynamic> json) {
    return ConnectionCheckResponse(
      status: json['status'],
      serverVersion: json['server_version'],
      toolVersion: json['tool_version'],
      message: json['message'],
      durationMs: json['duration_ms'],
      checkedAt: DateTime.parse(json['checked_at']),
    );
  }

  ConnectionCheckModel toModel() {
    return ConnectionCheckModel(
      // a status this console doesn't know yet reads as a failure
      status: CheckStatus.values.asNameMap()[status] ?? CheckStatus.failed,
      serverVersion: serverVersion,
      toolVersion: toolVersion,
      message: message,
      checkedAt: checkedAt,
    );
  }
}
