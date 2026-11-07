import 'package:service/dumpling.dart';

/// Body to reorder the sources, destinations or configs of a workspace: every
/// id of them, each once, in the new order.
class OrderRequest implements Validatable {
  final List<Object?>? ids;

  OrderRequest({this.ids});

  factory OrderRequest.fromJson(Map<String, dynamic> json) =>
      OrderRequest(ids: json.field<List<Object?>?>('ids'));

  @override
  ConstraintValidatorContext validate() =>
      ConstraintValidatorContext()..field('ids', ids).notNull();

  /// The ids, once checked they are exactly [saved] in some order: a 422
  /// otherwise (a partial order would leave the rest in no defined place).
  List<String> idsOf(Iterable<String> saved) {
    final expected = saved.toSet();
    final valid =
        ids!.length == expected.length && ids!.toSet().containsAll(expected);
    (ConstraintValidatorContext()
          ..field(
            'ids',
            ids,
          ).custom((_) => valid ? null : intl.errors.validations.order))
        .throwOnFailure();
    return ids!.cast<String>();
  }
}
