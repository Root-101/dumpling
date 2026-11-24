import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the drawer of a destination (new or edited). It lives while the
/// drawer is open, so the test, loading and errors show inside the form
class DestinationFormCubit extends Cubit<DestinationFormState>
    with GlobalEventBusCommunication<DestinationFormState> {
  final AuthCubit auth;
  final DestinationsRepo repo;
  final String workspace;

  /// The destination being edited; null: a new one
  final String? destinationId;

  DestinationFormCubit({
    required this.auth,
    required this.repo,
    required this.workspace,
    this.destinationId,
  }) : super(const DestinationFormInitialState());

  /// Tests the connection of the form, before saving it (in the service)
  Future<void> test(DestinationFormModel draft) async {
    emit(const DestinationFormTestingState());
    try {
      final check = await repo.testUnsaved(
        workspace: workspace,
        draft: draft,
        destinationId: destinationId,
        token: auth.auth?.accessToken,
      );
      emit(DestinationFormTestedOkState(check));
    } on Exception catch (e) {
      _emitError(e, testing: true);
    }
  }

  /// [tested]: the form was tested as it is saved. The service keeps only
  /// the tests of a saved destination, so it is tested again once saved
  Future<void> save(DestinationFormModel draft, {bool tested = false}) async {
    emit(const DestinationFormProcessInProgressState());
    try {
      var destination = await repo.save(
        workspace: workspace,
        draft: draft,
        id: destinationId,
        token: auth.auth?.accessToken,
      );
      if (tested) {
        // already saved: a failed test leaves it untested, not unsaved
        try {
          destination = destination.withCheck(
            await repo.testSaved(
              workspace: workspace,
              id: destination.id,
              token: auth.auth?.accessToken,
            ),
          );
        } on Exception catch (_) {}
      }
      emit(DestinationFormProcessingOKState(destination));
    } on Exception catch (e) {
      _emitError(e);
    }
  }

  /// A 422 goes to the fields; anything else to the whole form
  void _emitError(Exception e, {bool testing = false}) {
    final exception = ExceptionConverter.parse(e);
    if (exception.type == GlobalExceptionType.validation &&
        exception.data is List<ValidationError>) {
      emit(
        DestinationFormValidationErrorState(
          (exception.data as List<ValidationError>).asFailedValidations(),
        ),
      );
    } else if (testing) {
      emit(DestinationFormTestingErrorState(exception));
    } else {
      emit(DestinationFormProcessingErrorState(exception));
    }
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

final class DestinationFormInitialState extends DestinationFormState {
  const DestinationFormInitialState();
}

//----------------- test the connection of the form -----------------\\
abstract class DestinationFormTestState extends DestinationFormState {
  const DestinationFormTestState();
}

final class DestinationFormTestingState extends DestinationFormTestState {
  const DestinationFormTestingState();
}

final class DestinationFormTestedOkState extends DestinationFormTestState {
  final ConnectionCheckModel check;

  const DestinationFormTestedOkState(this.check);
}

final class DestinationFormTestingErrorState extends DestinationFormTestState {
  final GlobalException exception;

  const DestinationFormTestingErrorState(this.exception);
}

//----------------- validation -----------------\\
/// The service refused fields (422), of a test or a save: under each field
final class DestinationFormValidationErrorState extends DestinationFormState {
  /// The message of each `fieldName` ([DestinationFormField])
  final Map<String, String> failValidations;

  const DestinationFormValidationErrorState(this.failValidations);
}

//----------------- save -----------------\\
abstract class DestinationFormProcessState extends DestinationFormState {
  const DestinationFormProcessState();
}

final class DestinationFormProcessInProgressState
    extends DestinationFormProcessState {
  const DestinationFormProcessInProgressState();
}

/// Public contract: the list of destinations reloads on it (the bus)
final class DestinationFormProcessingOKState
    extends DestinationFormProcessState {
  final DestinationModel destination;

  const DestinationFormProcessingOKState(this.destination);
}

final class DestinationFormProcessingErrorState
    extends DestinationFormProcessState {
  final GlobalException exception;

  const DestinationFormProcessingErrorState(this.exception);
}
