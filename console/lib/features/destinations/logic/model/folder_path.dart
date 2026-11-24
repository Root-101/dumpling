import 'package:console/app_exporter.dart';

/// The rules of the service for a folder path, to tell before sending it
abstract class FolderPath {
  static final RegExp _pattern = RegExp(r'^[a-z0-9._-]+(/[a-z0-9._-]+)*$');

  /// `/orders/` → `orders`
  static String clean(String path) =>
      path.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  static bool isValid(String path) =>
      path.length <= 255 &&
      _pattern.hasMatch(path) &&
      path.split('/').every((s) => s != '.' && s != '..');

  /// How it shows: `/orders`
  static String show(String path) => '/$path';

  /// Why [path] (already [clean]) can't be added next to [folders]
  static String? error(String path, List<String> folders) => path.isEmpty
      ? app.intl.destinations.folderEmpty
      : !isValid(path)
      ? app.intl.destinations.folderInvalid
      : folders.contains(path)
      ? app.intl.destinations.folderRepeated
      : null;
}
