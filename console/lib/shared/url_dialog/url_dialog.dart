import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A screen whose dialog follows the URL (`…/sources/{id}`): the id in the URL
/// opens it, closing it goes back to the URL of the screen, and leaving its
/// URL (the browser's back) closes it
mixin UrlDialog<T extends StatefulWidget> on State<T> {
  String? _shown;

  /// [show] opens the dialog of [id] and completes when it closes; false:
  /// there is no [id]. [leave] goes back to the URL of the screen
  void followUrl(
    String? id, {
    required Future<bool> Function(String id) show,
    required VoidCallback leave,
  }) {
    if (id == _shown) return;
    _shown = id;
    // it may come from a build (a new URL): the dialogs change after it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (id == null) {
        Navigator.of(app.context).popUntil((route) => route is! PopupRoute);
      } else {
        _open(id, show, leave);
      }
    });
  }

  void _open(
    String id,
    Future<bool> Function(String id) show,
    VoidCallback leave,
  ) {
    show(id).then((found) {
      if (_shown != id || !mounted) return;
      _shown = null;
      if (!found) {
        app.snack.showError(
          message: app.intl.errors.pageNotFound,
          context: context,
        );
      }
      leave();
    });
  }
}
