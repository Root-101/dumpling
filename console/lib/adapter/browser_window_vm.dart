import 'dart:typed_data';

/// A file the user chose or dropped
typedef PickedFile = ({String name, Uint8List bytes});

/// Outside the browser there is no window: nothing is opened or guarded
class BrowserWindow {
  static void openBytes(List<int> bytes, {String? contentType}) {}

  static void openUrl(String url) {}

  static void download(
    List<int> bytes,
    String fileName, {
    String? contentType,
  }) {}

  static Future<PickedFile?> pickFile({String? accept}) async => null;

  static void Function() listenFileDrop({
    required void Function(PickedFile file) onFile,
    required void Function(bool over) onOver,
  }) => () {};

  static void guardLeave(bool on) {}
}
