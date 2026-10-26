import 'package:service/dumpling.dart';

/// Any S3-compatible bucket: AWS, Cloudflare R2, MinIO, feather-io…
class S3Settings implements DestinationSettings {
  static const String defaultRegion = 'us-east-1';
  static const String secretKey = 'secret_access_key';

  final String? endpoint;
  final String? region;
  final String? bucket;
  final String? accessKeyId;
  final String? secretAccessKey;
  final bool? pathStyle;

  S3Settings({
    this.endpoint,
    this.region,
    this.bucket,
    this.accessKeyId,
    this.secretAccessKey,
    this.pathStyle,
  });

  factory S3Settings.fromJson(Map<String, dynamic> json) => S3Settings(
    endpoint: json.field<String?>('endpoint'),
    region: json.field<String?>('region'),
    bucket: json.field<String?>('bucket'),
    accessKeyId: json.field<String?>('access_key_id'),
    secretAccessKey: json.field<String?>(secretKey),
    pathStyle: json.field<bool?>('path_style'),
  );

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field('endpoint', endpoint?.trim())
        .notNull()
        .size(max: 255)
        .custom(
          (value) => value == null || _isEndpoint(value)
              ? null
              : intl.errors.validations.s3Endpoint,
        )
    ..field('region', region?.trim()).size(min: 1, max: 64)
    // The rules of S3 for a bucket name
    ..field('bucket', bucket?.trim()).notNull().pattern(
      RegExp(r'^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$'),
      message: intl.errors.validations.bucketName,
    )
    ..field(
      'access_key_id',
      accessKeyId?.trim(),
    ).notNull().size(min: 1, max: 128)
    ..field(secretKey, secretAccessKey, sensitive: true).size(min: 1, max: 256);

  /// `http(s)://host[:port][/path]`, without query or credentials.
  static bool _isEndpoint(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  Uri get endpointUri => Uri.parse(endpoint!.trim());

  String get regionOrDefault {
    final value = region?.trim();
    return value == null || value.isEmpty ? defaultRegion : value;
  }

  @override
  Map<String, Object?> toJson() => {
    'endpoint': endpoint!.trim().replaceAll(RegExp(r'/+$'), ''),
    'region': regionOrDefault,
    'bucket': bucket!.trim(),
    'access_key_id': accessKeyId!.trim(),
    'path_style': pathStyle ?? false,
  };

  @override
  Map<String, String> get secrets => {secretKey: ?secretAccessKey};

  @override
  List<String> get requiredSecrets => const [secretKey];
}
