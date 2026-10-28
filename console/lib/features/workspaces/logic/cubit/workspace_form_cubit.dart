import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the dialog of a new workspace, or of the settings of one. It
/// lives while the dialog is open, so loading and errors show inside it
class WorkspaceFormCubit extends Cubit<WorkspaceFormState> {
  final WorkspaceRepo _repo;
  final AuthCubit _auth;

  WorkspaceFormCubit(this._repo, this._auth)
    : super(const WorkspaceFormInitialState());

  Future<void> create(WorkspaceDraft draft) => _process(
    () => _repo.create(draft: draft, token: _auth.auth?.accessToken),
  );

  Future<void> update(String slug, WorkspaceDraft draft) => _process(
    () =>
        _repo.update(slug: slug, draft: draft, token: _auth.auth?.accessToken),
  );

  Future<void> delete(WorkspaceModel workspace) => _process(() async {
    await _repo.delete(slug: workspace.slug, token: _auth.auth?.accessToken);
    return workspace;
  }, deleted: true);

  Future<void> _process(
    Future<WorkspaceModel> Function() run, {
    bool deleted = false,
  }) async {
    emit(const WorkspaceFormProcessInProgressState());
    try {
      final workspace = await run();
      emit(WorkspaceFormProcessingOKState(workspace, deleted: deleted));
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
  static const String schedule = 'defaults.schedule';
  static const String compression = 'defaults.compression';
  static const String objectKey = 'defaults.object_key';
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

  /// [workspace] was deleted, not saved
  final bool deleted;

  const WorkspaceFormProcessingOKState(this.workspace, {this.deleted = false});
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
