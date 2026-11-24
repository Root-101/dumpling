/// A line of the log of a run: technical, in English, like the tools it runs
class RunLogLine {
  final DateTime at;
  final String message;

  const RunLogLine(this.at, this.message);

  factory RunLogLine.fromJson(Map<String, dynamic> json) =>
      RunLogLine(DateTime.parse(json['at']), json['message']);
}
