import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A bucket. Each of its [folders] (`orders`, `eu/billing`) is a connection
/// point; without folders, the root is. [settings] are sent back on save, like
/// those of a [SourceNode] (the service keeps the secret key)
class DestinationNode {
  final String id;
  final String name;
  final String type;
  final Map<String, dynamic> settings;
  final List<String> folders;
  final Offset pos;

  const DestinationNode({
    required this.id,
    required this.name,
    required this.type,
    required this.settings,
    this.folders = const [],
    this.pos = Offset.zero,
  });

  /// `S3 · bucket-backups`
  String get detail =>
      [DestinationTypeLook.labelOf(type), ?settings['bucket']].join(' · ');

  String get bucket => settings['bucket'] ?? name;

  TypeLook get look => DestinationTypeLook.lookOf(type);

  /// What its connection test sends: the saved settings with the folders of
  /// the canvas; without the secret key, which the service fills in
  DestinationFormModel toFormModel() => DestinationFormModel(
    name: name,
    type: type,
    endpoint: settings['endpoint'] ?? '',
    region: settings['region'] ?? '',
    bucket: settings['bucket'] ?? '',
    accessKeyId: settings['access_key_id'] ?? '',
    pathStyle: settings['path_style'] ?? false,
    folders: folders,
  );

  DestinationNode copyWith({Offset? pos, List<String>? folders}) =>
      DestinationNode(
        id: id,
        name: name,
        type: type,
        settings: settings,
        folders: folders ?? this.folders,
        pos: pos ?? this.pos,
      );
}
