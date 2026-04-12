import 'package:drift/drift.dart';

class Templates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TemplateDimensions extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get parentId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get config => text().withDefault(const Constant('{}'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Instances extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get parentInstanceId => text().nullable()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class InstanceValues extends Table {
  TextColumn get id => text()();
  TextColumn get instanceId => text().references(Instances, #id, onDelete: KeyAction.cascade)();
  TextColumn get dimensionId => text().references(TemplateDimensions, #id, onDelete: KeyAction.cascade)();
  TextColumn get value => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE (instance_id, dimension_id)',
  ];
}

class InstanceCustomFields extends Table {
  TextColumn get id => text()();
  TextColumn get instanceId => text().references(Instances, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get value => text().withDefault(const Constant(''))();
  TextColumn get config => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};
}

class InstanceHiddenDimensions extends Table {
  TextColumn get id => text()();
  TextColumn get instanceId => text().references(Instances, #id, onDelete: KeyAction.cascade)();
  TextColumn get dimensionId => text().references(TemplateDimensions, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE (instance_id, dimension_id)',
  ];
}

class TemplateThumbnailFields extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get dimensionId => text().references(TemplateDimensions, #id, onDelete: KeyAction.cascade)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
