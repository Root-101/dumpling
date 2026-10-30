///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'messages.g.dart';

// Path: <root>
typedef ServiceMessagesEn = ServiceMessages; // ignore: unused_element

class ServiceMessages
    with BaseTranslations<ServiceMessagesLocale, ServiceMessages> {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [ServiceMessagesLocale.build] is preferred.
  ServiceMessages({
    Map<String, Node>? overrides,
    PluralResolver? cardinalResolver,
    PluralResolver? ordinalResolver,
    TranslationMetadata<ServiceMessagesLocale, ServiceMessages>? meta,
  }) : assert(
         overrides == null,
         'Set "translation_overrides: true" in order to enable this feature.',
       ),
       _meta =
           meta ??
           TranslationMetadata(
             locale: ServiceMessagesLocale.en,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <en>.
  final TranslationMetadata<ServiceMessagesLocale, ServiceMessages> _meta;
  @override
  TranslationMetadata<ServiceMessagesLocale, ServiceMessages> get $meta =>
      _meta;

  /// Access flat map
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final ServiceMessages _root = this; // ignore: unused_field

  ServiceMessages $copyWith({
    TranslationMetadata<ServiceMessagesLocale, ServiceMessages>? meta,
  }) => ServiceMessages(meta: meta ?? this.$meta);

  // Translations
  late final ServiceMessages$errors$en errors = ServiceMessages$errors$en._(
    _root,
  );
}

// Path: errors
class ServiceMessages$errors$en {
  ServiceMessages$errors$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations
  late final ServiceMessages$errors$auth$en auth =
      ServiceMessages$errors$auth$en._(_root);
  late final ServiceMessages$errors$workspaces$en workspaces =
      ServiceMessages$errors$workspaces$en._(_root);
  late final ServiceMessages$errors$sources$en sources =
      ServiceMessages$errors$sources$en._(_root);
  late final ServiceMessages$errors$destinations$en destinations =
      ServiceMessages$errors$destinations$en._(_root);
  late final ServiceMessages$errors$configs$en configs =
      ServiceMessages$errors$configs$en._(_root);
  late final ServiceMessages$errors$runs$en runs =
      ServiceMessages$errors$runs$en._(_root);
  late final ServiceMessages$errors$validations$en validations =
      ServiceMessages$errors$validations$en._(_root);
}

// Path: errors.auth
class ServiceMessages$errors$auth$en {
  ServiceMessages$errors$auth$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Wrong username or password'
  String get invalidCredentials => 'Wrong username or password';

  /// en: 'Too many failed sign-in attempts'
  String get tooManyLoginAttempts => 'Too many failed sign-in attempts';

  /// en: 'Invalid sign-in request'
  String get invalidLoginRequest => 'Invalid sign-in request';
}

// Path: errors.workspaces
class ServiceMessages$errors$workspaces$en {
  ServiceMessages$errors$workspaces$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'The workspace "{slug: String}" does not exist.'
  String notFound({required String slug}) =>
      'The workspace "${slug}" does not exist.';
}

// Path: errors.sources
class ServiceMessages$errors$sources$en {
  ServiceMessages$errors$sources$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'The source "{id: String}" does not exist in this workspace.'
  String notFound({required String id}) =>
      'The source "${id}" does not exist in this workspace.';

  /// en: 'Configs back up this source ({configs: int}): delete them or connect them to another source first.'
  String inUse({required int configs}) =>
      'Configs back up this source (${configs}): delete them or connect them to another source first.';
}

// Path: errors.destinations
class ServiceMessages$errors$destinations$en {
  ServiceMessages$errors$destinations$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'The destination "{id: String}" does not exist in this workspace.'
  String notFound({required String id}) =>
      'The destination "${id}" does not exist in this workspace.';

  /// en: 'Configs write to this destination ({configs: int}): delete them or connect them to another destination first.'
  String inUse({required int configs}) =>
      'Configs write to this destination (${configs}): delete them or connect them to another destination first.';

  /// en: 'The config "{config: String}" writes to "{folder: String}": move it before removing that folder.'
  String folderInUse({required String config, required String folder}) =>
      'The config "${config}" writes to "${folder}": move it before removing that folder.';
}

// Path: errors.configs
class ServiceMessages$errors$configs$en {
  ServiceMessages$errors$configs$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'The config "{id: String}" does not exist in this workspace.'
  String notFound({required String id}) =>
      'The config "${id}" does not exist in this workspace.';
}

// Path: errors.runs
class ServiceMessages$errors$runs$en {
  ServiceMessages$errors$runs$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'The run "{id: String}" does not exist in this workspace.'
  String notFound({required String id}) =>
      'The run "${id}" does not exist in this workspace.';

  /// en: 'This config is already running: wait for it to end.'
  String get alreadyRunning =>
      'This config is already running: wait for it to end.';

  /// en: '{name: String} must be one of: {values: String}'
  String invalidFilter({required String name, required String values}) =>
      '${name} must be one of: ${values}';

  /// en: 'limit must be from 1 to {max: int}'
  String invalidLimit({required int max}) => 'limit must be from 1 to ${max}';
}

// Path: errors.validations
class ServiceMessages$errors$validations$en {
  ServiceMessages$errors$validations$en._(this._root);

  final ServiceMessages _root; // ignore: unused_field

  // Translations

  /// en: 'Not a valid cron expression (minute hour day month weekday)'
  String get cron =>
      'Not a valid cron expression (minute hour day month weekday)';

  /// en: 'The object key cannot start with /'
  String get objectKey => 'The object key cannot start with /';

  /// en: 'Leave out the extension: it is added from the dump format and the compression'
  String get objectKeyExtension =>
      'Leave out the extension: it is added from the dump format and the compression';

  /// en: 'The object key cannot have . or .. folders'
  String get objectKeyDots => 'The object key cannot have . or .. folders';

  /// en: 'This type of source is not available yet'
  String get sourceTypeDisabled => 'This type of source is not available yet';

  /// en: 'This type of destination is not available yet'
  String get destinationTypeDisabled =>
      'This type of destination is not available yet';

  /// en: 'Not an endpoint URL (https://s3.us-east-1.amazonaws.com, http://minio:9000)'
  String get s3Endpoint =>
      'Not an endpoint URL (https://s3.us-east-1.amazonaws.com, http://minio:9000)';

  /// en: 'Not a valid bucket name: 3 to 63 lowercase letters, digits, dots or hyphens'
  String get bucketName =>
      'Not a valid bucket name: 3 to 63 lowercase letters, digits, dots or hyphens';

  /// en: 'Use lowercase letters, digits, - . _ and / between them'
  String get folderPath =>
      'Use lowercase letters, digits, - . _ and / between them';

  /// en: 'Each folder can only appear once'
  String get repeatedFolder => 'Each folder can only appear once';

  /// en: 'There is no such source in this workspace'
  String get unknownSource => 'There is no such source in this workspace';

  /// en: 'There is no such destination in this workspace'
  String get unknownDestination =>
      'There is no such destination in this workspace';

  /// en: 'Choose one of the folders of the destination'
  String get unknownFolder => 'Choose one of the folders of the destination';

  /// en: 'This destination has no folders: leave the folder empty to write to the root'
  String get folderOnRoot =>
      'This destination has no folders: leave the folder empty to write to the root';

  /// en: 'Not a node of this workspace: a new one has an id that starts with new_'
  String get unknownNode =>
      'Not a node of this workspace: a new one has an id that starts with new_';

  /// en: 'Each node needs its own id'
  String get repeatedNode => 'Each node needs its own id';

  /// en: 'x and y must be between -{max: int} and {max}'
  String canvasPosition({required Object max}) =>
      'x and y must be between -${max} and ${max}';

  /// en: 'Not a PostgreSQL connection URL (postgresql://user:password@host:5432/database)'
  String get postgresUrl =>
      'Not a PostgreSQL connection URL (postgresql://user:password@host:5432/database)';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on ServiceMessages {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'errors.auth.invalidCredentials' => 'Wrong username or password',
      'errors.auth.tooManyLoginAttempts' => 'Too many failed sign-in attempts',
      'errors.auth.invalidLoginRequest' => 'Invalid sign-in request',
      'errors.workspaces.notFound' => ({
        required String slug,
      }) => 'The workspace "${slug}" does not exist.',
      'errors.sources.notFound' => ({
        required String id,
      }) => 'The source "${id}" does not exist in this workspace.',
      'errors.sources.inUse' => ({
        required int configs,
      }) => 'Configs back up this source (${configs}): delete them or connect them to another source first.',
      'errors.destinations.notFound' => ({
        required String id,
      }) => 'The destination "${id}" does not exist in this workspace.',
      'errors.destinations.inUse' => ({
        required int configs,
      }) => 'Configs write to this destination (${configs}): delete them or connect them to another destination first.',
      'errors.destinations.folderInUse' => ({
        required String config,
        required String folder,
      }) => 'The config "${config}" writes to "${folder}": move it before removing that folder.',
      'errors.configs.notFound' => ({
        required String id,
      }) => 'The config "${id}" does not exist in this workspace.',
      'errors.runs.notFound' => ({
        required String id,
      }) => 'The run "${id}" does not exist in this workspace.',
      'errors.runs.alreadyRunning' =>
        'This config is already running: wait for it to end.',
      'errors.runs.invalidFilter' => ({
        required String name,
        required String values,
      }) => '${name} must be one of: ${values}',
      'errors.runs.invalidLimit' => ({
        required int max,
      }) => 'limit must be from 1 to ${max}',
      'errors.validations.cron' =>
        'Not a valid cron expression (minute hour day month weekday)',
      'errors.validations.objectKey' => 'The object key cannot start with /',
      'errors.validations.objectKeyExtension' => 'Leave out the extension: it is added from the dump format and the compression',
      'errors.validations.objectKeyDots' =>
        'The object key cannot have . or .. folders',
      'errors.validations.sourceTypeDisabled' =>
        'This type of source is not available yet',
      'errors.validations.destinationTypeDisabled' =>
        'This type of destination is not available yet',
      'errors.validations.s3Endpoint' => 'Not an endpoint URL (https://s3.us-east-1.amazonaws.com, http://minio:9000)',
      'errors.validations.bucketName' => 'Not a valid bucket name: 3 to 63 lowercase letters, digits, dots or hyphens',
      'errors.validations.folderPath' =>
        'Use lowercase letters, digits, - . _ and / between them',
      'errors.validations.repeatedFolder' => 'Each folder can only appear once',
      'errors.validations.unknownSource' =>
        'There is no such source in this workspace',
      'errors.validations.unknownDestination' =>
        'There is no such destination in this workspace',
      'errors.validations.unknownFolder' =>
        'Choose one of the folders of the destination',
      'errors.validations.folderOnRoot' => 'This destination has no folders: leave the folder empty to write to the root',
      'errors.validations.unknownNode' => 'Not a node of this workspace: a new one has an id that starts with new_',
      'errors.validations.repeatedNode' => 'Each node needs its own id',
      'errors.validations.canvasPosition' => ({
        required Object max,
      }) => 'x and y must be between -${max} and ${max}',
      'errors.validations.postgresUrl' => 'Not a PostgreSQL connection URL (postgresql://user:password@host:5432/database)',
      _ => null,
    };
  }
}
