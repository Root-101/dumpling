import 'package:console/app_exporter.dart';

/// What the form sends. An empty [secretKey] keeps the saved one when editing
class DestinationFormModel {
  final String name;
  final String type;
  final String endpoint;
  final String region;
  final String bucket;
  final String accessKeyId;
  final String? secretKey;
  final bool pathStyle;
  final List<String> folders;

  const DestinationFormModel({
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
  factory DestinationFormModel.of(
    DestinationModel destination, {
    required List<String> folders,
  }) {
    final s3 = destination.s3;
    return DestinationFormModel(
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
