import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the dialog of a new workspace. It lives while the dialog is open,
/// so loading and errors show inside the form
class WorkspaceFormCubit extends Cubit<WorkspaceFormState> {
  final WorkspaceRepo _repo;
  final AuthCubit _auth;

  WorkspaceFormCubit(this._repo, this._auth)
    : super(const WorkspaceFormInitialState());

  Future<void> create(WorkspaceDraft draft) async {
    emit(const WorkspaceFormProcessInProgressState());
    try {
      final workspace = await _repo.create(
        draft: draft,
        token: _auth.auth?.accessToken,
      );
      emit(WorkspaceFormProcessingOKState(workspace));
    } catch (e) {
      final exception = ExceptionConverter.parse(e);
      emit(
        WorkspaceFormProcessingErrorState(
          exception,
          fieldErrors: switch (exception.data) {
            List<ValidationError> errors
                when exception.type == GlobalExceptionType.validation =>
              errors.asFailedValidations(),
            _ => const {},
          },
        ),
      );
    }
  }
}

/// Field names of the form, equal to the `fieldName`s the API returns
abstract class WorkspaceFormField {
  static const String name = 'name';
  static const String description = 'description';
}

abstract class WorkspaceFormState {
  const WorkspaceFormState();
}

class WorkspaceFormInitialState extends WorkspaceFormState {
  const WorkspaceFormInitialState();
}

//------------------------- PROCESSING -------------------------\
class WorkspaceFormProcessInProgressState extends WorkspaceFormState {
  const WorkspaceFormProcessInProgressState();
}

class WorkspaceFormProcessingOKState extends WorkspaceFormState {
  final WorkspaceModel workspace;

  const WorkspaceFormProcessingOKState(this.workspace);
}

class WorkspaceFormProcessingErrorState extends WorkspaceFormState {
  final GlobalException exception;

  /// Errors per field; if empty, the error belongs to the whole form
  final Map<String, String> fieldErrors;

  const WorkspaceFormProcessingErrorState(
    this.exception, {
    this.fieldErrors = const {},
  });
}
