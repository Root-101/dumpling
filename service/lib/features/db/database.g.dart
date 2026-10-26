// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkspaceTableTable extends WorkspaceTable
    with TableInfo<$WorkspaceTableTable, WorkspaceTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkspaceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultScheduleMeta = const VerificationMeta(
    'defaultSchedule',
  );
  @override
  late final GeneratedColumn<String> defaultSchedule = GeneratedColumn<String>(
    'default_schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Compression, String>
  defaultCompression =
      GeneratedColumn<String>(
        'default_compression',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Compression>(
        $WorkspaceTableTable.$converterdefaultCompression,
      );
  static const VerificationMeta _defaultObjectKeyMeta = const VerificationMeta(
    'defaultObjectKey',
  );
  @override
  late final GeneratedColumn<String> defaultObjectKey = GeneratedColumn<String>(
    'default_object_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slug,
    name,
    description,
    color,
    defaultSchedule,
    defaultCompression,
    defaultObjectKey,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workspace';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkspaceTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('default_schedule')) {
      context.handle(
        _defaultScheduleMeta,
        defaultSchedule.isAcceptableOrUnknown(
          data['default_schedule']!,
          _defaultScheduleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultScheduleMeta);
    }
    if (data.containsKey('default_object_key')) {
      context.handle(
        _defaultObjectKeyMeta,
        defaultObjectKey.isAcceptableOrUnknown(
          data['default_object_key']!,
          _defaultObjectKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultObjectKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slug};
  @override
  WorkspaceTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkspaceTableData(
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      defaultSchedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_schedule'],
      )!,
      defaultCompression: $WorkspaceTableTable.$converterdefaultCompression
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}default_compression'],
            )!,
          ),
      defaultObjectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_object_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WorkspaceTableTable createAlias(String alias) {
    return $WorkspaceTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Compression, String, String>
  $converterdefaultCompression = const EnumNameConverter<Compression>(
    Compression.values,
  );
}

class WorkspaceTableData extends DataClass
    implements Insertable<WorkspaceTableData> {
  /// From the name when it is created; it never changes, so the links to the
  /// workspace (`/workspaces/{slug}`) keep working after a rename.
  final String slug;
  final String name;
  final String? description;

  /// ARGB, as the console sends it (Color.toARGB32).
  final int? color;

  /// What a new config starts with (each config can change them).
  final String defaultSchedule;
  final Compression defaultCompression;
  final String defaultObjectKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WorkspaceTableData({
    required this.slug,
    required this.name,
    this.description,
    this.color,
    required this.defaultSchedule,
    required this.defaultCompression,
    required this.defaultObjectKey,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slug'] = Variable<String>(slug);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['default_schedule'] = Variable<String>(defaultSchedule);
    {
      map['default_compression'] = Variable<String>(
        $WorkspaceTableTable.$converterdefaultCompression.toSql(
          defaultCompression,
        ),
      );
    }
    map['default_object_key'] = Variable<String>(defaultObjectKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WorkspaceTableCompanion toCompanion(bool nullToAbsent) {
    return WorkspaceTableCompanion(
      slug: Value(slug),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      defaultSchedule: Value(defaultSchedule),
      defaultCompression: Value(defaultCompression),
      defaultObjectKey: Value(defaultObjectKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WorkspaceTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkspaceTableData(
      slug: serializer.fromJson<String>(json['slug']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      color: serializer.fromJson<int?>(json['color']),
      defaultSchedule: serializer.fromJson<String>(json['defaultSchedule']),
      defaultCompression: $WorkspaceTableTable.$converterdefaultCompression
          .fromJson(serializer.fromJson<String>(json['defaultCompression'])),
      defaultObjectKey: serializer.fromJson<String>(json['defaultObjectKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slug': serializer.toJson<String>(slug),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'color': serializer.toJson<int?>(color),
      'defaultSchedule': serializer.toJson<String>(defaultSchedule),
      'defaultCompression': serializer.toJson<String>(
        $WorkspaceTableTable.$converterdefaultCompression.toJson(
          defaultCompression,
        ),
      ),
      'defaultObjectKey': serializer.toJson<String>(defaultObjectKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WorkspaceTableData copyWith({
    String? slug,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> color = const Value.absent(),
    String? defaultSchedule,
    Compression? defaultCompression,
    String? defaultObjectKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WorkspaceTableData(
    slug: slug ?? this.slug,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    color: color.present ? color.value : this.color,
    defaultSchedule: defaultSchedule ?? this.defaultSchedule,
    defaultCompression: defaultCompression ?? this.defaultCompression,
    defaultObjectKey: defaultObjectKey ?? this.defaultObjectKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WorkspaceTableData copyWithCompanion(WorkspaceTableCompanion data) {
    return WorkspaceTableData(
      slug: data.slug.present ? data.slug.value : this.slug,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      color: data.color.present ? data.color.value : this.color,
      defaultSchedule: data.defaultSchedule.present
          ? data.defaultSchedule.value
          : this.defaultSchedule,
      defaultCompression: data.defaultCompression.present
          ? data.defaultCompression.value
          : this.defaultCompression,
      defaultObjectKey: data.defaultObjectKey.present
          ? data.defaultObjectKey.value
          : this.defaultObjectKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceTableData(')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('defaultSchedule: $defaultSchedule, ')
          ..write('defaultCompression: $defaultCompression, ')
          ..write('defaultObjectKey: $defaultObjectKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slug,
    name,
    description,
    color,
    defaultSchedule,
    defaultCompression,
    defaultObjectKey,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkspaceTableData &&
          other.slug == this.slug &&
          other.name == this.name &&
          other.description == this.description &&
          other.color == this.color &&
          other.defaultSchedule == this.defaultSchedule &&
          other.defaultCompression == this.defaultCompression &&
          other.defaultObjectKey == this.defaultObjectKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WorkspaceTableCompanion extends UpdateCompanion<WorkspaceTableData> {
  final Value<String> slug;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> color;
  final Value<String> defaultSchedule;
  final Value<Compression> defaultCompression;
  final Value<String> defaultObjectKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WorkspaceTableCompanion({
    this.slug = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    this.defaultSchedule = const Value.absent(),
    this.defaultCompression = const Value.absent(),
    this.defaultObjectKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkspaceTableCompanion.insert({
    required String slug,
    required String name,
    this.description = const Value.absent(),
    this.color = const Value.absent(),
    required String defaultSchedule,
    required Compression defaultCompression,
    required String defaultObjectKey,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : slug = Value(slug),
       name = Value(name),
       defaultSchedule = Value(defaultSchedule),
       defaultCompression = Value(defaultCompression),
       defaultObjectKey = Value(defaultObjectKey);
  static Insertable<WorkspaceTableData> custom({
    Expression<String>? slug,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? color,
    Expression<String>? defaultSchedule,
    Expression<String>? defaultCompression,
    Expression<String>? defaultObjectKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slug != null) 'slug': slug,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (defaultSchedule != null) 'default_schedule': defaultSchedule,
      if (defaultCompression != null) 'default_compression': defaultCompression,
      if (defaultObjectKey != null) 'default_object_key': defaultObjectKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkspaceTableCompanion copyWith({
    Value<String>? slug,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? color,
    Value<String>? defaultSchedule,
    Value<Compression>? defaultCompression,
    Value<String>? defaultObjectKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WorkspaceTableCompanion(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      defaultSchedule: defaultSchedule ?? this.defaultSchedule,
      defaultCompression: defaultCompression ?? this.defaultCompression,
      defaultObjectKey: defaultObjectKey ?? this.defaultObjectKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (defaultSchedule.present) {
      map['default_schedule'] = Variable<String>(defaultSchedule.value);
    }
    if (defaultCompression.present) {
      map['default_compression'] = Variable<String>(
        $WorkspaceTableTable.$converterdefaultCompression.toSql(
          defaultCompression.value,
        ),
      );
    }
    if (defaultObjectKey.present) {
      map['default_object_key'] = Variable<String>(defaultObjectKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkspaceTableCompanion(')
          ..write('slug: $slug, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('color: $color, ')
          ..write('defaultSchedule: $defaultSchedule, ')
          ..write('defaultCompression: $defaultCompression, ')
          ..write('defaultObjectKey: $defaultObjectKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SourceTableTable extends SourceTable
    with TableInfo<$SourceTableTable, SourceTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceSlugMeta = const VerificationMeta(
    'workspaceSlug',
  );
  @override
  late final GeneratedColumn<String> workspaceSlug = GeneratedColumn<String>(
    'workspace_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspace (slug) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SourceType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SourceType>($SourceTableTable.$convertertype);
  static const VerificationMeta _settingsMeta = const VerificationMeta(
    'settings',
  );
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
    'settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretsEncryptedMeta = const VerificationMeta(
    'secretsEncrypted',
  );
  @override
  late final GeneratedColumn<String> secretsEncrypted = GeneratedColumn<String>(
    'secrets_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCheckMeta = const VerificationMeta(
    'lastCheck',
  );
  @override
  late final GeneratedColumn<String> lastCheck = GeneratedColumn<String>(
    'last_check',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canvasXMeta = const VerificationMeta(
    'canvasX',
  );
  @override
  late final GeneratedColumn<double> canvasX = GeneratedColumn<double>(
    'canvas_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canvasYMeta = const VerificationMeta(
    'canvasY',
  );
  @override
  late final GeneratedColumn<double> canvasY = GeneratedColumn<double>(
    'canvas_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceSlug,
    name,
    type,
    settings,
    secretsEncrypted,
    lastCheck,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_slug')) {
      context.handle(
        _workspaceSlugMeta,
        workspaceSlug.isAcceptableOrUnknown(
          data['workspace_slug']!,
          _workspaceSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceSlugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('settings')) {
      context.handle(
        _settingsMeta,
        settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta),
      );
    } else if (isInserting) {
      context.missing(_settingsMeta);
    }
    if (data.containsKey('secrets_encrypted')) {
      context.handle(
        _secretsEncryptedMeta,
        secretsEncrypted.isAcceptableOrUnknown(
          data['secrets_encrypted']!,
          _secretsEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secretsEncryptedMeta);
    }
    if (data.containsKey('last_check')) {
      context.handle(
        _lastCheckMeta,
        lastCheck.isAcceptableOrUnknown(data['last_check']!, _lastCheckMeta),
      );
    }
    if (data.containsKey('canvas_x')) {
      context.handle(
        _canvasXMeta,
        canvasX.isAcceptableOrUnknown(data['canvas_x']!, _canvasXMeta),
      );
    }
    if (data.containsKey('canvas_y')) {
      context.handle(
        _canvasYMeta,
        canvasY.isAcceptableOrUnknown(data['canvas_y']!, _canvasYMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $SourceTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      settings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings'],
      )!,
      secretsEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secrets_encrypted'],
      )!,
      lastCheck: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_check'],
      ),
      canvasX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_x'],
      ),
      canvasY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_y'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SourceTableTable createAlias(String alias) {
    return $SourceTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SourceType, String, String> $convertertype =
      const EnumNameConverter<SourceType>(SourceType.values);
}

class SourceTableData extends DataClass implements Insertable<SourceTableData> {
  /// `src_` and 16 random characters.
  final String id;

  /// Deleting the workspace deletes its sources.
  final String workspaceSlug;
  final String name;
  final SourceType type;

  /// [SourceSettings.toJson]: never a secret.
  final String settings;

  /// The secrets as JSON (`{"password": …}`), encrypted with [SecretCipher]
  /// bound to [id].
  final String secretsEncrypted;

  /// The last [ConnectionCheck] as JSON, null until the first test.
  final String? lastCheck;

  /// Where it sits on the canvas; null while it is off it.
  final double? canvasX;
  final double? canvasY;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SourceTableData({
    required this.id,
    required this.workspaceSlug,
    required this.name,
    required this.type,
    required this.settings,
    required this.secretsEncrypted,
    this.lastCheck,
    this.canvasX,
    this.canvasY,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_slug'] = Variable<String>(workspaceSlug);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $SourceTableTable.$convertertype.toSql(type),
      );
    }
    map['settings'] = Variable<String>(settings);
    map['secrets_encrypted'] = Variable<String>(secretsEncrypted);
    if (!nullToAbsent || lastCheck != null) {
      map['last_check'] = Variable<String>(lastCheck);
    }
    if (!nullToAbsent || canvasX != null) {
      map['canvas_x'] = Variable<double>(canvasX);
    }
    if (!nullToAbsent || canvasY != null) {
      map['canvas_y'] = Variable<double>(canvasY);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SourceTableCompanion toCompanion(bool nullToAbsent) {
    return SourceTableCompanion(
      id: Value(id),
      workspaceSlug: Value(workspaceSlug),
      name: Value(name),
      type: Value(type),
      settings: Value(settings),
      secretsEncrypted: Value(secretsEncrypted),
      lastCheck: lastCheck == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheck),
      canvasX: canvasX == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasX),
      canvasY: canvasY == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasY),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SourceTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceTableData(
      id: serializer.fromJson<String>(json['id']),
      workspaceSlug: serializer.fromJson<String>(json['workspaceSlug']),
      name: serializer.fromJson<String>(json['name']),
      type: $SourceTableTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      settings: serializer.fromJson<String>(json['settings']),
      secretsEncrypted: serializer.fromJson<String>(json['secretsEncrypted']),
      lastCheck: serializer.fromJson<String?>(json['lastCheck']),
      canvasX: serializer.fromJson<double?>(json['canvasX']),
      canvasY: serializer.fromJson<double?>(json['canvasY']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceSlug': serializer.toJson<String>(workspaceSlug),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $SourceTableTable.$convertertype.toJson(type),
      ),
      'settings': serializer.toJson<String>(settings),
      'secretsEncrypted': serializer.toJson<String>(secretsEncrypted),
      'lastCheck': serializer.toJson<String?>(lastCheck),
      'canvasX': serializer.toJson<double?>(canvasX),
      'canvasY': serializer.toJson<double?>(canvasY),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SourceTableData copyWith({
    String? id,
    String? workspaceSlug,
    String? name,
    SourceType? type,
    String? settings,
    String? secretsEncrypted,
    Value<String?> lastCheck = const Value.absent(),
    Value<double?> canvasX = const Value.absent(),
    Value<double?> canvasY = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SourceTableData(
    id: id ?? this.id,
    workspaceSlug: workspaceSlug ?? this.workspaceSlug,
    name: name ?? this.name,
    type: type ?? this.type,
    settings: settings ?? this.settings,
    secretsEncrypted: secretsEncrypted ?? this.secretsEncrypted,
    lastCheck: lastCheck.present ? lastCheck.value : this.lastCheck,
    canvasX: canvasX.present ? canvasX.value : this.canvasX,
    canvasY: canvasY.present ? canvasY.value : this.canvasY,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SourceTableData copyWithCompanion(SourceTableCompanion data) {
    return SourceTableData(
      id: data.id.present ? data.id.value : this.id,
      workspaceSlug: data.workspaceSlug.present
          ? data.workspaceSlug.value
          : this.workspaceSlug,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      settings: data.settings.present ? data.settings.value : this.settings,
      secretsEncrypted: data.secretsEncrypted.present
          ? data.secretsEncrypted.value
          : this.secretsEncrypted,
      lastCheck: data.lastCheck.present ? data.lastCheck.value : this.lastCheck,
      canvasX: data.canvasX.present ? data.canvasX.value : this.canvasX,
      canvasY: data.canvasY.present ? data.canvasY.value : this.canvasY,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceTableData(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings, ')
          ..write('secretsEncrypted: $secretsEncrypted, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceSlug,
    name,
    type,
    settings,
    secretsEncrypted,
    lastCheck,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceTableData &&
          other.id == this.id &&
          other.workspaceSlug == this.workspaceSlug &&
          other.name == this.name &&
          other.type == this.type &&
          other.settings == this.settings &&
          other.secretsEncrypted == this.secretsEncrypted &&
          other.lastCheck == this.lastCheck &&
          other.canvasX == this.canvasX &&
          other.canvasY == this.canvasY &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SourceTableCompanion extends UpdateCompanion<SourceTableData> {
  final Value<String> id;
  final Value<String> workspaceSlug;
  final Value<String> name;
  final Value<SourceType> type;
  final Value<String> settings;
  final Value<String> secretsEncrypted;
  final Value<String?> lastCheck;
  final Value<double?> canvasX;
  final Value<double?> canvasY;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SourceTableCompanion({
    this.id = const Value.absent(),
    this.workspaceSlug = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.settings = const Value.absent(),
    this.secretsEncrypted = const Value.absent(),
    this.lastCheck = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourceTableCompanion.insert({
    required String id,
    required String workspaceSlug,
    required String name,
    required SourceType type,
    required String settings,
    required String secretsEncrypted,
    this.lastCheck = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceSlug = Value(workspaceSlug),
       name = Value(name),
       type = Value(type),
       settings = Value(settings),
       secretsEncrypted = Value(secretsEncrypted);
  static Insertable<SourceTableData> custom({
    Expression<String>? id,
    Expression<String>? workspaceSlug,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? settings,
    Expression<String>? secretsEncrypted,
    Expression<String>? lastCheck,
    Expression<double>? canvasX,
    Expression<double>? canvasY,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceSlug != null) 'workspace_slug': workspaceSlug,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (settings != null) 'settings': settings,
      if (secretsEncrypted != null) 'secrets_encrypted': secretsEncrypted,
      if (lastCheck != null) 'last_check': lastCheck,
      if (canvasX != null) 'canvas_x': canvasX,
      if (canvasY != null) 'canvas_y': canvasY,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourceTableCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceSlug,
    Value<String>? name,
    Value<SourceType>? type,
    Value<String>? settings,
    Value<String>? secretsEncrypted,
    Value<String?>? lastCheck,
    Value<double?>? canvasX,
    Value<double?>? canvasY,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SourceTableCompanion(
      id: id ?? this.id,
      workspaceSlug: workspaceSlug ?? this.workspaceSlug,
      name: name ?? this.name,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      secretsEncrypted: secretsEncrypted ?? this.secretsEncrypted,
      lastCheck: lastCheck ?? this.lastCheck,
      canvasX: canvasX ?? this.canvasX,
      canvasY: canvasY ?? this.canvasY,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceSlug.present) {
      map['workspace_slug'] = Variable<String>(workspaceSlug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $SourceTableTable.$convertertype.toSql(type.value),
      );
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (secretsEncrypted.present) {
      map['secrets_encrypted'] = Variable<String>(secretsEncrypted.value);
    }
    if (lastCheck.present) {
      map['last_check'] = Variable<String>(lastCheck.value);
    }
    if (canvasX.present) {
      map['canvas_x'] = Variable<double>(canvasX.value);
    }
    if (canvasY.present) {
      map['canvas_y'] = Variable<double>(canvasY.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceTableCompanion(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings, ')
          ..write('secretsEncrypted: $secretsEncrypted, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DestinationTableTable extends DestinationTable
    with TableInfo<$DestinationTableTable, DestinationTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DestinationTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceSlugMeta = const VerificationMeta(
    'workspaceSlug',
  );
  @override
  late final GeneratedColumn<String> workspaceSlug = GeneratedColumn<String>(
    'workspace_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspace (slug) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DestinationType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DestinationType>($DestinationTableTable.$convertertype);
  static const VerificationMeta _settingsMeta = const VerificationMeta(
    'settings',
  );
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
    'settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secretsEncryptedMeta = const VerificationMeta(
    'secretsEncrypted',
  );
  @override
  late final GeneratedColumn<String> secretsEncrypted = GeneratedColumn<String>(
    'secrets_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCheckMeta = const VerificationMeta(
    'lastCheck',
  );
  @override
  late final GeneratedColumn<String> lastCheck = GeneratedColumn<String>(
    'last_check',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canvasXMeta = const VerificationMeta(
    'canvasX',
  );
  @override
  late final GeneratedColumn<double> canvasX = GeneratedColumn<double>(
    'canvas_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canvasYMeta = const VerificationMeta(
    'canvasY',
  );
  @override
  late final GeneratedColumn<double> canvasY = GeneratedColumn<double>(
    'canvas_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceSlug,
    name,
    type,
    settings,
    secretsEncrypted,
    lastCheck,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'destination';
  @override
  VerificationContext validateIntegrity(
    Insertable<DestinationTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_slug')) {
      context.handle(
        _workspaceSlugMeta,
        workspaceSlug.isAcceptableOrUnknown(
          data['workspace_slug']!,
          _workspaceSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceSlugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('settings')) {
      context.handle(
        _settingsMeta,
        settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta),
      );
    } else if (isInserting) {
      context.missing(_settingsMeta);
    }
    if (data.containsKey('secrets_encrypted')) {
      context.handle(
        _secretsEncryptedMeta,
        secretsEncrypted.isAcceptableOrUnknown(
          data['secrets_encrypted']!,
          _secretsEncryptedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secretsEncryptedMeta);
    }
    if (data.containsKey('last_check')) {
      context.handle(
        _lastCheckMeta,
        lastCheck.isAcceptableOrUnknown(data['last_check']!, _lastCheckMeta),
      );
    }
    if (data.containsKey('canvas_x')) {
      context.handle(
        _canvasXMeta,
        canvasX.isAcceptableOrUnknown(data['canvas_x']!, _canvasXMeta),
      );
    }
    if (data.containsKey('canvas_y')) {
      context.handle(
        _canvasYMeta,
        canvasY.isAcceptableOrUnknown(data['canvas_y']!, _canvasYMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DestinationTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DestinationTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $DestinationTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      settings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings'],
      )!,
      secretsEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secrets_encrypted'],
      )!,
      lastCheck: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_check'],
      ),
      canvasX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_x'],
      ),
      canvasY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_y'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DestinationTableTable createAlias(String alias) {
    return $DestinationTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DestinationType, String, String> $convertertype =
      const EnumNameConverter<DestinationType>(DestinationType.values);
}

class DestinationTableData extends DataClass
    implements Insertable<DestinationTableData> {
  /// `dst_` and 16 random characters.
  final String id;

  /// Deleting the workspace deletes its destinations.
  final String workspaceSlug;
  final String name;
  final DestinationType type;

  /// [DestinationSettings.toJson]: never a secret.
  final String settings;

  /// The secrets as JSON (`{"secret_access_key": …}`), encrypted with
  /// [SecretCipher] bound to [id].
  final String secretsEncrypted;

  /// The last [ConnectionCheck] as JSON, null until the first test.
  final String? lastCheck;

  /// Where it sits on the canvas; null while it is off it.
  final double? canvasX;
  final double? canvasY;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DestinationTableData({
    required this.id,
    required this.workspaceSlug,
    required this.name,
    required this.type,
    required this.settings,
    required this.secretsEncrypted,
    this.lastCheck,
    this.canvasX,
    this.canvasY,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_slug'] = Variable<String>(workspaceSlug);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $DestinationTableTable.$convertertype.toSql(type),
      );
    }
    map['settings'] = Variable<String>(settings);
    map['secrets_encrypted'] = Variable<String>(secretsEncrypted);
    if (!nullToAbsent || lastCheck != null) {
      map['last_check'] = Variable<String>(lastCheck);
    }
    if (!nullToAbsent || canvasX != null) {
      map['canvas_x'] = Variable<double>(canvasX);
    }
    if (!nullToAbsent || canvasY != null) {
      map['canvas_y'] = Variable<double>(canvasY);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DestinationTableCompanion toCompanion(bool nullToAbsent) {
    return DestinationTableCompanion(
      id: Value(id),
      workspaceSlug: Value(workspaceSlug),
      name: Value(name),
      type: Value(type),
      settings: Value(settings),
      secretsEncrypted: Value(secretsEncrypted),
      lastCheck: lastCheck == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheck),
      canvasX: canvasX == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasX),
      canvasY: canvasY == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasY),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DestinationTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DestinationTableData(
      id: serializer.fromJson<String>(json['id']),
      workspaceSlug: serializer.fromJson<String>(json['workspaceSlug']),
      name: serializer.fromJson<String>(json['name']),
      type: $DestinationTableTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      settings: serializer.fromJson<String>(json['settings']),
      secretsEncrypted: serializer.fromJson<String>(json['secretsEncrypted']),
      lastCheck: serializer.fromJson<String?>(json['lastCheck']),
      canvasX: serializer.fromJson<double?>(json['canvasX']),
      canvasY: serializer.fromJson<double?>(json['canvasY']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceSlug': serializer.toJson<String>(workspaceSlug),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $DestinationTableTable.$convertertype.toJson(type),
      ),
      'settings': serializer.toJson<String>(settings),
      'secretsEncrypted': serializer.toJson<String>(secretsEncrypted),
      'lastCheck': serializer.toJson<String?>(lastCheck),
      'canvasX': serializer.toJson<double?>(canvasX),
      'canvasY': serializer.toJson<double?>(canvasY),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DestinationTableData copyWith({
    String? id,
    String? workspaceSlug,
    String? name,
    DestinationType? type,
    String? settings,
    String? secretsEncrypted,
    Value<String?> lastCheck = const Value.absent(),
    Value<double?> canvasX = const Value.absent(),
    Value<double?> canvasY = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DestinationTableData(
    id: id ?? this.id,
    workspaceSlug: workspaceSlug ?? this.workspaceSlug,
    name: name ?? this.name,
    type: type ?? this.type,
    settings: settings ?? this.settings,
    secretsEncrypted: secretsEncrypted ?? this.secretsEncrypted,
    lastCheck: lastCheck.present ? lastCheck.value : this.lastCheck,
    canvasX: canvasX.present ? canvasX.value : this.canvasX,
    canvasY: canvasY.present ? canvasY.value : this.canvasY,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DestinationTableData copyWithCompanion(DestinationTableCompanion data) {
    return DestinationTableData(
      id: data.id.present ? data.id.value : this.id,
      workspaceSlug: data.workspaceSlug.present
          ? data.workspaceSlug.value
          : this.workspaceSlug,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      settings: data.settings.present ? data.settings.value : this.settings,
      secretsEncrypted: data.secretsEncrypted.present
          ? data.secretsEncrypted.value
          : this.secretsEncrypted,
      lastCheck: data.lastCheck.present ? data.lastCheck.value : this.lastCheck,
      canvasX: data.canvasX.present ? data.canvasX.value : this.canvasX,
      canvasY: data.canvasY.present ? data.canvasY.value : this.canvasY,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DestinationTableData(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings, ')
          ..write('secretsEncrypted: $secretsEncrypted, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceSlug,
    name,
    type,
    settings,
    secretsEncrypted,
    lastCheck,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DestinationTableData &&
          other.id == this.id &&
          other.workspaceSlug == this.workspaceSlug &&
          other.name == this.name &&
          other.type == this.type &&
          other.settings == this.settings &&
          other.secretsEncrypted == this.secretsEncrypted &&
          other.lastCheck == this.lastCheck &&
          other.canvasX == this.canvasX &&
          other.canvasY == this.canvasY &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DestinationTableCompanion extends UpdateCompanion<DestinationTableData> {
  final Value<String> id;
  final Value<String> workspaceSlug;
  final Value<String> name;
  final Value<DestinationType> type;
  final Value<String> settings;
  final Value<String> secretsEncrypted;
  final Value<String?> lastCheck;
  final Value<double?> canvasX;
  final Value<double?> canvasY;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DestinationTableCompanion({
    this.id = const Value.absent(),
    this.workspaceSlug = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.settings = const Value.absent(),
    this.secretsEncrypted = const Value.absent(),
    this.lastCheck = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DestinationTableCompanion.insert({
    required String id,
    required String workspaceSlug,
    required String name,
    required DestinationType type,
    required String settings,
    required String secretsEncrypted,
    this.lastCheck = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceSlug = Value(workspaceSlug),
       name = Value(name),
       type = Value(type),
       settings = Value(settings),
       secretsEncrypted = Value(secretsEncrypted);
  static Insertable<DestinationTableData> custom({
    Expression<String>? id,
    Expression<String>? workspaceSlug,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? settings,
    Expression<String>? secretsEncrypted,
    Expression<String>? lastCheck,
    Expression<double>? canvasX,
    Expression<double>? canvasY,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceSlug != null) 'workspace_slug': workspaceSlug,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (settings != null) 'settings': settings,
      if (secretsEncrypted != null) 'secrets_encrypted': secretsEncrypted,
      if (lastCheck != null) 'last_check': lastCheck,
      if (canvasX != null) 'canvas_x': canvasX,
      if (canvasY != null) 'canvas_y': canvasY,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DestinationTableCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceSlug,
    Value<String>? name,
    Value<DestinationType>? type,
    Value<String>? settings,
    Value<String>? secretsEncrypted,
    Value<String?>? lastCheck,
    Value<double?>? canvasX,
    Value<double?>? canvasY,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DestinationTableCompanion(
      id: id ?? this.id,
      workspaceSlug: workspaceSlug ?? this.workspaceSlug,
      name: name ?? this.name,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      secretsEncrypted: secretsEncrypted ?? this.secretsEncrypted,
      lastCheck: lastCheck ?? this.lastCheck,
      canvasX: canvasX ?? this.canvasX,
      canvasY: canvasY ?? this.canvasY,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceSlug.present) {
      map['workspace_slug'] = Variable<String>(workspaceSlug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $DestinationTableTable.$convertertype.toSql(type.value),
      );
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (secretsEncrypted.present) {
      map['secrets_encrypted'] = Variable<String>(secretsEncrypted.value);
    }
    if (lastCheck.present) {
      map['last_check'] = Variable<String>(lastCheck.value);
    }
    if (canvasX.present) {
      map['canvas_x'] = Variable<double>(canvasX.value);
    }
    if (canvasY.present) {
      map['canvas_y'] = Variable<double>(canvasY.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DestinationTableCompanion(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings, ')
          ..write('secretsEncrypted: $secretsEncrypted, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigTableTable extends ConfigTable
    with TableInfo<$ConfigTableTable, ConfigTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceSlugMeta = const VerificationMeta(
    'workspaceSlug',
  );
  @override
  late final GeneratedColumn<String> workspaceSlug = GeneratedColumn<String>(
    'workspace_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspace (slug) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source (id)',
    ),
  );
  static const VerificationMeta _destinationIdMeta = const VerificationMeta(
    'destinationId',
  );
  @override
  late final GeneratedColumn<String> destinationId = GeneratedColumn<String>(
    'destination_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES destination (id)',
    ),
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleMeta = const VerificationMeta(
    'schedule',
  );
  @override
  late final GeneratedColumn<String> schedule = GeneratedColumn<String>(
    'schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Compression, String> compression =
      GeneratedColumn<String>(
        'compression',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Compression>($ConfigTableTable.$convertercompression);
  static const VerificationMeta _objectKeyMeta = const VerificationMeta(
    'objectKey',
  );
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
    'object_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _canvasXMeta = const VerificationMeta(
    'canvasX',
  );
  @override
  late final GeneratedColumn<double> canvasX = GeneratedColumn<double>(
    'canvas_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canvasYMeta = const VerificationMeta(
    'canvasY',
  );
  @override
  late final GeneratedColumn<double> canvasY = GeneratedColumn<double>(
    'canvas_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceSlug,
    name,
    sourceId,
    destinationId,
    folder,
    schedule,
    compression,
    objectKey,
    enabled,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_slug')) {
      context.handle(
        _workspaceSlugMeta,
        workspaceSlug.isAcceptableOrUnknown(
          data['workspace_slug']!,
          _workspaceSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceSlugMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('destination_id')) {
      context.handle(
        _destinationIdMeta,
        destinationId.isAcceptableOrUnknown(
          data['destination_id']!,
          _destinationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationIdMeta);
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    if (data.containsKey('schedule')) {
      context.handle(
        _scheduleMeta,
        schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleMeta);
    }
    if (data.containsKey('object_key')) {
      context.handle(
        _objectKeyMeta,
        objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_objectKeyMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('canvas_x')) {
      context.handle(
        _canvasXMeta,
        canvasX.isAcceptableOrUnknown(data['canvas_x']!, _canvasXMeta),
      );
    }
    if (data.containsKey('canvas_y')) {
      context.handle(
        _canvasYMeta,
        canvasY.isAcceptableOrUnknown(data['canvas_y']!, _canvasYMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfigTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_slug'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      destinationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_id'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      ),
      schedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule'],
      )!,
      compression: $ConfigTableTable.$convertercompression.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}compression'],
        )!,
      ),
      objectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}object_key'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      canvasX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_x'],
      ),
      canvasY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canvas_y'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ConfigTableTable createAlias(String alias) {
    return $ConfigTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Compression, String, String> $convertercompression =
      const EnumNameConverter<Compression>(Compression.values);
}

class ConfigTableData extends DataClass implements Insertable<ConfigTableData> {
  /// `cfg_` and 16 random characters.
  final String id;

  /// Deleting the workspace deletes its configs.
  final String workspaceSlug;
  final String name;

  /// A source or destination in use can't be deleted: the service answers 409
  /// before the foreign key would fail.
  final String sourceId;
  final String destinationId;

  /// One of the folders of the destination, or null for its root (only when
  /// it has no folders).
  final String? folder;

  /// A cron expression, always in UTC.
  final String schedule;
  final Compression compression;

  /// Relative to the folder, with placeholders and without extension.
  final String objectKey;

  /// A disabled config keeps everything but its schedule doesn't run.
  final bool enabled;

  /// Where it sits on the canvas; null while it is off it.
  final double? canvasX;
  final double? canvasY;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ConfigTableData({
    required this.id,
    required this.workspaceSlug,
    required this.name,
    required this.sourceId,
    required this.destinationId,
    this.folder,
    required this.schedule,
    required this.compression,
    required this.objectKey,
    required this.enabled,
    this.canvasX,
    this.canvasY,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_slug'] = Variable<String>(workspaceSlug);
    map['name'] = Variable<String>(name);
    map['source_id'] = Variable<String>(sourceId);
    map['destination_id'] = Variable<String>(destinationId);
    if (!nullToAbsent || folder != null) {
      map['folder'] = Variable<String>(folder);
    }
    map['schedule'] = Variable<String>(schedule);
    {
      map['compression'] = Variable<String>(
        $ConfigTableTable.$convertercompression.toSql(compression),
      );
    }
    map['object_key'] = Variable<String>(objectKey);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || canvasX != null) {
      map['canvas_x'] = Variable<double>(canvasX);
    }
    if (!nullToAbsent || canvasY != null) {
      map['canvas_y'] = Variable<double>(canvasY);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConfigTableCompanion toCompanion(bool nullToAbsent) {
    return ConfigTableCompanion(
      id: Value(id),
      workspaceSlug: Value(workspaceSlug),
      name: Value(name),
      sourceId: Value(sourceId),
      destinationId: Value(destinationId),
      folder: folder == null && nullToAbsent
          ? const Value.absent()
          : Value(folder),
      schedule: Value(schedule),
      compression: Value(compression),
      objectKey: Value(objectKey),
      enabled: Value(enabled),
      canvasX: canvasX == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasX),
      canvasY: canvasY == null && nullToAbsent
          ? const Value.absent()
          : Value(canvasY),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConfigTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigTableData(
      id: serializer.fromJson<String>(json['id']),
      workspaceSlug: serializer.fromJson<String>(json['workspaceSlug']),
      name: serializer.fromJson<String>(json['name']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      destinationId: serializer.fromJson<String>(json['destinationId']),
      folder: serializer.fromJson<String?>(json['folder']),
      schedule: serializer.fromJson<String>(json['schedule']),
      compression: $ConfigTableTable.$convertercompression.fromJson(
        serializer.fromJson<String>(json['compression']),
      ),
      objectKey: serializer.fromJson<String>(json['objectKey']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      canvasX: serializer.fromJson<double?>(json['canvasX']),
      canvasY: serializer.fromJson<double?>(json['canvasY']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceSlug': serializer.toJson<String>(workspaceSlug),
      'name': serializer.toJson<String>(name),
      'sourceId': serializer.toJson<String>(sourceId),
      'destinationId': serializer.toJson<String>(destinationId),
      'folder': serializer.toJson<String?>(folder),
      'schedule': serializer.toJson<String>(schedule),
      'compression': serializer.toJson<String>(
        $ConfigTableTable.$convertercompression.toJson(compression),
      ),
      'objectKey': serializer.toJson<String>(objectKey),
      'enabled': serializer.toJson<bool>(enabled),
      'canvasX': serializer.toJson<double?>(canvasX),
      'canvasY': serializer.toJson<double?>(canvasY),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConfigTableData copyWith({
    String? id,
    String? workspaceSlug,
    String? name,
    String? sourceId,
    String? destinationId,
    Value<String?> folder = const Value.absent(),
    String? schedule,
    Compression? compression,
    String? objectKey,
    bool? enabled,
    Value<double?> canvasX = const Value.absent(),
    Value<double?> canvasY = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ConfigTableData(
    id: id ?? this.id,
    workspaceSlug: workspaceSlug ?? this.workspaceSlug,
    name: name ?? this.name,
    sourceId: sourceId ?? this.sourceId,
    destinationId: destinationId ?? this.destinationId,
    folder: folder.present ? folder.value : this.folder,
    schedule: schedule ?? this.schedule,
    compression: compression ?? this.compression,
    objectKey: objectKey ?? this.objectKey,
    enabled: enabled ?? this.enabled,
    canvasX: canvasX.present ? canvasX.value : this.canvasX,
    canvasY: canvasY.present ? canvasY.value : this.canvasY,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ConfigTableData copyWithCompanion(ConfigTableCompanion data) {
    return ConfigTableData(
      id: data.id.present ? data.id.value : this.id,
      workspaceSlug: data.workspaceSlug.present
          ? data.workspaceSlug.value
          : this.workspaceSlug,
      name: data.name.present ? data.name.value : this.name,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      destinationId: data.destinationId.present
          ? data.destinationId.value
          : this.destinationId,
      folder: data.folder.present ? data.folder.value : this.folder,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      compression: data.compression.present
          ? data.compression.value
          : this.compression,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      canvasX: data.canvasX.present ? data.canvasX.value : this.canvasX,
      canvasY: data.canvasY.present ? data.canvasY.value : this.canvasY,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigTableData(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('sourceId: $sourceId, ')
          ..write('destinationId: $destinationId, ')
          ..write('folder: $folder, ')
          ..write('schedule: $schedule, ')
          ..write('compression: $compression, ')
          ..write('objectKey: $objectKey, ')
          ..write('enabled: $enabled, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceSlug,
    name,
    sourceId,
    destinationId,
    folder,
    schedule,
    compression,
    objectKey,
    enabled,
    canvasX,
    canvasY,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigTableData &&
          other.id == this.id &&
          other.workspaceSlug == this.workspaceSlug &&
          other.name == this.name &&
          other.sourceId == this.sourceId &&
          other.destinationId == this.destinationId &&
          other.folder == this.folder &&
          other.schedule == this.schedule &&
          other.compression == this.compression &&
          other.objectKey == this.objectKey &&
          other.enabled == this.enabled &&
          other.canvasX == this.canvasX &&
          other.canvasY == this.canvasY &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ConfigTableCompanion extends UpdateCompanion<ConfigTableData> {
  final Value<String> id;
  final Value<String> workspaceSlug;
  final Value<String> name;
  final Value<String> sourceId;
  final Value<String> destinationId;
  final Value<String?> folder;
  final Value<String> schedule;
  final Value<Compression> compression;
  final Value<String> objectKey;
  final Value<bool> enabled;
  final Value<double?> canvasX;
  final Value<double?> canvasY;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConfigTableCompanion({
    this.id = const Value.absent(),
    this.workspaceSlug = const Value.absent(),
    this.name = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.destinationId = const Value.absent(),
    this.folder = const Value.absent(),
    this.schedule = const Value.absent(),
    this.compression = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.enabled = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigTableCompanion.insert({
    required String id,
    required String workspaceSlug,
    required String name,
    required String sourceId,
    required String destinationId,
    this.folder = const Value.absent(),
    required String schedule,
    required Compression compression,
    required String objectKey,
    this.enabled = const Value.absent(),
    this.canvasX = const Value.absent(),
    this.canvasY = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceSlug = Value(workspaceSlug),
       name = Value(name),
       sourceId = Value(sourceId),
       destinationId = Value(destinationId),
       schedule = Value(schedule),
       compression = Value(compression),
       objectKey = Value(objectKey);
  static Insertable<ConfigTableData> custom({
    Expression<String>? id,
    Expression<String>? workspaceSlug,
    Expression<String>? name,
    Expression<String>? sourceId,
    Expression<String>? destinationId,
    Expression<String>? folder,
    Expression<String>? schedule,
    Expression<String>? compression,
    Expression<String>? objectKey,
    Expression<bool>? enabled,
    Expression<double>? canvasX,
    Expression<double>? canvasY,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceSlug != null) 'workspace_slug': workspaceSlug,
      if (name != null) 'name': name,
      if (sourceId != null) 'source_id': sourceId,
      if (destinationId != null) 'destination_id': destinationId,
      if (folder != null) 'folder': folder,
      if (schedule != null) 'schedule': schedule,
      if (compression != null) 'compression': compression,
      if (objectKey != null) 'object_key': objectKey,
      if (enabled != null) 'enabled': enabled,
      if (canvasX != null) 'canvas_x': canvasX,
      if (canvasY != null) 'canvas_y': canvasY,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigTableCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceSlug,
    Value<String>? name,
    Value<String>? sourceId,
    Value<String>? destinationId,
    Value<String?>? folder,
    Value<String>? schedule,
    Value<Compression>? compression,
    Value<String>? objectKey,
    Value<bool>? enabled,
    Value<double?>? canvasX,
    Value<double?>? canvasY,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ConfigTableCompanion(
      id: id ?? this.id,
      workspaceSlug: workspaceSlug ?? this.workspaceSlug,
      name: name ?? this.name,
      sourceId: sourceId ?? this.sourceId,
      destinationId: destinationId ?? this.destinationId,
      folder: folder ?? this.folder,
      schedule: schedule ?? this.schedule,
      compression: compression ?? this.compression,
      objectKey: objectKey ?? this.objectKey,
      enabled: enabled ?? this.enabled,
      canvasX: canvasX ?? this.canvasX,
      canvasY: canvasY ?? this.canvasY,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceSlug.present) {
      map['workspace_slug'] = Variable<String>(workspaceSlug.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (destinationId.present) {
      map['destination_id'] = Variable<String>(destinationId.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<String>(schedule.value);
    }
    if (compression.present) {
      map['compression'] = Variable<String>(
        $ConfigTableTable.$convertercompression.toSql(compression.value),
      );
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (canvasX.present) {
      map['canvas_x'] = Variable<double>(canvasX.value);
    }
    if (canvasY.present) {
      map['canvas_y'] = Variable<double>(canvasY.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigTableCompanion(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('name: $name, ')
          ..write('sourceId: $sourceId, ')
          ..write('destinationId: $destinationId, ')
          ..write('folder: $folder, ')
          ..write('schedule: $schedule, ')
          ..write('compression: $compression, ')
          ..write('objectKey: $objectKey, ')
          ..write('enabled: $enabled, ')
          ..write('canvasX: $canvasX, ')
          ..write('canvasY: $canvasY, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RunTableTable extends RunTable
    with TableInfo<$RunTableTable, RunTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RunTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceSlugMeta = const VerificationMeta(
    'workspaceSlug',
  );
  @override
  late final GeneratedColumn<String> workspaceSlug = GeneratedColumn<String>(
    'workspace_slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workspace (slug) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _configIdMeta = const VerificationMeta(
    'configId',
  );
  @override
  late final GeneratedColumn<String> configId = GeneratedColumn<String>(
    'config_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES config (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _configNameMeta = const VerificationMeta(
    'configName',
  );
  @override
  late final GeneratedColumn<String> configName = GeneratedColumn<String>(
    'config_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNameMeta = const VerificationMeta(
    'sourceName',
  );
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
    'source_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SourceType, String> sourceType =
      GeneratedColumn<String>(
        'source_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SourceType>($RunTableTable.$convertersourceType);
  static const VerificationMeta _destinationNameMeta = const VerificationMeta(
    'destinationName',
  );
  @override
  late final GeneratedColumn<String> destinationName = GeneratedColumn<String>(
    'destination_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DestinationType, String>
  destinationType = GeneratedColumn<String>(
    'destination_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<DestinationType>($RunTableTable.$converterdestinationType);
  @override
  late final GeneratedColumnWithTypeConverter<RunTrigger, String> trigger =
      GeneratedColumn<String>(
        'trigger',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RunTrigger>($RunTableTable.$convertertrigger);
  @override
  late final GeneratedColumnWithTypeConverter<RunStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RunStatus>($RunTableTable.$converterstatus);
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logMeta = const VerificationMeta('log');
  @override
  late final GeneratedColumn<String> log = GeneratedColumn<String>(
    'log',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceSlug,
    configId,
    configName,
    sourceName,
    sourceType,
    destinationName,
    destinationType,
    trigger,
    status,
    location,
    sizeBytes,
    error,
    log,
    startedAt,
    finishedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'run';
  @override
  VerificationContext validateIntegrity(
    Insertable<RunTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_slug')) {
      context.handle(
        _workspaceSlugMeta,
        workspaceSlug.isAcceptableOrUnknown(
          data['workspace_slug']!,
          _workspaceSlugMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceSlugMeta);
    }
    if (data.containsKey('config_id')) {
      context.handle(
        _configIdMeta,
        configId.isAcceptableOrUnknown(data['config_id']!, _configIdMeta),
      );
    }
    if (data.containsKey('config_name')) {
      context.handle(
        _configNameMeta,
        configName.isAcceptableOrUnknown(data['config_name']!, _configNameMeta),
      );
    } else if (isInserting) {
      context.missing(_configNameMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
        _sourceNameMeta,
        sourceName.isAcceptableOrUnknown(data['source_name']!, _sourceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('destination_name')) {
      context.handle(
        _destinationNameMeta,
        destinationName.isAcceptableOrUnknown(
          data['destination_name']!,
          _destinationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationNameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('log')) {
      context.handle(
        _logMeta,
        log.isAcceptableOrUnknown(data['log']!, _logMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RunTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RunTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceSlug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_slug'],
      )!,
      configId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_id'],
      ),
      configName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_name'],
      )!,
      sourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_name'],
      )!,
      sourceType: $RunTableTable.$convertersourceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source_type'],
        )!,
      ),
      destinationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_name'],
      )!,
      destinationType: $RunTableTable.$converterdestinationType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destination_type'],
        )!,
      ),
      trigger: $RunTableTable.$convertertrigger.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trigger'],
        )!,
      ),
      status: $RunTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      log: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
    );
  }

  @override
  $RunTableTable createAlias(String alias) {
    return $RunTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SourceType, String, String> $convertersourceType =
      const EnumNameConverter<SourceType>(SourceType.values);
  static JsonTypeConverter2<DestinationType, String, String>
  $converterdestinationType = const EnumNameConverter<DestinationType>(
    DestinationType.values,
  );
  static JsonTypeConverter2<RunTrigger, String, String> $convertertrigger =
      const EnumNameConverter<RunTrigger>(RunTrigger.values);
  static JsonTypeConverter2<RunStatus, String, String> $converterstatus =
      const EnumNameConverter<RunStatus>(RunStatus.values);
}

class RunTableData extends DataClass implements Insertable<RunTableData> {
  /// `run_` and 16 random characters (also `{run_id}` in the object key).
  final String id;

  /// Deleting the workspace deletes its runs.
  final String workspaceSlug;

  /// Null once the config is deleted.
  final String? configId;
  final String configName;
  final String sourceName;
  final SourceType sourceType;
  final String destinationName;
  final DestinationType destinationType;
  final RunTrigger trigger;
  final RunStatus status;

  /// Where the backup goes (`backups/orders/2026/10/20.dump.gz`), once known.
  final String? location;

  /// Bytes uploaded so far, and in the end the size of the backup.
  final int sizeBytes;

  /// Why it failed, when it did.
  final String? error;

  /// The [RunLogLine]s as a JSON list.
  final String log;
  final DateTime startedAt;
  final DateTime? finishedAt;
  const RunTableData({
    required this.id,
    required this.workspaceSlug,
    this.configId,
    required this.configName,
    required this.sourceName,
    required this.sourceType,
    required this.destinationName,
    required this.destinationType,
    required this.trigger,
    required this.status,
    this.location,
    required this.sizeBytes,
    this.error,
    required this.log,
    required this.startedAt,
    this.finishedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_slug'] = Variable<String>(workspaceSlug);
    if (!nullToAbsent || configId != null) {
      map['config_id'] = Variable<String>(configId);
    }
    map['config_name'] = Variable<String>(configName);
    map['source_name'] = Variable<String>(sourceName);
    {
      map['source_type'] = Variable<String>(
        $RunTableTable.$convertersourceType.toSql(sourceType),
      );
    }
    map['destination_name'] = Variable<String>(destinationName);
    {
      map['destination_type'] = Variable<String>(
        $RunTableTable.$converterdestinationType.toSql(destinationType),
      );
    }
    {
      map['trigger'] = Variable<String>(
        $RunTableTable.$convertertrigger.toSql(trigger),
      );
    }
    {
      map['status'] = Variable<String>(
        $RunTableTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['log'] = Variable<String>(log);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    return map;
  }

  RunTableCompanion toCompanion(bool nullToAbsent) {
    return RunTableCompanion(
      id: Value(id),
      workspaceSlug: Value(workspaceSlug),
      configId: configId == null && nullToAbsent
          ? const Value.absent()
          : Value(configId),
      configName: Value(configName),
      sourceName: Value(sourceName),
      sourceType: Value(sourceType),
      destinationName: Value(destinationName),
      destinationType: Value(destinationType),
      trigger: Value(trigger),
      status: Value(status),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      sizeBytes: Value(sizeBytes),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      log: Value(log),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
    );
  }

  factory RunTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RunTableData(
      id: serializer.fromJson<String>(json['id']),
      workspaceSlug: serializer.fromJson<String>(json['workspaceSlug']),
      configId: serializer.fromJson<String?>(json['configId']),
      configName: serializer.fromJson<String>(json['configName']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      sourceType: $RunTableTable.$convertersourceType.fromJson(
        serializer.fromJson<String>(json['sourceType']),
      ),
      destinationName: serializer.fromJson<String>(json['destinationName']),
      destinationType: $RunTableTable.$converterdestinationType.fromJson(
        serializer.fromJson<String>(json['destinationType']),
      ),
      trigger: $RunTableTable.$convertertrigger.fromJson(
        serializer.fromJson<String>(json['trigger']),
      ),
      status: $RunTableTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      location: serializer.fromJson<String?>(json['location']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      error: serializer.fromJson<String?>(json['error']),
      log: serializer.fromJson<String>(json['log']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceSlug': serializer.toJson<String>(workspaceSlug),
      'configId': serializer.toJson<String?>(configId),
      'configName': serializer.toJson<String>(configName),
      'sourceName': serializer.toJson<String>(sourceName),
      'sourceType': serializer.toJson<String>(
        $RunTableTable.$convertersourceType.toJson(sourceType),
      ),
      'destinationName': serializer.toJson<String>(destinationName),
      'destinationType': serializer.toJson<String>(
        $RunTableTable.$converterdestinationType.toJson(destinationType),
      ),
      'trigger': serializer.toJson<String>(
        $RunTableTable.$convertertrigger.toJson(trigger),
      ),
      'status': serializer.toJson<String>(
        $RunTableTable.$converterstatus.toJson(status),
      ),
      'location': serializer.toJson<String?>(location),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'error': serializer.toJson<String?>(error),
      'log': serializer.toJson<String>(log),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
    };
  }

  RunTableData copyWith({
    String? id,
    String? workspaceSlug,
    Value<String?> configId = const Value.absent(),
    String? configName,
    String? sourceName,
    SourceType? sourceType,
    String? destinationName,
    DestinationType? destinationType,
    RunTrigger? trigger,
    RunStatus? status,
    Value<String?> location = const Value.absent(),
    int? sizeBytes,
    Value<String?> error = const Value.absent(),
    String? log,
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
  }) => RunTableData(
    id: id ?? this.id,
    workspaceSlug: workspaceSlug ?? this.workspaceSlug,
    configId: configId.present ? configId.value : this.configId,
    configName: configName ?? this.configName,
    sourceName: sourceName ?? this.sourceName,
    sourceType: sourceType ?? this.sourceType,
    destinationName: destinationName ?? this.destinationName,
    destinationType: destinationType ?? this.destinationType,
    trigger: trigger ?? this.trigger,
    status: status ?? this.status,
    location: location.present ? location.value : this.location,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    error: error.present ? error.value : this.error,
    log: log ?? this.log,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
  );
  RunTableData copyWithCompanion(RunTableCompanion data) {
    return RunTableData(
      id: data.id.present ? data.id.value : this.id,
      workspaceSlug: data.workspaceSlug.present
          ? data.workspaceSlug.value
          : this.workspaceSlug,
      configId: data.configId.present ? data.configId.value : this.configId,
      configName: data.configName.present
          ? data.configName.value
          : this.configName,
      sourceName: data.sourceName.present
          ? data.sourceName.value
          : this.sourceName,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      destinationName: data.destinationName.present
          ? data.destinationName.value
          : this.destinationName,
      destinationType: data.destinationType.present
          ? data.destinationType.value
          : this.destinationType,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      status: data.status.present ? data.status.value : this.status,
      location: data.location.present ? data.location.value : this.location,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      error: data.error.present ? data.error.value : this.error,
      log: data.log.present ? data.log.value : this.log,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RunTableData(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('configId: $configId, ')
          ..write('configName: $configName, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceType: $sourceType, ')
          ..write('destinationName: $destinationName, ')
          ..write('destinationType: $destinationType, ')
          ..write('trigger: $trigger, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('error: $error, ')
          ..write('log: $log, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceSlug,
    configId,
    configName,
    sourceName,
    sourceType,
    destinationName,
    destinationType,
    trigger,
    status,
    location,
    sizeBytes,
    error,
    log,
    startedAt,
    finishedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RunTableData &&
          other.id == this.id &&
          other.workspaceSlug == this.workspaceSlug &&
          other.configId == this.configId &&
          other.configName == this.configName &&
          other.sourceName == this.sourceName &&
          other.sourceType == this.sourceType &&
          other.destinationName == this.destinationName &&
          other.destinationType == this.destinationType &&
          other.trigger == this.trigger &&
          other.status == this.status &&
          other.location == this.location &&
          other.sizeBytes == this.sizeBytes &&
          other.error == this.error &&
          other.log == this.log &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt);
}

class RunTableCompanion extends UpdateCompanion<RunTableData> {
  final Value<String> id;
  final Value<String> workspaceSlug;
  final Value<String?> configId;
  final Value<String> configName;
  final Value<String> sourceName;
  final Value<SourceType> sourceType;
  final Value<String> destinationName;
  final Value<DestinationType> destinationType;
  final Value<RunTrigger> trigger;
  final Value<RunStatus> status;
  final Value<String?> location;
  final Value<int> sizeBytes;
  final Value<String?> error;
  final Value<String> log;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> rowid;
  const RunTableCompanion({
    this.id = const Value.absent(),
    this.workspaceSlug = const Value.absent(),
    this.configId = const Value.absent(),
    this.configName = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.destinationName = const Value.absent(),
    this.destinationType = const Value.absent(),
    this.trigger = const Value.absent(),
    this.status = const Value.absent(),
    this.location = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.error = const Value.absent(),
    this.log = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RunTableCompanion.insert({
    required String id,
    required String workspaceSlug,
    this.configId = const Value.absent(),
    required String configName,
    required String sourceName,
    required SourceType sourceType,
    required String destinationName,
    required DestinationType destinationType,
    required RunTrigger trigger,
    required RunStatus status,
    this.location = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.error = const Value.absent(),
    this.log = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceSlug = Value(workspaceSlug),
       configName = Value(configName),
       sourceName = Value(sourceName),
       sourceType = Value(sourceType),
       destinationName = Value(destinationName),
       destinationType = Value(destinationType),
       trigger = Value(trigger),
       status = Value(status),
       startedAt = Value(startedAt);
  static Insertable<RunTableData> custom({
    Expression<String>? id,
    Expression<String>? workspaceSlug,
    Expression<String>? configId,
    Expression<String>? configName,
    Expression<String>? sourceName,
    Expression<String>? sourceType,
    Expression<String>? destinationName,
    Expression<String>? destinationType,
    Expression<String>? trigger,
    Expression<String>? status,
    Expression<String>? location,
    Expression<int>? sizeBytes,
    Expression<String>? error,
    Expression<String>? log,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceSlug != null) 'workspace_slug': workspaceSlug,
      if (configId != null) 'config_id': configId,
      if (configName != null) 'config_name': configName,
      if (sourceName != null) 'source_name': sourceName,
      if (sourceType != null) 'source_type': sourceType,
      if (destinationName != null) 'destination_name': destinationName,
      if (destinationType != null) 'destination_type': destinationType,
      if (trigger != null) 'trigger': trigger,
      if (status != null) 'status': status,
      if (location != null) 'location': location,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (error != null) 'error': error,
      if (log != null) 'log': log,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RunTableCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceSlug,
    Value<String?>? configId,
    Value<String>? configName,
    Value<String>? sourceName,
    Value<SourceType>? sourceType,
    Value<String>? destinationName,
    Value<DestinationType>? destinationType,
    Value<RunTrigger>? trigger,
    Value<RunStatus>? status,
    Value<String?>? location,
    Value<int>? sizeBytes,
    Value<String?>? error,
    Value<String>? log,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? rowid,
  }) {
    return RunTableCompanion(
      id: id ?? this.id,
      workspaceSlug: workspaceSlug ?? this.workspaceSlug,
      configId: configId ?? this.configId,
      configName: configName ?? this.configName,
      sourceName: sourceName ?? this.sourceName,
      sourceType: sourceType ?? this.sourceType,
      destinationName: destinationName ?? this.destinationName,
      destinationType: destinationType ?? this.destinationType,
      trigger: trigger ?? this.trigger,
      status: status ?? this.status,
      location: location ?? this.location,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      error: error ?? this.error,
      log: log ?? this.log,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceSlug.present) {
      map['workspace_slug'] = Variable<String>(workspaceSlug.value);
    }
    if (configId.present) {
      map['config_id'] = Variable<String>(configId.value);
    }
    if (configName.present) {
      map['config_name'] = Variable<String>(configName.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(
        $RunTableTable.$convertersourceType.toSql(sourceType.value),
      );
    }
    if (destinationName.present) {
      map['destination_name'] = Variable<String>(destinationName.value);
    }
    if (destinationType.present) {
      map['destination_type'] = Variable<String>(
        $RunTableTable.$converterdestinationType.toSql(destinationType.value),
      );
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(
        $RunTableTable.$convertertrigger.toSql(trigger.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $RunTableTable.$converterstatus.toSql(status.value),
      );
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (log.present) {
      map['log'] = Variable<String>(log.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RunTableCompanion(')
          ..write('id: $id, ')
          ..write('workspaceSlug: $workspaceSlug, ')
          ..write('configId: $configId, ')
          ..write('configName: $configName, ')
          ..write('sourceName: $sourceName, ')
          ..write('sourceType: $sourceType, ')
          ..write('destinationName: $destinationName, ')
          ..write('destinationType: $destinationType, ')
          ..write('trigger: $trigger, ')
          ..write('status: $status, ')
          ..write('location: $location, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('error: $error, ')
          ..write('log: $log, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DestinationFolderTableTable extends DestinationFolderTable
    with TableInfo<$DestinationFolderTableTable, DestinationFolderTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DestinationFolderTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _destinationIdMeta = const VerificationMeta(
    'destinationId',
  );
  @override
  late final GeneratedColumn<String> destinationId = GeneratedColumn<String>(
    'destination_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES destination (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [destinationId, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'destination_folder';
  @override
  VerificationContext validateIntegrity(
    Insertable<DestinationFolderTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('destination_id')) {
      context.handle(
        _destinationIdMeta,
        destinationId.isAcceptableOrUnknown(
          data['destination_id']!,
          _destinationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {destinationId, path};
  @override
  DestinationFolderTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DestinationFolderTableData(
      destinationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
    );
  }

  @override
  $DestinationFolderTableTable createAlias(String alias) {
    return $DestinationFolderTableTable(attachedDatabase, alias);
  }
}

class DestinationFolderTableData extends DataClass
    implements Insertable<DestinationFolderTableData> {
  /// Deleting the destination deletes its folders.
  final String destinationId;

  /// Without slashes around it.
  final String path;
  const DestinationFolderTableData({
    required this.destinationId,
    required this.path,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['destination_id'] = Variable<String>(destinationId);
    map['path'] = Variable<String>(path);
    return map;
  }

  DestinationFolderTableCompanion toCompanion(bool nullToAbsent) {
    return DestinationFolderTableCompanion(
      destinationId: Value(destinationId),
      path: Value(path),
    );
  }

  factory DestinationFolderTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DestinationFolderTableData(
      destinationId: serializer.fromJson<String>(json['destinationId']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'destinationId': serializer.toJson<String>(destinationId),
      'path': serializer.toJson<String>(path),
    };
  }

  DestinationFolderTableData copyWith({String? destinationId, String? path}) =>
      DestinationFolderTableData(
        destinationId: destinationId ?? this.destinationId,
        path: path ?? this.path,
      );
  DestinationFolderTableData copyWithCompanion(
    DestinationFolderTableCompanion data,
  ) {
    return DestinationFolderTableData(
      destinationId: data.destinationId.present
          ? data.destinationId.value
          : this.destinationId,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DestinationFolderTableData(')
          ..write('destinationId: $destinationId, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(destinationId, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DestinationFolderTableData &&
          other.destinationId == this.destinationId &&
          other.path == this.path);
}

class DestinationFolderTableCompanion
    extends UpdateCompanion<DestinationFolderTableData> {
  final Value<String> destinationId;
  final Value<String> path;
  final Value<int> rowid;
  const DestinationFolderTableCompanion({
    this.destinationId = const Value.absent(),
    this.path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DestinationFolderTableCompanion.insert({
    required String destinationId,
    required String path,
    this.rowid = const Value.absent(),
  }) : destinationId = Value(destinationId),
       path = Value(path);
  static Insertable<DestinationFolderTableData> custom({
    Expression<String>? destinationId,
    Expression<String>? path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (destinationId != null) 'destination_id': destinationId,
      if (path != null) 'path': path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DestinationFolderTableCompanion copyWith({
    Value<String>? destinationId,
    Value<String>? path,
    Value<int>? rowid,
  }) {
    return DestinationFolderTableCompanion(
      destinationId: destinationId ?? this.destinationId,
      path: path ?? this.path,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (destinationId.present) {
      map['destination_id'] = Variable<String>(destinationId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DestinationFolderTableCompanion(')
          ..write('destinationId: $destinationId, ')
          ..write('path: $path, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkspaceTableTable workspaceTable = $WorkspaceTableTable(this);
  late final $SourceTableTable sourceTable = $SourceTableTable(this);
  late final $DestinationTableTable destinationTable = $DestinationTableTable(
    this,
  );
  late final $ConfigTableTable configTable = $ConfigTableTable(this);
  late final $RunTableTable runTable = $RunTableTable(this);
  late final $DestinationFolderTableTable destinationFolderTable =
      $DestinationFolderTableTable(this);
  late final Index runConfigStarted = Index(
    'run_config_started',
    'CREATE INDEX run_config_started ON run (config_id, started_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    workspaceTable,
    sourceTable,
    destinationTable,
    configTable,
    runTable,
    destinationFolderTable,
    runConfigStarted,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspace',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('source', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspace',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('destination', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspace',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('config', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workspace',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('run', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'config',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('run', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'destination',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('destination_folder', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$WorkspaceTableTableCreateCompanionBuilder =
    WorkspaceTableCompanion Function({
      required String slug,
      required String name,
      Value<String?> description,
      Value<int?> color,
      required String defaultSchedule,
      required Compression defaultCompression,
      required String defaultObjectKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WorkspaceTableTableUpdateCompanionBuilder =
    WorkspaceTableCompanion Function({
      Value<String> slug,
      Value<String> name,
      Value<String?> description,
      Value<int?> color,
      Value<String> defaultSchedule,
      Value<Compression> defaultCompression,
      Value<String> defaultObjectKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$WorkspaceTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkspaceTableTable,
          WorkspaceTableData
        > {
  $$WorkspaceTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SourceTableTable, List<SourceTableData>>
  _sourceTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sourceTable,
    aliasName: 'workspace__slug__source__workspace_slug',
  );

  $$SourceTableTableProcessedTableManager get sourceTableRefs {
    final manager = $$SourceTableTableTableManager($_db, $_db.sourceTable)
        .filter(
          (f) => f.workspaceSlug.slug.sqlEquals($_itemColumn<String>('slug')!),
        );

    final cache = $_typedResult.readTableOrNull(_sourceTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DestinationTableTable, List<DestinationTableData>>
  _destinationTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.destinationTable,
    aliasName: 'workspace__slug__destination__workspace_slug',
  );

  $$DestinationTableTableProcessedTableManager get destinationTableRefs {
    final manager =
        $$DestinationTableTableTableManager($_db, $_db.destinationTable).filter(
          (f) => f.workspaceSlug.slug.sqlEquals($_itemColumn<String>('slug')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _destinationTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConfigTableTable, List<ConfigTableData>>
  _configTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.configTable,
    aliasName: 'workspace__slug__config__workspace_slug',
  );

  $$ConfigTableTableProcessedTableManager get configTableRefs {
    final manager = $$ConfigTableTableTableManager($_db, $_db.configTable)
        .filter(
          (f) => f.workspaceSlug.slug.sqlEquals($_itemColumn<String>('slug')!),
        );

    final cache = $_typedResult.readTableOrNull(_configTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RunTableTable, List<RunTableData>>
  _runTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runTable,
    aliasName: 'workspace__slug__run__workspace_slug',
  );

  $$RunTableTableProcessedTableManager get runTableRefs {
    final manager = $$RunTableTableTableManager($_db, $_db.runTable).filter(
      (f) => f.workspaceSlug.slug.sqlEquals($_itemColumn<String>('slug')!),
    );

    final cache = $_typedResult.readTableOrNull(_runTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkspaceTableTableFilterComposer
    extends Composer<_$AppDatabase, $WorkspaceTableTable> {
  $$WorkspaceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultSchedule => $composableBuilder(
    column: $table.defaultSchedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Compression, Compression, String>
  get defaultCompression => $composableBuilder(
    column: $table.defaultCompression,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get defaultObjectKey => $composableBuilder(
    column: $table.defaultObjectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceTableRefs(
    Expression<bool> Function($$SourceTableTableFilterComposer f) f,
  ) {
    final $$SourceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.sourceTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTableTableFilterComposer(
            $db: $db,
            $table: $db.sourceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> destinationTableRefs(
    Expression<bool> Function($$DestinationTableTableFilterComposer f) f,
  ) {
    final $$DestinationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableFilterComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> configTableRefs(
    Expression<bool> Function($$ConfigTableTableFilterComposer f) f,
  ) {
    final $$ConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> runTableRefs(
    Expression<bool> Function($$RunTableTableFilterComposer f) f,
  ) {
    final $$RunTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.runTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunTableTableFilterComposer(
            $db: $db,
            $table: $db.runTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspaceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkspaceTableTable> {
  $$WorkspaceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultSchedule => $composableBuilder(
    column: $table.defaultSchedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCompression => $composableBuilder(
    column: $table.defaultCompression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultObjectKey => $composableBuilder(
    column: $table.defaultObjectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkspaceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkspaceTableTable> {
  $$WorkspaceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get defaultSchedule => $composableBuilder(
    column: $table.defaultSchedule,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Compression, String>
  get defaultCompression => $composableBuilder(
    column: $table.defaultCompression,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultObjectKey => $composableBuilder(
    column: $table.defaultObjectKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sourceTableRefs<T extends Object>(
    Expression<T> Function($$SourceTableTableAnnotationComposer a) f,
  ) {
    final $$SourceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.sourceTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> destinationTableRefs<T extends Object>(
    Expression<T> Function($$DestinationTableTableAnnotationComposer a) f,
  ) {
    final $$DestinationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> configTableRefs<T extends Object>(
    Expression<T> Function($$ConfigTableTableAnnotationComposer a) f,
  ) {
    final $$ConfigTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableAnnotationComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> runTableRefs<T extends Object>(
    Expression<T> Function($$RunTableTableAnnotationComposer a) f,
  ) {
    final $$RunTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slug,
      referencedTable: $db.runTable,
      getReferencedColumn: (t) => t.workspaceSlug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkspaceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkspaceTableTable,
          WorkspaceTableData,
          $$WorkspaceTableTableFilterComposer,
          $$WorkspaceTableTableOrderingComposer,
          $$WorkspaceTableTableAnnotationComposer,
          $$WorkspaceTableTableCreateCompanionBuilder,
          $$WorkspaceTableTableUpdateCompanionBuilder,
          (WorkspaceTableData, $$WorkspaceTableTableReferences),
          WorkspaceTableData,
          PrefetchHooks Function({
            bool sourceTableRefs,
            bool destinationTableRefs,
            bool configTableRefs,
            bool runTableRefs,
          })
        > {
  $$WorkspaceTableTableTableManager(
    _$AppDatabase db,
    $WorkspaceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkspaceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkspaceTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkspaceTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> slug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String> defaultSchedule = const Value.absent(),
                Value<Compression> defaultCompression = const Value.absent(),
                Value<String> defaultObjectKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceTableCompanion(
                slug: slug,
                name: name,
                description: description,
                color: color,
                defaultSchedule: defaultSchedule,
                defaultCompression: defaultCompression,
                defaultObjectKey: defaultObjectKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String slug,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> color = const Value.absent(),
                required String defaultSchedule,
                required Compression defaultCompression,
                required String defaultObjectKey,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkspaceTableCompanion.insert(
                slug: slug,
                name: name,
                description: description,
                color: color,
                defaultSchedule: defaultSchedule,
                defaultCompression: defaultCompression,
                defaultObjectKey: defaultObjectKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkspaceTableTable, WorkspaceTableData>(table),
                  $$WorkspaceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceTableRefs = false,
                destinationTableRefs = false,
                configTableRefs = false,
                runTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sourceTableRefs) db.sourceTable,
                    if (destinationTableRefs) db.destinationTable,
                    if (configTableRefs) db.configTable,
                    if (runTableRefs) db.runTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sourceTableRefs)
                        await $_getPrefetchedData<
                          WorkspaceTableData,
                          $WorkspaceTableTable,
                          SourceTableData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspaceTableTableReferences
                              ._sourceTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspaceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).sourceTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceSlug == item.slug,
                              ),
                          typedResults: items,
                        ),
                      if (destinationTableRefs)
                        await $_getPrefetchedData<
                          WorkspaceTableData,
                          $WorkspaceTableTable,
                          DestinationTableData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspaceTableTableReferences
                              ._destinationTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspaceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).destinationTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceSlug == item.slug,
                              ),
                          typedResults: items,
                        ),
                      if (configTableRefs)
                        await $_getPrefetchedData<
                          WorkspaceTableData,
                          $WorkspaceTableTable,
                          ConfigTableData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspaceTableTableReferences
                              ._configTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspaceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).configTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceSlug == item.slug,
                              ),
                          typedResults: items,
                        ),
                      if (runTableRefs)
                        await $_getPrefetchedData<
                          WorkspaceTableData,
                          $WorkspaceTableTable,
                          RunTableData
                        >(
                          currentTable: table,
                          referencedTable: $$WorkspaceTableTableReferences
                              ._runTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkspaceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).runTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.workspaceSlug == item.slug,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkspaceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkspaceTableTable,
      WorkspaceTableData,
      $$WorkspaceTableTableFilterComposer,
      $$WorkspaceTableTableOrderingComposer,
      $$WorkspaceTableTableAnnotationComposer,
      $$WorkspaceTableTableCreateCompanionBuilder,
      $$WorkspaceTableTableUpdateCompanionBuilder,
      (WorkspaceTableData, $$WorkspaceTableTableReferences),
      WorkspaceTableData,
      PrefetchHooks Function({
        bool sourceTableRefs,
        bool destinationTableRefs,
        bool configTableRefs,
        bool runTableRefs,
      })
    >;
typedef $$SourceTableTableCreateCompanionBuilder =
    SourceTableCompanion Function({
      required String id,
      required String workspaceSlug,
      required String name,
      required SourceType type,
      required String settings,
      required String secretsEncrypted,
      Value<String?> lastCheck,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SourceTableTableUpdateCompanionBuilder =
    SourceTableCompanion Function({
      Value<String> id,
      Value<String> workspaceSlug,
      Value<String> name,
      Value<SourceType> type,
      Value<String> settings,
      Value<String> secretsEncrypted,
      Value<String?> lastCheck,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SourceTableTableReferences
    extends BaseReferences<_$AppDatabase, $SourceTableTable, SourceTableData> {
  $$SourceTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspaceTableTable _workspaceSlugTable(_$AppDatabase db) =>
      db.workspaceTable.createAlias('source__workspace_slug__workspace__slug');

  $$WorkspaceTableTableProcessedTableManager get workspaceSlug {
    final $_column = $_itemColumn<String>('workspace_slug')!;

    final manager = $$WorkspaceTableTableTableManager(
      $_db,
      $_db.workspaceTable,
    ).filter((f) => f.slug.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceSlugTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ConfigTableTable, List<ConfigTableData>>
  _configTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.configTable,
    aliasName: 'source__id__config__source_id',
  );

  $$ConfigTableTableProcessedTableManager get configTableRefs {
    final manager = $$ConfigTableTableTableManager(
      $_db,
      $_db.configTable,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_configTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceTableTableFilterComposer
    extends Composer<_$AppDatabase, $SourceTableTable> {
  $$SourceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SourceType, SourceType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspaceTableTableFilterComposer get workspaceSlug {
    final $$WorkspaceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableFilterComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> configTableRefs(
    Expression<bool> Function($$ConfigTableTableFilterComposer f) f,
  ) {
    final $$ConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceTableTable> {
  $$SourceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspaceTableTableOrderingComposer get workspaceSlug {
    final $$WorkspaceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableOrderingComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceTableTable> {
  $$SourceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SourceType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCheck =>
      $composableBuilder(column: $table.lastCheck, builder: (column) => column);

  GeneratedColumn<double> get canvasX =>
      $composableBuilder(column: $table.canvasX, builder: (column) => column);

  GeneratedColumn<double> get canvasY =>
      $composableBuilder(column: $table.canvasY, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspaceTableTableAnnotationComposer get workspaceSlug {
    final $$WorkspaceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> configTableRefs<T extends Object>(
    Expression<T> Function($$ConfigTableTableAnnotationComposer a) f,
  ) {
    final $$ConfigTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableAnnotationComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceTableTable,
          SourceTableData,
          $$SourceTableTableFilterComposer,
          $$SourceTableTableOrderingComposer,
          $$SourceTableTableAnnotationComposer,
          $$SourceTableTableCreateCompanionBuilder,
          $$SourceTableTableUpdateCompanionBuilder,
          (SourceTableData, $$SourceTableTableReferences),
          SourceTableData,
          PrefetchHooks Function({bool workspaceSlug, bool configTableRefs})
        > {
  $$SourceTableTableTableManager(_$AppDatabase db, $SourceTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceSlug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<SourceType> type = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<String> secretsEncrypted = const Value.absent(),
                Value<String?> lastCheck = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceTableCompanion(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                type: type,
                settings: settings,
                secretsEncrypted: secretsEncrypted,
                lastCheck: lastCheck,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceSlug,
                required String name,
                required SourceType type,
                required String settings,
                required String secretsEncrypted,
                Value<String?> lastCheck = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourceTableCompanion.insert(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                type: type,
                settings: settings,
                secretsEncrypted: secretsEncrypted,
                lastCheck: lastCheck,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SourceTableTable, SourceTableData>(table),
                  $$SourceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workspaceSlug = false, configTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (configTableRefs) db.configTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceSlug) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workspaceSlug,
                            referencedTable: $$SourceTableTableReferences
                                ._workspaceSlugTable(db),
                            referencedColumn: $$SourceTableTableReferences
                                ._workspaceSlugTable(db)
                                .slug,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (configTableRefs)
                        await $_getPrefetchedData<
                          SourceTableData,
                          $SourceTableTable,
                          ConfigTableData
                        >(
                          currentTable: table,
                          referencedTable: $$SourceTableTableReferences
                              ._configTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceTableTableReferences(
                                db,
                                table,
                                p0,
                              ).configTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceTableTable,
      SourceTableData,
      $$SourceTableTableFilterComposer,
      $$SourceTableTableOrderingComposer,
      $$SourceTableTableAnnotationComposer,
      $$SourceTableTableCreateCompanionBuilder,
      $$SourceTableTableUpdateCompanionBuilder,
      (SourceTableData, $$SourceTableTableReferences),
      SourceTableData,
      PrefetchHooks Function({bool workspaceSlug, bool configTableRefs})
    >;
typedef $$DestinationTableTableCreateCompanionBuilder =
    DestinationTableCompanion Function({
      required String id,
      required String workspaceSlug,
      required String name,
      required DestinationType type,
      required String settings,
      required String secretsEncrypted,
      Value<String?> lastCheck,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$DestinationTableTableUpdateCompanionBuilder =
    DestinationTableCompanion Function({
      Value<String> id,
      Value<String> workspaceSlug,
      Value<String> name,
      Value<DestinationType> type,
      Value<String> settings,
      Value<String> secretsEncrypted,
      Value<String?> lastCheck,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DestinationTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DestinationTableTable,
          DestinationTableData
        > {
  $$DestinationTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkspaceTableTable _workspaceSlugTable(_$AppDatabase db) => db
      .workspaceTable
      .createAlias('destination__workspace_slug__workspace__slug');

  $$WorkspaceTableTableProcessedTableManager get workspaceSlug {
    final $_column = $_itemColumn<String>('workspace_slug')!;

    final manager = $$WorkspaceTableTableTableManager(
      $_db,
      $_db.workspaceTable,
    ).filter((f) => f.slug.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceSlugTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ConfigTableTable, List<ConfigTableData>>
  _configTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.configTable,
    aliasName: 'destination__id__config__destination_id',
  );

  $$ConfigTableTableProcessedTableManager get configTableRefs {
    final manager = $$ConfigTableTableTableManager(
      $_db,
      $_db.configTable,
    ).filter((f) => f.destinationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_configTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $DestinationFolderTableTable,
    List<DestinationFolderTableData>
  >
  _destinationFolderTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.destinationFolderTable,
        aliasName: 'destination__id__destination_folder__destination_id',
      );

  $$DestinationFolderTableTableProcessedTableManager
  get destinationFolderTableRefs {
    final manager = $$DestinationFolderTableTableTableManager(
      $_db,
      $_db.destinationFolderTable,
    ).filter((f) => f.destinationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _destinationFolderTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DestinationTableTableFilterComposer
    extends Composer<_$AppDatabase, $DestinationTableTable> {
  $$DestinationTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DestinationType, DestinationType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspaceTableTableFilterComposer get workspaceSlug {
    final $$WorkspaceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableFilterComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> configTableRefs(
    Expression<bool> Function($$ConfigTableTableFilterComposer f) f,
  ) {
    final $$ConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.destinationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> destinationFolderTableRefs(
    Expression<bool> Function($$DestinationFolderTableTableFilterComposer f) f,
  ) {
    final $$DestinationFolderTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.destinationFolderTable,
          getReferencedColumn: (t) => t.destinationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DestinationFolderTableTableFilterComposer(
                $db: $db,
                $table: $db.destinationFolderTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DestinationTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DestinationTableTable> {
  $$DestinationTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastCheck => $composableBuilder(
    column: $table.lastCheck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspaceTableTableOrderingComposer get workspaceSlug {
    final $$WorkspaceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableOrderingComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DestinationTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DestinationTableTable> {
  $$DestinationTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DestinationType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<String> get secretsEncrypted => $composableBuilder(
    column: $table.secretsEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastCheck =>
      $composableBuilder(column: $table.lastCheck, builder: (column) => column);

  GeneratedColumn<double> get canvasX =>
      $composableBuilder(column: $table.canvasX, builder: (column) => column);

  GeneratedColumn<double> get canvasY =>
      $composableBuilder(column: $table.canvasY, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspaceTableTableAnnotationComposer get workspaceSlug {
    final $$WorkspaceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> configTableRefs<T extends Object>(
    Expression<T> Function($$ConfigTableTableAnnotationComposer a) f,
  ) {
    final $$ConfigTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.destinationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableAnnotationComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> destinationFolderTableRefs<T extends Object>(
    Expression<T> Function($$DestinationFolderTableTableAnnotationComposer a) f,
  ) {
    final $$DestinationFolderTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.destinationFolderTable,
          getReferencedColumn: (t) => t.destinationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DestinationFolderTableTableAnnotationComposer(
                $db: $db,
                $table: $db.destinationFolderTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$DestinationTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DestinationTableTable,
          DestinationTableData,
          $$DestinationTableTableFilterComposer,
          $$DestinationTableTableOrderingComposer,
          $$DestinationTableTableAnnotationComposer,
          $$DestinationTableTableCreateCompanionBuilder,
          $$DestinationTableTableUpdateCompanionBuilder,
          (DestinationTableData, $$DestinationTableTableReferences),
          DestinationTableData,
          PrefetchHooks Function({
            bool workspaceSlug,
            bool configTableRefs,
            bool destinationFolderTableRefs,
          })
        > {
  $$DestinationTableTableTableManager(
    _$AppDatabase db,
    $DestinationTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DestinationTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DestinationTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DestinationTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceSlug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DestinationType> type = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<String> secretsEncrypted = const Value.absent(),
                Value<String?> lastCheck = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestinationTableCompanion(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                type: type,
                settings: settings,
                secretsEncrypted: secretsEncrypted,
                lastCheck: lastCheck,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceSlug,
                required String name,
                required DestinationType type,
                required String settings,
                required String secretsEncrypted,
                Value<String?> lastCheck = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestinationTableCompanion.insert(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                type: type,
                settings: settings,
                secretsEncrypted: secretsEncrypted,
                lastCheck: lastCheck,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DestinationTableTable, DestinationTableData>(
                    table,
                  ),
                  $$DestinationTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceSlug = false,
                configTableRefs = false,
                destinationFolderTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (configTableRefs) db.configTable,
                    if (destinationFolderTableRefs) db.destinationFolderTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceSlug) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workspaceSlug,
                            referencedTable: $$DestinationTableTableReferences
                                ._workspaceSlugTable(db),
                            referencedColumn: $$DestinationTableTableReferences
                                ._workspaceSlugTable(db)
                                .slug,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (configTableRefs)
                        await $_getPrefetchedData<
                          DestinationTableData,
                          $DestinationTableTable,
                          ConfigTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DestinationTableTableReferences
                              ._configTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DestinationTableTableReferences(
                                db,
                                table,
                                p0,
                              ).configTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.destinationId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (destinationFolderTableRefs)
                        await $_getPrefetchedData<
                          DestinationTableData,
                          $DestinationTableTable,
                          DestinationFolderTableData
                        >(
                          currentTable: table,
                          referencedTable: $$DestinationTableTableReferences
                              ._destinationFolderTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DestinationTableTableReferences(
                                db,
                                table,
                                p0,
                              ).destinationFolderTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.destinationId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DestinationTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DestinationTableTable,
      DestinationTableData,
      $$DestinationTableTableFilterComposer,
      $$DestinationTableTableOrderingComposer,
      $$DestinationTableTableAnnotationComposer,
      $$DestinationTableTableCreateCompanionBuilder,
      $$DestinationTableTableUpdateCompanionBuilder,
      (DestinationTableData, $$DestinationTableTableReferences),
      DestinationTableData,
      PrefetchHooks Function({
        bool workspaceSlug,
        bool configTableRefs,
        bool destinationFolderTableRefs,
      })
    >;
typedef $$ConfigTableTableCreateCompanionBuilder =
    ConfigTableCompanion Function({
      required String id,
      required String workspaceSlug,
      required String name,
      required String sourceId,
      required String destinationId,
      Value<String?> folder,
      required String schedule,
      required Compression compression,
      required String objectKey,
      Value<bool> enabled,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ConfigTableTableUpdateCompanionBuilder =
    ConfigTableCompanion Function({
      Value<String> id,
      Value<String> workspaceSlug,
      Value<String> name,
      Value<String> sourceId,
      Value<String> destinationId,
      Value<String?> folder,
      Value<String> schedule,
      Value<Compression> compression,
      Value<String> objectKey,
      Value<bool> enabled,
      Value<double?> canvasX,
      Value<double?> canvasY,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ConfigTableTableReferences
    extends BaseReferences<_$AppDatabase, $ConfigTableTable, ConfigTableData> {
  $$ConfigTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspaceTableTable _workspaceSlugTable(_$AppDatabase db) =>
      db.workspaceTable.createAlias('config__workspace_slug__workspace__slug');

  $$WorkspaceTableTableProcessedTableManager get workspaceSlug {
    final $_column = $_itemColumn<String>('workspace_slug')!;

    final manager = $$WorkspaceTableTableTableManager(
      $_db,
      $_db.workspaceTable,
    ).filter((f) => f.slug.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceSlugTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceTableTable _sourceIdTable(_$AppDatabase db) =>
      db.sourceTable.createAlias('config__source_id__source__id');

  $$SourceTableTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<String>('source_id')!;

    final manager = $$SourceTableTableTableManager(
      $_db,
      $_db.sourceTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DestinationTableTable _destinationIdTable(_$AppDatabase db) => db
      .destinationTable
      .createAlias('config__destination_id__destination__id');

  $$DestinationTableTableProcessedTableManager get destinationId {
    final $_column = $_itemColumn<String>('destination_id')!;

    final manager = $$DestinationTableTableTableManager(
      $_db,
      $_db.destinationTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_destinationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RunTableTable, List<RunTableData>>
  _runTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.runTable,
    aliasName: 'config__id__run__config_id',
  );

  $$RunTableTableProcessedTableManager get runTableRefs {
    final manager = $$RunTableTableTableManager(
      $_db,
      $_db.runTable,
    ).filter((f) => f.configId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_runTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConfigTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigTableTable> {
  $$ConfigTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Compression, Compression, String>
  get compression => $composableBuilder(
    column: $table.compression,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspaceTableTableFilterComposer get workspaceSlug {
    final $$WorkspaceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableFilterComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceTableTableFilterComposer get sourceId {
    final $$SourceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTableTableFilterComposer(
            $db: $db,
            $table: $db.sourceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DestinationTableTableFilterComposer get destinationId {
    final $$DestinationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableFilterComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> runTableRefs(
    Expression<bool> Function($$RunTableTableFilterComposer f) f,
  ) {
    final $$RunTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runTable,
      getReferencedColumn: (t) => t.configId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunTableTableFilterComposer(
            $db: $db,
            $table: $db.runTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConfigTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigTableTable> {
  $$ConfigTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get compression => $composableBuilder(
    column: $table.compression,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get objectKey => $composableBuilder(
    column: $table.objectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasX => $composableBuilder(
    column: $table.canvasX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canvasY => $composableBuilder(
    column: $table.canvasY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspaceTableTableOrderingComposer get workspaceSlug {
    final $$WorkspaceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableOrderingComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceTableTableOrderingComposer get sourceId {
    final $$SourceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTableTableOrderingComposer(
            $db: $db,
            $table: $db.sourceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DestinationTableTableOrderingComposer get destinationId {
    final $$DestinationTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableOrderingComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConfigTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigTableTable> {
  $$ConfigTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Compression, String> get compression =>
      $composableBuilder(
        column: $table.compression,
        builder: (column) => column,
      );

  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<double> get canvasX =>
      $composableBuilder(column: $table.canvasX, builder: (column) => column);

  GeneratedColumn<double> get canvasY =>
      $composableBuilder(column: $table.canvasY, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WorkspaceTableTableAnnotationComposer get workspaceSlug {
    final $$WorkspaceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceTableTableAnnotationComposer get sourceId {
    final $$SourceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sourceTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DestinationTableTableAnnotationComposer get destinationId {
    final $$DestinationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> runTableRefs<T extends Object>(
    Expression<T> Function($$RunTableTableAnnotationComposer a) f,
  ) {
    final $$RunTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.runTable,
      getReferencedColumn: (t) => t.configId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RunTableTableAnnotationComposer(
            $db: $db,
            $table: $db.runTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConfigTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigTableTable,
          ConfigTableData,
          $$ConfigTableTableFilterComposer,
          $$ConfigTableTableOrderingComposer,
          $$ConfigTableTableAnnotationComposer,
          $$ConfigTableTableCreateCompanionBuilder,
          $$ConfigTableTableUpdateCompanionBuilder,
          (ConfigTableData, $$ConfigTableTableReferences),
          ConfigTableData,
          PrefetchHooks Function({
            bool workspaceSlug,
            bool sourceId,
            bool destinationId,
            bool runTableRefs,
          })
        > {
  $$ConfigTableTableTableManager(_$AppDatabase db, $ConfigTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceSlug = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> destinationId = const Value.absent(),
                Value<String?> folder = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<Compression> compression = const Value.absent(),
                Value<String> objectKey = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigTableCompanion(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                sourceId: sourceId,
                destinationId: destinationId,
                folder: folder,
                schedule: schedule,
                compression: compression,
                objectKey: objectKey,
                enabled: enabled,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceSlug,
                required String name,
                required String sourceId,
                required String destinationId,
                Value<String?> folder = const Value.absent(),
                required String schedule,
                required Compression compression,
                required String objectKey,
                Value<bool> enabled = const Value.absent(),
                Value<double?> canvasX = const Value.absent(),
                Value<double?> canvasY = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigTableCompanion.insert(
                id: id,
                workspaceSlug: workspaceSlug,
                name: name,
                sourceId: sourceId,
                destinationId: destinationId,
                folder: folder,
                schedule: schedule,
                compression: compression,
                objectKey: objectKey,
                enabled: enabled,
                canvasX: canvasX,
                canvasY: canvasY,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigTableTable, ConfigTableData>(table),
                  $$ConfigTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workspaceSlug = false,
                sourceId = false,
                destinationId = false,
                runTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (runTableRefs) db.runTable],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (workspaceSlug) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workspaceSlug,
                            referencedTable: $$ConfigTableTableReferences
                                ._workspaceSlugTable(db),
                            referencedColumn: $$ConfigTableTableReferences
                                ._workspaceSlugTable(db)
                                .slug,
                          ) as T;
                        }
                        if (sourceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceId,
                            referencedTable: $$ConfigTableTableReferences
                                ._sourceIdTable(db),
                            referencedColumn: $$ConfigTableTableReferences
                                ._sourceIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (destinationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.destinationId,
                            referencedTable: $$ConfigTableTableReferences
                                ._destinationIdTable(db),
                            referencedColumn: $$ConfigTableTableReferences
                                ._destinationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (runTableRefs)
                        await $_getPrefetchedData<
                          ConfigTableData,
                          $ConfigTableTable,
                          RunTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ConfigTableTableReferences
                              ._runTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ConfigTableTableReferences(
                                db,
                                table,
                                p0,
                              ).runTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.configId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ConfigTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigTableTable,
      ConfigTableData,
      $$ConfigTableTableFilterComposer,
      $$ConfigTableTableOrderingComposer,
      $$ConfigTableTableAnnotationComposer,
      $$ConfigTableTableCreateCompanionBuilder,
      $$ConfigTableTableUpdateCompanionBuilder,
      (ConfigTableData, $$ConfigTableTableReferences),
      ConfigTableData,
      PrefetchHooks Function({
        bool workspaceSlug,
        bool sourceId,
        bool destinationId,
        bool runTableRefs,
      })
    >;
typedef $$RunTableTableCreateCompanionBuilder = RunTableCompanion Function({
  required String id,
  required String workspaceSlug,
  Value<String?> configId,
  required String configName,
  required String sourceName,
  required SourceType sourceType,
  required String destinationName,
  required DestinationType destinationType,
  required RunTrigger trigger,
  required RunStatus status,
  Value<String?> location,
  Value<int> sizeBytes,
  Value<String?> error,
  Value<String> log,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<int> rowid,
});
typedef $$RunTableTableUpdateCompanionBuilder = RunTableCompanion Function({
  Value<String> id,
  Value<String> workspaceSlug,
  Value<String?> configId,
  Value<String> configName,
  Value<String> sourceName,
  Value<SourceType> sourceType,
  Value<String> destinationName,
  Value<DestinationType> destinationType,
  Value<RunTrigger> trigger,
  Value<RunStatus> status,
  Value<String?> location,
  Value<int> sizeBytes,
  Value<String?> error,
  Value<String> log,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<int> rowid,
});

final class $$RunTableTableReferences
    extends BaseReferences<_$AppDatabase, $RunTableTable, RunTableData> {
  $$RunTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkspaceTableTable _workspaceSlugTable(_$AppDatabase db) =>
      db.workspaceTable.createAlias('run__workspace_slug__workspace__slug');

  $$WorkspaceTableTableProcessedTableManager get workspaceSlug {
    final $_column = $_itemColumn<String>('workspace_slug')!;

    final manager = $$WorkspaceTableTableTableManager(
      $_db,
      $_db.workspaceTable,
    ).filter((f) => f.slug.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workspaceSlugTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ConfigTableTable _configIdTable(_$AppDatabase db) =>
      db.configTable.createAlias('run__config_id__config__id');

  $$ConfigTableTableProcessedTableManager? get configId {
    final $_column = $_itemColumn<String>('config_id');
    if ($_column == null) return null;
    final manager = $$ConfigTableTableTableManager(
      $_db,
      $_db.configTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_configIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RunTableTableFilterComposer
    extends Composer<_$AppDatabase, $RunTableTable> {
  $$RunTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configName => $composableBuilder(
    column: $table.configName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SourceType, SourceType, String>
  get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DestinationType, DestinationType, String>
  get destinationType => $composableBuilder(
    column: $table.destinationType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<RunTrigger, RunTrigger, String> get trigger =>
      $composableBuilder(
        column: $table.trigger,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<RunStatus, RunStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get log => $composableBuilder(
    column: $table.log,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkspaceTableTableFilterComposer get workspaceSlug {
    final $$WorkspaceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableFilterComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigTableTableFilterComposer get configId {
    final $$ConfigTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configId,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableFilterComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RunTableTable> {
  $$RunTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configName => $composableBuilder(
    column: $table.configName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationType => $composableBuilder(
    column: $table.destinationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trigger => $composableBuilder(
    column: $table.trigger,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get log => $composableBuilder(
    column: $table.log,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkspaceTableTableOrderingComposer get workspaceSlug {
    final $$WorkspaceTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableOrderingComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigTableTableOrderingComposer get configId {
    final $$ConfigTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configId,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableOrderingComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RunTableTable> {
  $$RunTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get configName => $composableBuilder(
    column: $table.configName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceName => $composableBuilder(
    column: $table.sourceName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SourceType, String> get sourceType =>
      $composableBuilder(
        column: $table.sourceType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get destinationName => $composableBuilder(
    column: $table.destinationName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DestinationType, String>
  get destinationType => $composableBuilder(
    column: $table.destinationType,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RunTrigger, String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RunStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get log =>
      $composableBuilder(column: $table.log, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  $$WorkspaceTableTableAnnotationComposer get workspaceSlug {
    final $$WorkspaceTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workspaceSlug,
      referencedTable: $db.workspaceTable,
      getReferencedColumn: (t) => t.slug,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkspaceTableTableAnnotationComposer(
            $db: $db,
            $table: $db.workspaceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ConfigTableTableAnnotationComposer get configId {
    final $$ConfigTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.configId,
      referencedTable: $db.configTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConfigTableTableAnnotationComposer(
            $db: $db,
            $table: $db.configTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RunTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RunTableTable,
          RunTableData,
          $$RunTableTableFilterComposer,
          $$RunTableTableOrderingComposer,
          $$RunTableTableAnnotationComposer,
          $$RunTableTableCreateCompanionBuilder,
          $$RunTableTableUpdateCompanionBuilder,
          (RunTableData, $$RunTableTableReferences),
          RunTableData,
          PrefetchHooks Function({bool workspaceSlug, bool configId})
        > {
  $$RunTableTableTableManager(_$AppDatabase db, $RunTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RunTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RunTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RunTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceSlug = const Value.absent(),
                Value<String?> configId = const Value.absent(),
                Value<String> configName = const Value.absent(),
                Value<String> sourceName = const Value.absent(),
                Value<SourceType> sourceType = const Value.absent(),
                Value<String> destinationName = const Value.absent(),
                Value<DestinationType> destinationType = const Value.absent(),
                Value<RunTrigger> trigger = const Value.absent(),
                Value<RunStatus> status = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String> log = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunTableCompanion(
                id: id,
                workspaceSlug: workspaceSlug,
                configId: configId,
                configName: configName,
                sourceName: sourceName,
                sourceType: sourceType,
                destinationName: destinationName,
                destinationType: destinationType,
                trigger: trigger,
                status: status,
                location: location,
                sizeBytes: sizeBytes,
                error: error,
                log: log,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceSlug,
                Value<String?> configId = const Value.absent(),
                required String configName,
                required String sourceName,
                required SourceType sourceType,
                required String destinationName,
                required DestinationType destinationType,
                required RunTrigger trigger,
                required RunStatus status,
                Value<String?> location = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<String> log = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RunTableCompanion.insert(
                id: id,
                workspaceSlug: workspaceSlug,
                configId: configId,
                configName: configName,
                sourceName: sourceName,
                sourceType: sourceType,
                destinationName: destinationName,
                destinationType: destinationType,
                trigger: trigger,
                status: status,
                location: location,
                sizeBytes: sizeBytes,
                error: error,
                log: log,
                startedAt: startedAt,
                finishedAt: finishedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RunTableTable, RunTableData>(table),
                  $$RunTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({workspaceSlug = false, configId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (workspaceSlug) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.workspaceSlug,
                        referencedTable: $$RunTableTableReferences
                            ._workspaceSlugTable(db),
                        referencedColumn: $$RunTableTableReferences
                            ._workspaceSlugTable(db)
                            .slug,
                      ) as T;
                    }
                    if (configId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.configId,
                        referencedTable: $$RunTableTableReferences
                            ._configIdTable(db),
                        referencedColumn: $$RunTableTableReferences
                            ._configIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RunTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RunTableTable,
      RunTableData,
      $$RunTableTableFilterComposer,
      $$RunTableTableOrderingComposer,
      $$RunTableTableAnnotationComposer,
      $$RunTableTableCreateCompanionBuilder,
      $$RunTableTableUpdateCompanionBuilder,
      (RunTableData, $$RunTableTableReferences),
      RunTableData,
      PrefetchHooks Function({bool workspaceSlug, bool configId})
    >;
typedef $$DestinationFolderTableTableCreateCompanionBuilder =
    DestinationFolderTableCompanion Function({
      required String destinationId,
      required String path,
      Value<int> rowid,
    });
typedef $$DestinationFolderTableTableUpdateCompanionBuilder =
    DestinationFolderTableCompanion Function({
      Value<String> destinationId,
      Value<String> path,
      Value<int> rowid,
    });

final class $$DestinationFolderTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DestinationFolderTableTable,
          DestinationFolderTableData
        > {
  $$DestinationFolderTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DestinationTableTable _destinationIdTable(_$AppDatabase db) => db
      .destinationTable
      .createAlias('destination_folder__destination_id__destination__id');

  $$DestinationTableTableProcessedTableManager get destinationId {
    final $_column = $_itemColumn<String>('destination_id')!;

    final manager = $$DestinationTableTableTableManager(
      $_db,
      $_db.destinationTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_destinationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DestinationFolderTableTableFilterComposer
    extends Composer<_$AppDatabase, $DestinationFolderTableTable> {
  $$DestinationFolderTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  $$DestinationTableTableFilterComposer get destinationId {
    final $$DestinationTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableFilterComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DestinationFolderTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DestinationFolderTableTable> {
  $$DestinationFolderTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  $$DestinationTableTableOrderingComposer get destinationId {
    final $$DestinationTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableOrderingComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DestinationFolderTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DestinationFolderTableTable> {
  $$DestinationFolderTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  $$DestinationTableTableAnnotationComposer get destinationId {
    final $$DestinationTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.destinationId,
      referencedTable: $db.destinationTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DestinationTableTableAnnotationComposer(
            $db: $db,
            $table: $db.destinationTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DestinationFolderTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DestinationFolderTableTable,
          DestinationFolderTableData,
          $$DestinationFolderTableTableFilterComposer,
          $$DestinationFolderTableTableOrderingComposer,
          $$DestinationFolderTableTableAnnotationComposer,
          $$DestinationFolderTableTableCreateCompanionBuilder,
          $$DestinationFolderTableTableUpdateCompanionBuilder,
          (DestinationFolderTableData, $$DestinationFolderTableTableReferences),
          DestinationFolderTableData,
          PrefetchHooks Function({bool destinationId})
        > {
  $$DestinationFolderTableTableTableManager(
    _$AppDatabase db,
    $DestinationFolderTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DestinationFolderTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DestinationFolderTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DestinationFolderTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> destinationId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestinationFolderTableCompanion(
                destinationId: destinationId,
                path: path,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String destinationId,
                required String path,
                Value<int> rowid = const Value.absent(),
              }) => DestinationFolderTableCompanion.insert(
                destinationId: destinationId,
                path: path,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $DestinationFolderTableTable,
                    DestinationFolderTableData
                  >(table),
                  $$DestinationFolderTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({destinationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (destinationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.destinationId,
                        referencedTable: $$DestinationFolderTableTableReferences
                            ._destinationIdTable(db),
                        referencedColumn:
                            $$DestinationFolderTableTableReferences
                                ._destinationIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DestinationFolderTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DestinationFolderTableTable,
      DestinationFolderTableData,
      $$DestinationFolderTableTableFilterComposer,
      $$DestinationFolderTableTableOrderingComposer,
      $$DestinationFolderTableTableAnnotationComposer,
      $$DestinationFolderTableTableCreateCompanionBuilder,
      $$DestinationFolderTableTableUpdateCompanionBuilder,
      (DestinationFolderTableData, $$DestinationFolderTableTableReferences),
      DestinationFolderTableData,
      PrefetchHooks Function({bool destinationId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkspaceTableTableTableManager get workspaceTable =>
      $$WorkspaceTableTableTableManager(_db, _db.workspaceTable);
  $$SourceTableTableTableManager get sourceTable =>
      $$SourceTableTableTableManager(_db, _db.sourceTable);
  $$DestinationTableTableTableManager get destinationTable =>
      $$DestinationTableTableTableManager(_db, _db.destinationTable);
  $$ConfigTableTableTableManager get configTable =>
      $$ConfigTableTableTableManager(_db, _db.configTable);
  $$RunTableTableTableManager get runTable =>
      $$RunTableTableTableManager(_db, _db.runTable);
  $$DestinationFolderTableTableTableManager get destinationFolderTable =>
      $$DestinationFolderTableTableTableManager(
        _db,
        _db.destinationFolderTable,
      );
}
