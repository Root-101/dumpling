import 'package:console/app_exporter.dart';

/// How each type of destination shows: product names, not translated
abstract class DestinationTypeLook {
  static final Map<String, (String label, TypeLook look)> _types = {
    DestinationTypes.s3: (
      'S3',
      TypeLook('S3', app.colors.brand.accent, _logos.s3),
    ),
    'gdrive': (
      'Google Drive',
      TypeLook('GD', app.colors.brand.mongodb, _logos.gdrive),
    ),
    'dropbox': (
      'Dropbox',
      TypeLook('DB', app.colors.brand.postgres, _logos.dropbox),
    ),
    'azure': ('Azure Blob', TypeLook('AZ', app.colors.brand.postgres)),
    'sftp': ('SFTP', TypeLook('FT', app.colors.brand.sftp)),
  };

  static const DestinationsIcons _logos = DestinationsIcons();

  static String labelOf(String type) => _types[type]?.$1 ?? type;

  /// What it is, under the label in the type picker
  static String subOf(String type) => switch (type) {
    DestinationTypes.s3 => app.intl.destinations.typeSub.s3,
    'gdrive' => app.intl.destinations.typeSub.gdrive,
    'dropbox' => app.intl.destinations.typeSub.dropbox,
    'azure' => app.intl.destinations.typeSub.azure,
    'sftp' => app.intl.destinations.typeSub.sftp,
    _ => '',
  };

  static TypeLook lookOf(String type) =>
      _types[type]?.$2 ??
      TypeLook(type.substring(0, 2).toUpperCase(), app.colors.neutral.grey3);
}
