import 'package:console/app_exporter.dart';

/// A config of [WorkspaceStatsModel.preview]: what it connects, by id
typedef WorkspacePreviewLink = ({
  String source,
  String destination,
  bool failing,
});
