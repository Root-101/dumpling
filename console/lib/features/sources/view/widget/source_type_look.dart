import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// How each type of source shows: product names, not translated
abstract class SourceTypeLook {
  static final Map<String, (String label, String tool, TypeLook look)>
  _types = {
    SourceTypes.postgres: (
      'PostgreSQL',
      'pg_dump',
      TypeLook('PG', const Color(0xFF8AA8FF), _logos.postgresql),
    ),
    'mysql': (
      'MySQL',
      'mysqldump',
      TypeLook('MY', const Color(0xFF5CC8BD), _logos.mysql),
    ),
    'mariadb': (
      'MariaDB',
      'mariadb-dump',
      TypeLook('MA', const Color(0xFF5CC8BD), _logos.mariadb),
    ),
    'mongodb': (
      'MongoDB',
      'mongodump',
      TypeLook('MG', const Color(0xFF5FD17F), _logos.mongodb),
    ),
    'redis': (
      'Redis',
      'redis-cli --rdb',
      const TypeLook('RD', Color(0xFFEC8A86)),
    ),
  };

  static const SourcesIcons _logos = SourcesIcons();

  static String labelOf(String type) => _types[type]?.$1 ?? type;

  /// The dump tool, under the label in the type picker
  static String toolOf(String type) => _types[type]?.$2 ?? '';

  static TypeLook lookOf(String type) =>
      _types[type]?.$3 ??
      TypeLook(type.substring(0, 2).toUpperCase(), const Color(0xFFB0AEB8));
}
