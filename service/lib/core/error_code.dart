import 'package:service/dumpling.dart';

/// Every business error of the service: its stable code and its status.
///
/// [code] is the i18n key of its message without `errors.`; clients decide on
/// it, never on the text, so renaming one is a breaking change of the API.
enum ErrorCode {
  authInvalidCredentials('auth.invalidCredentials', StatusCode.unauthorized),
  authTooManyLoginAttempts(
    'auth.tooManyLoginAttempts',
    StatusCode.tooManyRequests,
  ),
  workspacesNotFound('workspaces.notFound', StatusCode.notFound),
  sourcesNotFound('sources.notFound', StatusCode.notFound),
  sourcesInUse('sources.inUse', StatusCode.conflict),
  destinationsNotFound('destinations.notFound', StatusCode.notFound),
  destinationsInUse('destinations.inUse', StatusCode.conflict),
  destinationsFolderInUse('destinations.folderInUse', StatusCode.conflict),
  configsNotFound('configs.notFound', StatusCode.notFound),
  apiKeysNotFound('apiKeys.notFound', StatusCode.notFound),
  runsNotFound('runs.notFound', StatusCode.notFound);

  final String code;
  final StatusCode status;

  const ErrorCode(this.code, this.status);
}
