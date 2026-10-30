import 'package:service/dumpling.dart';

/// The canvas of a workspace: every source, destination and config, each one
/// with its `position` (null: off the canvas).
class CanvasModel {
  final List<SourceModel> sources;
  final List<DestinationModel> destinations;
  final List<ConfigModel> configs;
  final Map<String, CanvasPosition> positions;

  /// After a save: the id each `new_` node got.
  final Map<String, String> ids;

  CanvasModel({
    required this.sources,
    required this.destinations,
    required this.configs,
    required this.positions,
    this.ids = const {},
  });

  Map<String, Object?> toJson() {
    Map<String, Object?> node(String id, Map<String, Object?> json) => {
      ...json,
      'position': positions[id]?.toJson(),
    };
    return {
      'sources': [for (final s in sources) node(s.id, s.toJson())],
      'destinations': [for (final d in destinations) node(d.id, d.toJson())],
      'configs': [for (final c in configs) node(c.id, c.toJson())],
      'ids': ids,
    };
  }
}
