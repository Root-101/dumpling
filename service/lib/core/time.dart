/// Now, in UTC. Never `DateTime.now()` alone: drift and the JSON would mix
/// zones.
DateTime utcNow() => DateTime.now().toUtc();

/// A moment as the API writes it: ISO 8601 in UTC with milliseconds
/// (`2026-10-30T05:16:13.373Z`).
String jsonDate(DateTime value) {
  final text = value.toUtc().toIso8601String();
  // toIso8601String gives microseconds when there are any: keep 3 decimals
  final dot = text.indexOf('.');
  return dot < 0 ? text : '${text.substring(0, dot + 4)}Z';
}
