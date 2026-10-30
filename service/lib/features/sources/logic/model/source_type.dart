/// The kinds of source. Only the enabled ones can be created; the others are
/// listed so the console shows them as coming soon.
enum SourceType {
  postgres(enabled: true),
  mysql,
  mariadb,
  mongodb,
  redis;

  final bool enabled;

  const SourceType({this.enabled = false});

  Map<String, Object?> toJson() => {'type': name, 'enabled': enabled};
}
