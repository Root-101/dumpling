import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// A file the user chose or dropped
typedef PickedFile = ({String name, Uint8List bytes});

/// The browser window: new tabs and the warning before leaving
class BrowserWindow {
  /// Opens [bytes] in a new tab, shown by the browser as [contentType]
  static void openBytes(List<int> bytes, {String? contentType}) {
    final blob = web.Blob(
      [Uint8List.fromList(bytes).toJS].toJS,
      web.BlobPropertyBag(type: contentType ?? 'application/octet-stream'),
    );
    web.window.open(web.URL.createObjectURL(blob), '_blank');
  }

  /// Saves [bytes] as a file called [fileName] (the browser's download)
  static void download(
    List<int> bytes,
    String fileName, {
    String? contentType,
  }) {
    final url = web.URL.createObjectURL(
      web.Blob(
        [Uint8List.fromList(bytes).toJS].toJS,
        web.BlobPropertyBag(type: contentType ?? 'application/octet-stream'),
      ),
    );
    (web.HTMLAnchorElement()
          ..href = url
          ..download = fileName)
        .click();
    web.URL.revokeObjectURL(url);
  }

  /// The file the user chooses (of the [accept] types), or null if none
  static Future<PickedFile?> pickFile({String? accept}) {
    final done = Completer<PickedFile?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept ?? '';
    input.onchange = ((web.Event _) {
      final file = input.files?.item(0);
      done.complete(file == null ? null : _read(file));
    }).toJS;
    input.oncancel = ((web.Event _) => done.complete(null)).toJS;
    input.click();
    return done.future;
  }

  /// While it lasts, a file dropped anywhere on the page goes to [onFile],
  /// and [onOver] says whether one is being dragged over it. Returns the
  /// function that stops it
  static void Function() listenFileDrop({
    required void Function(PickedFile file) onFile,
    required void Function(bool over) onOver,
  }) {
    final over = ((web.DragEvent e) {
      e.preventDefault();
      onOver(true);
    }).toJS;
    final leave = ((web.DragEvent e) => onOver(false)).toJS;
    final drop = ((web.DragEvent e) {
      e.preventDefault();
      onOver(false);
      final file = e.dataTransfer?.files.item(0);
      if (file != null) _read(file).then(onFile);
    }).toJS;
    web.window
      ..addEventListener('dragover', over)
      ..addEventListener('dragleave', leave)
      ..addEventListener('drop', drop);
    return () => web.window
      ..removeEventListener('dragover', over)
      ..removeEventListener('dragleave', leave)
      ..removeEventListener('drop', drop);
  }

  static Future<PickedFile> _read(web.File file) async => (
    name: file.name,
    bytes: (await file.arrayBuffer().toDart).toDart.asUint8List(),
  );

  /// Opens [url] in a new tab
  static void openUrl(String url) => web.window.open(url, '_blank');

  static final JSFunction _beforeUnload = ((web.Event event) {
    event.preventDefault();
  }).toJS;

  /// With [on], the browser asks before closing or reloading the tab
  static void guardLeave(bool on) {
    if (on) {
      web.window.addEventListener('beforeunload', _beforeUnload);
    } else {
      web.window.removeEventListener('beforeunload', _beforeUnload);
    }
  }
}
