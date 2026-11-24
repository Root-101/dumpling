import 'package:console/app_exporter.dart';

/// A step of a run ([RunModel.steps]) and how long it took, when known
class RunStep {
  final RunStepState state;
  final Duration? duration;

  const RunStep(this.state, [this.duration]);
}
