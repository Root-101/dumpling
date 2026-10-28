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
  late final AppMessages$runs$en runs = AppMessages$runs$en._(_root);
  late final AppMessages$backups$en backups = AppMessages$backups$en._(_root);
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

  /// en: 'Long names are cut on the canvas: a shorter one reads better.'
  String get longName =>
      'Long names are cut on the canvas: a shorter one reads better.';

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

  /// en: 'View details'
  String get viewDetails => 'View details';

  /// en: 'Refresh'
  String get refresh => 'Refresh';

  /// en: 'List'
  String get listView => 'List';

  /// en: 'Grid'
  String get gridView => 'Grid';

  /// en: 'Back'
  String get back => 'Back';

  /// en: 'Next'
  String get next => 'Next';

  /// en: 'Step {n: int} of {total: int}'
  String stepOf({required int n, required int total}) =>
      'Step ${n} of ${total}';

  /// en: '(one) {{n} backup} (other) {{n} backups}'
  String backupCount({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        one: '${n} backup',
        other: '${n} backups',
      );
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

  /// en: 'Not found'
  String get notFoundTitle => 'Not found';

  /// en: 'This page does not exist.'
  String get pageNotFound => 'This page does not exist.';

  /// en: 'Connection lost'
  String get offlineTitle => 'Connection lost';

  /// en: 'Can't reach the Dumpling service at {url: String}. Check that it is running and try again.'
  String offline({required String url}) =>
      'Can\'t reach the Dumpling service at ${url}. Check that it is running and try again.';
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

  /// en: 'Language: {name: String}'
  String language({required String name}) => 'Language: ${name}';

  /// en: 'Sign out'
  String get logout => 'Sign out';
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

  /// en: 'Enter your username'
  String get usernameHint => 'Enter your username';

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

  /// en: 'Backups made'
  String get tagline => 'Backups made';

  /// en: 'easy'
  String get taglineAccent => 'easy';

  /// en: 'Lightweight'
  String get tagLightweight => 'Lightweight';

  /// en: 'Drag & Drop Canvas'
  String get tagCanvas => 'Drag & Drop Canvas';

  /// en: 'Powered by Winter'
  String get tagWinter => 'Powered by Winter';

  /// en: 'Your session expired'
  String get expiredTitle => 'Your session expired';

  /// en: 'Your session ended after 12 hours. Sign in again to continue where you left off.'
  String get expiredDescription =>
      'Your session ended after 12 hours. Sign in again to continue where you left off.';

  /// en: 'Go to the sign-in page'
  String get toSignInPage => 'Go to the sign-in page';
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

  /// en: 'Settings for {name: String}'
  String settingsOf({required String name}) => 'Settings for ${name}';

  late final AppMessages$workspaces$settings$en settings =
      AppMessages$workspaces$settings$en._(_root);
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

  /// en: 'Last check'
  String get lastCheck => 'Last check';

  /// en: 'Connection check'
  String get checkTitle => 'Connection check';

  /// en: 'Before every run and when you test'
  String get checkNote => 'Before every run and when you test';

  /// en: 'Connection'
  String get connection => 'Connection';

  /// en: 'Edit connection'
  String get editConnection => 'Edit connection';
}

// Path: sources
class AppMessages$sources$en {
  AppMessages$sources$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Sources'
  String get title => 'Sources';

  /// en: 'What this workspace backs up: PostgreSQL databases.'
  String get description =>
      'What this workspace backs up: PostgreSQL databases.';

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

  /// en: 'Type'
  String get stepType => 'Type';

  /// en: 'Connection'
  String get stepConnection => 'Connection';

  /// en: 'Check & save'
  String get stepCheck => 'Check & save';

  /// en: 'What do you want to back up?'
  String get typeTitle => 'What do you want to back up?';

  /// en: 'How should Dumpling connect?'
  String get connectionTitle => 'How should Dumpling connect?';

  /// en: 'Check and save'
  String get checkTitle => 'Check and save';

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

  /// en: 'A {type: String} database this workspace backs up.'
  String detailDescription({required String type}) =>
      'A ${type} database this workspace backs up.';

  /// en: 'Backups'
  String get statBackups => 'Backups';

  /// en: '(zero) {none yet} (one) {in {n} destination} (other) {in {n} destinations}'
  String statDestinations({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('en'))(
        n,
        zero: 'none yet',
        one: 'in ${n} destination',
        other: 'in ${n} destinations',
      );

  /// en: 'Last backup'
  String get statLastBackup => 'Last backup';

  /// en: 'Backups using this source'
  String get sectionUses => 'Backups using this source';

  /// en: 'Open editor'
  String get openEditor => 'Open editor';

  /// en: 'No backup uses it yet. Connect it to a destination in the pipeline editor.'
  String get noUses =>
      'No backup uses it yet. Connect it to a destination in the pipeline editor.';

  /// en: 'Backup'
  String get columnBackup => 'Backup';

  /// en: 'Schedule'
  String get columnSchedule => 'Schedule';

  /// en: 'Last run'
  String get columnLastRun => 'Last run';

  /// en: 'Next run'
  String get columnNextRun => 'Next run';

  /// en: 'cron · UTC'
  String get cronUtc => 'cron · UTC';

  /// en: 'Paused'
  String get paused => 'Paused';

  /// en: 'Not run yet'
  String get neverRun => 'Not run yet';

  /// en: '•••••••• · stored encrypted'
  String get passwordStored => '•••••••• · stored encrypted';
}

// Path: destinations
class AppMessages$destinations$en {
  AppMessages$destinations$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Destinations'
  String get title => 'Destinations';

  /// en: 'Where this workspace writes backups: S3 buckets.'
  String get description => 'Where this workspace writes backups: S3 buckets.';

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

  /// en: 'Type'
  String get stepType => 'Type';

  /// en: 'Connection'
  String get stepConnection => 'Connection';

  /// en: 'Folders & check'
  String get stepFolders => 'Folders & check';

  /// en: 'Where should backups go?'
  String get typeTitle => 'Where should backups go?';

  /// en: 'How should Dumpling connect?'
  String get connectionTitle => 'How should Dumpling connect?';

  /// en: 'Folders and connection check'
  String get foldersTitle => 'Folders and connection check';

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

  /// en: 'A bucket this workspace writes backups to.'
  String get detailDescription => 'A bucket this workspace writes backups to.';

  /// en: 'Backups'
  String get statBackups => 'Backups';

  /// en: 'write here'
  String get statBackupsSub => 'write here';

  /// en: 'Folders'
  String get statFolders => 'Folders';

  /// en: 'connection points'
  String get statFoldersSub => 'connection points';

  /// en: 'Folders'
  String get sectionFolders => 'Folders';

  /// en: 'Folder'
  String get columnFolder => 'Folder';

  /// en: 'Written by'
  String get columnWrittenBy => 'Written by';

  /// en: 'Access key'
  String get accessKey => 'Access key';

  /// en: 'On'
  String get on => 'On';

  /// en: 'Off'
  String get off => 'Off';

  late final AppMessages$destinations$typeSub$en typeSub =
      AppMessages$destinations$typeSub$en._(_root);
}

// Path: canvas
class AppMessages$canvas$en {
  AppMessages$canvas$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Connect sources to destinations to build this workspace's backups.'
  String get description =>
      'Connect sources to destinations to build this workspace\'s backups.';

  /// en: 'Save canvas'
  String get save => 'Save canvas';

  /// en: 'Canvas saved'
  String get saved => 'Canvas saved';

  /// en: 'Discard the changes?'
  String get unsavedTitle => 'Discard the changes?';

  /// en: 'The canvas has changes that are not saved. Leaving discards them.'
  String get unsavedDescription =>
      'The canvas has changes that are not saved. Leaving discards them.';

  /// en: 'Discard'
  String get discard => 'Discard';

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

  /// en: 'Edit config'
  String get editConfig => 'Edit config';

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

  /// en: 'Folder'
  String get folder => 'Folder';

  late final AppMessages$canvas$testRun$en testRun =
      AppMessages$canvas$testRun$en._(_root);
  late final AppMessages$canvas$run$en run = AppMessages$canvas$run$en._(_root);
  late final AppMessages$canvas$guide$en guide = AppMessages$canvas$guide$en._(
    _root,
  );
}

// Path: runs
class AppMessages$runs$en {
  AppMessages$runs$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Run log'
  String get title => 'Run log';

  /// en: 'Every backup run in this workspace, scheduled or manual. Times in UTC, your local time below.'
  String get description =>
      'Every backup run in this workspace, scheduled or manual. Times in UTC, your local time below.';

  /// en: 'Search by backup, source or destination'
  String get search => 'Search by backup, source or destination';

  /// en: 'Status'
  String get columnStatus => 'Status';

  /// en: 'Source'
  String get columnSource => 'Source';

  /// en: 'Destination'
  String get columnDestination => 'Destination';

  /// en: 'Started'
  String get columnStarted => 'Started';

  /// en: 'Duration'
  String get columnDuration => 'Duration';

  /// en: 'Size'
  String get columnSize => 'Size';

  /// en: 'By schedule'
  String get scheduled => 'By schedule';

  /// en: 'Manual'
  String get manual => 'Manual';

  /// en: 'No runs yet'
  String get emptyTitle => 'No runs yet';

  /// en: 'Backups run on their schedule, or with Run now in the pipeline editor.'
  String get emptyDescription =>
      'Backups run on their schedule, or with Run now in the pipeline editor.';

  /// en: 'Only the 200 newest runs are shown.'
  String get newestOnly => 'Only the 200 newest runs are shown.';

  /// en: 'Log (UTC)'
  String get log => 'Log (UTC)';

  /// en: 'Copy log'
  String get copyLog => 'Copy log';

  /// en: 'Log copied'
  String get logCopied => 'Log copied';

  /// en: 'The log is written when the run ends. Refresh to see it.'
  String get logWhenDone =>
      'The log is written when the run ends. Refresh to see it.';

  /// en: 'This run has no log.'
  String get noLog => 'This run has no log.';

  /// en: 'Today · {date: String} (UTC)'
  String today({required String date}) => 'Today · ${date} (UTC)';

  /// en: 'Yesterday · {date: String} (UTC)'
  String yesterday({required String date}) => 'Yesterday · ${date} (UTC)';

  /// en: '{date: String} (UTC)'
  String day({required String date}) => '${date} (UTC)';

  /// en: '{n: int} succeeded'
  String succeeded({required int n}) => '${n} succeeded';

  /// en: '{n: int} failed'
  String failedCount({required int n}) => '${n} failed';

  /// en: '{size: String} in {duration: String}'
  String savedIn({required String size, required String duration}) =>
      '${size} in ${duration}';

  /// en: 'In progress'
  String get inProgress => 'In progress';

  /// en: 'In progress · {size: String} so far'
  String soFar({required String size}) => 'In progress · ${size} so far';

  /// en: 'Trigger'
  String get columnTrigger => 'Trigger';

  /// en: 'View run'
  String get viewRun => 'View run';

  /// en: 'Steps'
  String get steps => 'Steps';

  /// en: 'Connect to {name: String}'
  String stepConnect({required String name}) => 'Connect to ${name}';

  /// en: 'Dump and upload to {name: String}'
  String stepDump({required String name}) => 'Dump and upload to ${name}';

  /// en: 'Skipped'
  String get stepSkipped => 'Skipped';

  /// en: 'Waiting'
  String get stepWaiting => 'Waiting';

  /// en: 'Backup saved'
  String get resultSuccess => 'Backup saved';

  /// en: 'The backup failed'
  String get resultFailed => 'The backup failed';

  /// en: 'Running. Refresh to see how far it got.'
  String get resultRunning => 'Running. Refresh to see how far it got.';
}

// Path: backups
class AppMessages$backups$en {
  AppMessages$backups$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Backups'
  String get title => 'Backups';

  /// en: 'Every backup in this workspace, its last run and the next one.'
  String get description =>
      'Every backup in this workspace, its last run and the next one.';

  /// en: 'Open editor'
  String get openEditor => 'Open editor';

  /// en: 'New backup'
  String get newBackup => 'New backup';

  /// en: 'Healthy'
  String get healthy => 'Healthy';

  /// en: 'last run succeeded'
  String get healthySub => 'last run succeeded';

  /// en: 'Failing'
  String get failing => 'Failing';

  /// en: 'need attention'
  String get failingSub => 'need attention';

  /// en: 'Paused'
  String get paused => 'Paused';

  /// en: 'Next backup'
  String get nextBackup => 'Next backup';

  /// en: 'Next backup in'
  String get nextBackupIn => 'Next backup in';

  /// en: 'Nothing scheduled'
  String get nothingScheduled => 'Nothing scheduled';

  /// en: 'Search backups'
  String get search => 'Search backups';

  /// en: 'Status'
  String get columnStatus => 'Status';

  /// en: 'Source'
  String get columnSource => 'Source';

  /// en: 'Destination'
  String get columnDestination => 'Destination';

  /// en: 'Schedule'
  String get columnSchedule => 'Schedule';

  /// en: 'Last backup'
  String get columnLastRun => 'Last backup';

  /// en: 'Next backup'
  String get columnNextRun => 'Next backup';

  /// en: 'All sources'
  String get allSources => 'All sources';

  /// en: 'All destinations'
  String get allDestinations => 'All destinations';

  /// en: '{shown: int} of {total: int} backups'
  String shown({required int shown, required int total}) =>
      '${shown} of ${total} backups';

  /// en: 'Showing {shown: int} of {total: int} backups'
  String showing({required int shown, required int total}) =>
      'Showing ${shown} of ${total} backups';

  /// en: 'Times in UTC · now {utc: String} ({local: String})'
  String timesNote({required String utc, required String local}) =>
      'Times in UTC · now ${utc} (${local})';

  /// en: 'Sort:'
  String get sort => 'Sort:';

  /// en: 'Sort by'
  String get sortBy => 'Sort by';

  /// en: 'Last backup'
  String get sortLast => 'Last backup';

  /// en: 'Most recent first'
  String get sortLastSub => 'Most recent first';

  /// en: 'Last backup (oldest)'
  String get sortLastOld => 'Last backup (oldest)';

  /// en: 'Oldest first'
  String get sortLastOldSub => 'Oldest first';

  /// en: 'Next backup'
  String get sortNext => 'Next backup';

  /// en: 'Soonest first'
  String get sortNextSub => 'Soonest first';

  /// en: 'Source name'
  String get sortName => 'Source name';

  /// en: 'A to Z'
  String get sortNameSub => 'A to Z';

  /// en: 'in {time: String}'
  String inTime({required String time}) => 'in ${time}';

  /// en: 'Started {time: String} ago'
  String startedAgo({required String time}) => 'Started ${time} ago';

  /// en: 'Run {name: String} now'
  String runNowFor({required String name}) => 'Run ${name} now';

  /// en: 'Show run history'
  String get showRuns => 'Show run history';

  /// en: 'Hide run history'
  String get hideRuns => 'Hide run history';

  /// en: 'More actions for {name: String}'
  String moreFor({required String name}) => 'More actions for ${name}';

  /// en: 'View last run'
  String get viewLastRun => 'View last run';

  /// en: 'Edit config'
  String get editConfig => 'Edit config';

  /// en: 'Delete backup'
  String get deleteBackup => 'Delete backup';

  /// en: 'Recent runs'
  String get recentRuns => 'Recent runs';

  /// en: 'No runs yet'
  String get noRuns => 'No runs yet';

  /// en: 'View log'
  String get viewLog => 'View log';

  /// en: 'View details'
  String get viewDetails => 'View details';

  /// en: 'No file written'
  String get noFile => 'No file written';

  /// en: 'Uploading…'
  String get uploading => 'Uploading…';

  /// en: 'Manual'
  String get manual => 'Manual';

  /// en: 'By schedule'
  String get scheduled => 'By schedule';

  /// en: 'Delete the backup {name: String}?'
  String deleteTitle({required String name}) => 'Delete the backup ${name}?';

  /// en: 'Its schedule stops. Its runs stay in the run log, and the files already in the destination stay there.'
  String get deleteConfirm =>
      'Its schedule stops. Its runs stay in the run log, and the files already in the destination stay there.';

  /// en: 'Backup {name: String} deleted'
  String deleted({required String name}) => 'Backup ${name} deleted';

  /// en: 'Backup {name: String} saved'
  String saved({required String name}) => 'Backup ${name} saved';

  /// en: 'Connect a source to a destination in the pipeline editor to create one.'
  String get emptyDescription =>
      'Connect a source to a destination in the pipeline editor to create one.';
}

// Path: workspaces.settings
class AppMessages$workspaces$settings$en {
  AppMessages$workspaces$settings$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Workspace settings'
  String get title => 'Workspace settings';

  /// en: 'Applies only to this workspace'
  String get description => 'Applies only to this workspace';

  /// en: 'General'
  String get general => 'General';

  /// en: 'Defaults for new configs'
  String get defaults => 'Defaults for new configs';

  /// en: 'Danger zone'
  String get danger => 'Danger zone';

  /// en: 'Created'
  String get created => 'Created';

  /// en: 'Workspace ID'
  String get id => 'Workspace ID';

  /// en: 'Copy workspace ID'
  String get copyId => 'Copy workspace ID';

  /// en: 'Copied'
  String get copied => 'Copied';

  /// en: 'No description'
  String get noDescription => 'No description';

  /// en: 'A new connection on the canvas starts with these values. Each config can change them.'
  String get defaultsHint =>
      'A new connection on the canvas starts with these values. Each config can change them.';

  /// en: 'Schedule'
  String get schedule => 'Schedule';

  /// en: 'Cron'
  String get cron => 'Cron';

  /// en: 'Always in UTC.'
  String get cronHelp => 'Always in UTC.';

  /// en: 'Compression'
  String get compression => 'Compression';

  /// en: 'None'
  String get compressionNone => 'None';

  /// en: 'Object key'
  String get objectKey => 'Object key';

  /// en: 'Relative to the folder each config writes to, without extension.'
  String get objectKeyHelp =>
      'Relative to the folder each config writes to, without extension.';

  /// en: 'You have unsaved changes'
  String get unsaved => 'You have unsaved changes';

  /// en: 'Discard'
  String get discard => 'Discard';

  /// en: 'Saved'
  String get saved => 'Saved';

  /// en: 'Delete this workspace'
  String get deleteTitle => 'Delete this workspace';

  /// en: 'Removes its canvas, sources, destinations, configs and run history. Backup files already in your buckets stay where they are.'
  String get deleteDescription =>
      'Removes its canvas, sources, destinations, configs and run history. Backup files already in your buckets stay where they are.';

  /// en: 'Delete workspace'
  String get deleteButton => 'Delete workspace';

  /// en: 'Delete “{name: String}”?'
  String deleteConfirmTitle({required String name}) => 'Delete “${name}”?';

  /// en: 'This deletes its sources ({sources: int}), destinations ({destinations: int}), configs ({configs: int}) and their run history. Scheduled backups stop right away. It can't be undone.'
  String deleteConfirm({
    required int sources,
    required int destinations,
    required int configs,
  }) =>
      'This deletes its sources (${sources}), destinations (${destinations}), configs (${configs}) and their run history. Scheduled backups stop right away. It can\'t be undone.';

  /// en: 'Type'
  String get typeBefore => 'Type';

  /// en: 'to confirm'
  String get typeAfter => 'to confirm';

  /// en: 'Workspace {name: String} deleted'
  String deleted({required String name}) => 'Workspace ${name} deleted';
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

  /// en: 'Config name'
  String get configName => 'Config name';

  /// en: 'The custom format (pg_dump -Fc) is compressed already: gzip barely makes it smaller.'
  String get doubleCompression =>
      'The custom format (pg_dump -Fc) is compressed already: gzip barely makes it smaller.';

  /// en: 'Shown on the canvas, in Backups and in the run log.'
  String get nameHelp => 'Shown on the canvas, in Backups and in the run log.';

  /// en: 'Frequency'
  String get frequency => 'Frequency';

  /// en: 'Review'
  String get review => 'Review';

  /// en: 'Source'
  String get source => 'Source';

  /// en: 'Destination'
  String get destination => 'Destination';

  /// en: 'Computed when it is saved'
  String get nextRunOnSave => 'Computed when it is saved';

  /// en: 'minute hour day month weekday, in UTC. Hourly, daily and weekly write it for you.'
  String get cronHelp =>
      'minute hour day month weekday, in UTC. Hourly, daily and weekly write it for you.';

  /// en: 'Not a valid cron expression (minute hour day month weekday)'
  String get cronInvalid =>
      'Not a valid cron expression (minute hour day month weekday)';

  /// en: 'Enabled'
  String get enabled => 'Enabled';

  /// en: 'Runs on its schedule'
  String get enabledOn => 'Runs on its schedule';

  /// en: 'Off: it only runs with Run now'
  String get enabledOff => 'Off: it only runs with Run now';

  /// en: 'None'
  String get compressionNone => 'None';

  /// en: 'The object key cannot start with /'
  String get objectKeySlash => 'The object key cannot start with /';

  /// en: 'Leave out the extension: it is added from the dump format and the compression'
  String get objectKeyExtension =>
      'Leave out the extension: it is added from the dump format and the compression';

  /// en: 'The object key cannot have . or .. folders'
  String get objectKeyDots => 'The object key cannot have . or .. folders';

  /// en: 'Name & schedule'
  String get schedule => 'Name & schedule';

  /// en: 'Cron'
  String get cron => 'Cron';

  /// en: 'Time zone'
  String get timeZone => 'Time zone';

  /// en: 'Next run'
  String get nextRun => 'Next run';

  /// en: 'Output'
  String get output => 'Output';

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

  /// en: 'Next run writes'
  String get writes => 'Next run writes';

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

// Path: canvas.run
class AppMessages$canvas$run$en {
  AppMessages$canvas$run$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Run now'
  String get button => 'Run now';

  /// en: 'Runs this backup now, for real, as it is saved: the edits not saved yet are not used.'
  String get help =>
      'Runs this backup now, for real, as it is saved: the edits not saved yet are not used.';

  /// en: 'Save the canvas first: a run uses the saved config.'
  String get needsSave => 'Save the canvas first: a run uses the saved config.';

  /// en: 'Backup {name: String} done: {size: String}'
  String done({required String name, required String size}) =>
      'Backup ${name} done: ${size}';

  /// en: 'Backup {name: String} failed: {error: String}'
  String failed({required String name, required String error}) =>
      'Backup ${name} failed: ${error}';
}

// Path: canvas.guide
class AppMessages$canvas$guide$en {
  AppMessages$canvas$guide$en._(this._root);

  final AppMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Your first backup'
  String get title => 'Your first backup';

  /// en: 'Add a source'
  String get source => 'Add a source';

  /// en: 'The database to back up.'
  String get sourceHelp => 'The database to back up.';

  /// en: 'Add a destination'
  String get destination => 'Add a destination';

  /// en: 'The bucket the backups go to.'
  String get destinationHelp => 'The bucket the backups go to.';

  /// en: 'Connect them'
  String get connect => 'Connect them';

  /// en: 'Drag from the port of the source to a folder or the bucket: a config is created between them. Then save.'
  String get connectHelp =>
      'Drag from the port of the source to a folder or the bucket: a config is created between them. Then save.';

  /// en: 'Create one'
  String get create => 'Create one';

  /// en: 'Place {name: String}'
  String place({required String name}) => 'Place ${name}';
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
          'app.version' => ({
            required String version,
          }) => 'Dumpling v${version}',
          'common.longName' =>
            'Long names are cut on the canvas: a shorter one reads better.',
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
          'common.optionsFor' => ({
            required String name,
          }) => 'Options for ${name}',
          'common.viewDetails' => 'View details',
          'common.refresh' => 'Refresh',
          'common.listView' => 'List',
          'common.gridView' => 'Grid',
          'common.back' => 'Back',
          'common.next' => 'Next',
          'common.stepOf' => ({
            required int n,
            required int total,
          }) => 'Step ${n} of ${total}',
          'common.backupCount' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
                  n,
                  one: '${n} backup',
                  other: '${n} backups',
                ),
          'time.utc' => ({required String time}) => '${time} UTC',
          'time.local' => ({required String time}) => '${time} local',
          'errors.requestCancelled' => 'Request to API server was cancelled',
          'errors.connectionTimeout' => 'Connection timeout with API server. Check your internet connection',
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
          'errors.notFoundTitle' => 'Not found',
          'errors.pageNotFound' => 'This page does not exist.',
          'errors.offlineTitle' => 'Connection lost',
          'errors.offline' => ({
            required String url,
          }) => 'Can\'t reach the Dumpling service at ${url}. Check that it is running and try again.',
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
          'nav.language' => ({required String name}) => 'Language: ${name}',
          'nav.logout' => 'Sign out',
          'login.title' => 'Sign in',
          'login.description' => 'Manage your database backups.',
          'login.username' => 'Username',
          'login.usernameHint' => 'Enter your username',
          'login.password' => 'Password',
          'login.passwordHint' => 'Enter your password',
          'login.showPassword' => 'Show password',
          'login.hidePassword' => 'Hide password',
          'login.button' => 'Sign in',
          'login.signingIn' => 'Signing in…',
          'login.failedHint' => 'Check both and try again.',
          'login.envHint' =>
            'The username and password are set on the server with',
          'login.envHintAnd' => 'and',
          'login.tagline' => 'Backups made',
          'login.taglineAccent' => 'easy',
          'login.tagLightweight' => 'Lightweight',
          'login.tagCanvas' => 'Drag & Drop Canvas',
          'login.tagWinter' => 'Powered by Winter',
          'login.expiredTitle' => 'Your session expired',
          'login.expiredDescription' => 'Your session ended after 12 hours. Sign in again to continue where you left off.',
          'login.toSignInPage' => 'Go to the sign-in page',
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
          'colors.hexInvalid' =>
            'Enter a 6-digit HEX color, for example #0E7490',
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
          'workspaces.lastRun' => ({
            required String time,
          }) => 'Last run ${time}',
          'workspaces.noRuns' => 'No runs yet',
          'workspaces.openCanvas' => 'Open canvas',
          'workspaces.switchAndOpen' => 'Switch & open canvas',
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
          'workspaces.settingsOf' => ({
            required String name,
          }) => 'Settings for ${name}',
          'workspaces.settings.title' => 'Workspace settings',
          'workspaces.settings.description' => 'Applies only to this workspace',
          'workspaces.settings.general' => 'General',
          'workspaces.settings.defaults' => 'Defaults for new configs',
          'workspaces.settings.danger' => 'Danger zone',
          'workspaces.settings.created' => 'Created',
          'workspaces.settings.id' => 'Workspace ID',
          'workspaces.settings.copyId' => 'Copy workspace ID',
          'workspaces.settings.copied' => 'Copied',
          'workspaces.settings.noDescription' => 'No description',
          'workspaces.settings.defaultsHint' => 'A new connection on the canvas starts with these values. Each config can change them.',
          'workspaces.settings.schedule' => 'Schedule',
          'workspaces.settings.cron' => 'Cron',
          'workspaces.settings.cronHelp' => 'Always in UTC.',
          'workspaces.settings.compression' => 'Compression',
          'workspaces.settings.compressionNone' => 'None',
          'workspaces.settings.objectKey' => 'Object key',
          'workspaces.settings.objectKeyHelp' =>
            'Relative to the folder each config writes to, without extension.',
          'workspaces.settings.unsaved' => 'You have unsaved changes',
          'workspaces.settings.discard' => 'Discard',
          'workspaces.settings.saved' => 'Saved',
          'workspaces.settings.deleteTitle' => 'Delete this workspace',
          'workspaces.settings.deleteDescription' => 'Removes its canvas, sources, destinations, configs and run history. Backup files already in your buckets stay where they are.',
          'workspaces.settings.deleteButton' => 'Delete workspace',
          'workspaces.settings.deleteConfirmTitle' => ({
            required String name,
          }) => 'Delete “${name}”?',
          'workspaces.settings.deleteConfirm' => ({
            required int sources,
            required int destinations,
            required int configs,
          }) => 'This deletes its sources (${sources}), destinations (${destinations}), configs (${configs}) and their run history. Scheduled backups stop right away. It can\'t be undone.',
          'workspaces.settings.typeBefore' => 'Type',
          'workspaces.settings.typeAfter' => 'to confirm',
          'workspaces.settings.deleted' => ({
            required String name,
          }) => 'Workspace ${name} deleted',
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
          'connections.lastCheck' => 'Last check',
          'connections.checkTitle' => 'Connection check',
          'connections.checkNote' => 'Before every run and when you test',
          'connections.connection' => 'Connection',
          'connections.editConnection' => 'Edit connection',
          'sources.title' => 'Sources',
          'sources.description' =>
            'What this workspace backs up: PostgreSQL databases.',
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
                  n,
                  one: 'Used by ${n} backup. Remove it first.',
                  other: 'Used by ${n} backups. Remove them first.',
                ),
          'sources.deleteTitle' => ({
            required String name,
          }) => 'Delete the source ${name}?',
          'sources.deleteConfirm' => 'It isn\'t used by any backup. Its saved connection and password are removed from this workspace.',
          'sources.deleted' => ({
            required String name,
          }) => 'Source ${name} deleted',
          'sources.newTitle' => 'New source',
          'sources.editTitle' => 'Edit source',
          'sources.formDescription' => 'Connect what you want to back up.',
          'sources.stepType' => 'Type',
          'sources.stepConnection' => 'Connection',
          'sources.stepCheck' => 'Check & save',
          'sources.typeTitle' => 'What do you want to back up?',
          'sources.connectionTitle' => 'How should Dumpling connect?',
          'sources.checkTitle' => 'Check and save',
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
          'sources.urlHelp' => 'The password in the URL is stored encrypted and never shown again.',
          'sources.urlHelpEditing' =>
            'Without a password in the URL, the saved one is kept.',
          'sources.urlInvalid' =>
            'Use the format postgresql://user:password@host:5432/database',
          'sources.dumpFormat' => 'Dump format',
          'sources.formatCustom' => 'Custom (pg_dump -Fc)',
          'sources.formatPlain' => 'Plain SQL',
          'sources.testIdle' =>
            'Check the connection before saving the source.',
          'sources.connectedAs' => ({
            required String user,
          }) => 'Connected as ${user}',
          'sources.createButton' => 'Create source',
          'sources.created' => ({
            required String name,
          }) => 'Source ${name} created',
          'sources.saved' => ({required String name}) => 'Source ${name} saved',
          'sources.detailDescription' => ({
            required String type,
          }) => 'A ${type} database this workspace backs up.',
          'sources.statBackups' => 'Backups',
          'sources.statDestinations' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
                  n,
                  zero: 'none yet',
                  one: 'in ${n} destination',
                  other: 'in ${n} destinations',
                ),
          'sources.statLastBackup' => 'Last backup',
          'sources.sectionUses' => 'Backups using this source',
          'sources.openEditor' => 'Open editor',
          'sources.noUses' => 'No backup uses it yet. Connect it to a destination in the pipeline editor.',
          'sources.columnBackup' => 'Backup',
          'sources.columnSchedule' => 'Schedule',
          'sources.columnLastRun' => 'Last run',
          'sources.columnNextRun' => 'Next run',
          'sources.cronUtc' => 'cron · UTC',
          'sources.paused' => 'Paused',
          'sources.neverRun' => 'Not run yet',
          'sources.passwordStored' => '•••••••• · stored encrypted',
          'destinations.title' => 'Destinations',
          'destinations.description' =>
            'Where this workspace writes backups: S3 buckets.',
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
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
          'destinations.emptyDescription' =>
            'Add a bucket to write backups to.',
          'destinations.inUse' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
                  n,
                  one: '${n} backup',
                  other: '${n} backups',
                ),
          'destinations.notUsedYet' => 'Not used yet',
          'destinations.deleteFolder' => ({
            required String path,
          }) => 'Delete folder ${path}',
          'destinations.folderLocked' =>
            'In use by backups. Reconnect them first.',
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
          'destinations.stepType' => 'Type',
          'destinations.stepConnection' => 'Connection',
          'destinations.stepFolders' => 'Folders & check',
          'destinations.typeTitle' => 'Where should backups go?',
          'destinations.connectionTitle' => 'How should Dumpling connect?',
          'destinations.foldersTitle' => 'Folders and connection check',
          'destinations.name' => 'Name',
          'destinations.nameHint' => 'e.g. bucket-backups',
          'destinations.copyName' => ({required String name}) => '${name}-copy',
          'destinations.endpoint' => 'Endpoint',
          'destinations.endpointHelp' => 'Any S3-compatible URL. For AWS use https://s3.<region>.amazonaws.com.',
          'destinations.bucket' => 'Bucket',
          'destinations.region' => 'Region',
          'destinations.accessKeyId' => 'Access key ID',
          'destinations.secretKey' => 'Secret key',
          'destinations.secretKeepHint' => 'Leave empty to keep the saved one',
          'destinations.secretHelp' =>
            'Stored encrypted; never shown again after saving.',
          'destinations.pathStyle' => 'Path-style addressing',
          'destinations.pathStyleHelp' =>
            'Needed by most self-hosted S3 servers.',
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
          'destinations.detailDescription' =>
            'A bucket this workspace writes backups to.',
          'destinations.statBackups' => 'Backups',
          'destinations.statBackupsSub' => 'write here',
          'destinations.statFolders' => 'Folders',
          'destinations.statFoldersSub' => 'connection points',
          'destinations.sectionFolders' => 'Folders',
          'destinations.columnFolder' => 'Folder',
          'destinations.columnWrittenBy' => 'Written by',
          'destinations.accessKey' => 'Access key',
          'destinations.on' => 'On',
          'destinations.off' => 'Off',
          'destinations.typeSub.s3' => 'Any S3-compatible storage',
          'destinations.typeSub.gdrive' => 'Shared drive or folder',
          'destinations.typeSub.dropbox' => 'App folder',
          'destinations.typeSub.azure' => 'Storage container',
          'destinations.typeSub.sftp' => 'Any SSH server',
          'canvas.description' => 'Connect sources to destinations to build this workspace\'s backups.',
          'canvas.save' => 'Save canvas',
          'canvas.saved' => 'Canvas saved',
          'canvas.unsavedTitle' => 'Discard the changes?',
          'canvas.unsavedDescription' =>
            'The canvas has changes that are not saved. Leaving discards them.',
          'canvas.discard' => 'Discard',
          'canvas.newConfig' => 'New config',
          'canvas.removeFromCanvas' => 'Remove from canvas',
          'canvas.allSourcesPlaced' => 'Every source is on the canvas',
          'canvas.allDestinationsPlaced' =>
            'Every destination is on the canvas',
          'canvas.workspaceDefault' => 'Workspace default',
          'canvas.neverRun' => 'Never run',
          'canvas.disabled' => 'Disabled',
          'canvas.orphans' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('en'))(
                  n,
                  one: '${n} incomplete config',
                  other: '${n} incomplete configs',
                ),
          'canvas.orphansHelp' => 'Only complete flows (source → config → destination) are saved. The configs in amber are discarded on save; sources and destinations stay.',
          'canvas.semantics' => 'Canvas. Hold Space and drag to move it; right click for options; arrow keys pan; Ctrl and scroll zooms; F centers; click a connection and press Delete to remove it; Escape closes the config',
          'canvas.addSource' => 'Source',
          'canvas.addDestination' => 'Destination',
          'canvas.deleteConfig' => 'Delete config',
          'canvas.editConfig' => 'Edit config',
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
          'canvas.inspector.configName' => 'Config name',
          'canvas.inspector.doubleCompression' => 'The custom format (pg_dump -Fc) is compressed already: gzip barely makes it smaller.',
          'canvas.inspector.nameHelp' =>
            'Shown on the canvas, in Backups and in the run log.',
          'canvas.inspector.frequency' => 'Frequency',
          'canvas.inspector.review' => 'Review',
          'canvas.inspector.source' => 'Source',
          'canvas.inspector.destination' => 'Destination',
          'canvas.inspector.nextRunOnSave' => 'Computed when it is saved',
          'canvas.inspector.cronHelp' => 'minute hour day month weekday, in UTC. Hourly, daily and weekly write it for you.',
          'canvas.inspector.cronInvalid' =>
            'Not a valid cron expression (minute hour day month weekday)',
          'canvas.inspector.enabled' => 'Enabled',
          'canvas.inspector.enabledOn' => 'Runs on its schedule',
          'canvas.inspector.enabledOff' => 'Off: it only runs with Run now',
          'canvas.inspector.compressionNone' => 'None',
          'canvas.inspector.objectKeySlash' =>
            'The object key cannot start with /',
          'canvas.inspector.objectKeyExtension' => 'Leave out the extension: it is added from the dump format and the compression',
          'canvas.inspector.objectKeyDots' =>
            'The object key cannot have . or .. folders',
          'canvas.inspector.schedule' => 'Name & schedule',
          'canvas.inspector.cron' => 'Cron',
          'canvas.inspector.timeZone' => 'Time zone',
          'canvas.inspector.nextRun' => 'Next run',
          'canvas.inspector.output' => 'Output',
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
          'canvas.inspector.writes' => 'Next run writes',
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
          'canvas.run.button' => 'Run now',
          'canvas.run.help' => 'Runs this backup now, for real, as it is saved: the edits not saved yet are not used.',
          'canvas.run.needsSave' =>
            'Save the canvas first: a run uses the saved config.',
          'canvas.run.done' => ({
            required String name,
            required String size,
          }) => 'Backup ${name} done: ${size}',
          'canvas.run.failed' => ({
            required String name,
            required String error,
          }) => 'Backup ${name} failed: ${error}',
          'canvas.guide.title' => 'Your first backup',
          'canvas.guide.source' => 'Add a source',
          'canvas.guide.sourceHelp' => 'The database to back up.',
          'canvas.guide.destination' => 'Add a destination',
          'canvas.guide.destinationHelp' => 'The bucket the backups go to.',
          'canvas.guide.connect' => 'Connect them',
          'canvas.guide.connectHelp' => 'Drag from the port of the source to a folder or the bucket: a config is created between them. Then save.',
          'canvas.guide.create' => 'Create one',
          'canvas.guide.place' => ({required String name}) => 'Place ${name}',
          'runs.title' => 'Run log',
          'runs.description' => 'Every backup run in this workspace, scheduled or manual. Times in UTC, your local time below.',
          'runs.search' => 'Search by backup, source or destination',
          'runs.columnStatus' => 'Status',
          'runs.columnSource' => 'Source',
          'runs.columnDestination' => 'Destination',
          'runs.columnStarted' => 'Started',
          'runs.columnDuration' => 'Duration',
          'runs.columnSize' => 'Size',
          'runs.scheduled' => 'By schedule',
          'runs.manual' => 'Manual',
          'runs.emptyTitle' => 'No runs yet',
          'runs.emptyDescription' => 'Backups run on their schedule, or with Run now in the pipeline editor.',
          'runs.newestOnly' => 'Only the 200 newest runs are shown.',
          'runs.log' => 'Log (UTC)',
          'runs.copyLog' => 'Copy log',
          'runs.logCopied' => 'Log copied',
          'runs.logWhenDone' =>
            'The log is written when the run ends. Refresh to see it.',
          'runs.noLog' => 'This run has no log.',
          'runs.today' => ({required String date}) => 'Today · ${date} (UTC)',
          'runs.yesterday' => ({
            required String date,
          }) => 'Yesterday · ${date} (UTC)',
          'runs.day' => ({required String date}) => '${date} (UTC)',
          'runs.succeeded' => ({required int n}) => '${n} succeeded',
          'runs.failedCount' => ({required int n}) => '${n} failed',
          'runs.savedIn' => ({
            required String size,
            required String duration,
          }) => '${size} in ${duration}',
          'runs.inProgress' => 'In progress',
          'runs.soFar' => ({
            required String size,
          }) => 'In progress · ${size} so far',
          'runs.columnTrigger' => 'Trigger',
          'runs.viewRun' => 'View run',
          'runs.steps' => 'Steps',
          'runs.stepConnect' => ({
            required String name,
          }) => 'Connect to ${name}',
          'runs.stepDump' => ({
            required String name,
          }) => 'Dump and upload to ${name}',
          'runs.stepSkipped' => 'Skipped',
          'runs.stepWaiting' => 'Waiting',
          'runs.resultSuccess' => 'Backup saved',
          'runs.resultFailed' => 'The backup failed',
          'runs.resultRunning' => 'Running. Refresh to see how far it got.',
          'backups.title' => 'Backups',
          'backups.description' =>
            'Every backup in this workspace, its last run and the next one.',
          'backups.openEditor' => 'Open editor',
          'backups.newBackup' => 'New backup',
          'backups.healthy' => 'Healthy',
          'backups.healthySub' => 'last run succeeded',
          'backups.failing' => 'Failing',
          'backups.failingSub' => 'need attention',
          'backups.paused' => 'Paused',
          'backups.nextBackup' => 'Next backup',
          'backups.nextBackupIn' => 'Next backup in',
          'backups.nothingScheduled' => 'Nothing scheduled',
          'backups.search' => 'Search backups',
          'backups.columnStatus' => 'Status',
          'backups.columnSource' => 'Source',
          'backups.columnDestination' => 'Destination',
          'backups.columnSchedule' => 'Schedule',
          'backups.columnLastRun' => 'Last backup',
          'backups.columnNextRun' => 'Next backup',
          'backups.allSources' => 'All sources',
          'backups.allDestinations' => 'All destinations',
          'backups.shown' => ({
            required int shown,
            required int total,
          }) => '${shown} of ${total} backups',
          'backups.showing' => ({
            required int shown,
            required int total,
          }) => 'Showing ${shown} of ${total} backups',
          'backups.timesNote' => ({
            required String utc,
            required String local,
          }) => 'Times in UTC · now ${utc} (${local})',
          'backups.sort' => 'Sort:',
          'backups.sortBy' => 'Sort by',
          'backups.sortLast' => 'Last backup',
          'backups.sortLastSub' => 'Most recent first',
          'backups.sortLastOld' => 'Last backup (oldest)',
          'backups.sortLastOldSub' => 'Oldest first',
          'backups.sortNext' => 'Next backup',
          'backups.sortNextSub' => 'Soonest first',
          'backups.sortName' => 'Source name',
          'backups.sortNameSub' => 'A to Z',
          _ => null,
        } ??
        switch (path) {
          'backups.inTime' => ({required String time}) => 'in ${time}',
          'backups.startedAgo' => ({
            required String time,
          }) => 'Started ${time} ago',
          'backups.runNowFor' => ({required String name}) => 'Run ${name} now',
          'backups.showRuns' => 'Show run history',
          'backups.hideRuns' => 'Hide run history',
          'backups.moreFor' => ({
            required String name,
          }) => 'More actions for ${name}',
          'backups.viewLastRun' => 'View last run',
          'backups.editConfig' => 'Edit config',
          'backups.deleteBackup' => 'Delete backup',
          'backups.recentRuns' => 'Recent runs',
          'backups.noRuns' => 'No runs yet',
          'backups.viewLog' => 'View log',
          'backups.viewDetails' => 'View details',
          'backups.noFile' => 'No file written',
          'backups.uploading' => 'Uploading…',
          'backups.manual' => 'Manual',
          'backups.scheduled' => 'By schedule',
          'backups.deleteTitle' => ({
            required String name,
          }) => 'Delete the backup ${name}?',
          'backups.deleteConfirm' => 'Its schedule stops. Its runs stay in the run log, and the files already in the destination stay there.',
          'backups.deleted' => ({
            required String name,
          }) => 'Backup ${name} deleted',
          'backups.saved' => ({required String name}) => 'Backup ${name} saved',
          'backups.emptyDescription' => 'Connect a source to a destination in the pipeline editor to create one.',
          _ => null,
        };
  }
}
