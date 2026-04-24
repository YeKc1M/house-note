// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(Insertable<Template> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends DataClass implements Insertable<Template> {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;
  const Template(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Template.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Template copyWith(
          {String? id, String? name, int? createdAt, int? updatedAt}) =>
      Template(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplatesCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Template> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return TemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateDimensionsTable extends TemplateDimensions
    with TableInfo<$TemplateDimensionsTable, TemplateDimension> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateDimensionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES templates (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
      'config', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, templateId, name, type, config, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_dimensions';
  @override
  VerificationContext validateIntegrity(Insertable<TemplateDimension> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    } else if (isInserting) {
      context.missing(_configMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateDimension map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateDimension(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $TemplateDimensionsTable createAlias(String alias) {
    return $TemplateDimensionsTable(attachedDatabase, alias);
  }
}

class TemplateDimension extends DataClass
    implements Insertable<TemplateDimension> {
  final String id;
  final String templateId;
  final String name;
  final String type;
  final String config;
  final int sortOrder;
  const TemplateDimension(
      {required this.id,
      required this.templateId,
      required this.name,
      required this.type,
      required this.config,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['config'] = Variable<String>(config);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TemplateDimensionsCompanion toCompanion(bool nullToAbsent) {
    return TemplateDimensionsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      name: Value(name),
      type: Value(type),
      config: Value(config),
      sortOrder: Value(sortOrder),
    );
  }

  factory TemplateDimension.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateDimension(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      config: serializer.fromJson<String>(json['config']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'config': serializer.toJson<String>(config),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TemplateDimension copyWith(
          {String? id,
          String? templateId,
          String? name,
          String? type,
          String? config,
          int? sortOrder}) =>
      TemplateDimension(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        name: name ?? this.name,
        type: type ?? this.type,
        config: config ?? this.config,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  TemplateDimension copyWithCompanion(TemplateDimensionsCompanion data) {
    return TemplateDimension(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      config: data.config.present ? data.config.value : this.config,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateDimension(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, name, type, config, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateDimension &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.name == this.name &&
          other.type == this.type &&
          other.config == this.config &&
          other.sortOrder == this.sortOrder);
}

class TemplateDimensionsCompanion extends UpdateCompanion<TemplateDimension> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> config;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TemplateDimensionsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateDimensionsCompanion.insert({
    required String id,
    required String templateId,
    required String name,
    required String type,
    required String config,
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        name = Value(name),
        type = Value(type),
        config = Value(config),
        sortOrder = Value(sortOrder);
  static Insertable<TemplateDimension> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? config,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateDimensionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String>? name,
      Value<String>? type,
      Value<String>? config,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return TemplateDimensionsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateDimensionsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstancesTable extends Instances
    with TableInfo<$InstancesTable, Instance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES templates (id)'));
  static const VerificationMeta _parentInstanceIdMeta =
      const VerificationMeta('parentInstanceId');
  @override
  late final GeneratedColumn<String> parentInstanceId = GeneratedColumn<String>(
      'parent_instance_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES instances (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, templateId, parentInstanceId, name, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instances';
  @override
  VerificationContext validateIntegrity(Insertable<Instance> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('parent_instance_id')) {
      context.handle(
          _parentInstanceIdMeta,
          parentInstanceId.isAcceptableOrUnknown(
              data['parent_instance_id']!, _parentInstanceIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Instance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Instance(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      parentInstanceId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_instance_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $InstancesTable createAlias(String alias) {
    return $InstancesTable(attachedDatabase, alias);
  }
}

class Instance extends DataClass implements Insertable<Instance> {
  final String id;
  final String templateId;
  final String? parentInstanceId;
  final String name;
  final int createdAt;
  final int updatedAt;
  const Instance(
      {required this.id,
      required this.templateId,
      this.parentInstanceId,
      required this.name,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    if (!nullToAbsent || parentInstanceId != null) {
      map['parent_instance_id'] = Variable<String>(parentInstanceId);
    }
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  InstancesCompanion toCompanion(bool nullToAbsent) {
    return InstancesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      parentInstanceId: parentInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentInstanceId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Instance.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Instance(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      parentInstanceId: serializer.fromJson<String?>(json['parentInstanceId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'parentInstanceId': serializer.toJson<String?>(parentInstanceId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Instance copyWith(
          {String? id,
          String? templateId,
          Value<String?> parentInstanceId = const Value.absent(),
          String? name,
          int? createdAt,
          int? updatedAt}) =>
      Instance(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        parentInstanceId: parentInstanceId.present
            ? parentInstanceId.value
            : this.parentInstanceId,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Instance copyWithCompanion(InstancesCompanion data) {
    return Instance(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      parentInstanceId: data.parentInstanceId.present
          ? data.parentInstanceId.value
          : this.parentInstanceId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Instance(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('parentInstanceId: $parentInstanceId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateId, parentInstanceId, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Instance &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.parentInstanceId == this.parentInstanceId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstancesCompanion extends UpdateCompanion<Instance> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String?> parentInstanceId;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const InstancesCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.parentInstanceId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstancesCompanion.insert({
    required String id,
    required String templateId,
    this.parentInstanceId = const Value.absent(),
    required String name,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Instance> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? parentInstanceId,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (parentInstanceId != null) 'parent_instance_id': parentInstanceId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstancesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String?>? parentInstanceId,
      Value<String>? name,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return InstancesCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      parentInstanceId: parentInstanceId ?? this.parentInstanceId,
      name: name ?? this.name,
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
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (parentInstanceId.present) {
      map['parent_instance_id'] = Variable<String>(parentInstanceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstancesCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('parentInstanceId: $parentInstanceId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstanceValuesTable extends InstanceValues
    with TableInfo<$InstanceValuesTable, InstanceValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstanceValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instanceIdMeta =
      const VerificationMeta('instanceId');
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
      'instance_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES instances (id) ON DELETE CASCADE'));
  static const VerificationMeta _dimensionIdMeta =
      const VerificationMeta('dimensionId');
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
      'dimension_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES template_dimensions (id)'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, instanceId, dimensionId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instance_values';
  @override
  VerificationContext validateIntegrity(Insertable<InstanceValue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
          _instanceIdMeta,
          instanceId.isAcceptableOrUnknown(
              data['instance_id']!, _instanceIdMeta));
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
          _dimensionIdMeta,
          dimensionId.isAcceptableOrUnknown(
              data['dimension_id']!, _dimensionIdMeta));
    } else if (isInserting) {
      context.missing(_dimensionIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstanceValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstanceValue(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      instanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instance_id'])!,
      dimensionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dimension_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $InstanceValuesTable createAlias(String alias) {
    return $InstanceValuesTable(attachedDatabase, alias);
  }
}

class InstanceValue extends DataClass implements Insertable<InstanceValue> {
  final String id;
  final String instanceId;
  final String dimensionId;
  final String value;
  const InstanceValue(
      {required this.id,
      required this.instanceId,
      required this.dimensionId,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['dimension_id'] = Variable<String>(dimensionId);
    map['value'] = Variable<String>(value);
    return map;
  }

  InstanceValuesCompanion toCompanion(bool nullToAbsent) {
    return InstanceValuesCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      dimensionId: Value(dimensionId),
      value: Value(value),
    );
  }

  factory InstanceValue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstanceValue(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instanceId']),
      dimensionId: serializer.fromJson<String>(json['dimensionId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instanceId': serializer.toJson<String>(instanceId),
      'dimensionId': serializer.toJson<String>(dimensionId),
      'value': serializer.toJson<String>(value),
    };
  }

  InstanceValue copyWith(
          {String? id,
          String? instanceId,
          String? dimensionId,
          String? value}) =>
      InstanceValue(
        id: id ?? this.id,
        instanceId: instanceId ?? this.instanceId,
        dimensionId: dimensionId ?? this.dimensionId,
        value: value ?? this.value,
      );
  InstanceValue copyWithCompanion(InstanceValuesCompanion data) {
    return InstanceValue(
      id: data.id.present ? data.id.value : this.id,
      instanceId:
          data.instanceId.present ? data.instanceId.value : this.instanceId,
      dimensionId:
          data.dimensionId.present ? data.dimensionId.value : this.dimensionId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstanceValue(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, instanceId, dimensionId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstanceValue &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.dimensionId == this.dimensionId &&
          other.value == this.value);
}

class InstanceValuesCompanion extends UpdateCompanion<InstanceValue> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> dimensionId;
  final Value<String> value;
  final Value<int> rowid;
  const InstanceValuesCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstanceValuesCompanion.insert({
    required String id,
    required String instanceId,
    required String dimensionId,
    required String value,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        instanceId = Value(instanceId),
        dimensionId = Value(dimensionId),
        value = Value(value);
  static Insertable<InstanceValue> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? dimensionId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstanceValuesCompanion copyWith(
      {Value<String>? id,
      Value<String>? instanceId,
      Value<String>? dimensionId,
      Value<String>? value,
      Value<int>? rowid}) {
    return InstanceValuesCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      dimensionId: dimensionId ?? this.dimensionId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstanceValuesCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstanceCustomFieldsTable extends InstanceCustomFields
    with TableInfo<$InstanceCustomFieldsTable, InstanceCustomField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstanceCustomFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instanceIdMeta =
      const VerificationMeta('instanceId');
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
      'instance_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES instances (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
      'config', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, instanceId, name, type, value, config];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instance_custom_fields';
  @override
  VerificationContext validateIntegrity(
      Insertable<InstanceCustomField> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
          _instanceIdMeta,
          instanceId.isAcceptableOrUnknown(
              data['instance_id']!, _instanceIdMeta));
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    } else if (isInserting) {
      context.missing(_configMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstanceCustomField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstanceCustomField(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      instanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instance_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config'])!,
    );
  }

  @override
  $InstanceCustomFieldsTable createAlias(String alias) {
    return $InstanceCustomFieldsTable(attachedDatabase, alias);
  }
}

class InstanceCustomField extends DataClass
    implements Insertable<InstanceCustomField> {
  final String id;
  final String instanceId;
  final String name;
  final String type;
  final String value;
  final String config;
  const InstanceCustomField(
      {required this.id,
      required this.instanceId,
      required this.name,
      required this.type,
      required this.value,
      required this.config});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    map['config'] = Variable<String>(config);
    return map;
  }

  InstanceCustomFieldsCompanion toCompanion(bool nullToAbsent) {
    return InstanceCustomFieldsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      name: Value(name),
      type: Value(type),
      value: Value(value),
      config: Value(config),
    );
  }

  factory InstanceCustomField.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstanceCustomField(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instanceId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      config: serializer.fromJson<String>(json['config']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instanceId': serializer.toJson<String>(instanceId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'config': serializer.toJson<String>(config),
    };
  }

  InstanceCustomField copyWith(
          {String? id,
          String? instanceId,
          String? name,
          String? type,
          String? value,
          String? config}) =>
      InstanceCustomField(
        id: id ?? this.id,
        instanceId: instanceId ?? this.instanceId,
        name: name ?? this.name,
        type: type ?? this.type,
        value: value ?? this.value,
        config: config ?? this.config,
      );
  InstanceCustomField copyWithCompanion(InstanceCustomFieldsCompanion data) {
    return InstanceCustomField(
      id: data.id.present ? data.id.value : this.id,
      instanceId:
          data.instanceId.present ? data.instanceId.value : this.instanceId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      config: data.config.present ? data.config.value : this.config,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstanceCustomField(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('config: $config')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, instanceId, name, type, value, config);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstanceCustomField &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.name == this.name &&
          other.type == this.type &&
          other.value == this.value &&
          other.config == this.config);
}

class InstanceCustomFieldsCompanion
    extends UpdateCompanion<InstanceCustomField> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> name;
  final Value<String> type;
  final Value<String> value;
  final Value<String> config;
  final Value<int> rowid;
  const InstanceCustomFieldsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.config = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstanceCustomFieldsCompanion.insert({
    required String id,
    required String instanceId,
    required String name,
    required String type,
    required String value,
    required String config,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        instanceId = Value(instanceId),
        name = Value(name),
        type = Value(type),
        value = Value(value),
        config = Value(config);
  static Insertable<InstanceCustomField> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? value,
    Expression<String>? config,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (config != null) 'config': config,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstanceCustomFieldsCompanion copyWith(
      {Value<String>? id,
      Value<String>? instanceId,
      Value<String>? name,
      Value<String>? type,
      Value<String>? value,
      Value<String>? config,
      Value<int>? rowid}) {
    return InstanceCustomFieldsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      config: config ?? this.config,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstanceCustomFieldsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('config: $config, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstanceHiddenDimensionsTable extends InstanceHiddenDimensions
    with TableInfo<$InstanceHiddenDimensionsTable, InstanceHiddenDimension> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstanceHiddenDimensionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _instanceIdMeta =
      const VerificationMeta('instanceId');
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
      'instance_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES instances (id) ON DELETE CASCADE'));
  static const VerificationMeta _dimensionIdMeta =
      const VerificationMeta('dimensionId');
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
      'dimension_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES template_dimensions (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, instanceId, dimensionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'instance_hidden_dimensions';
  @override
  VerificationContext validateIntegrity(
      Insertable<InstanceHiddenDimension> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('instance_id')) {
      context.handle(
          _instanceIdMeta,
          instanceId.isAcceptableOrUnknown(
              data['instance_id']!, _instanceIdMeta));
    } else if (isInserting) {
      context.missing(_instanceIdMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
          _dimensionIdMeta,
          dimensionId.isAcceptableOrUnknown(
              data['dimension_id']!, _dimensionIdMeta));
    } else if (isInserting) {
      context.missing(_dimensionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstanceHiddenDimension map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstanceHiddenDimension(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      instanceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instance_id'])!,
      dimensionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dimension_id'])!,
    );
  }

  @override
  $InstanceHiddenDimensionsTable createAlias(String alias) {
    return $InstanceHiddenDimensionsTable(attachedDatabase, alias);
  }
}

class InstanceHiddenDimension extends DataClass
    implements Insertable<InstanceHiddenDimension> {
  final String id;
  final String instanceId;
  final String dimensionId;
  const InstanceHiddenDimension(
      {required this.id, required this.instanceId, required this.dimensionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['instance_id'] = Variable<String>(instanceId);
    map['dimension_id'] = Variable<String>(dimensionId);
    return map;
  }

  InstanceHiddenDimensionsCompanion toCompanion(bool nullToAbsent) {
    return InstanceHiddenDimensionsCompanion(
      id: Value(id),
      instanceId: Value(instanceId),
      dimensionId: Value(dimensionId),
    );
  }

  factory InstanceHiddenDimension.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstanceHiddenDimension(
      id: serializer.fromJson<String>(json['id']),
      instanceId: serializer.fromJson<String>(json['instanceId']),
      dimensionId: serializer.fromJson<String>(json['dimensionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'instanceId': serializer.toJson<String>(instanceId),
      'dimensionId': serializer.toJson<String>(dimensionId),
    };
  }

  InstanceHiddenDimension copyWith(
          {String? id, String? instanceId, String? dimensionId}) =>
      InstanceHiddenDimension(
        id: id ?? this.id,
        instanceId: instanceId ?? this.instanceId,
        dimensionId: dimensionId ?? this.dimensionId,
      );
  InstanceHiddenDimension copyWithCompanion(
      InstanceHiddenDimensionsCompanion data) {
    return InstanceHiddenDimension(
      id: data.id.present ? data.id.value : this.id,
      instanceId:
          data.instanceId.present ? data.instanceId.value : this.instanceId,
      dimensionId:
          data.dimensionId.present ? data.dimensionId.value : this.dimensionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstanceHiddenDimension(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('dimensionId: $dimensionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, instanceId, dimensionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstanceHiddenDimension &&
          other.id == this.id &&
          other.instanceId == this.instanceId &&
          other.dimensionId == this.dimensionId);
}

class InstanceHiddenDimensionsCompanion
    extends UpdateCompanion<InstanceHiddenDimension> {
  final Value<String> id;
  final Value<String> instanceId;
  final Value<String> dimensionId;
  final Value<int> rowid;
  const InstanceHiddenDimensionsCompanion({
    this.id = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstanceHiddenDimensionsCompanion.insert({
    required String id,
    required String instanceId,
    required String dimensionId,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        instanceId = Value(instanceId),
        dimensionId = Value(dimensionId);
  static Insertable<InstanceHiddenDimension> custom({
    Expression<String>? id,
    Expression<String>? instanceId,
    Expression<String>? dimensionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (instanceId != null) 'instance_id': instanceId,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstanceHiddenDimensionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? instanceId,
      Value<String>? dimensionId,
      Value<int>? rowid}) {
    return InstanceHiddenDimensionsCompanion(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      dimensionId: dimensionId ?? this.dimensionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstanceHiddenDimensionsCompanion(')
          ..write('id: $id, ')
          ..write('instanceId: $instanceId, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateThumbnailFieldsTable extends TemplateThumbnailFields
    with TableInfo<$TemplateThumbnailFieldsTable, TemplateThumbnailField> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateThumbnailFieldsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES templates (id) ON DELETE CASCADE'));
  static const VerificationMeta _dimensionIdMeta =
      const VerificationMeta('dimensionId');
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
      'dimension_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES template_dimensions (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, templateId, dimensionId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_thumbnail_fields';
  @override
  VerificationContext validateIntegrity(
      Insertable<TemplateThumbnailField> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
          _dimensionIdMeta,
          dimensionId.isAcceptableOrUnknown(
              data['dimension_id']!, _dimensionIdMeta));
    } else if (isInserting) {
      context.missing(_dimensionIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateThumbnailField map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateThumbnailField(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      dimensionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dimension_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $TemplateThumbnailFieldsTable createAlias(String alias) {
    return $TemplateThumbnailFieldsTable(attachedDatabase, alias);
  }
}

class TemplateThumbnailField extends DataClass
    implements Insertable<TemplateThumbnailField> {
  final String id;
  final String templateId;
  final String dimensionId;
  final int sortOrder;
  const TemplateThumbnailField(
      {required this.id,
      required this.templateId,
      required this.dimensionId,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['dimension_id'] = Variable<String>(dimensionId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TemplateThumbnailFieldsCompanion toCompanion(bool nullToAbsent) {
    return TemplateThumbnailFieldsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      dimensionId: Value(dimensionId),
      sortOrder: Value(sortOrder),
    );
  }

  factory TemplateThumbnailField.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateThumbnailField(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      dimensionId: serializer.fromJson<String>(json['dimensionId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'dimensionId': serializer.toJson<String>(dimensionId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TemplateThumbnailField copyWith(
          {String? id,
          String? templateId,
          String? dimensionId,
          int? sortOrder}) =>
      TemplateThumbnailField(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        dimensionId: dimensionId ?? this.dimensionId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  TemplateThumbnailField copyWithCompanion(
      TemplateThumbnailFieldsCompanion data) {
    return TemplateThumbnailField(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      dimensionId:
          data.dimensionId.present ? data.dimensionId.value : this.dimensionId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateThumbnailField(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, dimensionId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateThumbnailField &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.dimensionId == this.dimensionId &&
          other.sortOrder == this.sortOrder);
}

class TemplateThumbnailFieldsCompanion
    extends UpdateCompanion<TemplateThumbnailField> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> dimensionId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TemplateThumbnailFieldsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateThumbnailFieldsCompanion.insert({
    required String id,
    required String templateId,
    required String dimensionId,
    required int sortOrder,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        dimensionId = Value(dimensionId),
        sortOrder = Value(sortOrder);
  static Insertable<TemplateThumbnailField> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? dimensionId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateThumbnailFieldsCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<String>? dimensionId,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return TemplateThumbnailFieldsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      dimensionId: dimensionId ?? this.dimensionId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateThumbnailFieldsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $TemplateDimensionsTable templateDimensions =
      $TemplateDimensionsTable(this);
  late final $InstancesTable instances = $InstancesTable(this);
  late final $InstanceValuesTable instanceValues = $InstanceValuesTable(this);
  late final $InstanceCustomFieldsTable instanceCustomFields =
      $InstanceCustomFieldsTable(this);
  late final $InstanceHiddenDimensionsTable instanceHiddenDimensions =
      $InstanceHiddenDimensionsTable(this);
  late final $TemplateThumbnailFieldsTable templateThumbnailFields =
      $TemplateThumbnailFieldsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        templates,
        templateDimensions,
        instances,
        instanceValues,
        instanceCustomFields,
        instanceHiddenDimensions,
        templateThumbnailFields
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('template_dimensions', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('instances',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('instance_values', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('instances',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('instance_custom_fields', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('instances',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('instance_hidden_dimensions',
                  kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('templates',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('template_thumbnail_fields', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$TemplatesTableCreateCompanionBuilder = TemplatesCompanion Function({
  required String id,
  required String name,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TemplatesTableUpdateCompanionBuilder = TemplatesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$TemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $TemplatesTable, Template> {
  $$TemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TemplateDimensionsTable, List<TemplateDimension>>
      _templateDimensionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.templateDimensions,
              aliasName: $_aliasNameGenerator(
                  db.templates.id, db.templateDimensions.templateId));

  $$TemplateDimensionsTableProcessedTableManager get templateDimensionsRefs {
    final manager = $$TemplateDimensionsTableTableManager(
            $_db, $_db.templateDimensions)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_templateDimensionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstancesTable, List<Instance>>
      _instancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.instances,
          aliasName:
              $_aliasNameGenerator(db.templates.id, db.instances.templateId));

  $$InstancesTableProcessedTableManager get instancesRefs {
    final manager = $$InstancesTableTableManager($_db, $_db.instances)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_instancesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TemplateThumbnailFieldsTable,
      List<TemplateThumbnailField>> _templateThumbnailFieldsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.templateThumbnailFields,
          aliasName: $_aliasNameGenerator(
              db.templates.id, db.templateThumbnailFields.templateId));

  $$TemplateThumbnailFieldsTableProcessedTableManager
      get templateThumbnailFieldsRefs {
    final manager = $$TemplateThumbnailFieldsTableTableManager(
            $_db, $_db.templateThumbnailFields)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_templateThumbnailFieldsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> templateDimensionsRefs(
      Expression<bool> Function($$TemplateDimensionsTableFilterComposer f) f) {
    final $$TemplateDimensionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableFilterComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> instancesRefs(
      Expression<bool> Function($$InstancesTableFilterComposer f) f) {
    final $$InstancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableFilterComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> templateThumbnailFieldsRefs(
      Expression<bool> Function($$TemplateThumbnailFieldsTableFilterComposer f)
          f) {
    final $$TemplateThumbnailFieldsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.templateThumbnailFields,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateThumbnailFieldsTableFilterComposer(
                  $db: $db,
                  $table: $db.templateThumbnailFields,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
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

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> templateDimensionsRefs<T extends Object>(
      Expression<T> Function($$TemplateDimensionsTableAnnotationComposer a) f) {
    final $$TemplateDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.templateDimensions,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> instancesRefs<T extends Object>(
      Expression<T> Function($$InstancesTableAnnotationComposer a) f) {
    final $$InstancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableAnnotationComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> templateThumbnailFieldsRefs<T extends Object>(
      Expression<T> Function($$TemplateThumbnailFieldsTableAnnotationComposer a)
          f) {
    final $$TemplateThumbnailFieldsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.templateThumbnailFields,
            getReferencedColumn: (t) => t.templateId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateThumbnailFieldsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateThumbnailFields,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, $$TemplatesTableReferences),
    Template,
    PrefetchHooks Function(
        {bool templateDimensionsRefs,
        bool instancesRefs,
        bool templateThumbnailFieldsRefs})> {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplatesCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templateDimensionsRefs = false,
              instancesRefs = false,
              templateThumbnailFieldsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templateDimensionsRefs) db.templateDimensions,
                if (instancesRefs) db.instances,
                if (templateThumbnailFieldsRefs) db.templateThumbnailFields
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templateDimensionsRefs)
                    await $_getPrefetchedData<Template, $TemplatesTable,
                            TemplateDimension>(
                        currentTable: table,
                        referencedTable: $$TemplatesTableReferences
                            ._templateDimensionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .templateDimensionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items),
                  if (instancesRefs)
                    await $_getPrefetchedData<Template, $TemplatesTable,
                            Instance>(
                        currentTable: table,
                        referencedTable:
                            $$TemplatesTableReferences._instancesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .instancesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items),
                  if (templateThumbnailFieldsRefs)
                    await $_getPrefetchedData<Template, $TemplatesTable, TemplateThumbnailField>(
                        currentTable: table,
                        referencedTable: $$TemplatesTableReferences
                            ._templateThumbnailFieldsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplatesTableReferences(db, table, p0)
                                .templateThumbnailFieldsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TemplatesTable,
    Template,
    $$TemplatesTableFilterComposer,
    $$TemplatesTableOrderingComposer,
    $$TemplatesTableAnnotationComposer,
    $$TemplatesTableCreateCompanionBuilder,
    $$TemplatesTableUpdateCompanionBuilder,
    (Template, $$TemplatesTableReferences),
    Template,
    PrefetchHooks Function(
        {bool templateDimensionsRefs,
        bool instancesRefs,
        bool templateThumbnailFieldsRefs})>;
typedef $$TemplateDimensionsTableCreateCompanionBuilder
    = TemplateDimensionsCompanion Function({
  required String id,
  required String templateId,
  required String name,
  required String type,
  required String config,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$TemplateDimensionsTableUpdateCompanionBuilder
    = TemplateDimensionsCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String> name,
  Value<String> type,
  Value<String> config,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$TemplateDimensionsTableReferences extends BaseReferences<
    _$AppDatabase, $TemplateDimensionsTable, TemplateDimension> {
  $$TemplateDimensionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias($_aliasNameGenerator(
          db.templateDimensions.templateId, db.templates.id));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InstanceValuesTable, List<InstanceValue>>
      _instanceValuesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.instanceValues,
              aliasName: $_aliasNameGenerator(
                  db.templateDimensions.id, db.instanceValues.dimensionId));

  $$InstanceValuesTableProcessedTableManager get instanceValuesRefs {
    final manager = $$InstanceValuesTableTableManager($_db, $_db.instanceValues)
        .filter((f) => f.dimensionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_instanceValuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstanceHiddenDimensionsTable,
      List<InstanceHiddenDimension>> _instanceHiddenDimensionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.instanceHiddenDimensions,
          aliasName: $_aliasNameGenerator(db.templateDimensions.id,
              db.instanceHiddenDimensions.dimensionId));

  $$InstanceHiddenDimensionsTableProcessedTableManager
      get instanceHiddenDimensionsRefs {
    final manager = $$InstanceHiddenDimensionsTableTableManager(
            $_db, $_db.instanceHiddenDimensions)
        .filter((f) => f.dimensionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_instanceHiddenDimensionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TemplateThumbnailFieldsTable,
      List<TemplateThumbnailField>> _templateThumbnailFieldsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.templateThumbnailFields,
          aliasName: $_aliasNameGenerator(db.templateDimensions.id,
              db.templateThumbnailFields.dimensionId));

  $$TemplateThumbnailFieldsTableProcessedTableManager
      get templateThumbnailFieldsRefs {
    final manager = $$TemplateThumbnailFieldsTableTableManager(
            $_db, $_db.templateThumbnailFields)
        .filter((f) => f.dimensionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_templateThumbnailFieldsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TemplateDimensionsTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateDimensionsTable> {
  $$TemplateDimensionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> instanceValuesRefs(
      Expression<bool> Function($$InstanceValuesTableFilterComposer f) f) {
    final $$InstanceValuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instanceValues,
        getReferencedColumn: (t) => t.dimensionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstanceValuesTableFilterComposer(
              $db: $db,
              $table: $db.instanceValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> instanceHiddenDimensionsRefs(
      Expression<bool> Function($$InstanceHiddenDimensionsTableFilterComposer f)
          f) {
    final $$InstanceHiddenDimensionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.instanceHiddenDimensions,
            getReferencedColumn: (t) => t.dimensionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstanceHiddenDimensionsTableFilterComposer(
                  $db: $db,
                  $table: $db.instanceHiddenDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> templateThumbnailFieldsRefs(
      Expression<bool> Function($$TemplateThumbnailFieldsTableFilterComposer f)
          f) {
    final $$TemplateThumbnailFieldsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.templateThumbnailFields,
            getReferencedColumn: (t) => t.dimensionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateThumbnailFieldsTableFilterComposer(
                  $db: $db,
                  $table: $db.templateThumbnailFields,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TemplateDimensionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateDimensionsTable> {
  $$TemplateDimensionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateDimensionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateDimensionsTable> {
  $$TemplateDimensionsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> instanceValuesRefs<T extends Object>(
      Expression<T> Function($$InstanceValuesTableAnnotationComposer a) f) {
    final $$InstanceValuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instanceValues,
        getReferencedColumn: (t) => t.dimensionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstanceValuesTableAnnotationComposer(
              $db: $db,
              $table: $db.instanceValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> instanceHiddenDimensionsRefs<T extends Object>(
      Expression<T> Function(
              $$InstanceHiddenDimensionsTableAnnotationComposer a)
          f) {
    final $$InstanceHiddenDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.instanceHiddenDimensions,
            getReferencedColumn: (t) => t.dimensionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstanceHiddenDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.instanceHiddenDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> templateThumbnailFieldsRefs<T extends Object>(
      Expression<T> Function($$TemplateThumbnailFieldsTableAnnotationComposer a)
          f) {
    final $$TemplateThumbnailFieldsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.templateThumbnailFields,
            getReferencedColumn: (t) => t.dimensionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateThumbnailFieldsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateThumbnailFields,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$TemplateDimensionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplateDimensionsTable,
    TemplateDimension,
    $$TemplateDimensionsTableFilterComposer,
    $$TemplateDimensionsTableOrderingComposer,
    $$TemplateDimensionsTableAnnotationComposer,
    $$TemplateDimensionsTableCreateCompanionBuilder,
    $$TemplateDimensionsTableUpdateCompanionBuilder,
    (TemplateDimension, $$TemplateDimensionsTableReferences),
    TemplateDimension,
    PrefetchHooks Function(
        {bool templateId,
        bool instanceValuesRefs,
        bool instanceHiddenDimensionsRefs,
        bool templateThumbnailFieldsRefs})> {
  $$TemplateDimensionsTableTableManager(
      _$AppDatabase db, $TemplateDimensionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateDimensionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateDimensionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateDimensionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> config = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateDimensionsCompanion(
            id: id,
            templateId: templateId,
            name: name,
            type: type,
            config: config,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required String name,
            required String type,
            required String config,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateDimensionsCompanion.insert(
            id: id,
            templateId: templateId,
            name: name,
            type: type,
            config: config,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TemplateDimensionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templateId = false,
              instanceValuesRefs = false,
              instanceHiddenDimensionsRefs = false,
              templateThumbnailFieldsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (instanceValuesRefs) db.instanceValues,
                if (instanceHiddenDimensionsRefs) db.instanceHiddenDimensions,
                if (templateThumbnailFieldsRefs) db.templateThumbnailFields
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$TemplateDimensionsTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$TemplateDimensionsTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (instanceValuesRefs)
                    await $_getPrefetchedData<TemplateDimension,
                            $TemplateDimensionsTable, InstanceValue>(
                        currentTable: table,
                        referencedTable: $$TemplateDimensionsTableReferences
                            ._instanceValuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplateDimensionsTableReferences(db, table, p0)
                                .instanceValuesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dimensionId == item.id),
                        typedResults: items),
                  if (instanceHiddenDimensionsRefs)
                    await $_getPrefetchedData<TemplateDimension,
                            $TemplateDimensionsTable, InstanceHiddenDimension>(
                        currentTable: table,
                        referencedTable: $$TemplateDimensionsTableReferences
                            ._instanceHiddenDimensionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplateDimensionsTableReferences(db, table, p0)
                                .instanceHiddenDimensionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dimensionId == item.id),
                        typedResults: items),
                  if (templateThumbnailFieldsRefs)
                    await $_getPrefetchedData<TemplateDimension,
                            $TemplateDimensionsTable, TemplateThumbnailField>(
                        currentTable: table,
                        referencedTable: $$TemplateDimensionsTableReferences
                            ._templateThumbnailFieldsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TemplateDimensionsTableReferences(db, table, p0)
                                .templateThumbnailFieldsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.dimensionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TemplateDimensionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TemplateDimensionsTable,
    TemplateDimension,
    $$TemplateDimensionsTableFilterComposer,
    $$TemplateDimensionsTableOrderingComposer,
    $$TemplateDimensionsTableAnnotationComposer,
    $$TemplateDimensionsTableCreateCompanionBuilder,
    $$TemplateDimensionsTableUpdateCompanionBuilder,
    (TemplateDimension, $$TemplateDimensionsTableReferences),
    TemplateDimension,
    PrefetchHooks Function(
        {bool templateId,
        bool instanceValuesRefs,
        bool instanceHiddenDimensionsRefs,
        bool templateThumbnailFieldsRefs})>;
typedef $$InstancesTableCreateCompanionBuilder = InstancesCompanion Function({
  required String id,
  required String templateId,
  Value<String?> parentInstanceId,
  required String name,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$InstancesTableUpdateCompanionBuilder = InstancesCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String?> parentInstanceId,
  Value<String> name,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$InstancesTableReferences
    extends BaseReferences<_$AppDatabase, $InstancesTable, Instance> {
  $$InstancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias(
          $_aliasNameGenerator(db.instances.templateId, db.templates.id));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $InstancesTable _parentInstanceIdTable(_$AppDatabase db) =>
      db.instances.createAlias(
          $_aliasNameGenerator(db.instances.parentInstanceId, db.instances.id));

  $$InstancesTableProcessedTableManager? get parentInstanceId {
    final $_column = $_itemColumn<String>('parent_instance_id');
    if ($_column == null) return null;
    final manager = $$InstancesTableTableManager($_db, $_db.instances)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentInstanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$InstanceValuesTable, List<InstanceValue>>
      _instanceValuesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.instanceValues,
              aliasName: $_aliasNameGenerator(
                  db.instances.id, db.instanceValues.instanceId));

  $$InstanceValuesTableProcessedTableManager get instanceValuesRefs {
    final manager = $$InstanceValuesTableTableManager($_db, $_db.instanceValues)
        .filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_instanceValuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstanceCustomFieldsTable,
      List<InstanceCustomField>> _instanceCustomFieldsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.instanceCustomFields,
          aliasName: $_aliasNameGenerator(
              db.instances.id, db.instanceCustomFields.instanceId));

  $$InstanceCustomFieldsTableProcessedTableManager
      get instanceCustomFieldsRefs {
    final manager = $$InstanceCustomFieldsTableTableManager(
            $_db, $_db.instanceCustomFields)
        .filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_instanceCustomFieldsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InstanceHiddenDimensionsTable,
      List<InstanceHiddenDimension>> _instanceHiddenDimensionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.instanceHiddenDimensions,
          aliasName: $_aliasNameGenerator(
              db.instances.id, db.instanceHiddenDimensions.instanceId));

  $$InstanceHiddenDimensionsTableProcessedTableManager
      get instanceHiddenDimensionsRefs {
    final manager = $$InstanceHiddenDimensionsTableTableManager(
            $_db, $_db.instanceHiddenDimensions)
        .filter((f) => f.instanceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_instanceHiddenDimensionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$InstancesTableFilterComposer
    extends Composer<_$AppDatabase, $InstancesTable> {
  $$InstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$InstancesTableFilterComposer get parentInstanceId {
    final $$InstancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentInstanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableFilterComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> instanceValuesRefs(
      Expression<bool> Function($$InstanceValuesTableFilterComposer f) f) {
    final $$InstanceValuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instanceValues,
        getReferencedColumn: (t) => t.instanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstanceValuesTableFilterComposer(
              $db: $db,
              $table: $db.instanceValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> instanceCustomFieldsRefs(
      Expression<bool> Function($$InstanceCustomFieldsTableFilterComposer f)
          f) {
    final $$InstanceCustomFieldsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instanceCustomFields,
        getReferencedColumn: (t) => t.instanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstanceCustomFieldsTableFilterComposer(
              $db: $db,
              $table: $db.instanceCustomFields,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> instanceHiddenDimensionsRefs(
      Expression<bool> Function($$InstanceHiddenDimensionsTableFilterComposer f)
          f) {
    final $$InstanceHiddenDimensionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.instanceHiddenDimensions,
            getReferencedColumn: (t) => t.instanceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstanceHiddenDimensionsTableFilterComposer(
                  $db: $db,
                  $table: $db.instanceHiddenDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$InstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstancesTable> {
  $$InstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$InstancesTableOrderingComposer get parentInstanceId {
    final $$InstancesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentInstanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableOrderingComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstancesTable> {
  $$InstancesTableAnnotationComposer({
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

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$InstancesTableAnnotationComposer get parentInstanceId {
    final $$InstancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.parentInstanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableAnnotationComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> instanceValuesRefs<T extends Object>(
      Expression<T> Function($$InstanceValuesTableAnnotationComposer a) f) {
    final $$InstanceValuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.instanceValues,
        getReferencedColumn: (t) => t.instanceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstanceValuesTableAnnotationComposer(
              $db: $db,
              $table: $db.instanceValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> instanceCustomFieldsRefs<T extends Object>(
      Expression<T> Function($$InstanceCustomFieldsTableAnnotationComposer a)
          f) {
    final $$InstanceCustomFieldsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.instanceCustomFields,
            getReferencedColumn: (t) => t.instanceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstanceCustomFieldsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.instanceCustomFields,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> instanceHiddenDimensionsRefs<T extends Object>(
      Expression<T> Function(
              $$InstanceHiddenDimensionsTableAnnotationComposer a)
          f) {
    final $$InstanceHiddenDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.instanceHiddenDimensions,
            getReferencedColumn: (t) => t.instanceId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$InstanceHiddenDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.instanceHiddenDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$InstancesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstancesTable,
    Instance,
    $$InstancesTableFilterComposer,
    $$InstancesTableOrderingComposer,
    $$InstancesTableAnnotationComposer,
    $$InstancesTableCreateCompanionBuilder,
    $$InstancesTableUpdateCompanionBuilder,
    (Instance, $$InstancesTableReferences),
    Instance,
    PrefetchHooks Function(
        {bool templateId,
        bool parentInstanceId,
        bool instanceValuesRefs,
        bool instanceCustomFieldsRefs,
        bool instanceHiddenDimensionsRefs})> {
  $$InstancesTableTableManager(_$AppDatabase db, $InstancesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String?> parentInstanceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstancesCompanion(
            id: id,
            templateId: templateId,
            parentInstanceId: parentInstanceId,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            Value<String?> parentInstanceId = const Value.absent(),
            required String name,
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstancesCompanion.insert(
            id: id,
            templateId: templateId,
            parentInstanceId: parentInstanceId,
            name: name,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstancesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {templateId = false,
              parentInstanceId = false,
              instanceValuesRefs = false,
              instanceCustomFieldsRefs = false,
              instanceHiddenDimensionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (instanceValuesRefs) db.instanceValues,
                if (instanceCustomFieldsRefs) db.instanceCustomFields,
                if (instanceHiddenDimensionsRefs) db.instanceHiddenDimensions
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable:
                        $$InstancesTableReferences._templateIdTable(db),
                    referencedColumn:
                        $$InstancesTableReferences._templateIdTable(db).id,
                  ) as T;
                }
                if (parentInstanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.parentInstanceId,
                    referencedTable:
                        $$InstancesTableReferences._parentInstanceIdTable(db),
                    referencedColumn: $$InstancesTableReferences
                        ._parentInstanceIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (instanceValuesRefs)
                    await $_getPrefetchedData<Instance, $InstancesTable,
                            InstanceValue>(
                        currentTable: table,
                        referencedTable: $$InstancesTableReferences
                            ._instanceValuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InstancesTableReferences(db, table, p0)
                                .instanceValuesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.instanceId == item.id),
                        typedResults: items),
                  if (instanceCustomFieldsRefs)
                    await $_getPrefetchedData<Instance, $InstancesTable,
                            InstanceCustomField>(
                        currentTable: table,
                        referencedTable: $$InstancesTableReferences
                            ._instanceCustomFieldsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InstancesTableReferences(db, table, p0)
                                .instanceCustomFieldsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.instanceId == item.id),
                        typedResults: items),
                  if (instanceHiddenDimensionsRefs)
                    await $_getPrefetchedData<Instance, $InstancesTable,
                            InstanceHiddenDimension>(
                        currentTable: table,
                        referencedTable: $$InstancesTableReferences
                            ._instanceHiddenDimensionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$InstancesTableReferences(db, table, p0)
                                .instanceHiddenDimensionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.instanceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$InstancesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstancesTable,
    Instance,
    $$InstancesTableFilterComposer,
    $$InstancesTableOrderingComposer,
    $$InstancesTableAnnotationComposer,
    $$InstancesTableCreateCompanionBuilder,
    $$InstancesTableUpdateCompanionBuilder,
    (Instance, $$InstancesTableReferences),
    Instance,
    PrefetchHooks Function(
        {bool templateId,
        bool parentInstanceId,
        bool instanceValuesRefs,
        bool instanceCustomFieldsRefs,
        bool instanceHiddenDimensionsRefs})>;
typedef $$InstanceValuesTableCreateCompanionBuilder = InstanceValuesCompanion
    Function({
  required String id,
  required String instanceId,
  required String dimensionId,
  required String value,
  Value<int> rowid,
});
typedef $$InstanceValuesTableUpdateCompanionBuilder = InstanceValuesCompanion
    Function({
  Value<String> id,
  Value<String> instanceId,
  Value<String> dimensionId,
  Value<String> value,
  Value<int> rowid,
});

final class $$InstanceValuesTableReferences
    extends BaseReferences<_$AppDatabase, $InstanceValuesTable, InstanceValue> {
  $$InstanceValuesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InstancesTable _instanceIdTable(_$AppDatabase db) =>
      db.instances.createAlias(
          $_aliasNameGenerator(db.instanceValues.instanceId, db.instances.id));

  $$InstancesTableProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $$InstancesTableTableManager($_db, $_db.instances)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TemplateDimensionsTable _dimensionIdTable(_$AppDatabase db) =>
      db.templateDimensions.createAlias($_aliasNameGenerator(
          db.instanceValues.dimensionId, db.templateDimensions.id));

  $$TemplateDimensionsTableProcessedTableManager get dimensionId {
    final $_column = $_itemColumn<String>('dimension_id')!;

    final manager =
        $$TemplateDimensionsTableTableManager($_db, $_db.templateDimensions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dimensionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstanceValuesTableFilterComposer
    extends Composer<_$AppDatabase, $InstanceValuesTable> {
  $$InstanceValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  $$InstancesTableFilterComposer get instanceId {
    final $$InstancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableFilterComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableFilterComposer get dimensionId {
    final $$TemplateDimensionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableFilterComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstanceValuesTable> {
  $$InstanceValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  $$InstancesTableOrderingComposer get instanceId {
    final $$InstancesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableOrderingComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableOrderingComposer get dimensionId {
    final $$TemplateDimensionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableOrderingComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstanceValuesTable> {
  $$InstanceValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$InstancesTableAnnotationComposer get instanceId {
    final $$InstancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableAnnotationComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableAnnotationComposer get dimensionId {
    final $$TemplateDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.dimensionId,
            referencedTable: $db.templateDimensions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InstanceValuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstanceValuesTable,
    InstanceValue,
    $$InstanceValuesTableFilterComposer,
    $$InstanceValuesTableOrderingComposer,
    $$InstanceValuesTableAnnotationComposer,
    $$InstanceValuesTableCreateCompanionBuilder,
    $$InstanceValuesTableUpdateCompanionBuilder,
    (InstanceValue, $$InstanceValuesTableReferences),
    InstanceValue,
    PrefetchHooks Function({bool instanceId, bool dimensionId})> {
  $$InstanceValuesTableTableManager(
      _$AppDatabase db, $InstanceValuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstanceValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstanceValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstanceValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> instanceId = const Value.absent(),
            Value<String> dimensionId = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceValuesCompanion(
            id: id,
            instanceId: instanceId,
            dimensionId: dimensionId,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String instanceId,
            required String dimensionId,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceValuesCompanion.insert(
            id: id,
            instanceId: instanceId,
            dimensionId: dimensionId,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstanceValuesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({instanceId = false, dimensionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (instanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.instanceId,
                    referencedTable:
                        $$InstanceValuesTableReferences._instanceIdTable(db),
                    referencedColumn:
                        $$InstanceValuesTableReferences._instanceIdTable(db).id,
                  ) as T;
                }
                if (dimensionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dimensionId,
                    referencedTable:
                        $$InstanceValuesTableReferences._dimensionIdTable(db),
                    referencedColumn: $$InstanceValuesTableReferences
                        ._dimensionIdTable(db)
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
        ));
}

typedef $$InstanceValuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstanceValuesTable,
    InstanceValue,
    $$InstanceValuesTableFilterComposer,
    $$InstanceValuesTableOrderingComposer,
    $$InstanceValuesTableAnnotationComposer,
    $$InstanceValuesTableCreateCompanionBuilder,
    $$InstanceValuesTableUpdateCompanionBuilder,
    (InstanceValue, $$InstanceValuesTableReferences),
    InstanceValue,
    PrefetchHooks Function({bool instanceId, bool dimensionId})>;
typedef $$InstanceCustomFieldsTableCreateCompanionBuilder
    = InstanceCustomFieldsCompanion Function({
  required String id,
  required String instanceId,
  required String name,
  required String type,
  required String value,
  required String config,
  Value<int> rowid,
});
typedef $$InstanceCustomFieldsTableUpdateCompanionBuilder
    = InstanceCustomFieldsCompanion Function({
  Value<String> id,
  Value<String> instanceId,
  Value<String> name,
  Value<String> type,
  Value<String> value,
  Value<String> config,
  Value<int> rowid,
});

final class $$InstanceCustomFieldsTableReferences extends BaseReferences<
    _$AppDatabase, $InstanceCustomFieldsTable, InstanceCustomField> {
  $$InstanceCustomFieldsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InstancesTable _instanceIdTable(_$AppDatabase db) =>
      db.instances.createAlias($_aliasNameGenerator(
          db.instanceCustomFields.instanceId, db.instances.id));

  $$InstancesTableProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $$InstancesTableTableManager($_db, $_db.instances)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstanceCustomFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $InstanceCustomFieldsTable> {
  $$InstanceCustomFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnFilters(column));

  $$InstancesTableFilterComposer get instanceId {
    final $$InstancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableFilterComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceCustomFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstanceCustomFieldsTable> {
  $$InstanceCustomFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnOrderings(column));

  $$InstancesTableOrderingComposer get instanceId {
    final $$InstancesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableOrderingComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceCustomFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstanceCustomFieldsTable> {
  $$InstanceCustomFieldsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  $$InstancesTableAnnotationComposer get instanceId {
    final $$InstancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableAnnotationComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceCustomFieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstanceCustomFieldsTable,
    InstanceCustomField,
    $$InstanceCustomFieldsTableFilterComposer,
    $$InstanceCustomFieldsTableOrderingComposer,
    $$InstanceCustomFieldsTableAnnotationComposer,
    $$InstanceCustomFieldsTableCreateCompanionBuilder,
    $$InstanceCustomFieldsTableUpdateCompanionBuilder,
    (InstanceCustomField, $$InstanceCustomFieldsTableReferences),
    InstanceCustomField,
    PrefetchHooks Function({bool instanceId})> {
  $$InstanceCustomFieldsTableTableManager(
      _$AppDatabase db, $InstanceCustomFieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstanceCustomFieldsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstanceCustomFieldsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstanceCustomFieldsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> instanceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<String> config = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceCustomFieldsCompanion(
            id: id,
            instanceId: instanceId,
            name: name,
            type: type,
            value: value,
            config: config,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String instanceId,
            required String name,
            required String type,
            required String value,
            required String config,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceCustomFieldsCompanion.insert(
            id: id,
            instanceId: instanceId,
            name: name,
            type: type,
            value: value,
            config: config,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstanceCustomFieldsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({instanceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (instanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.instanceId,
                    referencedTable: $$InstanceCustomFieldsTableReferences
                        ._instanceIdTable(db),
                    referencedColumn: $$InstanceCustomFieldsTableReferences
                        ._instanceIdTable(db)
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
        ));
}

typedef $$InstanceCustomFieldsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InstanceCustomFieldsTable,
        InstanceCustomField,
        $$InstanceCustomFieldsTableFilterComposer,
        $$InstanceCustomFieldsTableOrderingComposer,
        $$InstanceCustomFieldsTableAnnotationComposer,
        $$InstanceCustomFieldsTableCreateCompanionBuilder,
        $$InstanceCustomFieldsTableUpdateCompanionBuilder,
        (InstanceCustomField, $$InstanceCustomFieldsTableReferences),
        InstanceCustomField,
        PrefetchHooks Function({bool instanceId})>;
typedef $$InstanceHiddenDimensionsTableCreateCompanionBuilder
    = InstanceHiddenDimensionsCompanion Function({
  required String id,
  required String instanceId,
  required String dimensionId,
  Value<int> rowid,
});
typedef $$InstanceHiddenDimensionsTableUpdateCompanionBuilder
    = InstanceHiddenDimensionsCompanion Function({
  Value<String> id,
  Value<String> instanceId,
  Value<String> dimensionId,
  Value<int> rowid,
});

final class $$InstanceHiddenDimensionsTableReferences extends BaseReferences<
    _$AppDatabase, $InstanceHiddenDimensionsTable, InstanceHiddenDimension> {
  $$InstanceHiddenDimensionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $InstancesTable _instanceIdTable(_$AppDatabase db) =>
      db.instances.createAlias($_aliasNameGenerator(
          db.instanceHiddenDimensions.instanceId, db.instances.id));

  $$InstancesTableProcessedTableManager get instanceId {
    final $_column = $_itemColumn<String>('instance_id')!;

    final manager = $$InstancesTableTableManager($_db, $_db.instances)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_instanceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TemplateDimensionsTable _dimensionIdTable(_$AppDatabase db) =>
      db.templateDimensions.createAlias($_aliasNameGenerator(
          db.instanceHiddenDimensions.dimensionId, db.templateDimensions.id));

  $$TemplateDimensionsTableProcessedTableManager get dimensionId {
    final $_column = $_itemColumn<String>('dimension_id')!;

    final manager =
        $$TemplateDimensionsTableTableManager($_db, $_db.templateDimensions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dimensionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InstanceHiddenDimensionsTableFilterComposer
    extends Composer<_$AppDatabase, $InstanceHiddenDimensionsTable> {
  $$InstanceHiddenDimensionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  $$InstancesTableFilterComposer get instanceId {
    final $$InstancesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableFilterComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableFilterComposer get dimensionId {
    final $$TemplateDimensionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableFilterComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceHiddenDimensionsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstanceHiddenDimensionsTable> {
  $$InstanceHiddenDimensionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  $$InstancesTableOrderingComposer get instanceId {
    final $$InstancesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableOrderingComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableOrderingComposer get dimensionId {
    final $$TemplateDimensionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableOrderingComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InstanceHiddenDimensionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstanceHiddenDimensionsTable> {
  $$InstanceHiddenDimensionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$InstancesTableAnnotationComposer get instanceId {
    final $$InstancesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.instanceId,
        referencedTable: $db.instances,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InstancesTableAnnotationComposer(
              $db: $db,
              $table: $db.instances,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableAnnotationComposer get dimensionId {
    final $$TemplateDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.dimensionId,
            referencedTable: $db.templateDimensions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InstanceHiddenDimensionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstanceHiddenDimensionsTable,
    InstanceHiddenDimension,
    $$InstanceHiddenDimensionsTableFilterComposer,
    $$InstanceHiddenDimensionsTableOrderingComposer,
    $$InstanceHiddenDimensionsTableAnnotationComposer,
    $$InstanceHiddenDimensionsTableCreateCompanionBuilder,
    $$InstanceHiddenDimensionsTableUpdateCompanionBuilder,
    (InstanceHiddenDimension, $$InstanceHiddenDimensionsTableReferences),
    InstanceHiddenDimension,
    PrefetchHooks Function({bool instanceId, bool dimensionId})> {
  $$InstanceHiddenDimensionsTableTableManager(
      _$AppDatabase db, $InstanceHiddenDimensionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstanceHiddenDimensionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$InstanceHiddenDimensionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstanceHiddenDimensionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> instanceId = const Value.absent(),
            Value<String> dimensionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceHiddenDimensionsCompanion(
            id: id,
            instanceId: instanceId,
            dimensionId: dimensionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String instanceId,
            required String dimensionId,
            Value<int> rowid = const Value.absent(),
          }) =>
              InstanceHiddenDimensionsCompanion.insert(
            id: id,
            instanceId: instanceId,
            dimensionId: dimensionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InstanceHiddenDimensionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({instanceId = false, dimensionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (instanceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.instanceId,
                    referencedTable: $$InstanceHiddenDimensionsTableReferences
                        ._instanceIdTable(db),
                    referencedColumn: $$InstanceHiddenDimensionsTableReferences
                        ._instanceIdTable(db)
                        .id,
                  ) as T;
                }
                if (dimensionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dimensionId,
                    referencedTable: $$InstanceHiddenDimensionsTableReferences
                        ._dimensionIdTable(db),
                    referencedColumn: $$InstanceHiddenDimensionsTableReferences
                        ._dimensionIdTable(db)
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
        ));
}

typedef $$InstanceHiddenDimensionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $InstanceHiddenDimensionsTable,
        InstanceHiddenDimension,
        $$InstanceHiddenDimensionsTableFilterComposer,
        $$InstanceHiddenDimensionsTableOrderingComposer,
        $$InstanceHiddenDimensionsTableAnnotationComposer,
        $$InstanceHiddenDimensionsTableCreateCompanionBuilder,
        $$InstanceHiddenDimensionsTableUpdateCompanionBuilder,
        (InstanceHiddenDimension, $$InstanceHiddenDimensionsTableReferences),
        InstanceHiddenDimension,
        PrefetchHooks Function({bool instanceId, bool dimensionId})>;
typedef $$TemplateThumbnailFieldsTableCreateCompanionBuilder
    = TemplateThumbnailFieldsCompanion Function({
  required String id,
  required String templateId,
  required String dimensionId,
  required int sortOrder,
  Value<int> rowid,
});
typedef $$TemplateThumbnailFieldsTableUpdateCompanionBuilder
    = TemplateThumbnailFieldsCompanion Function({
  Value<String> id,
  Value<String> templateId,
  Value<String> dimensionId,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $$TemplateThumbnailFieldsTableReferences extends BaseReferences<
    _$AppDatabase, $TemplateThumbnailFieldsTable, TemplateThumbnailField> {
  $$TemplateThumbnailFieldsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $TemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.templates.createAlias($_aliasNameGenerator(
          db.templateThumbnailFields.templateId, db.templates.id));

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$TemplatesTableTableManager($_db, $_db.templates)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TemplateDimensionsTable _dimensionIdTable(_$AppDatabase db) =>
      db.templateDimensions.createAlias($_aliasNameGenerator(
          db.templateThumbnailFields.dimensionId, db.templateDimensions.id));

  $$TemplateDimensionsTableProcessedTableManager get dimensionId {
    final $_column = $_itemColumn<String>('dimension_id')!;

    final manager =
        $$TemplateDimensionsTableTableManager($_db, $_db.templateDimensions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dimensionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TemplateThumbnailFieldsTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateThumbnailFieldsTable> {
  $$TemplateThumbnailFieldsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableFilterComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableFilterComposer get dimensionId {
    final $$TemplateDimensionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableFilterComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateThumbnailFieldsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateThumbnailFieldsTable> {
  $$TemplateThumbnailFieldsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableOrderingComposer get dimensionId {
    final $$TemplateDimensionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.dimensionId,
        referencedTable: $db.templateDimensions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplateDimensionsTableOrderingComposer(
              $db: $db,
              $table: $db.templateDimensions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TemplateThumbnailFieldsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateThumbnailFieldsTable> {
  $$TemplateThumbnailFieldsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.templates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.templates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TemplateDimensionsTableAnnotationComposer get dimensionId {
    final $$TemplateDimensionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.dimensionId,
            referencedTable: $db.templateDimensions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$TemplateDimensionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.templateDimensions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$TemplateThumbnailFieldsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TemplateThumbnailFieldsTable,
    TemplateThumbnailField,
    $$TemplateThumbnailFieldsTableFilterComposer,
    $$TemplateThumbnailFieldsTableOrderingComposer,
    $$TemplateThumbnailFieldsTableAnnotationComposer,
    $$TemplateThumbnailFieldsTableCreateCompanionBuilder,
    $$TemplateThumbnailFieldsTableUpdateCompanionBuilder,
    (TemplateThumbnailField, $$TemplateThumbnailFieldsTableReferences),
    TemplateThumbnailField,
    PrefetchHooks Function({bool templateId, bool dimensionId})> {
  $$TemplateThumbnailFieldsTableTableManager(
      _$AppDatabase db, $TemplateThumbnailFieldsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateThumbnailFieldsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateThumbnailFieldsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateThumbnailFieldsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> dimensionId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateThumbnailFieldsCompanion(
            id: id,
            templateId: templateId,
            dimensionId: dimensionId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required String dimensionId,
            required int sortOrder,
            Value<int> rowid = const Value.absent(),
          }) =>
              TemplateThumbnailFieldsCompanion.insert(
            id: id,
            templateId: templateId,
            dimensionId: dimensionId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$TemplateThumbnailFieldsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false, dimensionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable: $$TemplateThumbnailFieldsTableReferences
                        ._templateIdTable(db),
                    referencedColumn: $$TemplateThumbnailFieldsTableReferences
                        ._templateIdTable(db)
                        .id,
                  ) as T;
                }
                if (dimensionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.dimensionId,
                    referencedTable: $$TemplateThumbnailFieldsTableReferences
                        ._dimensionIdTable(db),
                    referencedColumn: $$TemplateThumbnailFieldsTableReferences
                        ._dimensionIdTable(db)
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
        ));
}

typedef $$TemplateThumbnailFieldsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TemplateThumbnailFieldsTable,
        TemplateThumbnailField,
        $$TemplateThumbnailFieldsTableFilterComposer,
        $$TemplateThumbnailFieldsTableOrderingComposer,
        $$TemplateThumbnailFieldsTableAnnotationComposer,
        $$TemplateThumbnailFieldsTableCreateCompanionBuilder,
        $$TemplateThumbnailFieldsTableUpdateCompanionBuilder,
        (TemplateThumbnailField, $$TemplateThumbnailFieldsTableReferences),
        TemplateThumbnailField,
        PrefetchHooks Function({bool templateId, bool dimensionId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$TemplateDimensionsTableTableManager get templateDimensions =>
      $$TemplateDimensionsTableTableManager(_db, _db.templateDimensions);
  $$InstancesTableTableManager get instances =>
      $$InstancesTableTableManager(_db, _db.instances);
  $$InstanceValuesTableTableManager get instanceValues =>
      $$InstanceValuesTableTableManager(_db, _db.instanceValues);
  $$InstanceCustomFieldsTableTableManager get instanceCustomFields =>
      $$InstanceCustomFieldsTableTableManager(_db, _db.instanceCustomFields);
  $$InstanceHiddenDimensionsTableTableManager get instanceHiddenDimensions =>
      $$InstanceHiddenDimensionsTableTableManager(
          _db, _db.instanceHiddenDimensions);
  $$TemplateThumbnailFieldsTableTableManager get templateThumbnailFields =>
      $$TemplateThumbnailFieldsTableTableManager(
          _db, _db.templateThumbnailFields);
}
