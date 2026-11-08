import 'package:console/app_exporter.dart';
import 'package:material_ui/material_ui.dart';

/// A screen whose dialog follows the URL (`…/sources/{id}`): the id in the URL
/// opens it, closing it goes back to the URL of the screen, and leaving its
/// URL (the browser's back, or the address bar to another screen) closes it
mixin UrlDialog<T extends StatefulWidget> on State<T> {
  String? _shown;

  /// The URL of the screen while its dialog is open (`…/sources`)
  String? _screen;

  String get _path =>
      RouteConfig.router.routerDelegate.currentConfiguration.uri.path;

  @override
  void initState() {
    super.initState();
    RouteConfig.router.routerDelegate.addListener(_onRoute);
  }

  @override
  void dispose() {
    RouteConfig.router.routerDelegate.removeListener(_onRoute);
    _onRoute();
    super.dispose();
  }

  /// The screens of the shell stay mounted: one whose URL is no longer the
  /// current one closes its dialog instead of leaving it over the next screen
  void _onRoute() {
    final screen = _screen;
    if (_shown == null || screen == null) return;
    if (mounted && _path.startsWith(screen)) return;
    _shown = null;
    _screen = null;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) =>
          Navigator.of(app.context).popUntil((route) => route is! PopupRoute),
    );
  }

  /// [show] opens the dialog of [id] and completes when it closes; false:
  /// there is no [id]. [leave] goes back to the URL of the screen
  void followUrl(
    String? id, {
    required Future<bool> Function(String id) show,
    required VoidCallback leave,
  }) {
    if (id == _shown) return;
    _shown = id;
    final path = _path;
    _screen = id == null || !path.endsWith('/$id')
        ? null
        : path.substring(0, path.length - id.length - 1);
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
      _screen = null;
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
