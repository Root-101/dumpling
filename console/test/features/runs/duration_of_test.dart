import 'package:console/app_exporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should show the two biggest units of a duration, days the largest', () {
    String of(Duration d) => RunsScreen.durationOf(d);

    expect(of(const Duration(milliseconds: 400)), '0.4 s');
    expect(of(const Duration(seconds: 42)), '42 s');
    expect(of(const Duration(minutes: 3, seconds: 5)), '3 min 5 s');
    expect(of(const Duration(hours: 23, minutes: 59)), '23 h 59 min');
    expect(of(const Duration(days: 1, hours: 3, minutes: 20)), '1 d 3 h');
    expect(of(const Duration(hours: 719, minutes: 39)), '29 d 23 h');
  });
}
