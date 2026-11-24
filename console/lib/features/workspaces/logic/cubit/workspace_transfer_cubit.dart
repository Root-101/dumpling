import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Export and import of workspaces. Not a singleton: whoever exports or
/// imports creates it and closes it after; the list of workspaces reloads on
/// [WorkspaceTransferImportedOkState] (the bus)
class WorkspaceTransferCubit extends Cubit<WorkspaceTransferState>
    with GlobalEventBusCommunication<WorkspaceTransferState> {
  final AuthCubit auth;
  final WorkspacesRepo repo;

  WorkspaceTransferCubit({required this.auth, required this.repo})
    : super(const WorkspaceTransferInitialState());

  /// The export of [workspace], or of every one when null
  Future<void> export({WorkspaceModel? workspace}) async {
    emit(const WorkspaceTransferExportingState());
    try {
      final file = await repo.export(
        slug: workspace?.slug,
        token: auth.auth?.accessToken,
      );
      emit(WorkspaceTransferExportedOkState(file, workspace: workspace));
    } on Exception catch (e) {
      emit(WorkspaceTransferExportingErrorState(ExceptionConverter.parse(e)));
    }
  }

  /// Adds the workspaces of [file] (an export, as it was read)
  Future<void> import(Map<String, dynamic> file) async {
    emit(const WorkspaceTransferImportingState());
    try {
      final created = await repo.import(
        file: file,
        token: auth.auth?.accessToken,
      );
      emit(WorkspaceTransferImportedOkState(created));
    } on Exception catch (e) {
      emit(WorkspaceTransferImportingErrorState(ExceptionConverter.parse(e)));
    }
  }
}

abstract class WorkspaceTransferState {
  const WorkspaceTransferState();
}

final class WorkspaceTransferInitialState extends WorkspaceTransferState {
  const WorkspaceTransferInitialState();
}

//----------------- export -----------------\\
abstract class WorkspaceTransferExportState extends WorkspaceTransferState {
  const WorkspaceTransferExportState();
}

final class WorkspaceTransferExportingState
    extends WorkspaceTransferExportState {
  const WorkspaceTransferExportingState();
}

final class WorkspaceTransferExportedOkState
    extends WorkspaceTransferExportState {
  /// The file, as the service sent it
  final Map<String, dynamic> file;

  /// The workspace exported; null: every one
  final WorkspaceModel? workspace;

  const WorkspaceTransferExportedOkState(this.file, {this.workspace});
}

final class WorkspaceTransferExportingErrorState
    extends WorkspaceTransferExportState {
  final GlobalException exception;

  const WorkspaceTransferExportingErrorState(this.exception);
}

//----------------- import -----------------\\
abstract class WorkspaceTransferImportState extends WorkspaceTransferState {
  const WorkspaceTransferImportState();
}

final class WorkspaceTransferImportingState
    extends WorkspaceTransferImportState {
  const WorkspaceTransferImportingState();
}

/// Public contract: the list of workspaces reloads on it
final class WorkspaceTransferImportedOkState
    extends WorkspaceTransferImportState {
  /// The workspaces added
  final List<WorkspaceModel> created;

  const WorkspaceTransferImportedOkState(this.created);
}

final class WorkspaceTransferImportingErrorState
    extends WorkspaceTransferImportState {
  final GlobalException exception;

  const WorkspaceTransferImportingErrorState(this.exception);
}
