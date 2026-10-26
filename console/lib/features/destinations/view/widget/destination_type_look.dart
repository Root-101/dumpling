import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// How each type of destination shows: product names, not translated
abstract class DestinationTypeLook {
  static const Map<String, (String label, TypeLook look)> _types = {
    DestinationTypes.s3: ('S3', TypeLook('S3', Color(0xFFE6B77E))),
    'gdrive': ('Google Drive', TypeLook('GD', Color(0xFF5FD17F))),
    'dropbox': ('Dropbox', TypeLook('DB', Color(0xFF8AA8FF))),
    'azure': ('Azure Blob', TypeLook('AZ', Color(0xFF8AA8FF))),
    'sftp': ('SFTP', TypeLook('FT', Color(0xFFD0CFD6))),
  };

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
      TypeLook(type.substring(0, 2).toUpperCase(), const Color(0xFFB0AEB8));
}
