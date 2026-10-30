import 'package:drift/drift.dart' show Value;
import 'package:service/dumpling.dart';

/// Body to create a config or replace it. A missing schedule, compression or
/// object key takes the default of the workspace; a missing `folder` is the
/// root of the destination.
class ConfigRequest implements Validatable {
  static const int maxNameLength = 64;

  final String? name;
  final String? sourceId;
  final String? destinationId;
  final String? folder;
  final String? schedule;
  final String? compression;
  final String? objectKey;
  final bool? enabled;

  ConfigRequest({
    this.name,
    this.sourceId,
    this.destinationId,
    this.folder,
    this.schedule,
    this.compression,
    this.objectKey,
    this.enabled,
  });

  factory ConfigRequest.fromJson(Map<String, dynamic> json) => ConfigRequest(
    name: json.field<String?>('name'),
    sourceId: json.field<String?>('source_id'),
    destinationId: json.field<String?>('destination_id'),
    folder: json.field<String?>('folder'),
    schedule: json.field<String?>('schedule'),
    compression: json.field<String?>('compression'),
    objectKey: json.field<String?>('object_key'),
    enabled: json.field<bool?>('enabled'),
  );

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field('name', name?.trim()).notNull().size(min: 1, max: maxNameLength)
    ..field('source_id', sourceId).notNull()
    ..field('destination_id', destinationId).notNull()
    ..field('schedule', schedule).cron()
    ..field('compression', compression).isEnum(Compression.values)
    ..field('object_key', objectKey).objectKey();

  String get trimmedName => name!.trim();

  /// What it stores once its source, destination and folder are known; a
  /// missing schedule, compression or object key takes the [defaults].
  ConfigTableCompanion values(
    WorkspaceDefaults defaults, {
    required String sourceId,
    required String destinationId,
    required String? folder,
  }) => ConfigTableCompanion(
    name: Value(trimmedName),
    sourceId: Value(sourceId),
    destinationId: Value(destinationId),
    folder: Value(folder),
    schedule: Value(schedule?.trim() ?? defaults.schedule),
    compression: Value(
      compression == null
          ? defaults.compression
          : Compression.values.byName(compression!),
    ),
    objectKey: Value(objectKey ?? defaults.objectKey),
    enabled: Value(enabled ?? true),
  );

  /// Why [folder] can't be where it writes in a destination with [folders]:
  /// one of them, or the root when it has none.
  static String? folderError(String? folder, List<String> folders) =>
      folders.isEmpty
      ? (folder == null ? null : intl.errors.validations.folderOnRoot)
      : (folders.contains(folder)
            ? null
            : intl.errors.validations.unknownFolder);

  /// The folder without slashes around it; null (the root) when empty.
  String? get cleanFolder {
    final value = folder?.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    return value == null || value.isEmpty ? null : value;
  }
}
