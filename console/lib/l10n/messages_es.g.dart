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
  @override
  late final AppMessages$runs$es runs = AppMessages$runs$es._(_root);
  @override
  late final AppMessages$backups$es backups = AppMessages$backups$es._(_root);
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
  String get longName =>
      'Los nombres largos se cortan en el canvas: uno más corto se lee mejor.';
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
  @override
  String get viewDetails => 'Ver detalle';
  @override
  String get refresh => 'Actualizar';
  @override
  String get listView => 'Lista';
  @override
  String get gridView => 'Cuadrícula';
  @override
  String get back => 'Atrás';
  @override
  String get next => 'Siguiente';
  @override
  String stepOf({required Object n, required Object total}) =>
      'Paso ${n} de ${total}';
  @override
  String backupCount({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        one: '${n} backup',
        other: '${n} backups',
      );
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
  @override
  String get notFoundTitle => 'No encontrado';
  @override
  String get pageNotFound => 'Esta página no existe.';
  @override
  String get offlineTitle => 'Conexión perdida';
  @override
  String offline({required String url}) =>
      'No se puede conectar con el servicio de Dumpling en ${url}. Revisa que esté corriendo e inténtalo de nuevo.';
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
  String language({required Object name}) => 'Idioma: ${name}';
  @override
  String get logout => 'Cerrar sesión';
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
  String get usernameHint => 'Escribe tu usuario';
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
  @override
  String get tagline => 'Respaldos';
  @override
  String get taglineAccent => 'sin esfuerzo';
  @override
  String get tagLightweight => 'Ligero';
  @override
  String get tagCanvas => 'Canvas drag & drop';
  @override
  String get tagWinter => 'Hecho con Winter';
  @override
  String get expiredTitle => 'Tu sesión expiró';
  @override
  String get expiredDescription =>
      'Tu sesión terminó tras 12 horas. Inicia sesión de nuevo para seguir donde lo dejaste.';
  @override
  String get toSignInPage => 'Ir a la página de inicio de sesión';
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
  @override
  String settingsOf({required Object name}) => 'Ajustes de ${name}';
  @override
  late final AppMessages$workspaces$settings$es settings =
      AppMessages$workspaces$settings$es._(_root);
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
  @override
  String get lastCheck => 'Última prueba';
  @override
  String get checkTitle => 'Prueba de conexión';
  @override
  String get checkNote => 'Antes de cada ejecución y al probarla';
  @override
  String get connection => 'Conexión';
  @override
  String get editConnection => 'Editar conexión';
}

// Path: sources
class AppMessages$sources$es implements AppMessages$sources$en {
  AppMessages$sources$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Sources';
  @override
  String get description =>
      'Lo que respalda este workspace: bases de datos PostgreSQL.';
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
  String get stepType => 'Tipo';
  @override
  String get stepConnection => 'Conexión';
  @override
  String get stepCheck => 'Revisar y guardar';
  @override
  String get typeTitle => '¿Qué quieres respaldar?';
  @override
  String get connectionTitle => '¿Cómo se conecta Dumpling?';
  @override
  String get checkTitle => 'Revisa y guarda';
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
  @override
  String detailDescription({required Object type}) =>
      'Una base de datos ${type} que este workspace respalda.';
  @override
  String get statBackups => 'Backups';
  @override
  String statDestinations({required num n}) =>
      (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(
        n,
        zero: 'ninguno aún',
        one: 'en ${n} destination',
        other: 'en ${n} destinations',
      );
  @override
  String get statLastBackup => 'Último backup';
  @override
  String get sectionUses => 'Backups de este source';
  @override
  String get openEditor => 'Abrir editor';
  @override
  String get noUses =>
      'Ningún backup lo usa todavía. Conéctalo a un destination en el editor de pipelines.';
  @override
  String get columnBackup => 'Backup';
  @override
  String get columnSchedule => 'Horario';
  @override
  String get columnLastRun => 'Última ejecución';
  @override
  String get columnNextRun => 'Siguiente';
  @override
  String get cronUtc => 'cron · UTC';
  @override
  String get paused => 'En pausa';
  @override
  String get neverRun => 'Aún no se ejecuta';
  @override
  String get passwordStored => '•••••••• · guardada cifrada';
}

// Path: destinations
class AppMessages$destinations$es implements AppMessages$destinations$en {
  AppMessages$destinations$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Destinations';
  @override
  String get description =>
      'Donde este workspace escribe los backups: buckets S3.';
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
  String get stepType => 'Tipo';
  @override
  String get stepConnection => 'Conexión';
  @override
  String get stepFolders => 'Carpetas y prueba';
  @override
  String get typeTitle => '¿A dónde van los backups?';
  @override
  String get connectionTitle => '¿Cómo se conecta Dumpling?';
  @override
  String get foldersTitle => 'Carpetas y prueba de conexión';
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
  String get detailDescription =>
      'Un bucket donde este workspace escribe backups.';
  @override
  String get statBackups => 'Backups';
  @override
  String get statBackupsSub => 'escriben aquí';
  @override
  String get statFolders => 'Carpetas';
  @override
  String get statFoldersSub => 'puntos de conexión';
  @override
  String get sectionFolders => 'Carpetas';
  @override
  String get columnFolder => 'Carpeta';
  @override
  String get columnWrittenBy => 'Lo escribe';
  @override
  String get accessKey => 'Access key';
  @override
  String get on => 'Sí';
  @override
  String get off => 'No';
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
  String get description =>
      'Conecta orígenes con destinos para armar los respaldos de este workspace.';
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
  @override
  String get semantics =>
      'Canvas. Mantén Espacio y arrastra para moverlo; clic derecho para opciones; las flechas lo mueven; Ctrl y la rueda hacen zoom; F lo centra; haz clic en una conexión y pulsa Supr para quitarla; Escape cierra la config';
  @override
  String get addSource => 'Origen';
  @override
  String get addDestination => 'Destino';
  @override
  String get deleteConfig => 'Eliminar config';
  @override
  String get editConfig => 'Editar config';
  @override
  String get removeConnection => 'Quitar conexión';
  @override
  String get removeConnectionKey => 'Quitar conexión (Supr)';
  @override
  String get configHere => 'La config se crea aquí';
  @override
  String get releaseToCreate => 'Suelta para crear la config';
  @override
  String get dragToDestination => 'Arrastra hasta un destino';
  @override
  String get last => 'Última';
  @override
  String get next => 'Próxima';
  @override
  late final AppMessages$canvas$runStatus$es runStatus =
      AppMessages$canvas$runStatus$es._(_root);
  @override
  late final AppMessages$canvas$frequency$es frequency =
      AppMessages$canvas$frequency$es._(_root);
  @override
  String get addFolder => '+ Agregar carpeta';
  @override
  String addFolderTitle({required String name}) =>
      'Agregar una carpeta a ${name}';
  @override
  String get addFolderDescription =>
      'Cada carpeta es un punto de conexión. Se crea en el bucket al guardar el canvas.';
  @override
  String get addFolderRoot =>
      'Con la primera carpeta, la raíz del bucket deja de ser un punto de conexión: las configs que escriben ahí se desconectan.';
  @override
  late final AppMessages$canvas$keys$es keys = AppMessages$canvas$keys$es._(
    _root,
  );
  @override
  late final AppMessages$canvas$shortcuts$es shortcuts =
      AppMessages$canvas$shortcuts$es._(_root);
  @override
  late final AppMessages$canvas$view$es view = AppMessages$canvas$view$es._(
    _root,
  );
  @override
  late final AppMessages$canvas$inspector$es inspector =
      AppMessages$canvas$inspector$es._(_root);
  @override
  late final AppMessages$canvas$columns$es columns =
      AppMessages$canvas$columns$es._(_root);
  @override
  String get folder => 'Carpeta';
  @override
  late final AppMessages$canvas$testRun$es testRun =
      AppMessages$canvas$testRun$es._(_root);
  @override
  late final AppMessages$canvas$run$es run = AppMessages$canvas$run$es._(_root);
  @override
  late final AppMessages$canvas$guide$es guide = AppMessages$canvas$guide$es._(
    _root,
  );
}

// Path: runs
class AppMessages$runs$es implements AppMessages$runs$en {
  AppMessages$runs$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Registro de ejecuciones';
  @override
  String get description =>
      'Cada ejecución de respaldo de este workspace, programada o manual. Horas en UTC, tu hora local debajo.';
  @override
  String get search => 'Buscar por respaldo, origen o destino';
  @override
  String get columnStatus => 'Estado';
  @override
  String get columnSource => 'Origen';
  @override
  String get columnDestination => 'Destino';
  @override
  String get columnStarted => 'Inicio';
  @override
  String get columnDuration => 'Duración';
  @override
  String get columnSize => 'Tamaño';
  @override
  String get scheduled => 'Programada';
  @override
  String get manual => 'Manual';
  @override
  String get emptyTitle => 'Aún no hay ejecuciones';
  @override
  String get emptyDescription =>
      'Los respaldos se ejecutan según su programación, o con Ejecutar ahora en el editor.';
  @override
  String get newestOnly =>
      'Solo se muestran las 200 ejecuciones más recientes.';
  @override
  String get log => 'Log (UTC)';
  @override
  String get copyLog => 'Copiar log';
  @override
  String get logCopied => 'Log copiado';
  @override
  String get logWhenDone =>
      'El log se escribe cuando termina la ejecución. Actualiza para verlo.';
  @override
  String get noLog => 'Esta ejecución no tiene log.';
  @override
  String today({required String date}) => 'Hoy · ${date} (UTC)';
  @override
  String yesterday({required String date}) => 'Ayer · ${date} (UTC)';
  @override
  String day({required String date}) => '${date} (UTC)';
  @override
  String succeeded({required int n}) => '${n} correctas';
  @override
  String failedCount({required int n}) => '${n} fallidas';
  @override
  String savedIn({required String size, required String duration}) =>
      '${size} en ${duration}';
  @override
  String get inProgress => 'En curso';
  @override
  String soFar({required String size}) => 'En curso · ${size} hasta ahora';
  @override
  String get columnTrigger => 'Tipo';
  @override
  String get viewRun => 'Ver ejecución';
  @override
  String get steps => 'Pasos';
  @override
  String stepConnect({required String name}) => 'Conectar con ${name}';
  @override
  String stepDump({required String name}) => 'Volcar y subir a ${name}';
  @override
  String get stepSkipped => 'Omitido';
  @override
  String get stepWaiting => 'En espera';
  @override
  String get resultSuccess => 'Respaldo guardado';
  @override
  String get resultFailed => 'El respaldo falló';
  @override
  String get resultRunning => 'En curso. Actualiza para ver cuánto avanzó.';
}

// Path: backups
class AppMessages$backups$es implements AppMessages$backups$en {
  AppMessages$backups$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Respaldos';
  @override
  String get description =>
      'Cada respaldo de este workspace, su última ejecución y la siguiente.';
  @override
  String get openEditor => 'Abrir editor';
  @override
  String get newBackup => 'Nuevo respaldo';
  @override
  String get healthy => 'Correctos';
  @override
  String get healthySub => 'la última ejecución salió bien';
  @override
  String get failing => 'Con fallas';
  @override
  String get failingSub => 'requieren atención';
  @override
  String get paused => 'Pausado';
  @override
  String get nextBackup => 'Próximo respaldo';
  @override
  String get nextBackupIn => 'Próximo respaldo en';
  @override
  String get nothingScheduled => 'Nada programado';
  @override
  String get search => 'Buscar respaldos';
  @override
  String get columnStatus => 'Estado';
  @override
  String get columnSource => 'Origen';
  @override
  String get columnDestination => 'Destino';
  @override
  String get columnSchedule => 'Programación';
  @override
  String get columnLastRun => 'Último respaldo';
  @override
  String get columnNextRun => 'Próximo respaldo';
  @override
  String get allSources => 'Todos los orígenes';
  @override
  String get allDestinations => 'Todos los destinos';
  @override
  String shown({required Object shown, required Object total}) =>
      '${shown} de ${total} respaldos';
  @override
  String showing({required Object shown, required Object total}) =>
      'Mostrando ${shown} de ${total} respaldos';
  @override
  String timesNote({required Object utc, required Object local}) =>
      'Horas en UTC · ahora ${utc} (${local})';
  @override
  String get sort => 'Orden:';
  @override
  String get sortBy => 'Ordenar por';
  @override
  String get sortLast => 'Último respaldo';
  @override
  String get sortLastSub => 'El más reciente primero';
  @override
  String get sortLastOld => 'Último respaldo (antiguo)';
  @override
  String get sortLastOldSub => 'El más antiguo primero';
  @override
  String get sortNext => 'Próximo respaldo';
  @override
  String get sortNextSub => 'El más cercano primero';
  @override
  String get sortName => 'Nombre del origen';
  @override
  String get sortNameSub => 'De la A a la Z';
  @override
  String inTime({required Object time}) => 'en ${time}';
  @override
  String startedAgo({required Object time}) => 'Empezó hace ${time}';
  @override
  String runNowFor({required Object name}) => 'Ejecutar ${name} ahora';
  @override
  String get showRuns => 'Ver las ejecuciones';
  @override
  String get hideRuns => 'Ocultar las ejecuciones';
  @override
  String moreFor({required Object name}) => 'Más acciones de ${name}';
  @override
  String get viewLastRun => 'Ver la última ejecución';
  @override
  String get editConfig => 'Editar config';
  @override
  String get deleteBackup => 'Eliminar respaldo';
  @override
  String get recentRuns => 'Ejecuciones recientes';
  @override
  String get noRuns => 'Aún no hay ejecuciones';
  @override
  String get viewLog => 'Ver log';
  @override
  String get viewDetails => 'Ver detalle';
  @override
  String get noFile => 'No se escribió archivo';
  @override
  String get uploading => 'Subiendo…';
  @override
  String get manual => 'Manual';
  @override
  String get scheduled => 'Programada';
  @override
  String deleteTitle({required Object name}) =>
      '¿Eliminar el respaldo ${name}?';
  @override
  String get deleteConfirm =>
      'Su programación se detiene. Sus ejecuciones quedan en el registro y los archivos que ya están en el destino se quedan ahí.';
  @override
  String deleted({required Object name}) => 'Respaldo ${name} eliminado';
  @override
  String saved({required Object name}) => 'Respaldo ${name} guardado';
  @override
  String get emptyDescription =>
      'Conecta un origen con un destino en el editor para crear uno.';
}

// Path: workspaces.settings
class AppMessages$workspaces$settings$es
    implements AppMessages$workspaces$settings$en {
  AppMessages$workspaces$settings$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Ajustes del workspace';
  @override
  String get description => 'Aplica solo a este workspace';
  @override
  String get general => 'General';
  @override
  String get defaults => 'Valores por defecto de los configs nuevos';
  @override
  String get danger => 'Zona de peligro';
  @override
  String get created => 'Creado';
  @override
  String get id => 'ID del workspace';
  @override
  String get copyId => 'Copiar el ID del workspace';
  @override
  String get copied => 'Copiado';
  @override
  String get noDescription => 'Sin descripción';
  @override
  String get defaultsHint =>
      'Una conexión nueva en el canvas empieza con estos valores. Cada config puede cambiarlos.';
  @override
  String get schedule => 'Programación';
  @override
  String get cron => 'Cron';
  @override
  String get cronHelp => 'Siempre en UTC.';
  @override
  String get compression => 'Compresión';
  @override
  String get compressionNone => 'Ninguna';
  @override
  String get objectKey => 'Object key';
  @override
  String get objectKeyHelp =>
      'Relativa a la carpeta donde escribe cada config, sin extensión.';
  @override
  String get unsaved => 'Tienes cambios sin guardar';
  @override
  String get discard => 'Descartar';
  @override
  String get saved => 'Guardado';
  @override
  String get deleteTitle => 'Eliminar este workspace';
  @override
  String get deleteDescription =>
      'Elimina su canvas, orígenes, destinos, configs e historial de ejecuciones. Los archivos de backup que ya están en tus buckets se quedan donde están.';
  @override
  String get deleteButton => 'Eliminar workspace';
  @override
  String deleteConfirmTitle({required Object name}) => '¿Eliminar «${name}»?';
  @override
  String deleteConfirm({
    required Object sources,
    required Object destinations,
    required Object configs,
  }) =>
      'Se eliminan sus orígenes (${sources}), destinos (${destinations}), configs (${configs}) y su historial de ejecuciones. Los backups programados se detienen al momento. No se puede deshacer.';
  @override
  String get typeBefore => 'Escribe';
  @override
  String get typeAfter => 'para confirmar';
  @override
  String deleted({required Object name}) => 'Workspace ${name} eliminado';
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

// Path: canvas.runStatus
class AppMessages$canvas$runStatus$es
    implements AppMessages$canvas$runStatus$en {
  AppMessages$canvas$runStatus$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get success => 'Correcta';
  @override
  String get failed => 'Fallida';
  @override
  String get running => 'En curso';
}

// Path: canvas.frequency
class AppMessages$canvas$frequency$es
    implements AppMessages$canvas$frequency$en {
  AppMessages$canvas$frequency$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get hourly => 'Cada hora';
  @override
  String get daily => 'Diaria';
  @override
  String get weekly => 'Semanal';
  @override
  String get cron => 'Cron';
}

// Path: canvas.keys
class AppMessages$canvas$keys$es implements AppMessages$canvas$keys$en {
  AppMessages$canvas$keys$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get space => 'Espacio';
  @override
  String get del => 'Supr';
  @override
  String get ctrl => 'Ctrl';
  @override
  String get esc => 'Esc';
}

// Path: canvas.shortcuts
class AppMessages$canvas$shortcuts$es
    implements AppMessages$canvas$shortcuts$en {
  AppMessages$canvas$shortcuts$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Atajos';
  @override
  String get hide => 'Ocultar atajos';
  @override
  String get moveCanvas => 'Mover el canvas';
  @override
  String get drag => ' + arrastrar';
  @override
  String get connect => 'Conectar';
  @override
  String get dragFromPort => 'arrastra desde un puerto';
  @override
  String get options => 'Opciones';
  @override
  String get rightClick => 'clic derecho';
  @override
  String get clickIt => 'clic en ella + ';
  @override
  String get zoom => 'Zoom';
  @override
  String get scroll => 'rueda';
  @override
  String get zoomInOut => 'Acercar / alejar';
  @override
  String get center => 'Centrar el canvas';
  @override
  String get reset => 'Volver a 100%';
  @override
  String get moveWithKeys => 'Mover con teclas';
  @override
  String get closeConfig => 'Cerrar la config';
  @override
  String get toggle => 'Mostrar / ocultar atajos';
}

// Path: canvas.view
class AppMessages$canvas$view$es implements AppMessages$canvas$view$en {
  AppMessages$canvas$view$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get settings => 'Ajustes del canvas';
  @override
  String get toggleShortcuts => 'Mostrar u ocultar atajos (?)';
  @override
  String get center => 'Centrar';
  @override
  String get centerTooltip => 'Centrar el canvas (F)';
  @override
  String get zoomOut => 'Alejar (−)';
  @override
  String get reset => 'Volver a 100% (0)';
  @override
  String get zoomIn => 'Acercar (+)';
  @override
  String get settingsTitle => 'Canvas';
  @override
  String get ctrlZoom => 'Mantén Ctrl para hacer zoom';
  @override
  String get ctrlZoomOn => 'La rueda mueve el canvas, Ctrl + rueda hace zoom';
  @override
  String get ctrlZoomOff => 'La rueda siempre hace zoom';
}

// Path: canvas.inspector
class AppMessages$canvas$inspector$es
    implements AppMessages$canvas$inspector$en {
  AppMessages$canvas$inspector$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get configName => 'Nombre de la config';
  @override
  String get doubleCompression =>
      'El formato custom (pg_dump -Fc) ya va comprimido: gzip apenas lo reduce.';
  @override
  String get nameHelp =>
      'Se muestra en el canvas, en Respaldos y en el registro de ejecuciones.';
  @override
  String get frequency => 'Frecuencia';
  @override
  String get review => 'Revisión';
  @override
  String get source => 'Origen';
  @override
  String get destination => 'Destino';
  @override
  String get nextRunOnSave => 'Se calcula al guardar';
  @override
  String get cronHelp =>
      'minuto hora día mes día-de-la-semana, en UTC. Cada hora, diaria y semanal lo escriben por ti.';
  @override
  String get cronInvalid =>
      'No es una expresión cron válida (minuto hora día mes día-de-la-semana)';
  @override
  String get enabled => 'Activa';
  @override
  String get enabledOn => 'Se ejecuta según su programación';
  @override
  String get enabledOff => 'Desactivada: solo se ejecuta con Ejecutar ahora';
  @override
  String get compressionNone => 'Ninguna';
  @override
  String get objectKeySlash => 'El object key no puede empezar con /';
  @override
  String get objectKeyExtension =>
      'Omite la extensión: se agrega según el formato del dump y la compresión';
  @override
  String get schedule => 'Nombre y programación';
  @override
  String get cron => 'Cron';
  @override
  String get timeZone => 'Zona horaria';
  @override
  String get nextRun => 'Próxima ejecución';
  @override
  String get output => 'Salida';
  @override
  String get objectKey => 'Object key';
  @override
  String get connectDestination =>
      'Conecta un destino para elegir dónde se guarda.';
  @override
  String relativeToFolder({required String folder}) =>
      'Relativa a la carpeta ${folder}. La extensión se agrega según el formato del dump y la compresión.';
  @override
  String relativeToRoot({required String bucket}) =>
      'Relativa a la raíz de ${bucket}. La extensión se agrega según el formato del dump y la compresión.';
  @override
  String get compression => 'Compresión';
  @override
  String get writes => 'La próxima ejecución escribe';
  @override
  String get missingSource => 'Nada: conecta un origen.';
  @override
  String get missingDestination => 'Nada: conecta un destino.';
  @override
  String get missingBoth => 'Nada: conecta un origen y un destino.';
  @override
  String get noSource => 'sin origen';
  @override
  String get noDestination => 'sin destino';
}

// Path: canvas.columns
class AppMessages$canvas$columns$es implements AppMessages$canvas$columns$en {
  AppMessages$canvas$columns$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get sources => 'Orígenes';
  @override
  String get configs => 'Config · una por conexión';
  @override
  String get destinations => 'Destinos';
}

// Path: canvas.testRun
class AppMessages$canvas$testRun$es implements AppMessages$canvas$testRun$en {
  AppMessages$canvas$testRun$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get button => 'Probar';
  @override
  String get help =>
      'Comprueba que cada flujo completo podría ejecutarse, sin hacer backups: cada origen conecta y pg_dump puede respaldarlo, cada destino acepta escrituras en sus carpetas.';
  @override
  String ok({required int n}) => 'Todo funciona: ${n} comprobaciones correctas';
  @override
  String failed({required String list}) =>
      'Fallaron algunas comprobaciones: ${list}';
  @override
  String get nothing =>
      'Nada que probar: primero conecta un origen a un destino.';
}

// Path: canvas.run
class AppMessages$canvas$run$es implements AppMessages$canvas$run$en {
  AppMessages$canvas$run$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get button => 'Ejecutar ahora';
  @override
  String get help =>
      'Ejecuta este backup ahora, de verdad, tal como está guardado: los cambios sin guardar no se usan.';
  @override
  String get needsSave =>
      'Guarda el canvas primero: una ejecución usa la config guardada.';
  @override
  String done({required String name, required String size}) =>
      'Backup ${name} terminado: ${size}';
  @override
  String failed({required String name, required String error}) =>
      'Backup ${name} falló: ${error}';
}

// Path: canvas.guide
class AppMessages$canvas$guide$es implements AppMessages$canvas$guide$en {
  AppMessages$canvas$guide$es._(this._root);

  final AppMessagesEs _root; // ignore: unused_field

  // Translations
  @override
  String get title => 'Tu primer backup';
  @override
  String get source => 'Agrega un origen';
  @override
  String get sourceHelp => 'La base de datos a respaldar.';
  @override
  String get destination => 'Agrega un destino';
  @override
  String get destinationHelp => 'El bucket donde van los backups.';
  @override
  String get connect => 'Conéctalos';
  @override
  String get connectHelp =>
      'Arrastra desde el puerto del origen hasta una carpeta o el bucket: se crea una config entre ellos. Luego guarda.';
  @override
  String get create => 'Crear uno';
  @override
  String place({required String name}) => 'Colocar ${name}';
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
          'app.version' => ({
            required Object version,
          }) => 'Dumpling v${version}',
          'common.longName' => 'Los nombres largos se cortan en el canvas: uno más corto se lee mejor.',
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
          'common.optionsFor' => ({
            required Object name,
          }) => 'Opciones de ${name}',
          'common.viewDetails' => 'Ver detalle',
          'common.refresh' => 'Actualizar',
          'common.listView' => 'Lista',
          'common.gridView' => 'Cuadrícula',
          'common.back' => 'Atrás',
          'common.next' => 'Siguiente',
          'common.stepOf' => ({
            required Object n,
            required Object total,
          }) => 'Paso ${n} de ${total}',
          'common.backupCount' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
                  n,
                  one: '${n} backup',
                  other: '${n} backups',
                ),
          'time.utc' => ({required Object time}) => '${time} UTC',
          'time.local' => ({required Object time}) => '${time} local',
          'errors.requestCancelled' => 'La petición al servidor fue cancelada',
          'errors.connectionTimeout' => 'Tiempo de conexión agotado con el servidor. Revisa tu conexión a internet',
          'errors.noConnection' => 'No se pudo conectar con el servidor. Revisa tu conexión a internet',
          'errors.receiveTimeout' =>
            'Tiempo de espera agotado al recibir datos del servidor',
          'errors.sendTimeout' =>
            'Tiempo de espera agotado al enviar datos al servidor',
          'errors.badCertificate' => 'Certificado inválido',
          'errors.connection' => 'Error de conexión',
          'errors.validation' => 'Error de validación',
          'errors.server' => 'Error del servidor',
          'errors.unknown' => 'Error desconocido',
          'errors.notFoundTitle' => 'No encontrado',
          'errors.pageNotFound' => 'Esta página no existe.',
          'errors.offlineTitle' => 'Conexión perdida',
          'errors.offline' => ({
            required String url,
          }) => 'No se puede conectar con el servicio de Dumpling en ${url}. Revisa que esté corriendo e inténtalo de nuevo.',
          'nav.switchWorkspace' => ({
            required Object name,
          }) => '${name} · cambiar de workspace',
          'nav.workspaces' => 'Workspaces',
          'nav.backups' => 'Backups',
          'nav.canvas' => 'Editor del pipeline',
          'nav.sources' => 'Orígenes',
          'nav.destinations' => 'Destinos',
          'nav.runs' => 'Registro de ejecuciones',
          'nav.failedRuns' => ({
            required Object count,
          }) => '${count} con fallos',
          'nav.language' => ({required Object name}) => 'Idioma: ${name}',
          'nav.logout' => 'Cerrar sesión',
          'login.title' => 'Inicia sesión',
          'login.description' => 'Gestiona los backups de tus bases de datos.',
          'login.username' => 'Usuario',
          'login.usernameHint' => 'Escribe tu usuario',
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
          'login.tagline' => 'Respaldos',
          'login.taglineAccent' => 'sin esfuerzo',
          'login.tagLightweight' => 'Ligero',
          'login.tagCanvas' => 'Canvas drag & drop',
          'login.tagWinter' => 'Hecho con Winter',
          'login.expiredTitle' => 'Tu sesión expiró',
          'login.expiredDescription' => 'Tu sesión terminó tras 12 horas. Inicia sesión de nuevo para seguir donde lo dejaste.',
          'login.toSignInPage' => 'Ir a la página de inicio de sesión',
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
          'workspaces.settingsOf' => ({
            required Object name,
          }) => 'Ajustes de ${name}',
          'workspaces.settings.title' => 'Ajustes del workspace',
          'workspaces.settings.description' => 'Aplica solo a este workspace',
          'workspaces.settings.general' => 'General',
          'workspaces.settings.defaults' =>
            'Valores por defecto de los configs nuevos',
          'workspaces.settings.danger' => 'Zona de peligro',
          'workspaces.settings.created' => 'Creado',
          'workspaces.settings.id' => 'ID del workspace',
          'workspaces.settings.copyId' => 'Copiar el ID del workspace',
          'workspaces.settings.copied' => 'Copiado',
          'workspaces.settings.noDescription' => 'Sin descripción',
          'workspaces.settings.defaultsHint' => 'Una conexión nueva en el canvas empieza con estos valores. Cada config puede cambiarlos.',
          'workspaces.settings.schedule' => 'Programación',
          'workspaces.settings.cron' => 'Cron',
          'workspaces.settings.cronHelp' => 'Siempre en UTC.',
          'workspaces.settings.compression' => 'Compresión',
          'workspaces.settings.compressionNone' => 'Ninguna',
          'workspaces.settings.objectKey' => 'Object key',
          'workspaces.settings.objectKeyHelp' =>
            'Relativa a la carpeta donde escribe cada config, sin extensión.',
          'workspaces.settings.unsaved' => 'Tienes cambios sin guardar',
          'workspaces.settings.discard' => 'Descartar',
          'workspaces.settings.saved' => 'Guardado',
          'workspaces.settings.deleteTitle' => 'Eliminar este workspace',
          'workspaces.settings.deleteDescription' => 'Elimina su canvas, orígenes, destinos, configs e historial de ejecuciones. Los archivos de backup que ya están en tus buckets se quedan donde están.',
          'workspaces.settings.deleteButton' => 'Eliminar workspace',
          'workspaces.settings.deleteConfirmTitle' => ({
            required Object name,
          }) => '¿Eliminar «${name}»?',
          'workspaces.settings.deleteConfirm' => ({
            required Object sources,
            required Object destinations,
            required Object configs,
          }) => 'Se eliminan sus orígenes (${sources}), destinos (${destinations}), configs (${configs}) y su historial de ejecuciones. Los backups programados se detienen al momento. No se puede deshacer.',
          'workspaces.settings.typeBefore' => 'Escribe',
          'workspaces.settings.typeAfter' => 'para confirmar',
          'workspaces.settings.deleted' => ({
            required Object name,
          }) => 'Workspace ${name} eliminado',
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
          'connections.lastCheck' => 'Última prueba',
          'connections.checkTitle' => 'Prueba de conexión',
          'connections.checkNote' => 'Antes de cada ejecución y al probarla',
          'connections.connection' => 'Conexión',
          'connections.editConnection' => 'Editar conexión',
          'sources.title' => 'Sources',
          'sources.description' =>
            'Lo que respalda este workspace: bases de datos PostgreSQL.',
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
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
          'sources.stepType' => 'Tipo',
          'sources.stepConnection' => 'Conexión',
          'sources.stepCheck' => 'Revisar y guardar',
          'sources.typeTitle' => '¿Qué quieres respaldar?',
          'sources.connectionTitle' => '¿Cómo se conecta Dumpling?',
          'sources.checkTitle' => 'Revisa y guarda',
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
          'sources.passwordKeepHint' =>
            'Déjala vacía para mantener la guardada',
          'sources.passwordHelp' => 'Usa un rol de solo lectura. Se guarda cifrada y no se vuelve a mostrar.',
          'sources.connectionUrl' => 'URL de conexión',
          'sources.urlHelp' => 'La contraseña de la URL se guarda cifrada y no se vuelve a mostrar.',
          'sources.urlHelpEditing' =>
            'Si la URL no trae contraseña, se mantiene la guardada.',
          'sources.urlInvalid' =>
            'Usa el formato postgresql://usuario:contraseña@host:5432/base',
          'sources.dumpFormat' => 'Formato del dump',
          'sources.formatCustom' => 'Custom (pg_dump -Fc)',
          'sources.formatPlain' => 'SQL plano',
          'sources.testIdle' =>
            'Revisa la conexión antes de guardar el source.',
          'sources.connectedAs' => ({
            required Object user,
          }) => 'Conectado como ${user}',
          'sources.createButton' => 'Crear source',
          'sources.created' => ({
            required Object name,
          }) => 'Source ${name} creado',
          'sources.saved' => ({
            required Object name,
          }) => 'Source ${name} guardado',
          'sources.detailDescription' => ({
            required Object type,
          }) => 'Una base de datos ${type} que este workspace respalda.',
          'sources.statBackups' => 'Backups',
          'sources.statDestinations' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
                  n,
                  zero: 'ninguno aún',
                  one: 'en ${n} destination',
                  other: 'en ${n} destinations',
                ),
          'sources.statLastBackup' => 'Último backup',
          'sources.sectionUses' => 'Backups de este source',
          'sources.openEditor' => 'Abrir editor',
          'sources.noUses' => 'Ningún backup lo usa todavía. Conéctalo a un destination en el editor de pipelines.',
          'sources.columnBackup' => 'Backup',
          'sources.columnSchedule' => 'Horario',
          'sources.columnLastRun' => 'Última ejecución',
          'sources.columnNextRun' => 'Siguiente',
          'sources.cronUtc' => 'cron · UTC',
          'sources.paused' => 'En pausa',
          'sources.neverRun' => 'Aún no se ejecuta',
          'sources.passwordStored' => '•••••••• · guardada cifrada',
          'destinations.title' => 'Destinations',
          'destinations.description' =>
            'Donde este workspace escribe los backups: buckets S3.',
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
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
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
                  n,
                  one: '${n} backup',
                  other: '${n} backups',
                ),
          'destinations.notUsedYet' => 'Sin usar',
          'destinations.deleteFolder' => ({
            required Object path,
          }) => 'Eliminar la carpeta ${path}',
          'destinations.folderLocked' =>
            'La usan backups. Reconéctalos primero.',
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
          'destinations.formDescription' =>
            'Elige dónde se escriben los backups.',
          'destinations.stepType' => 'Tipo',
          'destinations.stepConnection' => 'Conexión',
          'destinations.stepFolders' => 'Carpetas y prueba',
          'destinations.typeTitle' => '¿A dónde van los backups?',
          'destinations.connectionTitle' => '¿Cómo se conecta Dumpling?',
          'destinations.foldersTitle' => 'Carpetas y prueba de conexión',
          'destinations.name' => 'Nombre',
          'destinations.nameHint' => 'p. ej. bucket-backups',
          'destinations.copyName' => ({
            required Object name,
          }) => '${name}-copia',
          'destinations.endpoint' => 'Endpoint',
          'destinations.endpointHelp' => 'Cualquier URL compatible con S3. Para AWS usa https://s3.<región>.amazonaws.com.',
          'destinations.bucket' => 'Bucket',
          'destinations.region' => 'Región',
          'destinations.accessKeyId' => 'Access key ID',
          'destinations.secretKey' => 'Secret key',
          'destinations.secretKeepHint' =>
            'Déjala vacía para mantener la guardada',
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
          'destinations.detailDescription' =>
            'Un bucket donde este workspace escribe backups.',
          'destinations.statBackups' => 'Backups',
          'destinations.statBackupsSub' => 'escriben aquí',
          'destinations.statFolders' => 'Carpetas',
          'destinations.statFoldersSub' => 'puntos de conexión',
          'destinations.sectionFolders' => 'Carpetas',
          'destinations.columnFolder' => 'Carpeta',
          'destinations.columnWrittenBy' => 'Lo escribe',
          'destinations.accessKey' => 'Access key',
          'destinations.on' => 'Sí',
          'destinations.off' => 'No',
          'destinations.typeSub.s3' =>
            'Cualquier almacenamiento compatible con S3',
          'destinations.typeSub.gdrive' => 'Unidad o carpeta compartida',
          'destinations.typeSub.dropbox' => 'Carpeta de la app',
          'destinations.typeSub.azure' => 'Contenedor de almacenamiento',
          'destinations.typeSub.sftp' => 'Cualquier servidor SSH',
          'canvas.description' => 'Conecta orígenes con destinos para armar los respaldos de este workspace.',
          'canvas.save' => 'Guardar canvas',
          'canvas.saved' => 'Canvas guardado',
          'canvas.newConfig' => 'Nueva config',
          'canvas.removeFromCanvas' => 'Quitar del canvas',
          'canvas.allSourcesPlaced' => 'Todos los orígenes están en el canvas',
          'canvas.allDestinationsPlaced' =>
            'Todos los destinos están en el canvas',
          'canvas.workspaceDefault' => 'Predeterminado del workspace',
          'canvas.neverRun' => 'Nunca se ha ejecutado',
          'canvas.disabled' => 'Desactivada',
          'canvas.orphans' =>
            ({required num n}) =>
                (_root.$meta.cardinalResolver ??
                PluralResolvers.cardinal('es'))(
                  n,
                  one: '${n} config incompleta',
                  other: '${n} configs incompletas',
                ),
          'canvas.orphansHelp' => 'Solo se guardan los flujos completos (origen → config → destino). Las configs en ámbar se descartan al guardar; los orígenes y destinos se quedan.',
          'canvas.semantics' => 'Canvas. Mantén Espacio y arrastra para moverlo; clic derecho para opciones; las flechas lo mueven; Ctrl y la rueda hacen zoom; F lo centra; haz clic en una conexión y pulsa Supr para quitarla; Escape cierra la config',
          'canvas.addSource' => 'Origen',
          'canvas.addDestination' => 'Destino',
          'canvas.deleteConfig' => 'Eliminar config',
          'canvas.editConfig' => 'Editar config',
          'canvas.removeConnection' => 'Quitar conexión',
          'canvas.removeConnectionKey' => 'Quitar conexión (Supr)',
          'canvas.configHere' => 'La config se crea aquí',
          'canvas.releaseToCreate' => 'Suelta para crear la config',
          'canvas.dragToDestination' => 'Arrastra hasta un destino',
          'canvas.last' => 'Última',
          'canvas.next' => 'Próxima',
          'canvas.runStatus.success' => 'Correcta',
          'canvas.runStatus.failed' => 'Fallida',
          'canvas.runStatus.running' => 'En curso',
          'canvas.frequency.hourly' => 'Cada hora',
          'canvas.frequency.daily' => 'Diaria',
          'canvas.frequency.weekly' => 'Semanal',
          'canvas.frequency.cron' => 'Cron',
          'canvas.addFolder' => '+ Agregar carpeta',
          'canvas.addFolderTitle' => ({
            required String name,
          }) => 'Agregar una carpeta a ${name}',
          'canvas.addFolderDescription' => 'Cada carpeta es un punto de conexión. Se crea en el bucket al guardar el canvas.',
          'canvas.addFolderRoot' => 'Con la primera carpeta, la raíz del bucket deja de ser un punto de conexión: las configs que escriben ahí se desconectan.',
          'canvas.keys.space' => 'Espacio',
          'canvas.keys.del' => 'Supr',
          'canvas.keys.ctrl' => 'Ctrl',
          'canvas.keys.esc' => 'Esc',
          'canvas.shortcuts.title' => 'Atajos',
          'canvas.shortcuts.hide' => 'Ocultar atajos',
          'canvas.shortcuts.moveCanvas' => 'Mover el canvas',
          'canvas.shortcuts.drag' => ' + arrastrar',
          'canvas.shortcuts.connect' => 'Conectar',
          'canvas.shortcuts.dragFromPort' => 'arrastra desde un puerto',
          'canvas.shortcuts.options' => 'Opciones',
          'canvas.shortcuts.rightClick' => 'clic derecho',
          'canvas.shortcuts.clickIt' => 'clic en ella + ',
          'canvas.shortcuts.zoom' => 'Zoom',
          'canvas.shortcuts.scroll' => 'rueda',
          'canvas.shortcuts.zoomInOut' => 'Acercar / alejar',
          'canvas.shortcuts.center' => 'Centrar el canvas',
          'canvas.shortcuts.reset' => 'Volver a 100%',
          'canvas.shortcuts.moveWithKeys' => 'Mover con teclas',
          'canvas.shortcuts.closeConfig' => 'Cerrar la config',
          'canvas.shortcuts.toggle' => 'Mostrar / ocultar atajos',
          'canvas.view.settings' => 'Ajustes del canvas',
          'canvas.view.toggleShortcuts' => 'Mostrar u ocultar atajos (?)',
          'canvas.view.center' => 'Centrar',
          'canvas.view.centerTooltip' => 'Centrar el canvas (F)',
          'canvas.view.zoomOut' => 'Alejar (−)',
          'canvas.view.reset' => 'Volver a 100% (0)',
          'canvas.view.zoomIn' => 'Acercar (+)',
          'canvas.view.settingsTitle' => 'Canvas',
          'canvas.view.ctrlZoom' => 'Mantén Ctrl para hacer zoom',
          'canvas.view.ctrlZoomOn' =>
            'La rueda mueve el canvas, Ctrl + rueda hace zoom',
          'canvas.view.ctrlZoomOff' => 'La rueda siempre hace zoom',
          'canvas.inspector.configName' => 'Nombre de la config',
          'canvas.inspector.doubleCompression' => 'El formato custom (pg_dump -Fc) ya va comprimido: gzip apenas lo reduce.',
          'canvas.inspector.nameHelp' => 'Se muestra en el canvas, en Respaldos y en el registro de ejecuciones.',
          'canvas.inspector.frequency' => 'Frecuencia',
          'canvas.inspector.review' => 'Revisión',
          'canvas.inspector.source' => 'Origen',
          'canvas.inspector.destination' => 'Destino',
          'canvas.inspector.nextRunOnSave' => 'Se calcula al guardar',
          'canvas.inspector.cronHelp' => 'minuto hora día mes día-de-la-semana, en UTC. Cada hora, diaria y semanal lo escriben por ti.',
          'canvas.inspector.cronInvalid' => 'No es una expresión cron válida (minuto hora día mes día-de-la-semana)',
          'canvas.inspector.enabled' => 'Activa',
          'canvas.inspector.enabledOn' => 'Se ejecuta según su programación',
          'canvas.inspector.enabledOff' =>
            'Desactivada: solo se ejecuta con Ejecutar ahora',
          'canvas.inspector.compressionNone' => 'Ninguna',
          'canvas.inspector.objectKeySlash' =>
            'El object key no puede empezar con /',
          'canvas.inspector.objectKeyExtension' => 'Omite la extensión: se agrega según el formato del dump y la compresión',
          'canvas.inspector.schedule' => 'Nombre y programación',
          'canvas.inspector.cron' => 'Cron',
          'canvas.inspector.timeZone' => 'Zona horaria',
          'canvas.inspector.nextRun' => 'Próxima ejecución',
          'canvas.inspector.output' => 'Salida',
          'canvas.inspector.objectKey' => 'Object key',
          'canvas.inspector.connectDestination' =>
            'Conecta un destino para elegir dónde se guarda.',
          'canvas.inspector.relativeToFolder' => ({
            required String folder,
          }) => 'Relativa a la carpeta ${folder}. La extensión se agrega según el formato del dump y la compresión.',
          'canvas.inspector.relativeToRoot' => ({
            required String bucket,
          }) => 'Relativa a la raíz de ${bucket}. La extensión se agrega según el formato del dump y la compresión.',
          'canvas.inspector.compression' => 'Compresión',
          'canvas.inspector.writes' => 'La próxima ejecución escribe',
          'canvas.inspector.missingSource' => 'Nada: conecta un origen.',
          'canvas.inspector.missingDestination' => 'Nada: conecta un destino.',
          'canvas.inspector.missingBoth' =>
            'Nada: conecta un origen y un destino.',
          'canvas.inspector.noSource' => 'sin origen',
          'canvas.inspector.noDestination' => 'sin destino',
          'canvas.columns.sources' => 'Orígenes',
          'canvas.columns.configs' => 'Config · una por conexión',
          'canvas.columns.destinations' => 'Destinos',
          'canvas.folder' => 'Carpeta',
          'canvas.testRun.button' => 'Probar',
          'canvas.testRun.help' => 'Comprueba que cada flujo completo podría ejecutarse, sin hacer backups: cada origen conecta y pg_dump puede respaldarlo, cada destino acepta escrituras en sus carpetas.',
          'canvas.testRun.ok' => ({
            required int n,
          }) => 'Todo funciona: ${n} comprobaciones correctas',
          'canvas.testRun.failed' => ({
            required String list,
          }) => 'Fallaron algunas comprobaciones: ${list}',
          'canvas.testRun.nothing' =>
            'Nada que probar: primero conecta un origen a un destino.',
          'canvas.run.button' => 'Ejecutar ahora',
          'canvas.run.help' => 'Ejecuta este backup ahora, de verdad, tal como está guardado: los cambios sin guardar no se usan.',
          'canvas.run.needsSave' =>
            'Guarda el canvas primero: una ejecución usa la config guardada.',
          'canvas.run.done' => ({
            required String name,
            required String size,
          }) => 'Backup ${name} terminado: ${size}',
          'canvas.run.failed' => ({
            required String name,
            required String error,
          }) => 'Backup ${name} falló: ${error}',
          'canvas.guide.title' => 'Tu primer backup',
          'canvas.guide.source' => 'Agrega un origen',
          'canvas.guide.sourceHelp' => 'La base de datos a respaldar.',
          'canvas.guide.destination' => 'Agrega un destino',
          'canvas.guide.destinationHelp' => 'El bucket donde van los backups.',
          'canvas.guide.connect' => 'Conéctalos',
          'canvas.guide.connectHelp' => 'Arrastra desde el puerto del origen hasta una carpeta o el bucket: se crea una config entre ellos. Luego guarda.',
          'canvas.guide.create' => 'Crear uno',
          'canvas.guide.place' => ({required String name}) => 'Colocar ${name}',
          'runs.title' => 'Registro de ejecuciones',
          'runs.description' => 'Cada ejecución de respaldo de este workspace, programada o manual. Horas en UTC, tu hora local debajo.',
          'runs.search' => 'Buscar por respaldo, origen o destino',
          'runs.columnStatus' => 'Estado',
          'runs.columnSource' => 'Origen',
          'runs.columnDestination' => 'Destino',
          'runs.columnStarted' => 'Inicio',
          'runs.columnDuration' => 'Duración',
          'runs.columnSize' => 'Tamaño',
          'runs.scheduled' => 'Programada',
          'runs.manual' => 'Manual',
          'runs.emptyTitle' => 'Aún no hay ejecuciones',
          'runs.emptyDescription' => 'Los respaldos se ejecutan según su programación, o con Ejecutar ahora en el editor.',
          'runs.newestOnly' =>
            'Solo se muestran las 200 ejecuciones más recientes.',
          'runs.log' => 'Log (UTC)',
          'runs.copyLog' => 'Copiar log',
          'runs.logCopied' => 'Log copiado',
          'runs.logWhenDone' => 'El log se escribe cuando termina la ejecución. Actualiza para verlo.',
          'runs.noLog' => 'Esta ejecución no tiene log.',
          'runs.today' => ({required String date}) => 'Hoy · ${date} (UTC)',
          'runs.yesterday' => ({
            required String date,
          }) => 'Ayer · ${date} (UTC)',
          'runs.day' => ({required String date}) => '${date} (UTC)',
          'runs.succeeded' => ({required int n}) => '${n} correctas',
          'runs.failedCount' => ({required int n}) => '${n} fallidas',
          'runs.savedIn' => ({
            required String size,
            required String duration,
          }) => '${size} en ${duration}',
          'runs.inProgress' => 'En curso',
          'runs.soFar' => ({
            required String size,
          }) => 'En curso · ${size} hasta ahora',
          'runs.columnTrigger' => 'Tipo',
          'runs.viewRun' => 'Ver ejecución',
          'runs.steps' => 'Pasos',
          'runs.stepConnect' => ({
            required String name,
          }) => 'Conectar con ${name}',
          'runs.stepDump' => ({
            required String name,
          }) => 'Volcar y subir a ${name}',
          'runs.stepSkipped' => 'Omitido',
          'runs.stepWaiting' => 'En espera',
          'runs.resultSuccess' => 'Respaldo guardado',
          'runs.resultFailed' => 'El respaldo falló',
          'runs.resultRunning' => 'En curso. Actualiza para ver cuánto avanzó.',
          'backups.title' => 'Respaldos',
          'backups.description' => 'Cada respaldo de este workspace, su última ejecución y la siguiente.',
          'backups.openEditor' => 'Abrir editor',
          'backups.newBackup' => 'Nuevo respaldo',
          'backups.healthy' => 'Correctos',
          'backups.healthySub' => 'la última ejecución salió bien',
          'backups.failing' => 'Con fallas',
          'backups.failingSub' => 'requieren atención',
          'backups.paused' => 'Pausado',
          'backups.nextBackup' => 'Próximo respaldo',
          'backups.nextBackupIn' => 'Próximo respaldo en',
          'backups.nothingScheduled' => 'Nada programado',
          'backups.search' => 'Buscar respaldos',
          'backups.columnStatus' => 'Estado',
          'backups.columnSource' => 'Origen',
          'backups.columnDestination' => 'Destino',
          'backups.columnSchedule' => 'Programación',
          'backups.columnLastRun' => 'Último respaldo',
          'backups.columnNextRun' => 'Próximo respaldo',
          'backups.allSources' => 'Todos los orígenes',
          'backups.allDestinations' => 'Todos los destinos',
          'backups.shown' => ({
            required Object shown,
            required Object total,
          }) => '${shown} de ${total} respaldos',
          'backups.showing' => ({
            required Object shown,
            required Object total,
          }) => 'Mostrando ${shown} de ${total} respaldos',
          'backups.timesNote' => ({
            required Object utc,
            required Object local,
          }) => 'Horas en UTC · ahora ${utc} (${local})',
          'backups.sort' => 'Orden:',
          'backups.sortBy' => 'Ordenar por',
          'backups.sortLast' => 'Último respaldo',
          'backups.sortLastSub' => 'El más reciente primero',
          'backups.sortLastOld' => 'Último respaldo (antiguo)',
          'backups.sortLastOldSub' => 'El más antiguo primero',
          'backups.sortNext' => 'Próximo respaldo',
          'backups.sortNextSub' => 'El más cercano primero',
          'backups.sortName' => 'Nombre del origen',
          'backups.sortNameSub' => 'De la A a la Z',
          'backups.inTime' => ({required Object time}) => 'en ${time}',
          'backups.startedAgo' => ({
            required Object time,
          }) => 'Empezó hace ${time}',
          'backups.runNowFor' => ({
            required Object name,
          }) => 'Ejecutar ${name} ahora',
          'backups.showRuns' => 'Ver las ejecuciones',
          _ => null,
        } ??
        switch (path) {
          'backups.hideRuns' => 'Ocultar las ejecuciones',
          'backups.moreFor' => ({
            required Object name,
          }) => 'Más acciones de ${name}',
          'backups.viewLastRun' => 'Ver la última ejecución',
          'backups.editConfig' => 'Editar config',
          'backups.deleteBackup' => 'Eliminar respaldo',
          'backups.recentRuns' => 'Ejecuciones recientes',
          'backups.noRuns' => 'Aún no hay ejecuciones',
          'backups.viewLog' => 'Ver log',
          'backups.viewDetails' => 'Ver detalle',
          'backups.noFile' => 'No se escribió archivo',
          'backups.uploading' => 'Subiendo…',
          'backups.manual' => 'Manual',
          'backups.scheduled' => 'Programada',
          'backups.deleteTitle' => ({
            required Object name,
          }) => '¿Eliminar el respaldo ${name}?',
          'backups.deleteConfirm' => 'Su programación se detiene. Sus ejecuciones quedan en el registro y los archivos que ya están en el destino se quedan ahí.',
          'backups.deleted' => ({
            required Object name,
          }) => 'Respaldo ${name} eliminado',
          'backups.saved' => ({
            required Object name,
          }) => 'Respaldo ${name} guardado',
          'backups.emptyDescription' =>
            'Conecta un origen con un destino en el editor para crear uno.',
          _ => null,
        };
  }
}
