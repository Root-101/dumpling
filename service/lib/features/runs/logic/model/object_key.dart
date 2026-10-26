/// The name of the file a run writes, from the object key of its config.
abstract final class ObjectKey {
  /// [template] with its placeholders filled in, at [at] (UTC), plus
  /// [extension]: `{db}/{yyyy}-{MM}-{dd}` → `orders/2026-10-20.dump.gz`.
  static String render(
    String template, {
    required DateTime at,
    required String database,
    required String runId,
    required String extension,
  }) {
    String two(int n) => n.toString().padLeft(2, '0');
    final utc = at.toUtc();
    final values = {
      'yyyy': utc.year.toString().padLeft(4, '0'),
      'MM': two(utc.month),
      'dd': two(utc.day),
      'HH': two(utc.hour),
      'mm': two(utc.minute),
      'db': database,
      'run_id': runId,
    };
    // An unknown placeholder stays as it is
    final key = template.replaceAllMapped(
      RegExp(r'\{(\w+)\}'),
      (m) => values[m.group(1)] ?? m.group(0)!,
    );
    return '$key$extension';
  }
}
