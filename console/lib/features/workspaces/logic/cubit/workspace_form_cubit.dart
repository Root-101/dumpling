import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the dialog of a new workspace, or of the settings of one. It
/// lives while the dialog is open, so loading and errors show inside it
class WorkspaceFormCubit extends Cubit<WorkspaceFormState>
    with GlobalEventBusCommunication<WorkspaceFormState> {
  final AuthCubit auth;
  final WorkspacesRepo repo;

  WorkspaceFormCubit({required this.auth, required this.repo})
    : super(const WorkspaceFormInitialState());

  Future<void> create(WorkspaceFormModel draft) =>
      _save(() => repo.create(draft: draft, token: auth.auth?.accessToken));

  Future<void> update(String slug, WorkspaceFormModel draft) => _save(
    () => repo.update(slug: slug, draft: draft, token: auth.auth?.accessToken),
  );

  Future<void> delete(WorkspaceModel workspace) async {
    emit(const WorkspaceFormDeletingState());
    try {
      await repo.delete(slug: workspace.slug, token: auth.auth?.accessToken);
      emit(WorkspaceFormDeletedOkState(workspace));
    } on Exception catch (e) {
      emit(WorkspaceFormDeletingErrorState(ExceptionConverter.parse(e)));
    }
  }

  Future<void> _save(Future<WorkspaceModel> Function() run) async {
    emit(const WorkspaceFormProcessInProgressState());
    try {
      emit(WorkspaceFormProcessingOKState(await run()));
    } on Exception catch (e) {
      final exception = ExceptionConverter.parse(e);
      if (exception.type == GlobalExceptionType.validation &&
          exception.data is List<ValidationError>) {
        emit(
          WorkspaceFormValidationErrorState(
            (exception.data as List<ValidationError>).asFailedValidations(),
          ),
        );
      } else {
        emit(WorkspaceFormProcessingErrorState(exception));
      }
    }
  }
}

/// Field names of the form, equal to the `fieldName`s the API returns
abstract class WorkspaceFormField {
  static const String name = 'name';
  static const String description = 'description';
  static const String schedule = 'defaults.schedule';
  static const String compression = 'defaults.compression';
  static const String objectKey = 'defaults.object_key';
}

abstract class WorkspaceFormState {
  const WorkspaceFormState();
}

final class WorkspaceFormInitialState extends WorkspaceFormState {
  const WorkspaceFormInitialState();
}

//----------------- validation -----------------\\
/// The service refused fields (422): under each field
final class WorkspaceFormValidationErrorState extends WorkspaceFormState {
  /// The message of each `fieldName` ([WorkspaceFormField])
  final Map<String, String> failValidations;

  const WorkspaceFormValidationErrorState(this.failValidations);
}

//----------------- save -----------------\\
abstract class WorkspaceFormProcessState extends WorkspaceFormState {
  const WorkspaceFormProcessState();
}

final class WorkspaceFormProcessInProgressState
    extends WorkspaceFormProcessState {
  const WorkspaceFormProcessInProgressState();
}

/// Public contract: the list of workspaces reloads on it (the bus)
final class WorkspaceFormProcessingOKState extends WorkspaceFormProcessState {
  final WorkspaceModel workspace;

  const WorkspaceFormProcessingOKState(this.workspace);
}

final class WorkspaceFormProcessingErrorState
    extends WorkspaceFormProcessState {
  final GlobalException exception;

  const WorkspaceFormProcessingErrorState(this.exception);
}

//----------------- delete -----------------\\
abstract class WorkspaceFormDeleteState extends WorkspaceFormState {
  const WorkspaceFormDeleteState();
}

final class WorkspaceFormDeletingState extends WorkspaceFormDeleteState {
  const WorkspaceFormDeletingState();
}

/// Public contract: the list of workspaces reloads on it (the bus)
final class WorkspaceFormDeletedOkState extends WorkspaceFormDeleteState {
  final WorkspaceModel workspace;

  const WorkspaceFormDeletedOkState(this.workspace);
}

final class WorkspaceFormDeletingErrorState extends WorkspaceFormDeleteState {
  final GlobalException exception;

  const WorkspaceFormDeletingErrorState(this.exception);
}
