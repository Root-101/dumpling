/// The stable codes the service sends in the `code` of its Problem Details
/// ([GlobalException.errorCode]) and of each violation of a 422
/// ([ValidationError.code]). The same in every language: compare them to decide
/// a case, never the text (it comes translated by `Accept-Language`). The whole
/// list is in `docs/api.md` (*Errors*); one here per code a view needs.
class ApiErrorCode {
  ApiErrorCode._();

  /// Wrong username or password (401 of the sign-in)
  static const String authInvalidCredentials = 'auth.invalidCredentials';

  /// The sign-in is locked for a while (429, `Retry-After`)
  static const String authTooManyLoginAttempts = 'auth.tooManyLoginAttempts';

  /// The workspace of the URL doesn't exist (404)
  static const String workspacesNotFound = 'workspaces.notFound';
}
