/// A permission a key can have, as the form shows it
class ApiKeyPermission {
  /// As the service names it: `config.run`
  final String key;

  /// The action word in its group: *Run*
  final String label;

  /// What it allows, for its tooltip
  final String description;

  const ApiKeyPermission(this.key, this.label, this.description);
}
