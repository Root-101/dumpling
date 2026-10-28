import 'package:service/dumpling.dart';

/// What the service does with a kind of destination. A new type (Google
/// Drive, SFTP…) is one more implementation registered in [drivers].
abstract class DestinationDriver {
  /// The driver of each enabled type.
  static final Map<DestinationType, DestinationDriver> drivers = {
    DestinationType.s3: S3DestinationDriver(),
  };

  /// Checks from the service that it can write in each of [folders] (the root
  /// when empty) without leaving anything behind. It never throws: a failure
  /// is a result.
  Future<ConnectionCheck> testConnection(
    DestinationSettings settings,
    Map<String, String> secrets,
    List<String> folders,
  );

  /// Writes [data] as [key] in [folder] (the root when null) and returns its
  /// size; [onProgress] gets the bytes written so far. On a failure nothing is
  /// left behind, and it throws. [onPending] gets what [abortPending] needs
  /// if the process stops before the upload ends.
  Future<int> upload(
    DestinationSettings settings,
    Map<String, String> secrets,
    String? folder,
    String key,
    Stream<List<int>> data, {
    void Function(int bytes)? onProgress,
    void Function(Map<String, String> pending)? onPending,
  });

  /// Drops what an upload left half done ([pending] from [upload]).
  Future<void> abortPending(
    DestinationSettings settings,
    Map<String, String> secrets,
    Map<String, String> pending,
  );

  /// Where [key] in [folder] ends up, for the run log
  /// (`backups/orders/2026/10/20.dump.gz`).
  String location(DestinationSettings settings, String? folder, String key);
}
