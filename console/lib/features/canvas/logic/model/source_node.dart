import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A database to back up. [settings] are the ones the service returned
/// (never the password): the save sends them back as they are, and the
/// service keeps the saved password
class SourceNode {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> settings;
  final Offset pos;

  const SourceNode({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    this.pos = Offset.zero,
  });

  String get engine => SourceTypeLook.labelOf(type);

  TypeLook get look => SourceTypeLook.lookOf(type);

  /// `pg-prod-01.internal:5432/orders`
  String get detail => type == SourceTypes.postgres
      ? '${settings['host']}:${settings['port']}/${settings['database']}'
      : '';

  SourceNode copyWith({Offset? pos}) => SourceNode(
    id: id,
    name: name,
    type: type,
    settings: settings,
    pos: pos ?? this.pos,
  );
}
