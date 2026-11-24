import 'package:console/app_exporter.dart';

/// One check of a test run: a source or destination of [name], and what its
/// connection test found, or why the request failed ([error])
class CanvasCheck {
  final String name;
  final ConnectionCheckModel? check;
  final String? error;

  const CanvasCheck(this.name, {this.check, this.error});

  bool get ok => check?.status == CheckStatus.connected;
}
