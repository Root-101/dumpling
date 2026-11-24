import 'package:console/app_exporter.dart';

/// How each type of source shows: product names, not translated
abstract class SourceTypeLook {
  static final Map<String, (String label, String tool, TypeLook look)> _types =
      {
        SourceTypes.postgres: (
          'PostgreSQL',
          'pg_dump',
          TypeLook('PG', app.colors.brand.postgres, _logos.postgresql),
        ),
        'mysql': (
          'MySQL',
          'mysqldump',
          TypeLook('MY', app.colors.brand.mysql, _logos.mysql),
        ),
        'mariadb': (
          'MariaDB',
          'mariadb-dump',
          TypeLook('MA', app.colors.brand.mysql, _logos.mariadb),
        ),
        'mongodb': (
          'MongoDB',
          'mongodump',
          TypeLook('MG', app.colors.brand.mongodb, _logos.mongodb),
        ),
        'redis': (
          'Redis',
          'redis-cli --rdb',
          TypeLook('RD', app.colors.brand.redis),
        ),
      };

  static const SourcesIcons _logos = SourcesIcons();

  static String labelOf(String type) => _types[type]?.$1 ?? type;

  /// The dump tool, under the label in the type picker
  static String toolOf(String type) => _types[type]?.$2 ?? '';

  static TypeLook lookOf(String type) =>
      _types[type]?.$3 ??
      TypeLook(type.substring(0, 2).toUpperCase(), app.colors.neutral.grey3);
}
