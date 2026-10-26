import 'package:service/dumpling.dart';

/// The connection data of a destination, one implementation per
/// [DestinationType]. The [secrets] (secret keys) are write-only: stored
/// encrypted apart and never in [toJson], which is what the API returns and
/// the database keeps.
abstract class DestinationSettings implements Validatable {
  /// The settings of [type] in [json], or null for a type without them yet.
  static DestinationSettings? fromJson(
    DestinationType type,
    Map<String, dynamic> json,
  ) => switch (type) {
    DestinationType.s3 => S3Settings.fromJson(json),
    _ => null,
  };

  Map<String, Object?> toJson();

  /// The write-only values it carries, by name (`secret_access_key`).
  Map<String, String> get secrets;

  /// The names of the write-only values a destination of this type needs.
  List<String> get requiredSecrets;
}
