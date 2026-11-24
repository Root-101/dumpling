import 'package:console/app_exporter.dart';

/// The values a config takes, as the service accepts them
abstract class ConfigRules {
  static const int maxNameLength = 64;
  static const int maxObjectKeyLength = 512;
  static const List<String> compressions = ['gzip', 'none'];

  /// The extensions of a backup file: the engine adds them by itself
  static const List<String> _extensions = [
    '.dump', '.sql', '.gz', '.gzip', '.zip', '.tar', '.zst', '.bz2', '.xz', //
    '.bak', '.backup',
  ];

  static final RegExp _cronField = RegExp(r'^[\w*,/-]+$');

  static String? name(String value) =>
      value.trim().isEmpty ? app.intl.common.required : null;

  /// 5 fields (minute hour day month weekday); the service checks the rest
  static String? cron(String? value) {
    if (value == null) return null;
    final fields = value.trim().split(RegExp(r'\s+'));
    return fields.length == 5 && fields.every(_cronField.hasMatch)
        ? null
        : app.intl.canvas.inspector.cronInvalid;
  }

  /// Relative and without extension; null (empty) is the default
  static String? objectKey(String? value) {
    if (value == null) return null;
    if (value.startsWith('/')) return app.intl.canvas.inspector.objectKeySlash;
    if (value.split('/').any((s) => s == '.' || s == '..')) {
      return app.intl.canvas.inspector.objectKeyDots;
    }
    final file = value.split('/').last.toLowerCase();
    return _extensions.any(file.endsWith)
        ? app.intl.canvas.inspector.objectKeyExtension
        : null;
  }

  /// What the engine adds to the key: `.dump` or `.sql` from the dump format
  /// of [source], `.gz` with gzip
  static String extension(SourceNode source, String? compression) =>
      (source.settings['dump_format'] == 'plain' ? '.sql' : '.dump') +
      (compression == 'gzip' ? '.gz' : '');

  /// gzip over the custom format (`pg_dump -Fc`), compressed already: allowed,
  /// but it barely makes the file smaller
  static bool doubleCompression(SourceNode? source, String? compression) =>
      source != null &&
      source.settings['dump_format'] != 'plain' &&
      compression == 'gzip';
}
