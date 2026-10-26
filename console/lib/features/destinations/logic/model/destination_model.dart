import 'package:console/app_exporter.dart';

/// The kinds of destination the service knows. Only [s3] works today; the
/// others show as coming soon
abstract class DestinationTypes {
  static const String s3 = 's3';
}

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

  /// `s3.us-east-1.amazonaws.com/bucket-backups`
  String get address =>
      '${endpoint.replaceFirst(RegExp(r'^https?://'), '')}/$bucket';
}

/// A bucket backups are written to. Each of its [folders] is a connection
/// point on the canvas; with none, the bucket root is. [s3] is null for a
/// type this console can't read the settings of
class DestinationModel {
  final String id;
  final String name;
  final String type;
  final S3SettingsModel? s3;

  /// Without slashes around them (`orders`, `eu/billing`)
  final List<String> folders;

  /// Null until its connection is tested the first time
  final ConnectionCheckModel? lastCheck;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.type,
    this.s3,
    this.folders = const [],
    this.lastCheck,
  });

  DestinationModel withCheck(ConnectionCheckModel check) => DestinationModel(
    id: id,
    name: name,
    type: type,
    s3: s3,
    folders: folders,
    lastCheck: check,
  );
}

class DestinationTypeModel {
  final String type;
  final bool enabled;

  const DestinationTypeModel({required this.type, required this.enabled});
}

/// What the form sends. An empty [secretKey] keeps the saved one when editing
class DestinationDraft {
  final String name;
  final String type;
  final String endpoint;
  final String region;
  final String bucket;
  final String accessKeyId;
  final String? secretKey;
  final bool pathStyle;
  final List<String> folders;

  const DestinationDraft({
    required this.name,
    required this.type,
    this.endpoint = '',
    this.region = '',
    this.bucket = '',
    this.accessKeyId = '',
    this.secretKey,
    this.pathStyle = false,
    this.folders = const [],
  });

  /// [destination] as it is saved, with other [folders]: what changing its
  /// folders from the list sends
  factory DestinationDraft.of(
    DestinationModel destination, {
    required List<String> folders,
  }) {
    final s3 = destination.s3;
    return DestinationDraft(
      name: destination.name,
      type: destination.type,
      endpoint: s3?.endpoint ?? '',
      region: s3?.region ?? '',
      bucket: s3?.bucket ?? '',
      accessKeyId: s3?.accessKeyId ?? '',
      pathStyle: s3?.pathStyle ?? false,
      folders: folders,
    );
  }
}

/// The rules of the service for a folder path, to tell before sending it
abstract class FolderPath {
  static final RegExp _pattern = RegExp(r'^[a-z0-9._-]+(/[a-z0-9._-]+)*$');

  /// `/orders/` → `orders`
  static String clean(String path) =>
      path.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  static bool isValid(String path) =>
      path.length <= 255 &&
      _pattern.hasMatch(path) &&
      path.split('/').every((s) => s != '.' && s != '..');

  /// How it shows: `/orders`
  static String show(String path) => '/$path';
}
