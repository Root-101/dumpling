import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the drawer of a source (new or edited). It lives while the drawer
/// is open, so the test, loading and errors show inside the form
class SourceFormCubit extends Cubit<SourceFormState>
    with GlobalEventBusCommunication<SourceFormState> {
  final AuthCubit auth;
  final SourcesRepo repo;
  final String workspace;

  /// The source being edited; null: a new one
  final String? sourceId;

  SourceFormCubit({
    required this.auth,
    required this.repo,
    required this.workspace,
    this.sourceId,
  }) : super(const SourceFormInitialState());

  /// Tests the connection of the form, before saving it (in the service)
  Future<void> test(SourceFormModel draft) async {
    emit(const SourceFormTestingState());
    try {
      final check = await repo.testUnsaved(
        workspace: workspace,
        draft: draft,
        sourceId: sourceId,
        token: auth.auth?.accessToken,
      );
      emit(SourceFormTestedOkState(check));
    } on Exception catch (e) {
      _emitError(e, testing: true);
    }
  }

  /// [tested]: the form was tested as it is saved. The service keeps only
  /// the tests of a saved source, so it is tested again once saved
  Future<void> save(SourceFormModel draft, {bool tested = false}) async {
    emit(const SourceFormProcessInProgressState());
    try {
      var source = await repo.save(
        workspace: workspace,
        draft: draft,
        id: sourceId,
        token: auth.auth?.accessToken,
      );
      if (tested) {
        // already saved: a failed test leaves it untested, not unsaved
        try {
          source = source.withCheck(
            await repo.testSaved(
              workspace: workspace,
              id: source.id,
              token: auth.auth?.accessToken,
            ),
          );
        } catch (_) {}
      }
      emit(SourceFormProcessingOKState(source));
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
        SourceFormValidationErrorState(
          (exception.data as List<ValidationError>).asFailedValidations(),
        ),
      );
    } else if (testing) {
      emit(SourceFormTestingErrorState(exception));
    } else {
      emit(SourceFormProcessingErrorState(exception));
    }
  }
}

/// Field names of the form, equal to the `fieldName`s the API returns
abstract class SourceFormField {
  static const String name = 'name';
  static const String type = 'type';
  static const String connectionUrl = 'settings.connection_url';
  static const String host = 'settings.host';
  static const String port = 'settings.port';
  static const String database = 'settings.database';
  static const String username = 'settings.username';
  static const String password = 'settings.password';
  static const String dumpFormat = 'settings.dump_format';
  static const String sslMode = 'settings.ssl_mode';
}

abstract class SourceFormState {
  const SourceFormState();
}

final class SourceFormInitialState extends SourceFormState {
  const SourceFormInitialState();
}

//----------------- test the connection of the form -----------------\\
abstract class SourceFormTestState extends SourceFormState {
  const SourceFormTestState();
}

final class SourceFormTestingState extends SourceFormTestState {
  const SourceFormTestingState();
}

final class SourceFormTestedOkState extends SourceFormTestState {
  final ConnectionCheckModel check;

  const SourceFormTestedOkState(this.check);
}

final class SourceFormTestingErrorState extends SourceFormTestState {
  final GlobalException exception;

  const SourceFormTestingErrorState(this.exception);
}

//----------------- validation -----------------\\
/// The service refused fields (422), of a test or a save: under each field
final class SourceFormValidationErrorState extends SourceFormState {
  /// The message of each `fieldName` ([SourceFormField])
  final Map<String, String> failValidations;

  const SourceFormValidationErrorState(this.failValidations);
}

//----------------- save -----------------\\
abstract class SourceFormProcessState extends SourceFormState {
  const SourceFormProcessState();
}

final class SourceFormProcessInProgressState extends SourceFormProcessState {
  const SourceFormProcessInProgressState();
}

/// Public contract: the list of sources reloads on it (the bus)
final class SourceFormProcessingOKState extends SourceFormProcessState {
  final SourceModel source;

  const SourceFormProcessingOKState(this.source);
}

final class SourceFormProcessingErrorState extends SourceFormProcessState {
  final GlobalException exception;

  const SourceFormProcessingErrorState(this.exception);
}
