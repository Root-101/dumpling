/// The kinds of destination. Only the enabled ones can be created; the others
/// are listed so the console shows them as coming soon.
enum DestinationType {
  s3(enabled: true),
  gdrive,
  azure,
  dropbox,
  sftp;

  final bool enabled;

  const DestinationType({this.enabled = false});

  Map<String, Object?> toJson() => {'type': name, 'enabled': enabled};
}
