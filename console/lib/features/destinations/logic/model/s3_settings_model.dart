/// Where an S3 destination writes (never the secret key)
class S3SettingsModel {
  final String endpoint;
  final String region;
  final String bucket;
  final String accessKeyId;
  final bool pathStyle;

  const S3SettingsModel({
    required this.endpoint,
    required this.region,
    required this.bucket,
    required this.accessKeyId,
    required this.pathStyle,
  });

  /// `s3.us-east-1.amazonaws.com`
  String get address => endpoint.replaceFirst(RegExp(r'^https?://'), '');
}
