import 'package:console/app_exporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// State of the drawer of a source (new or edited). It lives while the drawer
/// is open, so the test, loading and errors show inside the form
class SourceFormCubit extends Cubit<SourceFormState> {
  final SourceRepo _repo;
  final AuthCubit _auth;
  final String workspace;

  /// The source being edited; null: a new one
  final String? sourceId;

  SourceFormCubit(
    this._repo,
    this._auth, {
    required this.workspace,
    this.sourceId,
  }) : super(const SourceFormInitialState());

  /// Tests the connection of the form, before saving it (in the service)
  Future<void> test(SourceDraft draft) async {
    emit(const SourceFormTestInProgressState());
    try {
      final check = await _repo.testUnsaved(
        workspace: workspace,
        draft: draft,
        sourceId: sourceId,
        token: _auth.auth?.accessToken,
      );
      emit(SourceFormTestedState(check));
    } catch (e) {
      _emitError(e);
    }
  }

  /// [tested]: the form was tested as it is saved. The service keeps only
  /// the tests of a saved source, so it is tested again once saved
  Future<void> save(SourceDraft draft, {bool tested = false}) async {
    emit(const SourceFormProcessInProgressState());
    try {
      var source = await _repo.save(
        workspace: workspace,
        draft: draft,
        id: sourceId,
        token: _auth.auth?.accessToken,
      );
      if (tested) {
        // already saved: a failed test leaves it untested, not unsaved
        try {
          source = source.withCheck(
            await _repo.testSaved(
              workspace: workspace,
              id: source.id,
              token: _auth.auth?.accessToken,
            ),
          );
        } catch (_) {}
      }
      emit(SourceFormProcessingOKState(source));
    } catch (e) {
      _emitError(e);
    }
  }

  void _emitError(Object e) {
    final exception = ExceptionConverter.parse(e);
    emit(
      SourceFormProcessingErrorState(
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
}

abstract class SourceFormState {
  const SourceFormState();
}

class SourceFormInitialState extends SourceFormState {
  const SourceFormInitialState();
}

//------------------------- TEST -------------------------\
class SourceFormTestInProgressState extends SourceFormState {
  const SourceFormTestInProgressState();
}

class SourceFormTestedState extends SourceFormState {
  final ConnectionCheckModel check;

  const SourceFormTestedState(this.check);
}

//------------------------- PROCESSING -------------------------\
class SourceFormProcessInProgressState extends SourceFormState {
  const SourceFormProcessInProgressState();
}

class SourceFormProcessingOKState extends SourceFormState {
  final SourceModel source;

  const SourceFormProcessingOKState(this.source);
}

/// A failed test or save
class SourceFormProcessingErrorState extends SourceFormState {
  final GlobalException exception;

  /// Errors per field; if empty, the error belongs to the whole form
  final Map<String, String> fieldErrors;

  const SourceFormProcessingErrorState(
    this.exception, {
    this.fieldErrors = const {},
  });
}
