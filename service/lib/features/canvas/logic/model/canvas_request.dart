import 'package:service/dumpling.dart';

/// Where a node sits on the canvas, in world coordinates.
class CanvasPosition {
  /// Far enough for any canvas, small enough to keep the numbers sane.
  static const int maxCoordinate = 100000;

  final double x;
  final double y;

  const CanvasPosition(this.x, this.y);

  factory CanvasPosition.fromJson(Map<String, dynamic> json) => CanvasPosition(
    json.field<num>('x').toDouble(),
    json.field<num>('y').toDouble(),
  );

  bool get inRange => x.abs() <= maxCoordinate && y.abs() <= maxCoordinate;

  Map<String, Object?> toJson() => {'x': x, 'y': y};
}

/// A node of the canvas: the [request] of a source, destination or config,
/// with its [id] and where it sits. The [id] is a saved one of the workspace,
/// or one the console makes up (`new_…`) so the configs can point at a node
/// that is not saved yet.
class CanvasNode<T> {
  static const String newPrefix = 'new_';

  final String id;

  /// Null: off the canvas (a source or destination waits in the toolbar).
  final CanvasPosition? position;
  final T request;

  CanvasNode(this.id, this.position, this.request);

  factory CanvasNode.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJson,
  ) => CanvasNode(
    json.field<String>('id'),
    json['position'] == null
        ? null
        : json.object('position', CanvasPosition.fromJson),
    fromJson(json),
  );

  bool get isNew => id.startsWith(newPrefix);
}

/// The whole canvas of a workspace, as the console edits it: what it leaves
/// out is deleted, what has a saved id is replaced and what has a `new_` id
/// is created. Saved in one transaction.
class CanvasRequest implements Validatable {
  static const int maxNodes = 500;

  final List<CanvasNode<SourceRequest>> sources;
  final List<CanvasNode<DestinationRequest>> destinations;
  final List<CanvasNode<ConfigRequest>> configs;

  CanvasRequest({
    required this.sources,
    required this.destinations,
    required this.configs,
  });

  factory CanvasRequest.fromJson(Map<String, dynamic> json) {
    List<CanvasNode<T>> nodes<T>(
      String name,
      T Function(Map<String, dynamic> json) fromJson,
    ) => [
      for (final (i, node) in json.field<List<Object?>>(name).indexed)
        if (node is Map<String, dynamic>)
          CanvasNode.fromJson(node, fromJson)
        else
          throw DeserializationException(
            'expected an object',
            path: '\$.$name[$i]',
          ),
    ];
    return CanvasRequest(
      sources: nodes('sources', SourceRequest.fromJson),
      destinations: nodes('destinations', DestinationRequest.fromJson),
      configs: nodes('configs', ConfigRequest.fromJson),
    );
  }

  @override
  ConstraintValidatorContext validate() {
    final context = ConstraintValidatorContext();
    final ids = <String>{};
    void check(String name, List<CanvasNode<Validatable>> nodes) {
      context.field(name, nodes).size(max: maxNodes);
      for (final (i, node) in nodes.indexed) {
        context
          ..merge(node.request.validate(), prefix: '$name[$i]')
          ..field('$name[$i].id', node.id).custom(
            (id) => ids.add(id) ? null : intl.errors.validations.repeatedNode,
          )
          ..field('$name[$i].position', node.position).custom(
            (p) => p == null || p.inRange
                ? null
                : intl.errors.validations.canvasPosition(
                    max: CanvasPosition.maxCoordinate,
                  ),
          );
      }
    }

    check('sources', sources);
    check('destinations', destinations);
    check('configs', configs);
    return context;
  }
}
