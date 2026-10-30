import 'package:service/dumpling.dart';

/// The connection data of a source, one implementation per [SourceType]. The
/// [secrets] (passwords) are write-only: they are stored encrypted apart and
/// never in [toJson], which is what the API returns and the database keeps.
abstract class SourceSettings implements Validatable {
  /// The settings of [type] in [json], or null for a type without them yet.
  static SourceSettings? fromJson(SourceType type, Map<String, dynamic> json) =>
      switch (type) {
        SourceType.postgres => PostgresSettings.fromJson(json),
        _ => null,
      };

  Map<String, Object?> toJson();

  /// The write-only values it carries, by name (`password`).
  Map<String, String> get secrets;

  /// The names of the write-only values a source of this type needs.
  List<String> get requiredSecrets;
}
