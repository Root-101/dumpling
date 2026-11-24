/// What the form sends: the secret never changes
class ApiKeyFormModel {
  final String name;
  final List<String> permissions;
  final List<String> configIds;

  const ApiKeyFormModel({
    required this.name,
    required this.permissions,
    required this.configIds,
  });
}
