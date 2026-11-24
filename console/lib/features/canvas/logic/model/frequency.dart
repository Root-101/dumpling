import 'package:console/app_exporter.dart';

enum Frequency {
  hourly,
  daily,
  weekly,
  cron;

  String get label => switch (this) {
    hourly => app.intl.canvas.frequency.hourly,
    daily => app.intl.canvas.frequency.daily,
    weekly => app.intl.canvas.frequency.weekly,
    cron => app.intl.canvas.frequency.cron,
  };

  /// What the picker shows for [cron]: the schedules it writes
  /// (`m * * * *`, `m h * * *`, `m h * * 0`), any other one is [cron]
  static Frequency of(String cron) {
    final f = cron.trim().split(RegExp(r'\s+'));
    if (f.length != 5 || f[2] != '*' || f[3] != '*') return Frequency.cron;
    final minute = int.tryParse(f[0]) != null;
    final hour = int.tryParse(f[1]) != null;
    if (minute && f[1] == '*' && f[4] == '*') return Frequency.hourly;
    if (minute && hour && f[4] == '*') return Frequency.daily;
    if (minute && hour && f[4] == '0') return Frequency.weekly;
    return Frequency.cron;
  }

  /// The cron [f] writes from [schedule]: hourly, daily and weekly keep its
  /// minute and hour (03:00 while it is the default of the workspace); cron
  /// keeps it as is
  static String? apply(Frequency f, String? schedule) {
    if (f == Frequency.cron) return schedule;
    final fields = (schedule ?? '0 3 * * *').trim().split(RegExp(r'\s+'));
    final m = int.tryParse(fields.first) ?? 0;
    final h = fields.length > 1 ? int.tryParse(fields[1]) ?? 3 : 3;
    return switch (f) {
      Frequency.hourly => '$m * * * *',
      Frequency.daily => '$m $h * * *',
      Frequency.weekly => '$m $h * * 0',
      Frequency.cron => schedule,
    };
  }
}
