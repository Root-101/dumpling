import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Nodes made through the API land on the canvas, apart', () {
    Map<String, dynamic> source(String id) => {
      'id': id,
      'name': id,
      'type': 'postgres',
      'settings': <String, dynamic>{},
      'position': null,
    };
    Map<String, dynamic> config(String id, String source) => {
      'id': id,
      'name': id,
      'source_id': source,
      'destination_id': 'dst_b',
      'folder': null,
      'schedule': '0 2 * * *',
      'compression': 'gzip',
      'object_key': null,
      'enabled': true,
      'next_run': null,
      'last_run': null,
      'position': null,
    };
    final model = CanvasResponse(
      sources: [source('src_a'), source('src_c'), source('src_unused')],
      destinations: [
        {
          'id': 'dst_b',
          'name': 'b',
          'type': 's3',
          'settings': <String, dynamic>{},
          'folders': <String>[],
          'position': null,
        },
      ],
      configs: [config('cfg_1', 'src_a'), config('cfg_2', 'src_c')],
      ids: const {},
    ).toModel();

    // what a config uses is on the canvas; the unused source stays off it
    expect(model.sources.map((s) => s.id), ['src_a', 'src_c']);
    expect(model.sourcePool.map((s) => s.id), ['src_unused']);
    expect(model.destinations.single.pos, isNot(Offset.zero));
    // each config between its ends, none over another
    final [a, b] = model.configs;
    expect(a.pos, isNot(Offset.zero));
    expect(
      CanvasGeometry.configRect(a).overlaps(CanvasGeometry.configRect(b)),
      isFalse,
    );
    expect(model.sources.first.pos.dx < a.pos.dx, isTrue);
    expect(a.pos.dx < model.destinations.single.pos.dx, isTrue);
  });
}
