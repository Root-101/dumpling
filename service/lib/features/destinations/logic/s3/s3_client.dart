import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:service/dumpling.dart';

/// An error answered by S3 (`AccessDenied`, `NoSuchBucket`…) or by the network.
class S3ClientException implements Exception {
  final int? status;
  final String? code;
  final String message;

  /// [message] and [code] come from the server: cut to [maxServerText].
  S3ClientException(String message, {this.status, String? code})
    : message = clipText(message),
      code = code == null ? null : clipText(code);

  /// The network failed, or S3 asked to try again later (5xx, 429)
  bool get transient => status == null || status == 429 || status! >= 500;

  @override
  String toString() => code == null ? message : '$code: $message';
}

/// The few S3 calls Dumpling needs, signed with SigV4, against any
/// S3-compatible endpoint (AWS, R2, MinIO, feather-io…). A destination only
/// writes: no listing, reading or deleting objects.
class S3Client {
  /// To connect, and to answer a request without a body.
  static const Duration timeout = Duration(seconds: 10);

  /// To send a body (a part of up to [S3Uploader.partSize]) and get the answer.
  static const Duration transferTimeout = Duration(minutes: 5);

  /// The largest answer read: S3 answers with a few hundred bytes of XML, and
  /// a server could send gigabytes (compressed, even) within the timeout.
  static const int maxAnswer = 1024 * 1024;

  /// Tries of a part, and the wait before the second (doubled for the third).
  static const int partTries = 3;
  static Duration retryDelay = const Duration(seconds: 2);

  /// `https://s3.us-east-1.amazonaws.com`, `http://minio.internal:9000`.
  final Uri endpoint;
  final String region;
  final String bucket;
  final String accessKeyId;
  final String secretAccessKey;

  /// `endpoint/bucket/key` instead of `bucket.endpoint/key`: what most
  /// self-hosted servers need.
  final bool pathStyle;

  S3Client({
    required this.endpoint,
    required this.region,
    required this.bucket,
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.pathStyle,
  });

  /// Uploads [key] in one request (up to 5 GiB; Dumpling sends one part).
  Future<void> putObject(String key, Uint8List body) async {
    await _send('PUT', key, body: body);
  }

  /// Starts a multipart upload of [key] and returns its upload id.
  Future<String> createMultipartUpload(String key) async {
    final (body: body, etag: _) = await _send(
      'POST',
      key,
      query: {'uploads': ''},
    );
    final uploadId = _tag(body, 'UploadId');
    if (uploadId == null) {
      throw S3ClientException('The answer has no UploadId');
    }
    return uploadId;
  }

  /// Uploads part [number] (from 1) and returns its ETag. A [transient]
  /// failure is tried again, up to [partTries] in all: one 503 must not throw
  /// away the parts already sent.
  Future<String> uploadPart(
    String key,
    String uploadId,
    int number,
    Uint8List body,
  ) async {
    for (var attempt = 1; ; attempt++) {
      try {
        final (body: _, etag: etag) = await _send(
          'PUT',
          key,
          query: {'partNumber': '$number', 'uploadId': uploadId},
          body: body,
        );
        if (etag == null) throw S3ClientException('The answer has no ETag');
        return etag;
      } on S3ClientException catch (e) {
        if (attempt == partTries || !e.transient) rethrow;
        logger.warning(
          'A part failed, trying again',
          fields: {'key': key, 'part': '$number', 'error': '$e'},
        );
        await Future<void>.delayed(retryDelay * attempt);
      }
    }
  }

  /// Joins the parts (their ETags, in order) into the object.
  Future<void> completeMultipartUpload(
    String key,
    String uploadId,
    List<String> etags,
  ) async {
    final xml = StringBuffer('<CompleteMultipartUpload>');
    for (var i = 0; i < etags.length; i++) {
      xml.write(
        '<Part><PartNumber>${i + 1}</PartNumber>'
        '<ETag>${_escape(etags[i])}</ETag></Part>',
      );
    }
    xml.write('</CompleteMultipartUpload>');
    final (body: body, etag: _) = await _send(
      'POST',
      key,
      query: {'uploadId': uploadId},
      body: Uint8List.fromList(utf8.encode(xml.toString())),
    );
    // S3 may answer 200 and still fail, with the error in the body
    if (body.contains('<Error>')) {
      throw S3ClientException(
        _tag(body, 'Message') ?? 'The upload could not be completed',
        code: _tag(body, 'Code'),
      );
    }
  }

  /// Abandons the upload: S3 drops its parts and no object is left.
  Future<void> abortMultipartUpload(String key, String uploadId) async {
    await _send('DELETE', key, query: {'uploadId': uploadId});
  }

  Future<({String body, String? etag})> _send(
    String method,
    String key, {
    Map<String, String> query = const {},
    Uint8List? body,
  }) async {
    final keyPath = key.split('/').map(SigV4Signer.uriEncode).join('/');
    final basePath = endpoint.path.replaceAll(RegExp(r'/+$'), '');
    final host = pathStyle ? endpoint.host : '$bucket.${endpoint.host}';
    final path = pathStyle
        ? '$basePath/${SigV4Signer.uriEncode(bucket)}/$keyPath'
        : '$basePath/$keyPath';
    final authority = endpoint.hasPort ? '$host:${endpoint.port}' : host;

    final now = DateTime.now().toUtc();
    final amzDate = SigV4Signer.amzDate(now);
    final scope = SigV4Signer.scope(SigV4Signer.dateStamp(now), region: region);
    final payloadHash = body == null
        ? SigV4Signer.emptyPayload
        : sha256.convert(body).toString();
    final headers = {
      'host': authority,
      'x-amz-date': amzDate,
      'x-amz-content-sha256': payloadHash,
    };
    final signedHeaders = (headers.keys.toList()..sort()).join(';');
    final signature = SigV4Signer.signature(
      secret: secretAccessKey,
      amzDate: amzDate,
      scope: scope,
      canonicalRequest: SigV4Signer.canonicalRequest(
        method: method,
        path: path,
        query: query,
        headers: headers,
        signedHeaders: signedHeaders,
        payloadHash: payloadHash,
      ),
    );
    final wait = body == null ? timeout : transferTimeout;

    final queryString = SigV4Signer.canonicalQuery(query);
    final uri = Uri.parse(
      '${endpoint.scheme}://$authority$path${queryString.isEmpty ? '' : '?$queryString'}',
    );
    final client = HttpClient()
      ..connectionTimeout = timeout
      // a small compressed answer would grow past [maxAnswer] in memory
      ..autoUncompress = false;
    try {
      final request = await client.openUrl(method, uri).timeout(timeout);
      // dart:io asks for gzip; without autoUncompress the answer must come plain
      request.headers.removeAll(HttpHeaders.acceptEncodingHeader);
      headers.forEach((name, value) {
        if (name != 'host') request.headers.set(name, value);
      });
      request.headers.set(
        'authorization',
        '${SigV4Signer.algorithm} Credential=$accessKeyId/$scope, '
            'SignedHeaders=$signedHeaders, Signature=$signature',
      );
      if (body != null) {
        request.contentLength = body.length;
        request.add(body);
      }
      final response = await request.close().timeout(wait);
      final answer = await _read(response).timeout(wait);
      if (response.statusCode >= 300) {
        throw S3ClientException(
          _tag(answer, 'Message') ?? 'HTTP ${response.statusCode}',
          status: response.statusCode,
          code: _tag(answer, 'Code'),
        );
      }
      return (body: answer, etag: response.headers.value('etag'));
    } on SocketException catch (e) {
      throw S3ClientException(e.osError?.message ?? e.message);
    } on HandshakeException catch (e) {
      throw S3ClientException(e.message);
    } on HttpException catch (e) {
      // Not an HTTP answer: http on a TLS port, a server that hangs up
      throw S3ClientException(e.message);
    } on TimeoutException {
      throw S3ClientException('Timed out after ${wait.inSeconds} s');
    } finally {
      client.close(force: true);
    }
  }

  /// The answer as text, failing past [maxAnswer] bytes.
  static Future<String> _read(HttpClientResponse response) async {
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response) {
      bytes.add(chunk);
      if (bytes.length > maxAnswer) {
        throw S3ClientException(
          'The answer is larger than ${maxAnswer ~/ 1024} KiB',
          status: response.statusCode,
        );
      }
    }
    return utf8.decode(bytes.takeBytes(), allowMalformed: true);
  }

  static String? _tag(String xml, String name) =>
      RegExp('<$name>([^<]*)</$name>').firstMatch(xml)?.group(1);

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
