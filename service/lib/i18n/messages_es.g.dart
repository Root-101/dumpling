///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'messages.g.dart';

import 'package:intl/intl.dart';
import 'package:slang/generated.dart';

// Path: <root>
class ServiceMessagesEs
    with BaseTranslations<ServiceMessagesLocale, ServiceMessages>
    implements ServiceMessages {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [ServiceMessagesLocale.build] is preferred.
  ServiceMessagesEs({
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
             locale: ServiceMessagesLocale.es,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <es>.
  final TranslationMetadata<ServiceMessagesLocale, ServiceMessages> _meta;
  @override
  TranslationMetadata<ServiceMessagesLocale, ServiceMessages> get $meta =>
      _meta;

  /// Access flat map
  @override
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final ServiceMessagesEs _root = this; // ignore: unused_field

  @override
  ServiceMessagesEs $copyWith({
    TranslationMetadata<ServiceMessagesLocale, ServiceMessages>? meta,
  }) => ServiceMessagesEs(meta: meta ?? this.$meta);

  // Translations
  @override
  late final ServiceMessages$errors$es errors = ServiceMessages$errors$es._(
    _root,
  );
}

// Path: errors
class ServiceMessages$errors$es implements ServiceMessages$errors$en {
  ServiceMessages$errors$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  late final ServiceMessages$errors$auth$es auth =
      ServiceMessages$errors$auth$es._(_root);
  @override
  late final ServiceMessages$errors$workspaces$es workspaces =
      ServiceMessages$errors$workspaces$es._(_root);
  @override
  late final ServiceMessages$errors$sources$es sources =
      ServiceMessages$errors$sources$es._(_root);
  @override
  late final ServiceMessages$errors$destinations$es destinations =
      ServiceMessages$errors$destinations$es._(_root);
  @override
  late final ServiceMessages$errors$configs$es configs =
      ServiceMessages$errors$configs$es._(_root);
  @override
  late final ServiceMessages$errors$runs$es runs =
      ServiceMessages$errors$runs$es._(_root);
  @override
  late final ServiceMessages$errors$validations$es validations =
      ServiceMessages$errors$validations$es._(_root);
}

// Path: errors.auth
class ServiceMessages$errors$auth$es implements ServiceMessages$errors$auth$en {
  ServiceMessages$errors$auth$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get invalidCredentials => 'Usuario o contraseña incorrectos';
  @override
  String get tooManyLoginAttempts =>
      'Demasiados intentos de inicio de sesión fallidos';
  @override
  String get invalidLoginRequest => 'Petición de inicio de sesión no válida';
}

// Path: errors.workspaces
class ServiceMessages$errors$workspaces$es
    implements ServiceMessages$errors$workspaces$en {
  ServiceMessages$errors$workspaces$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String notFound({required Object slug}) =>
      'El workspace "${slug}" no existe.';
}

// Path: errors.sources
class ServiceMessages$errors$sources$es
    implements ServiceMessages$errors$sources$en {
  ServiceMessages$errors$sources$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String notFound({required Object id}) =>
      'El origen "${id}" no existe en este workspace.';
  @override
  String inUse({required Object configs}) =>
      'Hay configs que respaldan este origen (${configs}): bórralas o conéctalas a otro origen primero.';
}

// Path: errors.destinations
class ServiceMessages$errors$destinations$es
    implements ServiceMessages$errors$destinations$en {
  ServiceMessages$errors$destinations$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String notFound({required Object id}) =>
      'El destino "${id}" no existe en este workspace.';
  @override
  String inUse({required Object configs}) =>
      'Hay configs que escriben en este destino (${configs}): bórralas o conéctalas a otro destino primero.';
  @override
  String folderInUse({required Object config, required Object folder}) =>
      'La config "${config}" escribe en "${folder}": muévela antes de quitar esa carpeta.';
}

// Path: errors.configs
class ServiceMessages$errors$configs$es
    implements ServiceMessages$errors$configs$en {
  ServiceMessages$errors$configs$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String notFound({required Object id}) =>
      'La config "${id}" no existe en este workspace.';
}

// Path: errors.runs
class ServiceMessages$errors$runs$es implements ServiceMessages$errors$runs$en {
  ServiceMessages$errors$runs$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String notFound({required Object id}) =>
      'La ejecución "${id}" no existe en este workspace.';
  @override
  String get alreadyRunning =>
      'Esta config ya se está ejecutando: espera a que termine.';
  @override
  String invalidFilter({required Object name, required Object values}) =>
      '${name} debe ser uno de: ${values}';
  @override
  String invalidLimit({required Object max}) => 'limit debe ir de 1 a ${max}';
}

// Path: errors.validations
class ServiceMessages$errors$validations$es
    implements ServiceMessages$errors$validations$en {
  ServiceMessages$errors$validations$es._(this._root);

  final ServiceMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get cron =>
      'No es una expresión cron válida (minuto hora día mes día-de-la-semana)';
  @override
  String get objectKey => 'La clave del objeto no puede empezar por /';
  @override
  String get objectKeyExtension =>
      'Quita la extensión: se agrega según el formato del dump y la compresión';
  @override
  String get objectKeyDots =>
      'La clave del objeto no puede tener carpetas . o ..';
  @override
  String get sourceTypeDisabled =>
      'Este tipo de origen todavía no está disponible';
  @override
  String get destinationTypeDisabled =>
      'Este tipo de destino todavía no está disponible';
  @override
  String get s3Endpoint =>
      'No es una URL de endpoint (https://s3.us-east-1.amazonaws.com, http://minio:9000)';
  @override
  String get bucketName =>
      'No es un nombre de bucket válido: de 3 a 63 minúsculas, dígitos, puntos o guiones';
  @override
  String get folderPath => 'Usa minúsculas, dígitos, - . _ y / entre ellos';
  @override
  String get repeatedFolder => 'Cada carpeta solo puede aparecer una vez';
  @override
  String get unknownSource => 'No existe ese origen en este workspace';
  @override
  String get unknownDestination => 'No existe ese destino en este workspace';
  @override
  String get unknownFolder => 'Elige una de las carpetas del destino';
  @override
  String get folderOnRoot =>
      'Este destino no tiene carpetas: deja la carpeta vacía para escribir en la raíz';
  @override
  String get unknownNode =>
      'No es un nodo de este workspace: uno nuevo lleva un id que empieza por new_';
  @override
  String get repeatedNode => 'Cada nodo necesita su propio id';
  @override
  String canvasPosition({required Object max}) =>
      'x e y deben estar entre -${max} y ${max}';
  @override
  String get postgresUrl =>
      'No es una URL de conexión de PostgreSQL (postgresql://usuario:contraseña@host:5432/base)';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on ServiceMessagesEs {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'errors.auth.invalidCredentials' => 'Usuario o contraseña incorrectos',
      'errors.auth.tooManyLoginAttempts' =>
        'Demasiados intentos de inicio de sesión fallidos',
      'errors.auth.invalidLoginRequest' =>
        'Petición de inicio de sesión no válida',
      'errors.workspaces.notFound' => ({
        required Object slug,
      }) => 'El workspace "${slug}" no existe.',
      'errors.sources.notFound' => ({
        required Object id,
      }) => 'El origen "${id}" no existe en este workspace.',
      'errors.sources.inUse' => ({
        required Object configs,
      }) => 'Hay configs que respaldan este origen (${configs}): bórralas o conéctalas a otro origen primero.',
      'errors.destinations.notFound' => ({
        required Object id,
      }) => 'El destino "${id}" no existe en este workspace.',
      'errors.destinations.inUse' => ({
        required Object configs,
      }) => 'Hay configs que escriben en este destino (${configs}): bórralas o conéctalas a otro destino primero.',
      'errors.destinations.folderInUse' => ({
        required Object config,
        required Object folder,
      }) => 'La config "${config}" escribe en "${folder}": muévela antes de quitar esa carpeta.',
      'errors.configs.notFound' => ({
        required Object id,
      }) => 'La config "${id}" no existe en este workspace.',
      'errors.runs.notFound' => ({
        required Object id,
      }) => 'La ejecución "${id}" no existe en este workspace.',
      'errors.runs.alreadyRunning' =>
        'Esta config ya se está ejecutando: espera a que termine.',
      'errors.runs.invalidFilter' => ({
        required Object name,
        required Object values,
      }) => '${name} debe ser uno de: ${values}',
      'errors.runs.invalidLimit' => ({
        required Object max,
      }) => 'limit debe ir de 1 a ${max}',
      'errors.validations.cron' => 'No es una expresión cron válida (minuto hora día mes día-de-la-semana)',
      'errors.validations.objectKey' =>
        'La clave del objeto no puede empezar por /',
      'errors.validations.objectKeyExtension' => 'Quita la extensión: se agrega según el formato del dump y la compresión',
      'errors.validations.objectKeyDots' =>
        'La clave del objeto no puede tener carpetas . o ..',
      'errors.validations.sourceTypeDisabled' =>
        'Este tipo de origen todavía no está disponible',
      'errors.validations.destinationTypeDisabled' =>
        'Este tipo de destino todavía no está disponible',
      'errors.validations.s3Endpoint' => 'No es una URL de endpoint (https://s3.us-east-1.amazonaws.com, http://minio:9000)',
      'errors.validations.bucketName' => 'No es un nombre de bucket válido: de 3 a 63 minúsculas, dígitos, puntos o guiones',
      'errors.validations.folderPath' =>
        'Usa minúsculas, dígitos, - . _ y / entre ellos',
      'errors.validations.repeatedFolder' =>
        'Cada carpeta solo puede aparecer una vez',
      'errors.validations.unknownSource' =>
        'No existe ese origen en este workspace',
      'errors.validations.unknownDestination' =>
        'No existe ese destino en este workspace',
      'errors.validations.unknownFolder' =>
        'Elige una de las carpetas del destino',
      'errors.validations.folderOnRoot' => 'Este destino no tiene carpetas: deja la carpeta vacía para escribir en la raíz',
      'errors.validations.unknownNode' => 'No es un nodo de este workspace: uno nuevo lleva un id que empieza por new_',
      'errors.validations.repeatedNode' => 'Cada nodo necesita su propio id',
      'errors.validations.canvasPosition' => ({
        required Object max,
      }) => 'x e y deben estar entre -${max} y ${max}',
      'errors.validations.postgresUrl' => 'No es una URL de conexión de PostgreSQL (postgresql://usuario:contraseña@host:5432/base)',
      _ => null,
    };
  }
}
