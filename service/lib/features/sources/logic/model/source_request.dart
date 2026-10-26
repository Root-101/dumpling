import 'package:service/dumpling.dart';

/// Body to create a source, replace it or test a connection. On a replace a
/// missing secret (the password) keeps the stored one.
class SourceRequest implements Validatable {
  static const int maxNameLength = 64;

  final String? name;
  final String? type;

  /// Null when it is missing or [type] is unknown or disabled.
  final SourceSettings? settings;

  SourceRequest({this.name, this.type, this.settings});

  factory SourceRequest.fromJson(Map<String, dynamic> json) {
    final type = json.field<String?>('type');
    final settings = json.field<Map<String, dynamic>?>('settings');
    final sourceType = SourceType.values.asNameMap()[type];
    return SourceRequest(
      name: json.field<String?>('name'),
      type: type,
      settings: settings == null || sourceType == null
          ? null
          : SourceSettings.fromJson(sourceType, settings),
    );
  }

  @override
  ConstraintValidatorContext validate() {
    final context = ConstraintValidatorContext()
      ..field('name', name?.trim()).notNull().size(min: 1, max: maxNameLength)
      ..field('type', type)
          .notNull()
          .isEnum(SourceType.values)
          .custom(
            (value) => sourceType?.enabled ?? true
                ? null
                : intl.errors.validations.sourceTypeDisabled,
          );
    // The settings depend on the type: only checked for one that works
    if (sourceType?.enabled ?? false) {
      context.field('settings', settings).notNull().valid();
    }
    return context;
  }

  SourceType? get sourceType => SourceType.values.asNameMap()[type];

  String get trimmedName => name!.trim();
}
