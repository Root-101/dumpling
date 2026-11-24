/// What a connection test found, the same values as the service
enum CheckStatus {
  /// Connected, and the dump tool can back it up
  connected,

  /// Connected, but the server is newer than the dump tool
  incompatible,

  /// Connected, but the dump tool is not installed where the service runs
  toolMissing,

  /// Could not connect or sign in
  failed,
}
