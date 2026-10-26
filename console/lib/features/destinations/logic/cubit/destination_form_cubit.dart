import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the drawer of a destination (new or edited). It lives while the
/// drawer is open, so the test, loading and errors show inside the form
class DestinationFormCubit extends Cubit<DestinationFormState> {
  final DestinationRepo _repo;
  final AuthCubit _auth;
  final String workspace;

  /// The destination being edited; null: a new one
  final String? destinationId;

  DestinationFormCubit(
    this._repo,
    this._auth, {
    required this.workspace,
    this.destinationId,
  }) : super(const DestinationFormInitialState());

  /// Tests the connection of the form, before saving it (in the service)
  Future<void> test(DestinationDraft draft) async {
    emit(const DestinationFormTestInProgressState());
    try {
      final check = await _repo.testUnsaved(
        workspace: workspace,
        draft: draft,
        destinationId: destinationId,
        token: _auth.auth?.accessToken,
      );
      emit(DestinationFormTestedState(check));
    } catch (e) {
      _emitError(e);
    }
  }

  Future<void> save(DestinationDraft draft) async {
    emit(const DestinationFormProcessInProgressState());
    try {
      final destination = await _repo.save(
        workspace: workspace,
        draft: draft,
        id: destinationId,
        token: _auth.auth?.accessToken,
      );
      emit(DestinationFormProcessingOKState(destination));
    } catch (e) {
      _emitError(e);
    }
  }

  void _emitError(Object e) {
    final exception = ExceptionConverter.parse(e);
    emit(
      DestinationFormProcessingErrorState(
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

/// Field names of the form, equal to the `fieldName`s the API returns
abstract class DestinationFormField {
  static const String name = 'name';
  static const String type = 'type';
  static const String endpoint = 'settings.endpoint';
  static const String region = 'settings.region';
  static const String bucket = 'settings.bucket';
  static const String accessKeyId = 'settings.access_key_id';
  static const String secretKey = 'settings.secret_access_key';
  static const String folders = 'folders';
}

abstract class DestinationFormState {
  const DestinationFormState();
}

class DestinationFormInitialState extends DestinationFormState {
  const DestinationFormInitialState();
}

//------------------------- TEST -------------------------\
class DestinationFormTestInProgressState extends DestinationFormState {
  const DestinationFormTestInProgressState();
}

class DestinationFormTestedState extends DestinationFormState {
  final ConnectionCheckModel check;

  const DestinationFormTestedState(this.check);
}

//------------------------- PROCESSING -------------------------\
class DestinationFormProcessInProgressState extends DestinationFormState {
  const DestinationFormProcessInProgressState();
}

class DestinationFormProcessingOKState extends DestinationFormState {
  final DestinationModel destination;

  const DestinationFormProcessingOKState(this.destination);
}

/// A failed test or save
class DestinationFormProcessingErrorState extends DestinationFormState {
  final GlobalException exception;

  /// Errors per field; if empty, the error belongs to the whole form
  final Map<String, String> fieldErrors;

  const DestinationFormProcessingErrorState(
    this.exception, {
    this.fieldErrors = const {},
  });
}
