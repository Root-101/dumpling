import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the form of a key (new or edited). It lives while the form is
/// open; the list of keys takes the saved one from the bus
class ApiKeyFormCubit extends Cubit<ApiKeyFormState>
    with GlobalEventBusCommunication<ApiKeyFormState> {
  final AuthCubit auth;
  final ApiKeysRepo repo;
  final String workspace;

  /// The key being edited; null: a new one
  final String? keyId;

  ApiKeyFormCubit({
    required this.auth,
    required this.repo,
    required this.workspace,
    this.keyId,
  }) : super(const ApiKeyFormInitialState());

  /// Creates the key, or changes [keyId]; a new one comes with its text, shown
  /// once
  Future<void> save(ApiKeyDraft draft) async {
    emit(const ApiKeyFormProcessInProgressState());
    try {
      final key = await repo.save(
        workspace: workspace,
        draft: draft,
        id: keyId,
        token: auth.auth?.accessToken,
      );
      emit(
        ApiKeyFormProcessingOKState(
          key,
          workspace: workspace,
          created: keyId == null,
        ),
      );
    } on Exception catch (e) {
      final exception = ExceptionConverter.parse(e);
      if (exception.type == GlobalExceptionType.validation &&
          exception.data is List<ValidationError>) {
        emit(
          ApiKeyFormValidationErrorState(
            (exception.data as List<ValidationError>).asFailedValidations(),
            exception,
          ),
        );
      } else {
        emit(ApiKeyFormProcessingErrorState(exception));
      }
    }
  }
}

abstract class ApiKeyFormState {
  const ApiKeyFormState();
}

final class ApiKeyFormInitialState extends ApiKeyFormState {
  const ApiKeyFormInitialState();
}

//----------------- validation -----------------\\
/// The service refused fields (422)
final class ApiKeyFormValidationErrorState extends ApiKeyFormState {
  final Map<String, String> failValidations;

  /// The whole answer: the form has no field for every rule (a permission
  /// of another workspace), so it may show it as a notice
  final GlobalException exception;

  const ApiKeyFormValidationErrorState(this.failValidations, this.exception);
}

//----------------- save -----------------\\
abstract class ApiKeyFormProcessState extends ApiKeyFormState {
  const ApiKeyFormProcessState();
}

final class ApiKeyFormProcessInProgressState extends ApiKeyFormProcessState {
  const ApiKeyFormProcessInProgressState();
}

/// Public contract: the list of keys takes [key] from it (the bus)
final class ApiKeyFormProcessingOKState extends ApiKeyFormProcessState {
  /// A new one with its text in `key`
  final ApiKeyModel key;
  final String workspace;
  final bool created;

  const ApiKeyFormProcessingOKState(
    this.key, {
    required this.workspace,
    required this.created,
  });
}

final class ApiKeyFormProcessingErrorState extends ApiKeyFormProcessState {
  final GlobalException exception;

  const ApiKeyFormProcessingErrorState(this.exception);
}
