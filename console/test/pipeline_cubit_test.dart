import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a drop on a folder row targets that folder, on a bucket without folders its root', () {
    final s = PipelineState.demo();
    final bb = s.destination('bb')!;
    // second folder row of bucket-backups: its port is at y + 87 + 40
    expect(
      PipelineGeometry.hit(s.destinations, bb.pos + const Offset(10, 127)),
      const DropTarget('bb', 'users'),
    );
    expect(
      PipelineGeometry.destinationPort(bb, 'users'),
      bb.pos + const Offset(0, 127),
    );
    final ca = s.destination('ca')!;
    expect(
      PipelineGeometry.hit(s.destinations, ca.pos + const Offset(-20, 40)),
      const DropTarget('ca', null),
    );
    expect(PipelineGeometry.hit(s.destinations, const Offset(0, 0)), isNull);
  });

  test('connect creates a selected config; any config can be deleted', () {
    final cubit = PipelineCubit();
    cubit.connect('users', const DropTarget('ca', null));
    final created = cubit.state.selected!;
    expect(created.sourceId, 'users');
    expect(created.objectKey, startsWith('users-db/'));

    cubit.deleteConfig('j3'); // media-assets is left an orphan
    expect(cubit.state.configs.any((c) => c.id == 'j3'), isFalse);
    expect(cubit.state.source('media'), isNotNull);

    cubit.deleteConfig(created.id);
    expect(cubit.state.configs.any((c) => c.id == created.id), isFalse);
    expect(cubit.state.selectedId, isNull);
  });

  test('relink moves a config to another destination', () {
    final cubit = PipelineCubit()..relink('j1', const DropTarget('ca', null));
    final j1 = cubit.state.configs.firstWhere((c) => c.id == 'j1');
    expect((j1.destinationId, j1.folderId), ('ca', null));
  });

  test('disconnect leaves orphans; attachSource reconnects', () {
    final cubit = PipelineCubit()
      ..disconnect('j1', WireEnd.source)
      ..disconnect('j2', WireEnd.destination);
    final j1 = cubit.state.config('j1')!;
    final j2 = cubit.state.config('j2')!;
    expect(j1.sourceId, isNull);
    expect((j2.destinationId, j2.folderId), (null, null));
    expect(PipelineGeometry.wireEnds(cubit.state, j1, WireEnd.source), isNull);

    cubit.attachSource('users', 'j1');
    expect(cubit.state.config('j1')!.sourceId, 'users');
  });

  test('deleting a source or destination leaves its configs as orphans', () {
    final cubit = PipelineCubit();
    expect(cubit.state.orphans, 0);
    cubit.deleteSource('media'); // j3 loses its source
    expect(cubit.state.config('j3')!.sourceId, isNull);
    expect(cubit.state.sourcePool.last.id, 'media');
    // j3 and cold-archive: its only config is not a complete flow any more
    expect(cubit.state.orphans, 2);
    expect(cubit.state.destinationOrphan('ca'), isTrue);

    cubit.deleteDestination('ca'); // j3 loses its destination too
    expect(cubit.state.config('j3')!.destinationId, isNull);
    expect(cubit.state.orphans, 1);

    cubit.deleteConfig('j3');
    expect(cubit.state.orphans, 0);
  });

  test('only complete flows are kept: a broken chain is orphan end to end', () {
    final cubit = PipelineCubit()..disconnect('j1', WireEnd.destination);
    final s = cubit.state;
    expect(PipelineState.configOrphan(s.config('j1')!), isTrue);
    expect(s.sourceOrphan('orders'), isTrue); // its only config is broken
    expect(s.destinationOrphan('bb'), isFalse); // j2 still completes it
    expect(s.orphans, 2);
  });

  test('a click on a wire picks it', () {
    final s = PipelineState.demo();
    final j1 = s.config('j1')!;
    final (a, b) = PipelineGeometry.wireEnds(s, j1, WireEnd.destination)!;
    final mid = PipelineGeometry.curveAt(a, b, 0.5);
    expect(PipelineGeometry.hitWire(s, mid + const Offset(0, 3), 6), (
      'j1',
      WireEnd.destination,
    ));
    expect(PipelineGeometry.hitWire(s, const Offset(300, 700), 6), isNull);
  });
}
