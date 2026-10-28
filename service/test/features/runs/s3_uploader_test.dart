@TestOn('vm')
library;

import 'package:service/dumpling.dart';
import 'package:test/test.dart';

import '../../support/fake_s3.dart';

void main() {
  final s3 = FakeS3();
  late S3Client client;

  setUpAll(() async {
    await s3.start();
    client = S3Client(
      endpoint: Uri.parse(s3.endpoint),
      region: FakeS3.region,
      bucket: 'backups',
      accessKeyId: FakeS3.accessKeyId,
      secretAccessKey: FakeS3.secretAccessKey,
      pathStyle: true,
    );
  });
  tearDownAll(s3.stop);
  setUp(s3.reset);

  /// [length] bytes in chunks of 100, like the output of a process.
  Stream<List<int>> bytes(int length, {Object? failAfter}) async* {
    for (var i = 0; i < length; i += 100) {
      if (failAfter != null && i >= (failAfter as int)) {
        throw DumpException('pg_dump exited with code 1');
      }
      yield List.generate(
        i + 100 > length ? length - i : 100,
        (j) => (i + j) % 251,
      );
    }
  }

  List<int> expected(int length) => List.generate(length, (i) => i % 251);

  group('S3Uploader', () {
    test('Should send a stream that fits in one part with PutObject', () async {
      final size = await S3Uploader(
        client,
        partSize: 1000,
      ).upload('orders/a.dump', bytes(250));
      expect(size, 250);
      expect(s3.objects['backups/orders/a.dump'], expected(250));
      expect(s3.requests.single, startsWith('PUT /backups/orders/a.dump'));
    });

    test('Should send a bigger one part by part, in order', () async {
      final progress = <int>[];
      final multipart = <String>[];
      final size = await S3Uploader(client, partSize: 1000).upload(
        'orders/b.dump',
        bytes(2500),
        onProgress: progress.add,
        onMultipart: multipart.add,
      );
      expect(size, 2500);
      // once, with the id S3 gave
      expect(multipart, [startsWith('upload-')]);
      expect(s3.objects['backups/orders/b.dump'], expected(2500));
      expect(progress, [1000, 2000, 2500]);
      expect(s3.openUploads, isEmpty);
      expect(s3.requests.where((r) => r.contains('partNumber')), hasLength(3));
    });

    test('Should try a part again when S3 asks to slow down', () async {
      S3Client.retryDelay = Duration.zero;
      s3.failingParts = 2;
      final size = await S3Uploader(
        client,
        partSize: 1000,
      ).upload('orders/d.dump', bytes(2500));
      expect(size, 2500);
      expect(s3.objects['backups/orders/d.dump'], expected(2500));
      // the first part, twice failed, then the three
      expect(s3.requests.where((r) => r.contains('partNumber')), hasLength(5));
    });

    test('Should give up and abort after the last try', () async {
      S3Client.retryDelay = Duration.zero;
      s3.failingParts = S3Client.partTries;
      await expectLater(
        S3Uploader(client, partSize: 1000).upload('orders/e.dump', bytes(2500)),
        throwsA(
          isA<S3ClientException>().having((e) => e.code, 'code', 'SlowDown'),
        ),
      );
      expect(s3.objects, isEmpty);
      expect(s3.openUploads, isEmpty);
    });

    test('Should abort the upload when the stream fails', () async {
      await expectLater(
        S3Uploader(
          client,
          partSize: 1000,
        ).upload('orders/c.dump', bytes(5000, failAfter: 2500)),
        throwsA(isA<DumpException>()),
      );
      expect(s3.objects, isEmpty);
      expect(s3.openUploads, isEmpty);
      expect(s3.requests.last, startsWith('DELETE'));
    });
  });

  group('ObjectKey', () {
    test('Should fill in the placeholders and add the extension', () {
      expect(
        ObjectKey.render(
          '{db}/{yyyy}/{MM}/{dd}-{HH}{mm}-{run_id}-{nope}',
          at: DateTime.utc(2026, 3, 7, 4, 5),
          database: 'orders',
          runId: 'run_abc',
          extension: '.dump.gz',
        ),
        'orders/2026/03/07-0405-run_abc-{nope}.dump.gz',
      );
    });

    test('Should keep the name of the database one folder', () {
      String key(String database) => ObjectKey.render(
        '{db}/{run_id}',
        at: DateTime.utc(2026),
        database: database,
        runId: 'r',
        extension: '.dump',
      );
      expect(key('..'), '_/r.dump');
      expect(key('a/b'), 'a_b/r.dump');
      expect(key('orders.v2'), 'orders.v2/r.dump');
    });

    test('Should reject . and .. folders in the object key', () {
      bool valid(String key) {
        final context = ConstraintValidatorContext();
        context.field<String?>('object_key', key).objectKey();
        return context.violations.isEmpty;
      }

      expect(valid('{db}/{yyyy}'), isTrue);
      expect(valid('../x/{db}'), isFalse);
      expect(valid('{db}/./{yyyy}'), isFalse);
    });
  });
}
