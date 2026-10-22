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

  test('connect creates a selected config; the last config of a source cannot be deleted', () {
    final cubit = PipelineCubit();
    cubit.connect('users', const DropTarget('ca', null));
    final created = cubit.state.selected!;
    expect(created.sourceId, 'users');
    expect(created.objectKey, startsWith('users-db/'));

    cubit.deleteConfig('j3'); // only config of media-assets
    expect(cubit.state.configs.any((c) => c.id == 'j3'), isTrue);

    cubit.deleteConfig(created.id);
    expect(cubit.state.configs.any((c) => c.id == created.id), isFalse);
    expect(cubit.state.selectedId, isNull);
  });

  test('relink moves a config to another destination', () {
    final cubit = PipelineCubit()..relink('j1', const DropTarget('ca', null));
    final j1 = cubit.state.configs.firstWhere((c) => c.id == 'j1');
    expect((j1.destinationId, j1.folderId), ('ca', null));
  });
}
