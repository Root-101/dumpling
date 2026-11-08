import 'package:service/dumpling.dart';

/// Body to create an API key or change it: its name, what it may do and,
/// optionally, the only configs it reaches. The secret never changes.
class ApiKeyRequest implements Validatable {
  static const int maxNameLength = 64;

  final String? name;
  final List<Object?>? permissions;

  /// Missing or empty: every config of the workspace.
  final List<Object?>? configIds;

  ApiKeyRequest({this.name, this.permissions, this.configIds});

  factory ApiKeyRequest.fromJson(Map<String, dynamic> json) => ApiKeyRequest(
    name: json.field<String?>('name'),
    permissions: json.field<List<Object?>?>('permissions'),
    configIds: json.field<List<Object?>?>('config_ids'),
  );

  @override
  ConstraintValidatorContext validate() => ConstraintValidatorContext()
    ..field('name', name?.trim()).notNull().size(min: 1, max: maxNameLength)
    ..field('permissions', permissions)
        .notNull()
        .size(min: 1)
        .custom(
          (list) => list!.every(Permissions.grantable.contains)
              ? null
              : intl.errors.validations.permission,
        )
    ..field('config_ids', configIds).custom(
      (list) => (list ?? const []).every((id) => id is String)
          ? null
          : intl.errors.validations.unknownConfig,
    )
    ..field('config_ids', configIds).custom(
      (list) =>
          (list ?? const []).isEmpty ||
              (permissions ?? const []).any(Permissions.limitable.contains)
          ? null
          : intl.errors.validations.limitWithout,
    )
    ..field('permissions', permissions).custom(
      (list) =>
          (configIds ?? const []).isEmpty ||
              !(list ?? const []).any(Permissions.notLimitable.contains)
          ? null
          : intl.errors.validations.notLimitable,
    );

  String get trimmedName => name!.trim();

  /// Each once, in the order of [Permissions.grantable].
  List<String> get cleanPermissions => [
    for (final p in Permissions.grantable)
      if (permissions!.contains(p)) p,
  ];

  List<String> get cleanConfigIds => {...?configIds?.cast<String>()}.toList();
}

/// Body of Run now: an optional [label] that names what asked for it (a
/// version, a commit), shown in the run log.
class RunNowRequest implements Validatable {
  static const int maxLabelLength = 64;
  static final RegExp _label = RegExp(r'^[A-Za-z0-9._-]+$');

  final String? label;

  RunNowRequest({this.label});

  factory RunNowRequest.fromJson(Map<String, dynamic> json) =>
      RunNowRequest(label: json.field<String?>('label'));

  @override
  ConstraintValidatorContext validate() =>
      ConstraintValidatorContext()
        ..field('label', label).custom(
          (value) =>
              value == null ||
                  (value.length <= maxLabelLength && _label.hasMatch(value))
              ? null
              : intl.errors.validations.label(max: maxLabelLength),
        );
}
