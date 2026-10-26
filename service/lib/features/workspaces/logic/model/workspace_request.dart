import 'package:service/dumpling.dart';

/// Body to create a workspace or replace its data: a missing `description` or
/// `color` clears it, a missing default takes the one of [WorkspaceDefaults].
class WorkspaceRequest implements Validatable {
  static const int maxNameLength = 64;
  static const int maxDescriptionLength = 256;

  final String? name;
  final String? description;
  final int? color;
  final String? defaultSchedule;
  final String? defaultCompression;
  final String? defaultObjectKey;

  WorkspaceRequest({
    this.name,
    this.description,
    this.color,
    this.defaultSchedule,
    this.defaultCompression,
    this.defaultObjectKey,
  });

  factory WorkspaceRequest.fromJson(Map<String, dynamic> json) {
    final defaults = json.field<Map<String, dynamic>?>('defaults') ?? const {};
    return WorkspaceRequest(
      name: json.field<String?>('name'),
      description: json.field<String?>('description'),
      color: json.field<int?>('color'),
      defaultSchedule: defaults.field<String?>('schedule'),
      defaultCompression: defaults.field<String?>('compression'),
      defaultObjectKey: defaults.field<String?>('object_key'),
    );
  }

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field('name', name?.trim()).notNull().size(min: 1, max: maxNameLength)
    ..field('description', description).size(max: maxDescriptionLength)
    // Unsigned 32-bit ARGB color, as the console sends it (Color.toARGB32)
    ..field('color', color).min(0).max(0xFFFFFFFF)
    ..field('defaults.schedule', defaultSchedule).cron()
    ..field(
      'defaults.compression',
      defaultCompression,
    ).isEnum(Compression.values)
    ..field('defaults.object_key', defaultObjectKey).objectKey();

  String get trimmedName => name!.trim();

  String? get cleanDescription {
    final value = description?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  String get schedule =>
      defaultSchedule?.trim() ?? WorkspaceDefaults.defaultSchedule;

  Compression get compression => defaultCompression == null
      ? WorkspaceDefaults.defaultCompression
      : Compression.values.byName(defaultCompression!);

  String get objectKey =>
      defaultObjectKey ?? WorkspaceDefaults.defaultObjectKey;
}
