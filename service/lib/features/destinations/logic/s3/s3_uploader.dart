import 'dart:typed_data';

import 'package:service/dumpling.dart';

/// Uploads a stream of unknown size, as the dump comes: one part at a time
/// (the stream waits while a part goes up), so the memory stays at about one
/// [partSize]. A stream that fits in one part is a single PutObject. If the
/// stream or S3 fails, the multipart upload is aborted: no half object is
/// left in the bucket.
class S3Uploader {
  /// S3 takes up to 10 000 parts.
  // shortcut: 16 MiB parts cap a backup at ~156 GiB; for bigger ones, grow the
  // part as the upload goes.
  static const int defaultPartSize = 16 * 1024 * 1024;

  final S3Client client;
  final int partSize;

  S3Uploader(this.client, {this.partSize = defaultPartSize});

  /// Uploads [data] to [key] and returns its size; [onProgress] gets the bytes
  /// uploaded so far after each part.
  Future<int> upload(
    String key,
    Stream<List<int>> data, {
    void Function(int bytes)? onProgress,
  }) async {
    final buffer = BytesBuilder(copy: false);
    final etags = <String>[];
    String? uploadId;
    var uploaded = 0;

    Future<void> sendPart() async {
      final part = buffer.takeBytes();
      uploadId ??= await client.createMultipartUpload(key);
      etags.add(
        await client.uploadPart(key, uploadId!, etags.length + 1, part),
      );
      uploaded += part.length;
      onProgress?.call(uploaded);
    }

    try {
      await for (final chunk in data) {
        buffer.add(chunk);
        if (buffer.length >= partSize) await sendPart();
      }
      if (uploadId == null) {
        final body = buffer.takeBytes();
        await client.putObject(key, Uint8List.fromList(body));
        onProgress?.call(body.length);
        return body.length;
      }
      if (buffer.isNotEmpty) await sendPart();
      await client.completeMultipartUpload(key, uploadId!, etags);
      return uploaded;
    } catch (_) {
      if (uploadId != null) {
        try {
          await client.abortMultipartUpload(key, uploadId!);
        } on S3ClientException catch (e) {
          // The parts stay until a lifecycle rule of the bucket drops them
          logger.warning(
            'Could not abort a failed upload',
            fields: {'key': key, 'error': '$e'},
          );
        }
      }
      rethrow;
    }
  }
}
