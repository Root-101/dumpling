import 'package:service/dumpling.dart';

/// The rules of a schedule and an object key, the same for a config and for
/// the defaults of its workspace.
extension BackupRules on FieldValidator<String?> {
  static const int maxObjectKeyLength = 512;

  /// The extensions of a backup file, which the engine adds by itself.
  static const List<String> _extensions = [
    '.dump', '.sql', '.gz', '.gzip', '.zip', '.tar', '.zst', '.bz2', '.xz', //
    '.bak', '.backup',
  ];

  /// A cron expression of 5 fields (always in UTC).
  FieldValidator<String?> cron() => custom(
    (value) =>
        value == null || isCron(value) ? null : intl.errors.validations.cron,
  );

  /// Relative (no `/` first) and without extension.
  FieldValidator<String?> objectKey() => size(min: 1, max: maxObjectKeyLength)
      .custom(
        (value) => value == null || !value.startsWith('/')
            ? null
            : intl.errors.validations.objectKey,
      )
      .custom(
        (value) => value == null || !_hasExtension(value)
            ? null
            : intl.errors.validations.objectKeyExtension,
      );

  static bool isCron(String value) {
    try {
      CronSchedule.parse(value, utc: true);
      return true;
    } on FormatException {
      return false;
    }
  }

  /// Whether the file name (after the last `/`) ends in one of [_extensions].
  static bool _hasExtension(String key) {
    final file = key.split('/').last.toLowerCase();
    return _extensions.any(file.endsWith);
  }
}
