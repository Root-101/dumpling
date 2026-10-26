/// A backup: what it dumps ([sourceId]) and where it writes it
/// ([destinationId], in [folder]). Only what the lists need so far
class ConfigModel {
  final String id;
  final String name;
  final String sourceId;
  final String destinationId;

  /// Null: the root of the destination
  final String? folder;

  const ConfigModel({
    required this.id,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    this.folder,
  });
}
