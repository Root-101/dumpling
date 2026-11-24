import 'package:console/app_exporter.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// The navigator of a screen of a workspace (`/workspaces/{slug}/{path}`)
/// and, when it has [itemName], of the dialog of one of its items over it
/// (`{path}/{itemPath}/:id`)
abstract class SectionNavigator {
  String get name;

  String get path => name;

  /// The route of the dialog of one item; null: it has none
  String? get itemName => null;

  /// Between [path] and the id of an item (`backups/runs/:id`)
  String? get itemPath => null;

  Widget builder(BuildContext context, GoRouterState state);

  /// [query] keeps the filters of the screen
  void go({required String workspace, Map<String, String> query = const {}}) =>
      app.navigator.go(
        name,
        pathParameters: {RouteNames.slugParam: workspace},
        queryParameters: query,
      );

  /// The dialog of the item [id] over the screen
  void open({
    required String workspace,
    required String id,
    Map<String, String> query = const {},
  }) => app.navigator.go(
    itemName!,
    pathParameters: {RouteNames.slugParam: workspace, RouteNames.idParam: id},
    queryParameters: query,
  );

  /// The screen and its item share one page: an id keeps the screen as it is
  /// and opens its dialog over it
  List<RouteBase> routes() {
    final item = itemName;
    if (item == null) {
      return [GoRoute(name: name, path: path, builder: builder)];
    }
    Page<void> page(BuildContext context, GoRouterState state) =>
        MaterialPage(key: ValueKey(path), child: builder(context, state));
    return [
      GoRoute(name: name, path: path, pageBuilder: page),
      GoRoute(
        name: item,
        path: [path, ?itemPath, ':${RouteNames.idParam}'].join('/'),
        pageBuilder: page,
      ),
    ];
  }
}
