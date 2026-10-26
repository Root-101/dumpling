///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

import 'messages.g.dart';

import 'package:intl/intl.dart';
import 'package:slang/generated.dart';

// Path: <root>
class AppMessagesEs
    with BaseTranslations<AppMessagesLocale, AppMessages>
    implements AppMessages {
  /// You can call this constructor and build your own translation instance of this locale.
  /// Constructing via the enum [AppMessagesLocale.build] is preferred.
  AppMessagesEs({
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
             locale: AppMessagesLocale.es,
             overrides: overrides ?? {},
             cardinalResolver: cardinalResolver,
             ordinalResolver: ordinalResolver,
           ) {
    _meta.setFlatMapFunction(_flatMapFunction);
  }

  /// Metadata for the translations of <es>.
  final TranslationMetadata<AppMessagesLocale, AppMessages> _meta;
  @override
  TranslationMetadata<AppMessagesLocale, AppMessages> get $meta => _meta;

  /// Access flat map
  @override
  dynamic operator [](String key) => _meta.getTranslation(key);

  late final AppMessagesEs _root = this; // ignore: unused_field

  @override
  AppMessagesEs $copyWith({
    TranslationMetadata<AppMessagesLocale, AppMessages>? meta,
  }) => AppMessagesEs(meta: meta ?? this.$meta);

  // Translations
  @override
  late final AppMessages$app$es app = AppMessages$app$es._(_root);
  @override
  late final AppMessages$common$es common = AppMessages$common$es._(_root);
  @override
  late final AppMessages$time$es time = AppMessages$time$es._(_root);
  @override
  late final AppMessages$errors$es errors = AppMessages$errors$es._(_root);
  @override
  late final AppMessages$nav$es nav = AppMessages$nav$es._(_root);
  @override
  late final AppMessages$login$es login = AppMessages$login$es._(_root);
  @override
  late final AppMessages$colors$es colors = AppMessages$colors$es._(_root);
  @override
  late final AppMessages$workspaces$es workspaces = AppMessages$workspaces$es._(
    _root,
  );
  @override
  late final AppMessages$connections$es connections =
      AppMessages$connections$es._(_root);
  @override
  late final AppMessages$sources$es sources = AppMessages$sources$es._(_root);
  @override
  late final AppMessages$destinations$es destinations =
      AppMessages$destinations$es._(_root);
  @override
  late final AppMessages$canvas$es canvas = AppMessages$canvas$es._(_root);
}

// Path: app
class AppMessages$app$es implements AppMessages$app$en {
  AppMessages$app$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get name => 'Dumpling';
  @override
  String get needMoreSpace => 'Se necesita más espacio';
  @override
  String get splashText => 'Cargando tus backups…';
  @override
  String version({required Object version}) => 'Dumpling v${version}';
}

// Path: common
class AppMessages$common$es implements AppMessages$common$en {
  AppMessages$common$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get loading => 'Cargando';
  @override
  String get error => 'Error';
  @override
  String get tryAgain => 'Reintentar';
  @override
  String get noData => 'Sin datos';
  @override
  String get cancel => 'Cancelar';
  @override
  String get close => 'Cerrar';
  @override
  String get required => 'Requerido';
  @override
  String get optional => '(opcional)';
  @override
  String get filters => 'Filtros';
  @override
  String get clearAll => 'Limpiar todo';
  @override
  String get done => 'Listo';
  @override
  String get all => 'Todos';
  @override
  String get selected => 'Elegido';
  @override
  String get soon => 'Pronto';
  @override
  String get edit => 'Editar';
  @override
  String get duplicate => 'Duplicar';
  @override
  String get delete => 'Eliminar';
  @override
  String get add => 'Agregar';
  @override
  String get saving => 'Guardando…';
  @override
  String get saveChanges => 'Guardar cambios';
  @override
  String get noMatches => 'Nada coincide con tu búsqueda';
  @override
  String get clearSearch => 'Limpiar búsqueda y filtros';
  @override
  String shownOf({required Object shown, required Object total}) =>
      '${shown} de ${total}';
  @override
  String optionsFor({required Object name}) => 'Opciones de ${name}';
}

// Path: time
class AppMessages$time$es implements AppMessages$time$en {
  AppMessages$time$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String utc({required Object time}) => '${time} UTC';
  @override
  String local({required Object time}) => '${time} local';
}

// Path: errors
class AppMessages$errors$es implements AppMessages$errors$en {
  AppMessages$errors$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get requestCancelled => 'La petición al servidor fue cancelada';
  @override
  String get connectionTimeout =>
      'Tiempo de conexión agotado con el servidor. Revisa tu conexión a internet';
  @override
  String get noConnection =>
      'No se pudo conectar con el servidor. Revisa tu conexión a internet';
  @override
  String get receiveTimeout =>
      'Tiempo de espera agotado al recibir datos del servidor';
  @override
  String get sendTimeout =>
      'Tiempo de espera agotado al enviar datos al servidor';
  @override
  String get badCertificate => 'Certificado inválido';
  @override
  String get connection => 'Error de conexión';
  @override
  String get validation => 'Error de validación';
  @override
  String get server => 'Error del servidor';
  @override
  String get unknown => 'Error desconocido';
}

// Path: nav
class AppMessages$nav$es implements AppMessages$nav$en {
  AppMessages$nav$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String switchWorkspace({required Object name}) =>
      '${name} · cambiar de workspace';
  @override
  String get workspaces => 'Workspaces';
  @override
  String get backups => 'Backups';
  @override
  String get canvas => 'Editor del pipeline';
  @override
  String get sources => 'Orígenes';
  @override
  String get destinations => 'Destinos';
  @override
  String get runs => 'Registro de ejecuciones';
  @override
  String failedRuns({required Object count}) => '${count} con fallos';
  @override
  String get settings => 'Ajustes del workspace';
  @override
  String language({required Object name}) => 'Idioma: ${name}';
  @override
  String get logout => 'Cerrar sesión';
  @override
  String get comingSoon => 'Esta pantalla viene después.';
}

// Path: login
class AppMessages$login$es implements AppMessages$login$en {
  AppMessages$login$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Inicia sesión';
  @override
  String get description => 'Gestiona los backups de tus bases de datos.';
  @override
  String get username => 'Usuario';
  @override
  String get usernameHint => 'admin';
  @override
  String get password => 'Contraseña';
  @override
  String get passwordHint => 'Escribe tu contraseña';
  @override
  String get showPassword => 'Mostrar contraseña';
  @override
  String get hidePassword => 'Ocultar contraseña';
  @override
  String get button => 'Iniciar sesión';
  @override
  String get signingIn => 'Iniciando sesión…';
  @override
  String get failedHint => 'Revisa ambos e inténtalo de nuevo.';
  @override
  String get envHint =>
      'El usuario y la contraseña se definen en el servidor con';
  @override
  String get envHintAnd => 'y';
}

// Path: colors
class AppMessages$colors$es implements AppMessages$colors$en {
  AppMessages$colors$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get none => 'Sin color';
  @override
  String get custom => 'Color personalizado';
  @override
  String get apply => 'Aplicar';
  @override
  String get saturationBrightness => 'Saturación y brillo';
  @override
  String get hue => 'Tono';
  @override
  String contrast({required Object ratio}) =>
      'Inicial blanca sobre este color: ${ratio}:1';
  @override
  String contrastLow({required Object ratio}) =>
      'Poco contraste con la inicial blanca (${ratio}:1). Costará leerla.';
  @override
  String get hexInvalid =>
      'Escribe un color HEX de 6 dígitos, por ejemplo #0E7490';
  @override
  String get violet => 'Violeta';
  @override
  String get blue => 'Azul';
  @override
  String get teal => 'Verde azulado';
  @override
  String get green => 'Verde';
  @override
  String get amber => 'Ámbar';
  @override
  String get red => 'Rojo';
  @override
  String get pink => 'Rosa';
  @override
  String get slate => 'Pizarra';
}

// Path: workspaces
class AppMessages$workspaces$es implements AppMessages$workspaces$en {
  AppMessages$workspaces$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Workspaces';
  @override
  String get description =>
      'Cada workspace es independiente: su propio canvas, orígenes, destinos y backups.';
  @override
  String get create => 'Nuevo workspace';
  @override
  String get createHint =>
      'Un canvas nuevo para otro entorno, cliente o proyecto.';
  @override
  String get current => 'Actual';
  @override
  String get sources => 'Orígenes';
  @override
  String get destinations => 'Destinos';
  @override
  String get backups => 'Backups';
  @override
  String get noBackups => 'Todavía sin backups';
  @override
  String get healthy => 'Todo en orden';
  @override
  String failing({required Object count}) => '${count} con fallos';
  @override
  String get running => 'Ejecutándose ahora';
  @override
  String lastRun({required Object time}) => 'Última ejecución ${time}';
  @override
  String get noRuns => 'Todavía sin ejecuciones';
  @override
  String get openCanvas => 'Abrir canvas';
  @override
  String get switchAndOpen => 'Cambiar y abrir canvas';
  @override
  String moreOptions({required Object name}) => 'Más opciones de ${name}';
  @override
  String get formTitle => 'Nuevo workspace';
  @override
  String get formDescription =>
      'Los workspaces no comparten nada: cada uno tiene su propio canvas, conexiones, backups e historial de ejecuciones.';
  @override
  String get name => 'Nombre';
  @override
  String get nameHint => 'p. ej. Staging';
  @override
  String get descriptionLabel => 'Descripción';
  @override
  String get descriptionHint => 'Para qué es este workspace';
  @override
  String get color => 'Color';
  @override
  String get emptyCanvas => 'Un workspace nuevo empieza con el canvas vacío.';
  @override
  String get createButton => 'Crear workspace';
  @override
  String get creating => 'Creando…';
  @override
  String created({required Object name}) => 'Workspace ${name} creado';
}

// Path: connections
class AppMessages$connections$es implements AppMessages$connections$en {
  AppMessages$connections$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get notTested => 'Sin probar';
  @override
  String get notTestedYet => 'Todavía sin probar';
  @override
  String get testing => 'Probando…';
  @override
  String get test => 'Probar conexión';
  @override
  String get connected => 'Conectado';
  @override
  String get incompatible => 'Incompatible';
  @override
  String get incompatibleTitle =>
      'Conectó, pero el servidor es más nuevo que la herramienta de dump';
  @override
  String incompatibleSub({required Object server, required Object tool}) =>
      'Servidor ${server} · ${tool}. Actualiza la herramienta de dump donde corre Dumpling.';
  @override
  String get toolMissing => 'Falta la herramienta';
  @override
  String get toolMissingTitle =>
      'Conectó, pero la herramienta de dump no está instalada donde corre Dumpling';
  @override
  String get unreachable => 'Sin conexión';
  @override
  String get failedTitle => 'No se pudo conectar';
}

// Path: sources
class AppMessages$sources$es implements AppMessages$sources$en {
  AppMessages$sources$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Sources';
  @override
  String description({required Object workspace}) =>
      'Lo que respalda el workspace ${workspace}: bases de datos PostgreSQL.';
  @override
  String get create => 'Nuevo source';
  @override
  String get search => 'Buscar sources';
  @override
  String get columnName => 'Nombre';
  @override
  String get columnType => 'Tipo';
  @override
  String get columnHost => 'Host';
  @override
  String get columnBackups => 'Backups';
  @override
  String get columnStatus => 'Estado';
  @override
  String get emptyTitle => 'Todavía no hay sources';
  @override
  String get emptyDescription => 'Conecta una base de datos para respaldarla.';
  @override
  String inUse({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: 'Lo usa ${n} backup. Quítalo primero.',
        other: 'Lo usan ${n} backups. Quítalos primero.',
      );
  @override
  String deleteTitle({required Object name}) => '¿Eliminar el source ${name}?';
  @override
  String get deleteConfirm =>
      'Ningún backup lo usa. Su conexión y su contraseña guardadas se borran de este workspace.';
  @override
  String deleted({required Object name}) => 'Source ${name} eliminado';
  @override
  String get newTitle => 'Nuevo source';
  @override
  String get editTitle => 'Editar source';
  @override
  String get formDescription => 'Conecta lo que quieres respaldar.';
  @override
  String get sectionType => '01 Tipo';
  @override
  String get sectionConnection => '02 Conexión';
  @override
  String get name => 'Nombre';
  @override
  String get nameHint => 'p. ej. orders-db';
  @override
  String copyName({required Object name}) => '${name}-copia';
  @override
  String get connectWith => 'Conectar con';
  @override
  String get byFields => 'Campos';
  @override
  String get byUrl => 'URL de conexión';
  @override
  String get host => 'Host';
  @override
  String get port => 'Puerto';
  @override
  String get portInvalid => 'De 1 a 65535';
  @override
  String get database => 'Base de datos';
  @override
  String get username => 'Usuario';
  @override
  String get password => 'Contraseña';
  @override
  String get passwordKeepHint => 'Déjala vacía para mantener la guardada';
  @override
  String get passwordHelp =>
      'Usa un rol de solo lectura. Se guarda cifrada y no se vuelve a mostrar.';
  @override
  String get connectionUrl => 'URL de conexión';
  @override
  String get urlHelp =>
      'La contraseña de la URL se guarda cifrada y no se vuelve a mostrar.';
  @override
  String get urlHelpEditing =>
      'Si la URL no trae contraseña, se mantiene la guardada.';
  @override
  String get urlInvalid =>
      'Usa el formato postgresql://usuario:contraseña@host:5432/base';
  @override
  String get dumpFormat => 'Formato del dump';
  @override
  String get formatCustom => 'Custom (pg_dump -Fc)';
  @override
  String get formatPlain => 'SQL plano';
  @override
  String get testIdle => 'Revisa la conexión antes de guardar el source.';
  @override
  String connectedAs({required Object user}) => 'Conectado como ${user}';
  @override
  String get createButton => 'Crear source';
  @override
  String created({required Object name}) => 'Source ${name} creado';
  @override
  String saved({required Object name}) => 'Source ${name} guardado';
}

// Path: destinations
class AppMessages$destinations$es implements AppMessages$destinations$en {
  AppMessages$destinations$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Destinations';
  @override
  String description({required Object workspace}) =>
      'Donde el workspace ${workspace} escribe los backups: buckets S3.';
  @override
  String get create => 'Nuevo destination';
  @override
  String get search => 'Buscar destinations';
  @override
  String get columnName => 'Nombre';
  @override
  String get columnType => 'Tipo';
  @override
  String get columnEndpoint => 'Endpoint';
  @override
  String get columnBackups => 'Backups';
  @override
  String get columnStatus => 'Estado';
  @override
  String get bucketRoot => 'Raíz del bucket';
  @override
  String folderCount({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: '${n} carpeta',
        other: '${n} carpetas',
      );
  @override
  String showFolders({required Object name}) =>
      'Mostrar las carpetas de ${name}';
  @override
  String hideFolders({required Object name}) =>
      'Ocultar las carpetas de ${name}';
  @override
  String get emptyTitle => 'Todavía no hay destinations';
  @override
  String get emptyDescription => 'Agrega un bucket donde escribir los backups.';
  @override
  String inUse({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: 'Lo usa ${n} backup. Quítalo primero.',
        other: 'Lo usan ${n} backups. Quítalos primero.',
      );
  @override
  String deleteTitle({required Object name}) =>
      '¿Eliminar el destination ${name}?';
  @override
  String get deleteConfirm =>
      'Ningún backup lo usa. Su conexión y sus llaves guardadas se borran de este workspace. Los archivos que ya están en el bucket se quedan ahí.';
  @override
  String deleted({required Object name}) => 'Destination ${name} eliminado';
  @override
  String get noFolders =>
      'Sin carpetas · la raíz del bucket es el único punto de conexión';
  @override
  String folderUsed({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: '${n} backup',
        other: '${n} backups',
      );
  @override
  String get notUsedYet => 'Sin usar';
  @override
  String deleteFolder({required Object path}) => 'Eliminar la carpeta ${path}';
  @override
  String get folderLocked => 'La usan backups. Reconéctalos primero.';
  @override
  String get addFolder => 'Agregar carpeta';
  @override
  String get folderHint => '/nombre-carpeta';
  @override
  String get folderEmpty => 'Escribe el nombre de la carpeta';
  @override
  String get folderInvalid => 'Minúsculas, dígitos, - . _ y / entre ellos';
  @override
  String get folderRepeated => 'Esa carpeta ya existe';
  @override
  String folderAdded({required Object path}) => 'Carpeta ${path} agregada';
  @override
  String folderDeleted({required Object path}) => 'Carpeta ${path} eliminada';
  @override
  String get newTitle => 'Nuevo destination';
  @override
  String get editTitle => 'Editar destination';
  @override
  String get formDescription => 'Elige dónde se escriben los backups.';
  @override
  String get sectionType => '01 Tipo';
  @override
  String get sectionConnection => '02 Conexión';
  @override
  String get sectionFolders => '03 Carpetas';
  @override
  String get name => 'Nombre';
  @override
  String get nameHint => 'p. ej. bucket-backups';
  @override
  String copyName({required Object name}) => '${name}-copia';
  @override
  String get endpoint => 'Endpoint';
  @override
  String get endpointHelp =>
      'Cualquier URL compatible con S3. Para AWS usa https://s3.<región>.amazonaws.com.';
  @override
  String get bucket => 'Bucket';
  @override
  String get region => 'Región';
  @override
  String get accessKeyId => 'Access key ID';
  @override
  String get secretKey => 'Secret key';
  @override
  String get secretKeepHint => 'Déjala vacía para mantener la guardada';
  @override
  String get secretHelp => 'Se guarda cifrada y no se vuelve a mostrar.';
  @override
  String get pathStyle => 'Direcciones path-style';
  @override
  String get pathStyleHelp =>
      'La necesitan casi todos los servidores S3 propios.';
  @override
  String get permissions =>
      'Permisos necesarios: s3:PutObject y s3:AbortMultipartUpload.';
  @override
  String get foldersHelp =>
      'Las carpetas son opcionales. Con al menos una, cada carpeta es un punto de conexión del canvas y la raíz del bucket no. Sin carpetas, la raíz del bucket es el único punto de conexión.';
  @override
  String get testIdle =>
      'Dumpling inicia y cancela una subida multipart en cada carpeta; no queda nada en el bucket.';
  @override
  String connectedSub({required Object bucket}) =>
      '${bucket} · no quedó nada en el bucket';
  @override
  String get createButton => 'Crear destination';
  @override
  String created({required Object name}) => 'Destination ${name} creado';
  @override
  String saved({required Object name}) => 'Destination ${name} guardado';
  @override
  late final AppMessages$destinations$typeSub$es typeSub =
      AppMessages$destinations$typeSub$es._(_root);
}

// Path: canvas
class AppMessages$canvas$es implements AppMessages$canvas$en {
  AppMessages$canvas$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String description({required String workspace}) =>
      'Conecta los orígenes y destinos de ${workspace}. Nada cambia hasta que guardes.';
  @override
  String get save => 'Guardar canvas';
  @override
  String get saved => 'Canvas guardado';
  @override
  String get newConfig => 'Nueva config';
  @override
  String get removeFromCanvas => 'Quitar del canvas';
  @override
  String get allSourcesPlaced => 'Todos los orígenes están en el canvas';
  @override
  String get allDestinationsPlaced => 'Todos los destinos están en el canvas';
  @override
  String get workspaceDefault => 'Predeterminado del workspace';
  @override
  String get neverRun => 'Nunca se ha ejecutado';
  @override
  String get disabled => 'Desactivada';
  @override
  String orphans({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: '${n} config incompleta',
        other: '${n} configs incompletas',
      );
  @override
  String get orphansHelp =>
      'Solo se guardan los flujos completos (origen → config → destino). Las configs en ámbar se descartan al guardar; los orígenes y destinos se quedan.';
}

// Path: destinations.typeSub
class AppMessages$destinations$typeSub$es
    implements AppMessages$destinations$typeSub$en {
  AppMessages$destinations$typeSub$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get s3 => 'Cualquier almacenamiento compatible con S3';
  @override
  String get gdrive => 'Unidad o carpeta compartida';
  @override
  String get dropbox => 'Carpeta de la app';
  @override
  String get azure => 'Contenedor de almacenamiento';
  @override
  String get sftp => 'Cualquier servidor SSH';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on AppMessagesEs {
  dynamic _flatMapFunction(String path) {
    return switch (path) {
      'app.name' => 'Dumpling',
      'app.needMoreSpace' => 'Se necesita más espacio',
      'app.splashText' => 'Cargando tus backups…',
      'app.version' => ({required Object version}) => 'Dumpling v${version}',
      'common.loading' => 'Cargando',
      'common.error' => 'Error',
      'common.tryAgain' => 'Reintentar',
      'common.noData' => 'Sin datos',
      'common.cancel' => 'Cancelar',
      'common.close' => 'Cerrar',
      'common.required' => 'Requerido',
      'common.optional' => '(opcional)',
      'common.filters' => 'Filtros',
      'common.clearAll' => 'Limpiar todo',
      'common.done' => 'Listo',
      'common.all' => 'Todos',
      'common.selected' => 'Elegido',
      'common.soon' => 'Pronto',
      'common.edit' => 'Editar',
      'common.duplicate' => 'Duplicar',
      'common.delete' => 'Eliminar',
      'common.add' => 'Agregar',
      'common.saving' => 'Guardando…',
      'common.saveChanges' => 'Guardar cambios',
      'common.noMatches' => 'Nada coincide con tu búsqueda',
      'common.clearSearch' => 'Limpiar búsqueda y filtros',
      'common.shownOf' => ({
        required Object shown,
        required Object total,
      }) => '${shown} de ${total}',
      'common.optionsFor' => ({required Object name}) => 'Opciones de ${name}',
      'time.utc' => ({required Object time}) => '${time} UTC',
      'time.local' => ({required Object time}) => '${time} local',
      'errors.requestCancelled' => 'La petición al servidor fue cancelada',
      'errors.connectionTimeout' => 'Tiempo de conexión agotado con el servidor. Revisa tu conexión a internet',
      'errors.noConnection' =>
        'No se pudo conectar con el servidor. Revisa tu conexión a internet',
      'errors.receiveTimeout' =>
        'Tiempo de espera agotado al recibir datos del servidor',
      'errors.sendTimeout' =>
        'Tiempo de espera agotado al enviar datos al servidor',
      'errors.badCertificate' => 'Certificado inválido',
      'errors.connection' => 'Error de conexión',
      'errors.validation' => 'Error de validación',
      'errors.server' => 'Error del servidor',
      'errors.unknown' => 'Error desconocido',
      'nav.switchWorkspace' => ({
        required Object name,
      }) => '${name} · cambiar de workspace',
      'nav.workspaces' => 'Workspaces',
      'nav.backups' => 'Backups',
      'nav.canvas' => 'Editor del pipeline',
      'nav.sources' => 'Orígenes',
      'nav.destinations' => 'Destinos',
      'nav.runs' => 'Registro de ejecuciones',
      'nav.failedRuns' => ({required Object count}) => '${count} con fallos',
      'nav.settings' => 'Ajustes del workspace',
      'nav.language' => ({required Object name}) => 'Idioma: ${name}',
      'nav.logout' => 'Cerrar sesión',
      'nav.comingSoon' => 'Esta pantalla viene después.',
      'login.title' => 'Inicia sesión',
      'login.description' => 'Gestiona los backups de tus bases de datos.',
      'login.username' => 'Usuario',
      'login.usernameHint' => 'admin',
      'login.password' => 'Contraseña',
      'login.passwordHint' => 'Escribe tu contraseña',
      'login.showPassword' => 'Mostrar contraseña',
      'login.hidePassword' => 'Ocultar contraseña',
      'login.button' => 'Iniciar sesión',
      'login.signingIn' => 'Iniciando sesión…',
      'login.failedHint' => 'Revisa ambos e inténtalo de nuevo.',
      'login.envHint' =>
        'El usuario y la contraseña se definen en el servidor con',
      'login.envHintAnd' => 'y',
      'colors.none' => 'Sin color',
      'colors.custom' => 'Color personalizado',
      'colors.apply' => 'Aplicar',
      'colors.saturationBrightness' => 'Saturación y brillo',
      'colors.hue' => 'Tono',
      'colors.contrast' => ({
        required Object ratio,
      }) => 'Inicial blanca sobre este color: ${ratio}:1',
      'colors.contrastLow' => ({
        required Object ratio,
      }) => 'Poco contraste con la inicial blanca (${ratio}:1). Costará leerla.',
      'colors.hexInvalid' =>
        'Escribe un color HEX de 6 dígitos, por ejemplo #0E7490',
      'colors.violet' => 'Violeta',
      'colors.blue' => 'Azul',
      'colors.teal' => 'Verde azulado',
      'colors.green' => 'Verde',
      'colors.amber' => 'Ámbar',
      'colors.red' => 'Rojo',
      'colors.pink' => 'Rosa',
      'colors.slate' => 'Pizarra',
      'workspaces.title' => 'Workspaces',
      'workspaces.description' => 'Cada workspace es independiente: su propio canvas, orígenes, destinos y backups.',
      'workspaces.create' => 'Nuevo workspace',
      'workspaces.createHint' =>
        'Un canvas nuevo para otro entorno, cliente o proyecto.',
      'workspaces.current' => 'Actual',
      'workspaces.sources' => 'Orígenes',
      'workspaces.destinations' => 'Destinos',
      'workspaces.backups' => 'Backups',
      'workspaces.noBackups' => 'Todavía sin backups',
      'workspaces.healthy' => 'Todo en orden',
      'workspaces.failing' => ({
        required Object count,
      }) => '${count} con fallos',
      'workspaces.running' => 'Ejecutándose ahora',
      'workspaces.lastRun' => ({
        required Object time,
      }) => 'Última ejecución ${time}',
      'workspaces.noRuns' => 'Todavía sin ejecuciones',
      'workspaces.openCanvas' => 'Abrir canvas',
      'workspaces.switchAndOpen' => 'Cambiar y abrir canvas',
      'workspaces.moreOptions' => ({
        required Object name,
      }) => 'Más opciones de ${name}',
      'workspaces.formTitle' => 'Nuevo workspace',
      'workspaces.formDescription' => 'Los workspaces no comparten nada: cada uno tiene su propio canvas, conexiones, backups e historial de ejecuciones.',
      'workspaces.name' => 'Nombre',
      'workspaces.nameHint' => 'p. ej. Staging',
      'workspaces.descriptionLabel' => 'Descripción',
      'workspaces.descriptionHint' => 'Para qué es este workspace',
      'workspaces.color' => 'Color',
      'workspaces.emptyCanvas' =>
        'Un workspace nuevo empieza con el canvas vacío.',
      'workspaces.createButton' => 'Crear workspace',
      'workspaces.creating' => 'Creando…',
      'workspaces.created' => ({
        required Object name,
      }) => 'Workspace ${name} creado',
      'connections.notTested' => 'Sin probar',
      'connections.notTestedYet' => 'Todavía sin probar',
      'connections.testing' => 'Probando…',
      'connections.test' => 'Probar conexión',
      'connections.connected' => 'Conectado',
      'connections.incompatible' => 'Incompatible',
      'connections.incompatibleTitle' =>
        'Conectó, pero el servidor es más nuevo que la herramienta de dump',
      'connections.incompatibleSub' => ({
        required Object server,
        required Object tool,
      }) => 'Servidor ${server} · ${tool}. Actualiza la herramienta de dump donde corre Dumpling.',
      'connections.toolMissing' => 'Falta la herramienta',
      'connections.toolMissingTitle' => 'Conectó, pero la herramienta de dump no está instalada donde corre Dumpling',
      'connections.unreachable' => 'Sin conexión',
      'connections.failedTitle' => 'No se pudo conectar',
      'sources.title' => 'Sources',
      'sources.description' => ({
        required Object workspace,
      }) => 'Lo que respalda el workspace ${workspace}: bases de datos PostgreSQL.',
      'sources.create' => 'Nuevo source',
      'sources.search' => 'Buscar sources',
      'sources.columnName' => 'Nombre',
      'sources.columnType' => 'Tipo',
      'sources.columnHost' => 'Host',
      'sources.columnBackups' => 'Backups',
      'sources.columnStatus' => 'Estado',
      'sources.emptyTitle' => 'Todavía no hay sources',
      'sources.emptyDescription' =>
        'Conecta una base de datos para respaldarla.',
      'sources.inUse' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
              n,
              one: 'Lo usa ${n} backup. Quítalo primero.',
              other: 'Lo usan ${n} backups. Quítalos primero.',
            ),
      'sources.deleteTitle' => ({
        required Object name,
      }) => '¿Eliminar el source ${name}?',
      'sources.deleteConfirm' => 'Ningún backup lo usa. Su conexión y su contraseña guardadas se borran de este workspace.',
      'sources.deleted' => ({
        required Object name,
      }) => 'Source ${name} eliminado',
      'sources.newTitle' => 'Nuevo source',
      'sources.editTitle' => 'Editar source',
      'sources.formDescription' => 'Conecta lo que quieres respaldar.',
      'sources.sectionType' => '01 Tipo',
      'sources.sectionConnection' => '02 Conexión',
      'sources.name' => 'Nombre',
      'sources.nameHint' => 'p. ej. orders-db',
      'sources.copyName' => ({required Object name}) => '${name}-copia',
      'sources.connectWith' => 'Conectar con',
      'sources.byFields' => 'Campos',
      'sources.byUrl' => 'URL de conexión',
      'sources.host' => 'Host',
      'sources.port' => 'Puerto',
      'sources.portInvalid' => 'De 1 a 65535',
      'sources.database' => 'Base de datos',
      'sources.username' => 'Usuario',
      'sources.password' => 'Contraseña',
      'sources.passwordKeepHint' => 'Déjala vacía para mantener la guardada',
      'sources.passwordHelp' => 'Usa un rol de solo lectura. Se guarda cifrada y no se vuelve a mostrar.',
      'sources.connectionUrl' => 'URL de conexión',
      'sources.urlHelp' =>
        'La contraseña de la URL se guarda cifrada y no se vuelve a mostrar.',
      'sources.urlHelpEditing' =>
        'Si la URL no trae contraseña, se mantiene la guardada.',
      'sources.urlInvalid' =>
        'Usa el formato postgresql://usuario:contraseña@host:5432/base',
      'sources.dumpFormat' => 'Formato del dump',
      'sources.formatCustom' => 'Custom (pg_dump -Fc)',
      'sources.formatPlain' => 'SQL plano',
      'sources.testIdle' => 'Revisa la conexión antes de guardar el source.',
      'sources.connectedAs' => ({
        required Object user,
      }) => 'Conectado como ${user}',
      'sources.createButton' => 'Crear source',
      'sources.created' => ({required Object name}) => 'Source ${name} creado',
      'sources.saved' => ({required Object name}) => 'Source ${name} guardado',
      'destinations.title' => 'Destinations',
      'destinations.description' => ({
        required Object workspace,
      }) => 'Donde el workspace ${workspace} escribe los backups: buckets S3.',
      'destinations.create' => 'Nuevo destination',
      'destinations.search' => 'Buscar destinations',
      'destinations.columnName' => 'Nombre',
      'destinations.columnType' => 'Tipo',
      'destinations.columnEndpoint' => 'Endpoint',
      'destinations.columnBackups' => 'Backups',
      'destinations.columnStatus' => 'Estado',
      'destinations.bucketRoot' => 'Raíz del bucket',
      'destinations.folderCount' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
              n,
              one: '${n} carpeta',
              other: '${n} carpetas',
            ),
      'destinations.showFolders' => ({
        required Object name,
      }) => 'Mostrar las carpetas de ${name}',
      'destinations.hideFolders' => ({
        required Object name,
      }) => 'Ocultar las carpetas de ${name}',
      'destinations.emptyTitle' => 'Todavía no hay destinations',
      'destinations.emptyDescription' =>
        'Agrega un bucket donde escribir los backups.',
      'destinations.inUse' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
              n,
              one: 'Lo usa ${n} backup. Quítalo primero.',
              other: 'Lo usan ${n} backups. Quítalos primero.',
            ),
      'destinations.deleteTitle' => ({
        required Object name,
      }) => '¿Eliminar el destination ${name}?',
      'destinations.deleteConfirm' => 'Ningún backup lo usa. Su conexión y sus llaves guardadas se borran de este workspace. Los archivos que ya están en el bucket se quedan ahí.',
      'destinations.deleted' => ({
        required Object name,
      }) => 'Destination ${name} eliminado',
      'destinations.noFolders' =>
        'Sin carpetas · la raíz del bucket es el único punto de conexión',
      'destinations.folderUsed' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
              n,
              one: '${n} backup',
              other: '${n} backups',
            ),
      'destinations.notUsedYet' => 'Sin usar',
      'destinations.deleteFolder' => ({
        required Object path,
      }) => 'Eliminar la carpeta ${path}',
      'destinations.folderLocked' => 'La usan backups. Reconéctalos primero.',
      'destinations.addFolder' => 'Agregar carpeta',
      'destinations.folderHint' => '/nombre-carpeta',
      'destinations.folderEmpty' => 'Escribe el nombre de la carpeta',
      'destinations.folderInvalid' =>
        'Minúsculas, dígitos, - . _ y / entre ellos',
      'destinations.folderRepeated' => 'Esa carpeta ya existe',
      'destinations.folderAdded' => ({
        required Object path,
      }) => 'Carpeta ${path} agregada',
      'destinations.folderDeleted' => ({
        required Object path,
      }) => 'Carpeta ${path} eliminada',
      'destinations.newTitle' => 'Nuevo destination',
      'destinations.editTitle' => 'Editar destination',
      'destinations.formDescription' => 'Elige dónde se escriben los backups.',
      'destinations.sectionType' => '01 Tipo',
      'destinations.sectionConnection' => '02 Conexión',
      'destinations.sectionFolders' => '03 Carpetas',
      'destinations.name' => 'Nombre',
      'destinations.nameHint' => 'p. ej. bucket-backups',
      'destinations.copyName' => ({required Object name}) => '${name}-copia',
      'destinations.endpoint' => 'Endpoint',
      'destinations.endpointHelp' => 'Cualquier URL compatible con S3. Para AWS usa https://s3.<región>.amazonaws.com.',
      'destinations.bucket' => 'Bucket',
      'destinations.region' => 'Región',
      'destinations.accessKeyId' => 'Access key ID',
      'destinations.secretKey' => 'Secret key',
      'destinations.secretKeepHint' => 'Déjala vacía para mantener la guardada',
      'destinations.secretHelp' =>
        'Se guarda cifrada y no se vuelve a mostrar.',
      'destinations.pathStyle' => 'Direcciones path-style',
      'destinations.pathStyleHelp' =>
        'La necesitan casi todos los servidores S3 propios.',
      'destinations.permissions' =>
        'Permisos necesarios: s3:PutObject y s3:AbortMultipartUpload.',
      'destinations.foldersHelp' => 'Las carpetas son opcionales. Con al menos una, cada carpeta es un punto de conexión del canvas y la raíz del bucket no. Sin carpetas, la raíz del bucket es el único punto de conexión.',
      'destinations.testIdle' => 'Dumpling inicia y cancela una subida multipart en cada carpeta; no queda nada en el bucket.',
      'destinations.connectedSub' => ({
        required Object bucket,
      }) => '${bucket} · no quedó nada en el bucket',
      'destinations.createButton' => 'Crear destination',
      'destinations.created' => ({
        required Object name,
      }) => 'Destination ${name} creado',
      'destinations.saved' => ({
        required Object name,
      }) => 'Destination ${name} guardado',
      'destinations.typeSub.s3' => 'Cualquier almacenamiento compatible con S3',
      'destinations.typeSub.gdrive' => 'Unidad o carpeta compartida',
      'destinations.typeSub.dropbox' => 'Carpeta de la app',
      'destinations.typeSub.azure' => 'Contenedor de almacenamiento',
      'destinations.typeSub.sftp' => 'Cualquier servidor SSH',
      'canvas.description' => ({
        required String workspace,
      }) => 'Conecta los orígenes y destinos de ${workspace}. Nada cambia hasta que guardes.',
      'canvas.save' => 'Guardar canvas',
      'canvas.saved' => 'Canvas guardado',
      'canvas.newConfig' => 'Nueva config',
      'canvas.removeFromCanvas' => 'Quitar del canvas',
      'canvas.allSourcesPlaced' => 'Todos los orígenes están en el canvas',
      'canvas.allDestinationsPlaced' => 'Todos los destinos están en el canvas',
      'canvas.workspaceDefault' => 'Predeterminado del workspace',
      'canvas.neverRun' => 'Nunca se ha ejecutado',
      'canvas.disabled' => 'Desactivada',
      'canvas.orphans' =>
        ({required num n}) =>
            (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
              n,
              one: '${n} config incompleta',
              other: '${n} configs incompletas',
            ),
      'canvas.orphansHelp' => 'Solo se guardan los flujos completos (origen → config → destino). Las configs en ámbar se descartan al guardar; los orígenes y destinos se quedan.',
      _ => null,
    };
  }
}
