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
      _ => null,
    };
  }
}
