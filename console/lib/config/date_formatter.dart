import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormatter _instance = DateFormatter._internal();

  DateFormatter._internal();

  factory DateFormatter() => _instance;

  /// dd/MMM/yyyy
  DateFormat get m => DateFormat('dd/MMM/yyyy');

  /// dd/MMM hh:mm a: when a run started or ended (`20/Oct 02:14 AM`), in UTC
  /// with the local time next to it ([AppDateTime])
  DateFormat get time => DateFormat('dd/MMM hh:mm a');

  /// EEE d MMM: a day of the run log (`Tue 20 Oct`), in UTC
  DateFormat get day => DateFormat('EEE d MMM');

  /// HH:mm:ss: a line of the log of a run, in UTC
  DateFormat get clock => DateFormat('HH:mm:ss');
}
