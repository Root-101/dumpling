/// The schedule (cron, UTC), the compression (`gzip`, `none`) and the object
/// key a new config of the workspace starts with
typedef WorkspaceDefaults = ({
  String schedule,
  String compression,
  String objectKey,
});
