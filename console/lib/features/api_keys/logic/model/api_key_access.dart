import 'package:console/app_exporter.dart';

/// What a key may do, by the template its permissions match
enum ApiKeyAccess {
  run,
  read,
  full,
  custom;

  /// The template [permissions] are, or [custom]. A key [limited] to some
  /// configs matches the template without what it can't have
  static ApiKeyAccess of(Iterable<String> permissions, {bool limited = false}) {
    final set = permissions.toSet();
    for (final access in [run, read, full]) {
      final template = ApiKeyPermissions.of(access, limited: limited);
      if (set.length == template.length && set.containsAll(template)) {
        return access;
      }
    }
    return custom;
  }

  String get label => switch (this) {
    run => app.intl.apiKeys.run,
    read => app.intl.apiKeys.read,
    full => app.intl.apiKeys.full,
    custom => app.intl.apiKeys.custom,
  };
}
