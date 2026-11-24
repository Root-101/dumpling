import 'package:service/dumpling.dart';

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
          code: 'validations.label',
        );
}
