///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'messages.g.dart';

// Path: <root>
typedef AppMessagesEn = AppMessages; // ignore: unused_element

class AppMessages with BaseTranslations<AppMessagesLocale, AppMessages> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppMessagesLocale.build] is preferred.
  AppMessages({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<AppMessagesLocale, AppMessages>? meta,
  }) : assert(
         overrides == null,
         'Set "translation_overrides: true" in order to enable this feature.',
       ),
       _meta =
           meta ??
           TranslationMetadata(
             locale: AppMessagesLocale.en,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  final TranslationMetadata<AppMessagesLocale, AppMessages> _meta;
  @override
  TranslationMetadata<AppMessagesLocale, AppMessages> get $meta => _meta;

  /// Access flat map
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final AppMessages _root = this; // ignore: unused_field

  AppMessages $copyWith({
    TranslationMetadata<AppMessagesLocale, AppMessages>? meta,
  }) => AppMessages(meta: meta ?? this.$meta);

  // Translations
  late final AppMessages$app$en app = AppMessages$app$en._(_root);
  late final AppMessages$common$en common = AppMessages$common$en._(_root);
  late final AppMessages$time$en time = AppMessages$time$en._(_root);
  late final AppMessages$errors$en errors = AppMessages$errors$en._(_root);
  late final AppMessages$nav$en nav = AppMessages$nav$en._(_root);
  late final AppMessages$login$en login = AppMessages$login$en._(_root);
  late final AppMessages$colors$en colors = AppMessages$colors$en._(_root);
  late final AppMessages$workspaces$en workspaces = AppMessages$workspaces$en._(
    _root,
  );
  late final AppMessages$connections$en connections =
      AppMessages$connections$en._(_root);
  late final AppMessages$sources$en sources = AppMessages$sources$en._(_root);
  late final AppMessages$destinations$en destinations =
      AppMessages$destinations$en._(_root);
  late final AppMessages$canvas$en canvas = AppMessages$canvas$en._(_root);
}

// Path: app
class AppMessages$app$en {
  AppMessages$app$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Dumpling'
  String get name => 'Dumpling';

  /// en: 'Need more space'
  String get needMoreSpace => 'Need more space';

  /// en: 'Loading your backups…'
  String get splashText => 'Loading your backups…';

  /// en: 'Dumpling v{version: String}'
  String version({required String version}) => 'Dumpling v${version}';
}

// Path: common
class AppMessages$common$en {
  AppMessages$common$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Loading'
  String get loading => 'Loading';

  /// en: 'Error'
  String get error => 'Error';

  /// en: 'Try again'
  String get tryAgain => 'Try again';

  /// en: 'No data'
  String get noData => 'No data';

  /// en: 'Cancel'
  String get cancel => 'Cancel';

  /// en: 'Close'
  String get close => 'Close';

  /// en: 'Required'
  String get required => 'Required';

  /// en: '(optional)'
  String get optional => '(optional)';

  /// en: 'Filters'
  String get filters => 'Filters';

  /// en: 'Clear all'
  String get clearAll => 'Clear all';

  /// en: 'Done'
  String get done => 'Done';

  /// en: 'All'
  String get all => 'All';

  /// en: 'Selected'
  String get selected => 'Selected';

  /// en: 'Soon'
  String get soon => 'Soon';

  /// en: 'Edit'
  String get edit => 'Edit';

  /// en: 'Duplicate'
  String get duplicate => 'Duplicate';

  /// en: 'Delete'
  String get delete => 'Delete';

  /// en: 'Add'
  String get add => 'Add';

  /// en: 'Saving…'
  String get saving => 'Saving…';

  /// en: 'Save changes'
  String get saveChanges => 'Save changes';

  /// en: 'Nothing matches your search'
  String get noMatches => 'Nothing matches your search';

  /// en: 'Clear search and filters'
  String get clearSearch => 'Clear search and filters';

  /// en: '{shown: int} of {total: int}'
  String shownOf({required int shown, required int total}) =>
      '${shown} of ${total}';

  /// en: 'Options for {name: String}'
  String optionsFor({required String name}) => 'Options for ${name}';
}

// Path: time
class AppMessages$time$en {
  AppMessages$time$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: '{time: String} UTC'
  String utc({required String time}) => '${time} UTC';

  /// en: '{time: String} local'
  String local({required String time}) => '${time} local';
}

// Path: errors
class AppMessages$errors$en {
  AppMessages$errors$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Request to API server was cancelled'
  String get requestCancelled => 'Request to API server was cancelled';

  /// en: 'Connection timeout with API server. Check your internet connection'
  String get connectionTimeout =>
      'Connection timeout with API server. Check your internet connection';

  /// en: 'Connection to API server failed due to internet connection'
  String get noConnection =>
      'Connection to API server failed due to internet connection';

  /// en: 'Receive timeout in connection with API server'
  String get receiveTimeout => 'Receive timeout in connection with API server';

  /// en: 'Send timeout with API server'
  String get sendTimeout => 'Send timeout with API server';

  /// en: 'Bad certificate'
  String get badCertificate => 'Bad certificate';

  /// en: 'Connection error'
  String get connection => 'Connection error';

  /// en: 'Validation error'
  String get validation => 'Validation error';

  /// en: 'Server error'
  String get server => 'Server error';

  /// en: 'Unknown error'
  String get unknown => 'Unknown error';
}

// Path: nav
class AppMessages$nav$en {
  AppMessages$nav$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: '{name: String} · switch workspace'
  String switchWorkspace({required String name}) =>
      '${name} · switch workspace';

  /// en: 'Workspaces'
  String get workspaces => 'Workspaces';

  /// en: 'Backups'
  String get backups => 'Backups';

  /// en: 'Pipeline editor'
  String get canvas => 'Pipeline editor';

  /// en: 'Sources'
  String get sources => 'Sources';

  /// en: 'Destinations'
  String get destinations => 'Destinations';

  /// en: 'Run log'
  String get runs => 'Run log';

  /// en: '{count: int} failing'
  String failedRuns({required int count}) => '${count} failing';

  /// en: 'Workspace settings'
  String get settings => 'Workspace settings';

  /// en: 'Language: {name: String}'
  String language({required String name}) => 'Language: ${name}';

  /// en: 'Sign out'
  String get logout => 'Sign out';

  /// en: 'This screen comes next.'
  String get comingSoon => 'This screen comes next.';
}

// Path: login
class AppMessages$login$en {
  AppMessages$login$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Sign in'
  String get title => 'Sign in';

  /// en: 'Manage your database backups.'
  String get description => 'Manage your database backups.';

  /// en: 'Username'
  String get username => 'Username';

  /// en: 'admin'
  String get usernameHint => 'admin';

  /// en: 'Password'
  String get password => 'Password';

  /// en: 'Enter your password'
  String get passwordHint => 'Enter your password';

  /// en: 'Show password'
  String get showPassword => 'Show password';

  /// en: 'Hide password'
  String get hidePassword => 'Hide password';

  /// en: 'Sign in'
  String get button => 'Sign in';

  /// en: 'Signing in…'
  String get signingIn => 'Signing in…';

  /// en: 'Check both and try again.'
  String get failedHint => 'Check both and try again.';

  /// en: 'The username and password are set on the server with'
  String get envHint => 'The username and password are set on the server with';

  /// en: 'and'
  String get envHintAnd => 'and';
}

// Path: colors
class AppMessages$colors$en {
  AppMessages$colors$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'No color'
  String get none => 'No color';

  /// en: 'Custom color'
  String get custom => 'Custom color';

  /// en: 'Apply'
  String get apply => 'Apply';

  /// en: 'Saturation and brightness'
  String get saturationBrightness => 'Saturation and brightness';

  /// en: 'Hue'
  String get hue => 'Hue';

  /// en: 'White initial on this color: {ratio: String}:1'
  String contrast({required String ratio}) =>
      'White initial on this color: ${ratio}:1';

  /// en: 'Low contrast with the white initial ({ratio: String}:1). It will be hard to read.'
  String contrastLow({required String ratio}) =>
      'Low contrast with the white initial (${ratio}:1). It will be hard to read.';

  /// en: 'Enter a 6-digit HEX color, for example #0E7490'
  String get hexInvalid => 'Enter a 6-digit HEX color, for example #0E7490';

  /// en: 'Violet'
  String get violet => 'Violet';

  /// en: 'Blue'
  String get blue => 'Blue';

  /// en: 'Teal'
  String get teal => 'Teal';

  /// en: 'Green'
  String get green => 'Green';

  /// en: 'Amber'
  String get amber => 'Amber';

  /// en: 'Red'
  String get red => 'Red';

  /// en: 'Pink'
  String get pink => 'Pink';

  /// en: 'Slate'
  String get slate => 'Slate';
}

// Path: workspaces
class AppMessages$workspaces$en {
  AppMessages$workspaces$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Workspaces'
  String get title => 'Workspaces';

  /// en: 'Each workspace is separate: its own canvas, sources, destinations and backups.'
  String get description =>
      'Each workspace is separate: its own canvas, sources, destinations and backups.';

  /// en: 'New workspace'
  String get create => 'New workspace';

  /// en: 'A fresh canvas for another environment, client or project.'
  String get createHint =>
      'A fresh canvas for another environment, client or project.';

  /// en: 'Current'
  String get current => 'Current';

  /// en: 'Sources'
  String get sources => 'Sources';

  /// en: 'Destinations'
  String get destinations => 'Destinations';

  /// en: 'Backups'
  String get backups => 'Backups';

  /// en: 'No backups yet'
  String get noBackups => 'No backups yet';

  /// en: 'All healthy'
  String get healthy => 'All healthy';

  /// en: '{count: int} failing'
  String failing({required int count}) => '${count} failing';

  /// en: 'Running now'
  String get running => 'Running now';

  /// en: 'Last run {time: String}'
  String lastRun({required String time}) => 'Last run ${time}';

  /// en: 'No runs yet'
  String get noRuns => 'No runs yet';

  /// en: 'Open canvas'
  String get openCanvas => 'Open canvas';

  /// en: 'Switch & open canvas'
  String get switchAndOpen => 'Switch & open canvas';

  /// en: 'More options for {name: String}'
  String moreOptions({required String name}) => 'More options for ${name}';

  /// en: 'New workspace'
  String get formTitle => 'New workspace';

  /// en: 'Nothing is shared between workspaces: each one has its own canvas, connections, backups and run history.'
  String get formDescription =>
      'Nothing is shared between workspaces: each one has its own canvas, connections, backups and run history.';

  /// en: 'Name'
  String get name => 'Name';

  /// en: 'e.g. Staging'
  String get nameHint => 'e.g. Staging';

  /// en: 'Description'
  String get descriptionLabel => 'Description';

  /// en: 'What this workspace is for'
  String get descriptionHint => 'What this workspace is for';

  /// en: 'Color'
  String get color => 'Color';

  /// en: 'A new workspace starts with an empty canvas.'
  String get emptyCanvas => 'A new workspace starts with an empty canvas.';

  /// en: 'Create workspace'
  String get createButton => 'Create workspace';

  /// en: 'Creating…'
  String get creating => 'Creating…';

  /// en: 'Workspace {name: String} created'
  String created({required String name}) => 'Workspace ${name} created';
}

// Path: connections
class AppMessages$connections$en {
  AppMessages$connections$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Not tested'
  String get notTested => 'Not tested';

  /// en: 'Not tested yet'
  String get notTestedYet => 'Not tested yet';

  /// en: 'Testing…'
  String get testing => 'Testing…';

  /// en: 'Test connection'
  String get test => 'Test connection';

  /// en: 'Connected'
  String get connected => 'Connected';

  /// en: 'Incompatible'
  String get incompatible => 'Incompatible';

  /// en: 'Connected, but the server is newer than the dump tool'
  String get incompatibleTitle =>
      'Connected, but the server is newer than the dump tool';

  /// en: 'Server {server: String} · {tool: String}. Update the dump tool where Dumpling runs.'
  String incompatibleSub({required String server, required String tool}) =>
      'Server ${server} · ${tool}. Update the dump tool where Dumpling runs.';

  /// en: 'Tool missing'
  String get toolMissing => 'Tool missing';

  /// en: 'Connected, but the dump tool is not installed where Dumpling runs'
  String get toolMissingTitle =>
      'Connected, but the dump tool is not installed where Dumpling runs';

  /// en: 'Unreachable'
  String get unreachable => 'Unreachable';

  /// en: 'Couldn't connect'
  String get failedTitle => 'Couldn\'t connect';
}

// Path: sources
class AppMessages$sources$en {
  AppMessages$sources$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Sources'
  String get title => 'Sources';

  /// en: 'What the {workspace: String} workspace backs up: PostgreSQL databases.'
  String description({required String workspace}) =>
      'What the ${workspace} workspace backs up: PostgreSQL databases.';

  /// en: 'New source'
  String get create => 'New source';

  /// en: 'Search sources'
  String get search => 'Search sources';

  /// en: 'Name'
  String get columnName => 'Name';

  /// en: 'Type'
  String get columnType => 'Type';

  /// en: 'Host'
  String get columnHost => 'Host';

  /// en: 'Backups'
  String get columnBackups => 'Backups';

  /// en: 'Status'
  String get columnStatus => 'Status';

  /// en: 'No sources yet'
  String get emptyTitle => 'No sources yet';

  /// en: 'Connect a database to back it up.'
  String get emptyDescription => 'Connect a database to back it up.';

  /// en: '(one) {Used by {n} backup. Remove it first.} (other) {Used by {n} backups. Remove them first.}'
  String inUse({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: 'Used by ${n} backup. Remove it first.',
        other: 'Used by ${n} backups. Remove them first.',
      );

  /// en: 'Delete the source {name: String}?'
  String deleteTitle({required String name}) => 'Delete the source ${name}?';

  /// en: 'It isn't used by any backup. Its saved connection and password are removed from this workspace.'
  String get deleteConfirm =>
      'It isn\'t used by any backup. Its saved connection and password are removed from this workspace.';

  /// en: 'Source {name: String} deleted'
  String deleted({required String name}) => 'Source ${name} deleted';

  /// en: 'New source'
  String get newTitle => 'New source';

  /// en: 'Edit source'
  String get editTitle => 'Edit source';

  /// en: 'Connect what you want to back up.'
  String get formDescription => 'Connect what you want to back up.';

  /// en: '01 Type'
  String get sectionType => '01 Type';

  /// en: '02 Connection'
  String get sectionConnection => '02 Connection';

  /// en: 'Name'
  String get name => 'Name';

  /// en: 'e.g. orders-db'
  String get nameHint => 'e.g. orders-db';

  /// en: '{name: String}-copy'
  String copyName({required String name}) => '${name}-copy';

  /// en: 'Connect with'
  String get connectWith => 'Connect with';

  /// en: 'Fields'
  String get byFields => 'Fields';

  /// en: 'Connection URL'
  String get byUrl => 'Connection URL';

  /// en: 'Host'
  String get host => 'Host';

  /// en: 'Port'
  String get port => 'Port';

  /// en: 'From 1 to 65535'
  String get portInvalid => 'From 1 to 65535';

  /// en: 'Database'
  String get database => 'Database';

  /// en: 'User'
  String get username => 'User';

  /// en: 'Password'
  String get password => 'Password';

  /// en: 'Leave empty to keep the saved one'
  String get passwordKeepHint => 'Leave empty to keep the saved one';

  /// en: 'Use a read-only role. Stored encrypted; never shown again after saving.'
  String get passwordHelp =>
      'Use a read-only role. Stored encrypted; never shown again after saving.';

  /// en: 'Connection URL'
  String get connectionUrl => 'Connection URL';

  /// en: 'The password in the URL is stored encrypted and never shown again.'
  String get urlHelp =>
      'The password in the URL is stored encrypted and never shown again.';

  /// en: 'Without a password in the URL, the saved one is kept.'
  String get urlHelpEditing =>
      'Without a password in the URL, the saved one is kept.';

  /// en: 'Use the format postgresql://user:password@host:5432/database'
  String get urlInvalid =>
      'Use the format postgresql://user:password@host:5432/database';

  /// en: 'Dump format'
  String get dumpFormat => 'Dump format';

  /// en: 'Custom (pg_dump -Fc)'
  String get formatCustom => 'Custom (pg_dump -Fc)';

  /// en: 'Plain SQL'
  String get formatPlain => 'Plain SQL';

  /// en: 'Check the connection before saving the source.'
  String get testIdle => 'Check the connection before saving the source.';

  /// en: 'Connected as {user: String}'
  String connectedAs({required String user}) => 'Connected as ${user}';

  /// en: 'Create source'
  String get createButton => 'Create source';

  /// en: 'Source {name: String} created'
  String created({required String name}) => 'Source ${name} created';

  /// en: 'Source {name: String} saved'
  String saved({required String name}) => 'Source ${name} saved';
}

// Path: destinations
class AppMessages$destinations$en {
  AppMessages$destinations$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Destinations'
  String get title => 'Destinations';

  /// en: 'Where the {workspace: String} workspace writes backups: S3 buckets.'
  String description({required String workspace}) =>
      'Where the ${workspace} workspace writes backups: S3 buckets.';

  /// en: 'New destination'
  String get create => 'New destination';

  /// en: 'Search destinations'
  String get search => 'Search destinations';

  /// en: 'Name'
  String get columnName => 'Name';

  /// en: 'Type'
  String get columnType => 'Type';

  /// en: 'Endpoint'
  String get columnEndpoint => 'Endpoint';

  /// en: 'Backups'
  String get columnBackups => 'Backups';

  /// en: 'Status'
  String get columnStatus => 'Status';

  /// en: 'Bucket root'
  String get bucketRoot => 'Bucket root';

  /// en: '(one) {{n} folder} (other) {{n} folders}'
  String folderCount({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} folder',
        other: '${n} folders',
      );

  /// en: 'Show the folders of {name: String}'
  String showFolders({required String name}) => 'Show the folders of ${name}';

  /// en: 'Hide the folders of {name: String}'
  String hideFolders({required String name}) => 'Hide the folders of ${name}';

  /// en: 'No destinations yet'
  String get emptyTitle => 'No destinations yet';

  /// en: 'Add a bucket to write backups to.'
  String get emptyDescription => 'Add a bucket to write backups to.';

  /// en: '(one) {Used by {n} backup. Remove it first.} (other) {Used by {n} backups. Remove them first.}'
  String inUse({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: 'Used by ${n} backup. Remove it first.',
        other: 'Used by ${n} backups. Remove them first.',
      );

  /// en: 'Delete the destination {name: String}?'
  String deleteTitle({required String name}) =>
      'Delete the destination ${name}?';

  /// en: 'It isn't used by any backup. Its saved connection and keys are removed from this workspace. The files already in the bucket stay there.'
  String get deleteConfirm =>
      'It isn\'t used by any backup. Its saved connection and keys are removed from this workspace. The files already in the bucket stay there.';

  /// en: 'Destination {name: String} deleted'
  String deleted({required String name}) => 'Destination ${name} deleted';

  /// en: 'No folders · the bucket root is the only connection point'
  String get noFolders =>
      'No folders · the bucket root is the only connection point';

  /// en: '(one) {{n} backup} (other) {{n} backups}'
  String folderUsed({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} backup',
        other: '${n} backups',
      );

  /// en: 'Not used yet'
  String get notUsedYet => 'Not used yet';

  /// en: 'Delete folder {path: String}'
  String deleteFolder({required String path}) => 'Delete folder ${path}';

  /// en: 'In use by backups. Reconnect them first.'
  String get folderLocked => 'In use by backups. Reconnect them first.';

  /// en: 'Add folder'
  String get addFolder => 'Add folder';

  /// en: '/folder-name'
  String get folderHint => '/folder-name';

  /// en: 'Enter a folder name'
  String get folderEmpty => 'Enter a folder name';

  /// en: 'Lowercase letters, digits, - . _ and / between them'
  String get folderInvalid =>
      'Lowercase letters, digits, - . _ and / between them';

  /// en: 'That folder already exists'
  String get folderRepeated => 'That folder already exists';

  /// en: 'Folder {path: String} added'
  String folderAdded({required String path}) => 'Folder ${path} added';

  /// en: 'Folder {path: String} deleted'
  String folderDeleted({required String path}) => 'Folder ${path} deleted';

  /// en: 'New destination'
  String get newTitle => 'New destination';

  /// en: 'Edit destination'
  String get editTitle => 'Edit destination';

  /// en: 'Choose where backups are written.'
  String get formDescription => 'Choose where backups are written.';

  /// en: '01 Type'
  String get sectionType => '01 Type';

  /// en: '02 Connection'
  String get sectionConnection => '02 Connection';

  /// en: '03 Folders'
  String get sectionFolders => '03 Folders';

  /// en: 'Name'
  String get name => 'Name';

  /// en: 'e.g. bucket-backups'
  String get nameHint => 'e.g. bucket-backups';

  /// en: '{name: String}-copy'
  String copyName({required String name}) => '${name}-copy';

  /// en: 'Endpoint'
  String get endpoint => 'Endpoint';

  /// en: 'Any S3-compatible URL. For AWS use https://s3.<region>.amazonaws.com.'
  String get endpointHelp =>
      'Any S3-compatible URL. For AWS use https://s3.<region>.amazonaws.com.';

  /// en: 'Bucket'
  String get bucket => 'Bucket';

  /// en: 'Region'
  String get region => 'Region';

  /// en: 'Access key ID'
  String get accessKeyId => 'Access key ID';

  /// en: 'Secret key'
  String get secretKey => 'Secret key';

  /// en: 'Leave empty to keep the saved one'
  String get secretKeepHint => 'Leave empty to keep the saved one';

  /// en: 'Stored encrypted; never shown again after saving.'
  String get secretHelp => 'Stored encrypted; never shown again after saving.';

  /// en: 'Path-style addressing'
  String get pathStyle => 'Path-style addressing';

  /// en: 'Needed by most self-hosted S3 servers.'
  String get pathStyleHelp => 'Needed by most self-hosted S3 servers.';

  /// en: 'Permissions needed: s3:PutObject and s3:AbortMultipartUpload.'
  String get permissions =>
      'Permissions needed: s3:PutObject and s3:AbortMultipartUpload.';

  /// en: 'Folders are optional. With at least one folder, each folder is a connection point on the canvas and the bucket root is not. With no folders, the bucket root is the only connection point.'
  String get foldersHelp =>
      'Folders are optional. With at least one folder, each folder is a connection point on the canvas and the bucket root is not. With no folders, the bucket root is the only connection point.';

  /// en: 'Dumpling starts and aborts a multipart upload in each folder; nothing is left in the bucket.'
  String get testIdle =>
      'Dumpling starts and aborts a multipart upload in each folder; nothing is left in the bucket.';

  /// en: '{bucket: String} · nothing was left in the bucket'
  String connectedSub({required String bucket}) =>
      '${bucket} · nothing was left in the bucket';

  /// en: 'Create destination'
  String get createButton => 'Create destination';

  /// en: 'Destination {name: String} created'
  String created({required String name}) => 'Destination ${name} created';

  /// en: 'Destination {name: String} saved'
  String saved({required String name}) => 'Destination ${name} saved';

  late final AppMessages$destinations$typeSub$en typeSub =
      AppMessages$destinations$typeSub$en._(_root);
}

// Path: canvas
class AppMessages$canvas$en {
  AppMessages$canvas$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Connect the sources and destinations of {workspace: String}. Nothing changes until you save.'
  String description({required String workspace}) =>
      'Connect the sources and destinations of ${workspace}. Nothing changes until you save.';

  /// en: 'Save canvas'
  String get save => 'Save canvas';

  /// en: 'Canvas saved'
  String get saved => 'Canvas saved';

  /// en: 'New config'
  String get newConfig => 'New config';

  /// en: 'Remove from canvas'
  String get removeFromCanvas => 'Remove from canvas';

  /// en: 'Every source is on the canvas'
  String get allSourcesPlaced => 'Every source is on the canvas';

  /// en: 'Every destination is on the canvas'
  String get allDestinationsPlaced => 'Every destination is on the canvas';

  /// en: 'Workspace default'
  String get workspaceDefault => 'Workspace default';

  /// en: 'Never run'
  String get neverRun => 'Never run';

  /// en: 'Disabled'
  String get disabled => 'Disabled';

  /// en: '(one) {{n} incomplete config} (other) {{n} incomplete configs}'
  String orphans({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} incomplete config',
        other: '${n} incomplete configs',
      );

  /// en: 'Only complete flows (source → config → destination) are saved. The configs in amber are discarded on save; sources and destinations stay.'
  String get orphansHelp =>
      'Only complete flows (source → config → destination) are saved. The configs in amber are discarded on save; sources and destinations stay.';

  /// en: 'Canvas. Hold Space and drag to move it; right click for options; arrow keys pan; Ctrl and scroll zooms; F centers; click a connection and press Delete to remove it; Escape closes the config'
  String get semantics =>
      'Canvas. Hold Space and drag to move it; right click for options; arrow keys pan; Ctrl and scroll zooms; F centers; click a connection and press Delete to remove it; Escape closes the config';

  /// en: 'Source'
  String get addSource => 'Source';

  /// en: 'Destination'
  String get addDestination => 'Destination';

  /// en: 'Delete config'
  String get deleteConfig => 'Delete config';

  /// en: 'Remove connection'
  String get removeConnection => 'Remove connection';

  /// en: 'Remove connection (Del)'
  String get removeConnectionKey => 'Remove connection (Del)';

  /// en: 'Config is created here'
  String get configHere => 'Config is created here';

  /// en: 'Release to create the config'
  String get releaseToCreate => 'Release to create the config';

  /// en: 'Drag to a destination'
  String get dragToDestination => 'Drag to a destination';

  /// en: 'Last'
  String get last => 'Last';

  /// en: 'Next'
  String get next => 'Next';

  late final AppMessages$canvas$runStatus$en runStatus =
      AppMessages$canvas$runStatus$en._(_root);
  late final AppMessages$canvas$frequency$en frequency =
      AppMessages$canvas$frequency$en._(_root);

  /// en: '+ Add folder'
  String get addFolder => '+ Add folder';

  /// en: 'Add a folder to {name: String}'
  String addFolderTitle({required String name}) => 'Add a folder to ${name}';

  /// en: 'Each folder is a connection point. It is created in the bucket when the canvas is saved.'
  String get addFolderDescription =>
      'Each folder is a connection point. It is created in the bucket when the canvas is saved.';

  /// en: 'With the first folder the bucket root stops being a connection point: the configs that write to it are disconnected.'
  String get addFolderRoot =>
      'With the first folder the bucket root stops being a connection point: the configs that write to it are disconnected.';

  late final AppMessages$canvas$keys$en keys = AppMessages$canvas$keys$en._(
    _root,
  );
  late final AppMessages$canvas$shortcuts$en shortcuts =
      AppMessages$canvas$shortcuts$en._(_root);
  late final AppMessages$canvas$view$en view = AppMessages$canvas$view$en._(
    _root,
  );
  late final AppMessages$canvas$inspector$en inspector =
      AppMessages$canvas$inspector$en._(_root);
  late final AppMessages$canvas$columns$en columns =
      AppMessages$canvas$columns$en._(_root);
  late final AppMessages$canvas$hints$en hints = AppMessages$canvas$hints$en._(
    _root,
  );

  /// en: 'Folder'
  String get folder => 'Folder';

  late final AppMessages$canvas$testRun$en testRun =
      AppMessages$canvas$testRun$en._(_root);
}

// Path: destinations.typeSub
class AppMessages$destinations$typeSub$en {
  AppMessages$destinations$typeSub$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Any S3-compatible storage'
  String get s3 => 'Any S3-compatible storage';

  /// en: 'Shared drive or folder'
  String get gdrive => 'Shared drive or folder';

  /// en: 'App folder'
  String get dropbox => 'App folder';

  /// en: 'Storage container'
  String get azure => 'Storage container';

  /// en: 'Any SSH server'
  String get sftp => 'Any SSH server';
}

// Path: canvas.runStatus
class AppMessages$canvas$runStatus$en {
  AppMessages$canvas$runStatus$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Success'
  String get success => 'Success';

  /// en: 'Failed'
  String get failed => 'Failed';

  /// en: 'Running'
  String get running => 'Running';
}

// Path: canvas.frequency
class AppMessages$canvas$frequency$en {
  AppMessages$canvas$frequency$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Hourly'
  String get hourly => 'Hourly';

  /// en: 'Daily'
  String get daily => 'Daily';

  /// en: 'Weekly'
  String get weekly => 'Weekly';

  /// en: 'Cron'
  String get cron => 'Cron';
}

// Path: canvas.keys
class AppMessages$canvas$keys$en {
  AppMessages$canvas$keys$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Space'
  String get space => 'Space';

  /// en: 'Del'
  String get del => 'Del';

  /// en: 'Ctrl'
  String get ctrl => 'Ctrl';

  /// en: 'Esc'
  String get esc => 'Esc';
}

// Path: canvas.shortcuts
class AppMessages$canvas$shortcuts$en {
  AppMessages$canvas$shortcuts$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Shortcuts'
  String get title => 'Shortcuts';

  /// en: 'Hide shortcuts'
  String get hide => 'Hide shortcuts';

  /// en: 'Move canvas'
  String get moveCanvas => 'Move canvas';

  /// en: ' + drag'
  String get drag => ' + drag';

  /// en: 'Connect'
  String get connect => 'Connect';

  /// en: 'drag from a port'
  String get dragFromPort => 'drag from a port';

  /// en: 'Options'
  String get options => 'Options';

  /// en: 'right click'
  String get rightClick => 'right click';

  /// en: 'click it + '
  String get clickIt => 'click it + ';

  /// en: 'Zoom'
  String get zoom => 'Zoom';

  /// en: 'scroll'
  String get scroll => 'scroll';

  /// en: 'Zoom in / out'
  String get zoomInOut => 'Zoom in / out';

  /// en: 'Center canvas'
  String get center => 'Center canvas';

  /// en: 'Reset to 100%'
  String get reset => 'Reset to 100%';

  /// en: 'Move with keys'
  String get moveWithKeys => 'Move with keys';

  /// en: 'Close config'
  String get closeConfig => 'Close config';

  /// en: 'Show / hide shortcuts'
  String get toggle => 'Show / hide shortcuts';
}

// Path: canvas.view
class AppMessages$canvas$view$en {
  AppMessages$canvas$view$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Canvas settings'
  String get settings => 'Canvas settings';

  /// en: 'Show or hide shortcuts (?)'
  String get toggleShortcuts => 'Show or hide shortcuts (?)';

  /// en: 'Center'
  String get center => 'Center';

  /// en: 'Center canvas (F)'
  String get centerTooltip => 'Center canvas (F)';

  /// en: 'Zoom out (−)'
  String get zoomOut => 'Zoom out (−)';

  /// en: 'Reset to 100% (0)'
  String get reset => 'Reset to 100% (0)';

  /// en: 'Zoom in (+)'
  String get zoomIn => 'Zoom in (+)';

  /// en: 'Canvas'
  String get settingsTitle => 'Canvas';

  /// en: 'Hold Ctrl to zoom'
  String get ctrlZoom => 'Hold Ctrl to zoom';

  /// en: 'Scroll moves the canvas, Ctrl + scroll zooms'
  String get ctrlZoomOn => 'Scroll moves the canvas, Ctrl + scroll zooms';

  /// en: 'Scroll always zooms'
  String get ctrlZoomOff => 'Scroll always zooms';
}

// Path: canvas.inspector
class AppMessages$canvas$inspector$en {
  AppMessages$canvas$inspector$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Config'
  String get title => 'Config';

  /// en: 'Close (Esc)'
  String get close => 'Close (Esc)';

  /// en: '01 Schedule'
  String get schedule => '01 Schedule';

  /// en: 'Cron'
  String get cron => 'Cron';

  /// en: 'Time zone'
  String get timeZone => 'Time zone';

  /// en: 'Next run'
  String get nextRun => 'Next run';

  /// en: '02 Output'
  String get output => '02 Output';

  /// en: 'Object key'
  String get objectKey => 'Object key';

  /// en: 'Connect a destination to choose where it goes.'
  String get connectDestination =>
      'Connect a destination to choose where it goes.';

  /// en: 'Relative to the folder {folder: String}. The extension is added from the dump format and the compression.'
  String relativeToFolder({required String folder}) =>
      'Relative to the folder ${folder}. The extension is added from the dump format and the compression.';

  /// en: 'Relative to the root of {bucket: String}. The extension is added from the dump format and the compression.'
  String relativeToRoot({required String bucket}) =>
      'Relative to the root of ${bucket}. The extension is added from the dump format and the compression.';

  /// en: 'Compression'
  String get compression => 'Compression';

  /// en: '03 Next run writes'
  String get writes => '03 Next run writes';

  /// en: 'Nothing: connect a source.'
  String get missingSource => 'Nothing: connect a source.';

  /// en: 'Nothing: connect a destination.'
  String get missingDestination => 'Nothing: connect a destination.';

  /// en: 'Nothing: connect a source and a destination.'
  String get missingBoth => 'Nothing: connect a source and a destination.';

  /// en: 'no source'
  String get noSource => 'no source';

  /// en: 'no destination'
  String get noDestination => 'no destination';
}

// Path: canvas.columns
class AppMessages$canvas$columns$en {
  AppMessages$canvas$columns$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Sources'
  String get sources => 'Sources';

  /// en: 'Config · one per connection'
  String get configs => 'Config · one per connection';

  /// en: 'Destinations'
  String get destinations => 'Destinations';
}

// Path: canvas.hints
class AppMessages$canvas$hints$en {
  AppMessages$canvas$hints$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Drag from a source port'
  String get dragFromSource => 'Drag from a source port';

  /// en: 'Drop on a folder or bucket'
  String get dropOnDestination => 'Drop on a folder or bucket';
}

// Path: canvas.testRun
class AppMessages$canvas$testRun$en {
  AppMessages$canvas$testRun$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Test run'
  String get button => 'Test run';

  /// en: 'Checks that every complete flow could run, without backing anything up: each source connects and pg_dump can dump it, each destination takes a write in its folders.'
  String get help =>
      'Checks that every complete flow could run, without backing anything up: each source connects and pg_dump can dump it, each destination takes a write in its folders.';

  /// en: 'Everything works: {n: int} checks passed'
  String ok({required int n}) => 'Everything works: ${n} checks passed';

  /// en: 'Some checks failed: {list: String}'
  String failed({required String list}) => 'Some checks failed: ${list}';

  /// en: 'Nothing to test: connect a source to a destination first.'
  String get nothing =>
      'Nothing to test: connect a source to a destination first.';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on AppMessages {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'app.name' => 'Dumpling',
      'app.needMoreSpace' => 'Need more space',
      'app.splashText' => 'Loading your backups…',
      'app.version' => ({required String version}) => 'Dumpling v${version}',
      'common.loading' => 'Loading',
      'common.error' => 'Error',
      'common.tryAgain' => 'Try again',
      'common.noData' => 'No data',
      'common.cancel' => 'Cancel',
      'common.close' => 'Close',
      'common.required' => 'Required',
      'common.optional' => '(optional)',
      'common.filters' => 'Filters',
      'common.clearAll' => 'Clear all',
      'common.done' => 'Done',
      'common.all' => 'All',
      'common.selected' => 'Selected',
      'common.soon' => 'Soon',
      'common.edit' => 'Edit',
      'common.duplicate' => 'Duplicate',
      'common.delete' => 'Delete',
      'common.add' => 'Add',
      'common.saving' => 'Saving…',
      'common.saveChanges' => 'Save changes',
      'common.noMatches' => 'Nothing matches your search',
      'common.clearSearch' => 'Clear search and filters',
      'common.shownOf' => ({
        required int shown,
        required int total,
      }) => '${shown} of ${total}',
      'common.optionsFor' => ({required String name}) => 'Options for ${name}',
      'time.utc' => ({required String time}) => '${time} UTC',
      'time.local' => ({required String time}) => '${time} local',
      'errors.requestCancelled' => 'Request to API server was cancelled',
      'errors.connectionTimeout' =>
        'Connection timeout with API server. Check your internet connection',
      'errors.noConnection' =>
        'Connection to API server failed due to internet connection',
      'errors.receiveTimeout' =>
        'Receive timeout in connection with API server',
      'errors.sendTimeout' => 'Send timeout with API server',
      'errors.badCertificate' => 'Bad certificate',
      'errors.connection' => 'Connection error',
      'errors.validation' => 'Validation error',
      'errors.server' => 'Server error',
      'errors.unknown' => 'Unknown error',
      'nav.switchWorkspace' => ({
        required String name,
      }) => '${name} · switch workspace',
      'nav.workspaces' => 'Workspaces',
      'nav.backups' => 'Backups',
      'nav.canvas' => 'Pipeline editor',
      'nav.sources' => 'Sources',
      'nav.destinations' => 'Destinations',
      'nav.runs' => 'Run log',
      'nav.failedRuns' => ({required int count}) => '${count} failing',
      'nav.settings' => 'Workspace settings',
      'nav.language' => ({required String name}) => 'Language: ${name}',
      'nav.logout' => 'Sign out',
      'nav.comingSoon' => 'This screen comes next.',
      'login.title' => 'Sign in',
      'login.description' => 'Manage your database backups.',
      'login.username' => 'Username',
      'login.usernameHint' => 'admin',
      'login.password' => 'Password',
      'login.passwordHint' => 'Enter your password',
      'login.showPassword' => 'Show password',
      'login.hidePassword' => 'Hide password',
      'login.button' => 'Sign in',
      'login.signingIn' => 'Signing in…',
      'login.failedHint' => 'Check both and try again.',
      'login.envHint' => 'The username and password are set on the server with',
      'login.envHintAnd' => 'and',
      'colors.none' => 'No color',
      'colors.custom' => 'Custom color',
      'colors.apply' => 'Apply',
      'colors.saturationBrightness' => 'Saturation and brightness',
      'colors.hue' => 'Hue',
      'colors.contrast' => ({
        required String ratio,
      }) => 'White initial on this color: ${ratio}:1',
      'colors.contrastLow' => ({
        required String ratio,
      }) => 'Low contrast with the white initial (${ratio}:1). It will be hard to read.',
      'colors.hexInvalid' => 'Enter a 6-digit HEX color, for example #0E7490',
      'colors.violet' => 'Violet',
      'colors.blue' => 'Blue',
      'colors.teal' => 'Teal',
      'colors.green' => 'Green',
      'colors.amber' => 'Amber',
      'colors.red' => 'Red',
      'colors.pink' => 'Pink',
      'colors.slate' => 'Slate',
      'workspaces.title' => 'Workspaces',
      'workspaces.description' => 'Each workspace is separate: its own canvas, sources, destinations and backups.',
      'workspaces.create' => 'New workspace',
      'workspaces.createHint' =>
        'A fresh canvas for another environment, client or project.',
      'workspaces.current' => 'Current',
      'workspaces.sources' => 'Sources',
      'workspaces.destinations' => 'Destinations',
      'workspaces.backups' => 'Backups',
      'workspaces.noBackups' => 'No backups yet',
      'workspaces.healthy' => 'All healthy',
      'workspaces.failing' => ({required int count}) => '${count} failing',
      'workspaces.running' => 'Running now',
      'workspaces.lastRun' => ({required String time}) => 'Last run ${time}',
      'workspaces.noRuns' => 'No runs yet',
      'workspaces.openCanvas' => 'Open canvas',
      'workspaces.switchAndOpen' => 'Switch & open canvas',
      'workspaces.moreOptions' => ({
        required String name,
      }) => 'More options for ${name}',
      'workspaces.formTitle' => 'New workspace',
      'workspaces.formDescription' => 'Nothing is shared between workspaces: each one has its own canvas, connections, backups and run history.',
      'workspaces.name' => 'Name',
      'workspaces.nameHint' => 'e.g. Staging',
      'workspaces.descriptionLabel' => 'Description',
      'workspaces.descriptionHint' => 'What this workspace is for',
      'workspaces.color' => 'Color',
      'workspaces.emptyCanvas' =>
        'A new workspace starts with an empty canvas.',
      'workspaces.createButton' => 'Create workspace',
      'workspaces.creating' => 'Creating…',
      'workspaces.created' => ({
        required String name,
      }) => 'Workspace ${name} created',
      'connections.notTested' => 'Not tested',
      'connections.notTestedYet' => 'Not tested yet',
      'connections.testing' => 'Testing…',
      'connections.test' => 'Test connection',
      'connections.connected' => 'Connected',
      'connections.incompatible' => 'Incompatible',
      'connections.incompatibleTitle' =>
        'Connected, but the server is newer than the dump tool',
      'connections.incompatibleSub' => ({
        required String server,
        required String tool,
      }) => 'Server ${server} · ${tool}. Update the dump tool where Dumpling runs.',
      'connections.toolMissing' => 'Tool missing',
      'connections.toolMissingTitle' =>
        'Connected, but the dump tool is not installed where Dumpling runs',
      'connections.unreachable' => 'Unreachable',
      'connections.failedTitle' => 'Couldn\'t connect',
      'sources.title' => 'Sources',
      'sources.description' => ({
        required String workspace,
      }) => 'What the ${workspace} workspace backs up: PostgreSQL databases.',
      'sources.create' => 'New source',
      'sources.search' => 'Search sources',
      'sources.columnName' => 'Name',
      'sources.columnType' => 'Type',
      'sources.columnHost' => 'Host',
      'sources.columnBackups' => 'Backups',
      'sources.columnStatus' => 'Status',
      'sources.emptyTitle' => 'No sources yet',
      'sources.emptyDescription' => 'Connect a database to back it up.',
      'sources.inUse' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: 'Used by ${n} backup. Remove it first.',
              other: 'Used by ${n} backups. Remove them first.',
            ),
      'sources.deleteTitle' => ({
        required String name,
      }) => 'Delete the source ${name}?',
      'sources.deleteConfirm' => 'It isn\'t used by any backup. Its saved connection and password are removed from this workspace.',
      'sources.deleted' => ({required String name}) => 'Source ${name} deleted',
      'sources.newTitle' => 'New source',
      'sources.editTitle' => 'Edit source',
      'sources.formDescription' => 'Connect what you want to back up.',
      'sources.sectionType' => '01 Type',
      'sources.sectionConnection' => '02 Connection',
      'sources.name' => 'Name',
      'sources.nameHint' => 'e.g. orders-db',
      'sources.copyName' => ({required String name}) => '${name}-copy',
      'sources.connectWith' => 'Connect with',
      'sources.byFields' => 'Fields',
      'sources.byUrl' => 'Connection URL',
      'sources.host' => 'Host',
      'sources.port' => 'Port',
      'sources.portInvalid' => 'From 1 to 65535',
      'sources.database' => 'Database',
      'sources.username' => 'User',
      'sources.password' => 'Password',
      'sources.passwordKeepHint' => 'Leave empty to keep the saved one',
      'sources.passwordHelp' => 'Use a read-only role. Stored encrypted; never shown again after saving.',
      'sources.connectionUrl' => 'Connection URL',
      'sources.urlHelp' =>
        'The password in the URL is stored encrypted and never shown again.',
      'sources.urlHelpEditing' =>
        'Without a password in the URL, the saved one is kept.',
      'sources.urlInvalid' =>
        'Use the format postgresql://user:password@host:5432/database',
      'sources.dumpFormat' => 'Dump format',
      'sources.formatCustom' => 'Custom (pg_dump -Fc)',
      'sources.formatPlain' => 'Plain SQL',
      'sources.testIdle' => 'Check the connection before saving the source.',
      'sources.connectedAs' => ({
        required String user,
      }) => 'Connected as ${user}',
      'sources.createButton' => 'Create source',
      'sources.created' => ({required String name}) => 'Source ${name} created',
      'sources.saved' => ({required String name}) => 'Source ${name} saved',
      'destinations.title' => 'Destinations',
      'destinations.description' => ({
        required String workspace,
      }) => 'Where the ${workspace} workspace writes backups: S3 buckets.',
      'destinations.create' => 'New destination',
      'destinations.search' => 'Search destinations',
      'destinations.columnName' => 'Name',
      'destinations.columnType' => 'Type',
      'destinations.columnEndpoint' => 'Endpoint',
      'destinations.columnBackups' => 'Backups',
      'destinations.columnStatus' => 'Status',
      'destinations.bucketRoot' => 'Bucket root',
      'destinations.folderCount' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: '${n} folder',
              other: '${n} folders',
            ),
      'destinations.showFolders' => ({
        required String name,
      }) => 'Show the folders of ${name}',
      'destinations.hideFolders' => ({
        required String name,
      }) => 'Hide the folders of ${name}',
      'destinations.emptyTitle' => 'No destinations yet',
      'destinations.emptyDescription' => 'Add a bucket to write backups to.',
      'destinations.inUse' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: 'Used by ${n} backup. Remove it first.',
              other: 'Used by ${n} backups. Remove them first.',
            ),
      'destinations.deleteTitle' => ({
        required String name,
      }) => 'Delete the destination ${name}?',
      'destinations.deleteConfirm' => 'It isn\'t used by any backup. Its saved connection and keys are removed from this workspace. The files already in the bucket stay there.',
      'destinations.deleted' => ({
        required String name,
      }) => 'Destination ${name} deleted',
      'destinations.noFolders' =>
        'No folders · the bucket root is the only connection point',
      'destinations.folderUsed' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: '${n} backup',
              other: '${n} backups',
            ),
      'destinations.notUsedYet' => 'Not used yet',
      'destinations.deleteFolder' => ({
        required String path,
      }) => 'Delete folder ${path}',
      'destinations.folderLocked' => 'In use by backups. Reconnect them first.',
      'destinations.addFolder' => 'Add folder',
      'destinations.folderHint' => '/folder-name',
      'destinations.folderEmpty' => 'Enter a folder name',
      'destinations.folderInvalid' =>
        'Lowercase letters, digits, - . _ and / between them',
      'destinations.folderRepeated' => 'That folder already exists',
      'destinations.folderAdded' => ({
        required String path,
      }) => 'Folder ${path} added',
      'destinations.folderDeleted' => ({
        required String path,
      }) => 'Folder ${path} deleted',
      'destinations.newTitle' => 'New destination',
      'destinations.editTitle' => 'Edit destination',
      'destinations.formDescription' => 'Choose where backups are written.',
      'destinations.sectionType' => '01 Type',
      'destinations.sectionConnection' => '02 Connection',
      'destinations.sectionFolders' => '03 Folders',
      'destinations.name' => 'Name',
      'destinations.nameHint' => 'e.g. bucket-backups',
      'destinations.copyName' => ({required String name}) => '${name}-copy',
      'destinations.endpoint' => 'Endpoint',
      'destinations.endpointHelp' =>
        'Any S3-compatible URL. For AWS use https://s3.<region>.amazonaws.com.',
      'destinations.bucket' => 'Bucket',
      'destinations.region' => 'Region',
      'destinations.accessKeyId' => 'Access key ID',
      'destinations.secretKey' => 'Secret key',
      'destinations.secretKeepHint' => 'Leave empty to keep the saved one',
      'destinations.secretHelp' =>
        'Stored encrypted; never shown again after saving.',
      'destinations.pathStyle' => 'Path-style addressing',
      'destinations.pathStyleHelp' => 'Needed by most self-hosted S3 servers.',
      'destinations.permissions' =>
        'Permissions needed: s3:PutObject and s3:AbortMultipartUpload.',
      'destinations.foldersHelp' => 'Folders are optional. With at least one folder, each folder is a connection point on the canvas and the bucket root is not. With no folders, the bucket root is the only connection point.',
      'destinations.testIdle' => 'Dumpling starts and aborts a multipart upload in each folder; nothing is left in the bucket.',
      'destinations.connectedSub' => ({
        required String bucket,
      }) => '${bucket} · nothing was left in the bucket',
      'destinations.createButton' => 'Create destination',
      'destinations.created' => ({
        required String name,
      }) => 'Destination ${name} created',
      'destinations.saved' => ({
        required String name,
      }) => 'Destination ${name} saved',
      'destinations.typeSub.s3' => 'Any S3-compatible storage',
      'destinations.typeSub.gdrive' => 'Shared drive or folder',
      'destinations.typeSub.dropbox' => 'App folder',
      'destinations.typeSub.azure' => 'Storage container',
      'destinations.typeSub.sftp' => 'Any SSH server',
      'canvas.description' => ({
        required String workspace,
      }) => 'Connect the sources and destinations of ${workspace}. Nothing changes until you save.',
      'canvas.save' => 'Save canvas',
      'canvas.saved' => 'Canvas saved',
      'canvas.newConfig' => 'New config',
      'canvas.removeFromCanvas' => 'Remove from canvas',
      'canvas.allSourcesPlaced' => 'Every source is on the canvas',
      'canvas.allDestinationsPlaced' => 'Every destination is on the canvas',
      'canvas.workspaceDefault' => 'Workspace default',
      'canvas.neverRun' => 'Never run',
      'canvas.disabled' => 'Disabled',
      'canvas.orphans' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
              n,
              one: '${n} incomplete config',
              other: '${n} incomplete configs',
            ),
      'canvas.orphansHelp' => 'Only complete flows (source → config → destination) are saved. The configs in amber are discarded on save; sources and destinations stay.',
      'canvas.semantics' => 'Canvas. Hold Space and drag to move it; right click for options; arrow keys pan; Ctrl and scroll zooms; F centers; click a connection and press Delete to remove it; Escape closes the config',
      'canvas.addSource' => 'Source',
      'canvas.addDestination' => 'Destination',
      'canvas.deleteConfig' => 'Delete config',
      'canvas.removeConnection' => 'Remove connection',
      'canvas.removeConnectionKey' => 'Remove connection (Del)',
      'canvas.configHere' => 'Config is created here',
      'canvas.releaseToCreate' => 'Release to create the config',
      'canvas.dragToDestination' => 'Drag to a destination',
      'canvas.last' => 'Last',
      'canvas.next' => 'Next',
      'canvas.runStatus.success' => 'Success',
      'canvas.runStatus.failed' => 'Failed',
      'canvas.runStatus.running' => 'Running',
      'canvas.frequency.hourly' => 'Hourly',
      'canvas.frequency.daily' => 'Daily',
      'canvas.frequency.weekly' => 'Weekly',
      'canvas.frequency.cron' => 'Cron',
      'canvas.addFolder' => '+ Add folder',
      'canvas.addFolderTitle' => ({
        required String name,
      }) => 'Add a folder to ${name}',
      'canvas.addFolderDescription' => 'Each folder is a connection point. It is created in the bucket when the canvas is saved.',
      'canvas.addFolderRoot' => 'With the first folder the bucket root stops being a connection point: the configs that write to it are disconnected.',
      'canvas.keys.space' => 'Space',
      'canvas.keys.del' => 'Del',
      'canvas.keys.ctrl' => 'Ctrl',
      'canvas.keys.esc' => 'Esc',
      'canvas.shortcuts.title' => 'Shortcuts',
      'canvas.shortcuts.hide' => 'Hide shortcuts',
      'canvas.shortcuts.moveCanvas' => 'Move canvas',
      'canvas.shortcuts.drag' => ' + drag',
      'canvas.shortcuts.connect' => 'Connect',
      'canvas.shortcuts.dragFromPort' => 'drag from a port',
      'canvas.shortcuts.options' => 'Options',
      'canvas.shortcuts.rightClick' => 'right click',
      'canvas.shortcuts.clickIt' => 'click it + ',
      'canvas.shortcuts.zoom' => 'Zoom',
      'canvas.shortcuts.scroll' => 'scroll',
      'canvas.shortcuts.zoomInOut' => 'Zoom in / out',
      'canvas.shortcuts.center' => 'Center canvas',
      'canvas.shortcuts.reset' => 'Reset to 100%',
      'canvas.shortcuts.moveWithKeys' => 'Move with keys',
      'canvas.shortcuts.closeConfig' => 'Close config',
      'canvas.shortcuts.toggle' => 'Show / hide shortcuts',
      'canvas.view.settings' => 'Canvas settings',
      'canvas.view.toggleShortcuts' => 'Show or hide shortcuts (?)',
      'canvas.view.center' => 'Center',
      'canvas.view.centerTooltip' => 'Center canvas (F)',
      'canvas.view.zoomOut' => 'Zoom out (−)',
      'canvas.view.reset' => 'Reset to 100% (0)',
      'canvas.view.zoomIn' => 'Zoom in (+)',
      'canvas.view.settingsTitle' => 'Canvas',
      'canvas.view.ctrlZoom' => 'Hold Ctrl to zoom',
      'canvas.view.ctrlZoomOn' =>
        'Scroll moves the canvas, Ctrl + scroll zooms',
      'canvas.view.ctrlZoomOff' => 'Scroll always zooms',
      'canvas.inspector.title' => 'Config',
      'canvas.inspector.close' => 'Close (Esc)',
      'canvas.inspector.schedule' => '01 Schedule',
      'canvas.inspector.cron' => 'Cron',
      'canvas.inspector.timeZone' => 'Time zone',
      'canvas.inspector.nextRun' => 'Next run',
      'canvas.inspector.output' => '02 Output',
      'canvas.inspector.objectKey' => 'Object key',
      'canvas.inspector.connectDestination' =>
        'Connect a destination to choose where it goes.',
      'canvas.inspector.relativeToFolder' => ({
        required String folder,
      }) => 'Relative to the folder ${folder}. The extension is added from the dump format and the compression.',
      'canvas.inspector.relativeToRoot' => ({
        required String bucket,
      }) => 'Relative to the root of ${bucket}. The extension is added from the dump format and the compression.',
      'canvas.inspector.compression' => 'Compression',
      'canvas.inspector.writes' => '03 Next run writes',
      'canvas.inspector.missingSource' => 'Nothing: connect a source.',
      'canvas.inspector.missingDestination' =>
        'Nothing: connect a destination.',
      'canvas.inspector.missingBoth' =>
        'Nothing: connect a source and a destination.',
      'canvas.inspector.noSource' => 'no source',
      'canvas.inspector.noDestination' => 'no destination',
      'canvas.columns.sources' => 'Sources',
      'canvas.columns.configs' => 'Config · one per connection',
      'canvas.columns.destinations' => 'Destinations',
      'canvas.hints.dragFromSource' => 'Drag from a source port',
      'canvas.hints.dropOnDestination' => 'Drop on a folder or bucket',
      'canvas.folder' => 'Folder',
      'canvas.testRun.button' => 'Test run',
      'canvas.testRun.help' => 'Checks that every complete flow could run, without backing anything up: each source connects and pg_dump can dump it, each destination takes a write in its folders.',
      'canvas.testRun.ok' => ({
        required int n,
      }) => 'Everything works: ${n} checks passed',
      'canvas.testRun.failed' => ({
        required String list,
      }) => 'Some checks failed: ${list}',
      'canvas.testRun.nothing' =>
        'Nothing to test: connect a source to a destination first.',
      _ => null,
    };
  }
}
