import 'package:console/app_exporter.dart';

/// A canvas as the service returns it: the nodes without position are off
/// the canvas ([sourcePool], [destinationPool]). [ids] maps the `new_` ids of
/// a save to the saved ones
class CanvasModel {
  final List<SourceNode> sources;
  final List<SourceNode> sourcePool;
  final List<DestinationNode> destinations;
  final List<DestinationNode> destinationPool;
  final List<BackupConfig> configs;
  final Map<String, String> ids;

  /// The place of each source and destination in its list, as the service
  /// keeps them (dragged by hand): a save sends them back in that order
  final Map<String, int> order;

  const CanvasModel({
    required this.sources,
    required this.sourcePool,
    required this.destinations,
    required this.destinationPool,
    required this.configs,
    this.ids = const {},
    this.order = const {},
  });
}
