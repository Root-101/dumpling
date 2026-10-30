import 'package:service/dumpling.dart';

/// Body to create a destination, replace it or test a connection. On a
/// replace a missing secret keeps the stored one, and [folders] replaces the
/// folders (none: the bucket root is the only connection point).
class DestinationRequest implements Validatable {
  static const int maxNameLength = 64;
  static const int maxFolders = 50;
  static const int maxFolderLength = 255;

  /// Lowercase letters, digits, `-`, `.`, `_` and `/` between them.
  static final RegExp folderPattern = RegExp(r'^[a-z0-9._-]+(/[a-z0-9._-]+)*$');

  final String? name;
  final String? type;

  /// Null when it is missing or [type] is unknown or disabled.
  final DestinationSettings? settings;
  final List<String>? folders;

  DestinationRequest({this.name, this.type, this.settings, this.folders});

  factory DestinationRequest.fromJson(Map<String, dynamic> json) {
    final type = json.field<String?>('type');
    final settings = json.field<Map<String, dynamic>?>('settings');
    final destinationType = DestinationType.values.asNameMap()[type];
    return DestinationRequest(
      name: json.field<String?>('name'),
      type: type,
      settings: settings == null || destinationType == null
          ? null
          : DestinationSettings.fromJson(destinationType, settings),
      folders: json.field<List<String>?>('folders'),
    );
  }

  @override
  ConstraintValidatorContext validate() {
    final context = ConstraintValidatorContext()
      ..field('name', name?.trim()).notNull().size(min: 1, max: maxNameLength)
      ..field('type', type)
          .notNull()
          .isEnum(DestinationType.values)
          .custom(
            (value) => destinationType?.enabled ?? true
                ? null
                : intl.errors.validations.destinationTypeDisabled,
          )
      ..field('folders', folders).size(max: maxFolders).custom((value) {
        final paths = cleanFolders;
        if (paths.any((p) => p.length > maxFolderLength || !_isFolder(p))) {
          return intl.errors.validations.folderPath;
        }
        return paths.toSet().length == paths.length
            ? null
            : intl.errors.validations.repeatedFolder;
      });
    // The settings depend on the type: only checked for one that works
    if (destinationType?.enabled ?? false) {
      context.field('settings', settings).notNull().valid();
    }
    return context;
  }

  /// No `.` or `..` segments: they would climb out of the bucket path.
  static bool _isFolder(String path) =>
      folderPattern.hasMatch(path) &&
      path.split('/').every((s) => s != '.' && s != '..');

  DestinationType? get destinationType =>
      DestinationType.values.asNameMap()[type];

  String get trimmedName => name!.trim();

  /// The folders without spaces or slashes around them (`/orders/` → `orders`).
  List<String> get cleanFolders => [
    for (final folder in folders ?? const <String>[])
      folder.trim().replaceAll(RegExp(r'^/+|/+$'), ''),
  ];
}
