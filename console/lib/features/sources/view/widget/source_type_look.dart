import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// How each type of source shows: product names, not translated
abstract class SourceTypeLook {
  static const Map<String, (String label, String tool, TypeLook look)>
  _types = {
    SourceTypes.postgres: (
      'PostgreSQL',
      'pg_dump',
      TypeLook('PG', Color(0xFF8AA8FF)),
    ),
    'mysql': ('MySQL', 'mysqldump', TypeLook('MY', Color(0xFF5CC8BD))),
    'mariadb': ('MariaDB', 'mariadb-dump', TypeLook('MA', Color(0xFF5CC8BD))),
    'mongodb': ('MongoDB', 'mongodump', TypeLook('MG', Color(0xFF5FD17F))),
    'redis': ('Redis', 'redis-cli --rdb', TypeLook('RD', Color(0xFFEC8A86))),
  };

  static String labelOf(String type) => _types[type]?.$1 ?? type;

  /// The dump tool, under the label in the type picker
  static String toolOf(String type) => _types[type]?.$2 ?? '';

  static TypeLook lookOf(String type) =>
      _types[type]?.$3 ??
      TypeLook(type.substring(0, 2).toUpperCase(), const Color(0xFFB0AEB8));
}
