import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:service/dumpling.dart';

/// A tiny S3 for the tests: it checks the SigV4 signature (and the sha256 of
/// the body) of each request, answers PutObject and the multipart calls, and
/// keeps the objects in memory. A key under [deniedPrefix] gets
/// `AccessDenied`.
class FakeS3 {
  static const String accessKeyId = 'FAKEACCESSKEY';
  static const String secretAccessKey = 'fake-secret-access-key';
  static const String region = 'us-east-1';

  final String deniedPrefix;
  late final HttpServer _server;

  /// `METHOD path?query` of every request that passed the signature.
  final List<String> requests = [];

  /// The objects written, by `bucket/key`.
  final Map<String, List<int>> objects = {};

  /// Upload ids started and not aborted or completed yet, with their key.
  final Map<String, String> openUploads = {};
  final Map<String, Map<int, List<int>>> _parts = {};

  /// How many of the next parts get `503 SlowDown`.
  int failingParts = 0;
  var _next = 0;

  FakeS3({this.deniedPrefix = 'denied/'});

  int get port => _server.port;

  String get endpoint => 'http://127.0.0.1:$port';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen(_handle);
  }

  Future<void> stop() => _server.close(force: true);

  /// Forgets every request, object and upload.
  void reset() {
    requests.clear();
    objects.clear();
    openUploads.clear();
    _parts.clear();
    failingParts = 0;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    final body = [for (final chunk in await request.toList()) ...chunk];
    final path = request.uri.path;
    final query = request.uri.queryParameters;
    if (!_validSignature(request, body)) {
      return _error(response, 403, 'SignatureDoesNotMatch');
    }
    requests.add('${request.method} $path?${request.uri.query}');
    // Path style: /bucket/key
    final segments = path.split('/').skip(1).map(Uri.decodeComponent).toList();
    final object = segments.join('/');
    final key = segments.skip(1).join('/');
    if (key.startsWith(deniedPrefix)) {
      return _error(response, 403, 'AccessDenied');
    }
    final uploadId = query['uploadId'];
    switch (request.method) {
      case 'POST' when query.containsKey('uploads'):
        final id = 'upload-${_next++}';
        openUploads[id] = object;
        _parts[id] = {};
        response.write(
          '<InitiateMultipartUploadResult><UploadId>$id</UploadId>'
          '</InitiateMultipartUploadResult>',
        );
      case 'PUT' when uploadId != null && failingParts > 0:
        failingParts--;
        return _error(response, 503, 'SlowDown');
      case 'PUT' when uploadId != null:
        final number = int.parse(query['partNumber']!);
        _parts[uploadId]![number] = body;
        response.headers.set('etag', '"etag-$number"');
      case 'POST' when uploadId != null:
        final parts = _parts.remove(uploadId)!;
        openUploads.remove(uploadId);
        objects[object] = [
          for (final n in parts.keys.toList()..sort()) ...parts[n]!,
        ];
        response.write('<CompleteMultipartUploadResult/>');
      case 'DELETE' when uploadId != null:
        openUploads.remove(uploadId);
        _parts.remove(uploadId);
        response.statusCode = 204;
      case 'PUT':
        objects[object] = body;
        response.headers.set('etag', '"etag"');
      default:
        return _error(response, 501, 'NotImplemented');
    }
    await response.close();
  }

  bool _validSignature(HttpRequest request, List<int> body) {
    final authorization = request.headers.value('authorization') ?? '';
    final match = RegExp(
      r'Credential=([^/]+)/([^,]+), SignedHeaders=([^,]+), Signature=(\w+)',
    ).firstMatch(authorization);
    if (match == null || match.group(1) != accessKeyId) return false;
    final payloadHash = request.headers.value('x-amz-content-sha256')!;
    if (payloadHash != sha256.convert(body).toString()) return false;
    final signedHeaders = match.group(3)!;
    final headers = {
      for (final name in signedHeaders.split(';'))
        name: request.headers.value(name) ?? '',
    };
    final expected = SigV4Signer.signature(
      secret: secretAccessKey,
      amzDate: request.headers.value('x-amz-date')!,
      scope: match.group(2)!,
      canonicalRequest: SigV4Signer.canonicalRequest(
        method: request.method,
        path: request.uri.path,
        query: request.uri.queryParameters,
        headers: headers,
        signedHeaders: signedHeaders,
        payloadHash: payloadHash,
      ),
    );
    return expected == match.group(4);
  }

  Future<void> _error(HttpResponse response, int status, String code) async {
    response
      ..statusCode = status
      ..write('<Error><Code>$code</Code><Message>$code here</Message></Error>');
    await response.close();
  }
}
