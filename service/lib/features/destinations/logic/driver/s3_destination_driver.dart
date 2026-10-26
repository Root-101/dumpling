import 'dart:math';

import 'package:service/dumpling.dart';

class S3DestinationDriver implements DestinationDriver {
  static final Random _random = Random.secure();

  /// Starts a multipart upload in each folder and aborts it: it proves the
  /// keys, the bucket and the write permission there (`s3:PutObject` and
  /// `s3:AbortMultipartUpload`, the only ones Dumpling needs), and no object
  /// is ever created.
  @override
  Future<ConnectionCheck> testConnection(
    DestinationSettings settings,
    Map<String, String> secrets,
    List<String> folders,
  ) async {
    final watch = Stopwatch()..start();
    final client = _client(settings, secrets);

    ConnectionCheck result(CheckStatus status, {String? message}) =>
        ConnectionCheck(
          status: status,
          message: message,
          durationMs: watch.elapsedMilliseconds,
          checkedAt: DateTime.now().toUtc(),
        );

    final name = '.dumpling-check-${_random.nextInt(1 << 32)}';
    for (final folder in folders.isEmpty ? const [''] : folders) {
      final key = folder.isEmpty ? name : '$folder/$name';
      try {
        final uploadId = await client.createMultipartUpload(key);
        await client.abortMultipartUpload(key, uploadId);
      } on S3ClientException catch (e) {
        // The folder that failed, for the console to point at
        return result(
          CheckStatus.failed,
          message: folder.isEmpty ? '$e' : '$folder: $e',
        );
      }
    }
    return result(CheckStatus.connected);
  }

  @override
  Future<int> upload(
    DestinationSettings settings,
    Map<String, String> secrets,
    String? folder,
    String key,
    Stream<List<int>> data, {
    void Function(int bytes)? onProgress,
  }) =>
      S3Uploader(_client(settings, secrets))
          .upload(_objectKey(folder, key), data, onProgress: onProgress);

  @override
  String location(DestinationSettings settings, String? folder, String key) =>
      '${(settings as S3Settings).bucket!.trim()}/${_objectKey(folder, key)}';

  static String _objectKey(String? folder, String key) =>
      folder == null ? key : '$folder/$key';

  static S3Client _client(
    DestinationSettings settings,
    Map<String, String> secrets,
  ) {
    final s3 = settings as S3Settings;
    return S3Client(
      endpoint: s3.endpointUri,
      region: s3.regionOrDefault,
      bucket: s3.bucket!.trim(),
      accessKeyId: s3.accessKeyId!.trim(),
      secretAccessKey: secrets[S3Settings.secretKey]!,
      pathStyle: s3.pathStyle ?? false,
    );
  }
}
