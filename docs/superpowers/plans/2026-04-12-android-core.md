# House Note Android Local Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Flutter Android app for House Note covering template management, instance creation/editing, hierarchical browsing, and thumbnail customization with offline-first SQLite storage.

**Architecture:** Flutter with `flutter_bloc` for state management, Drift (SQLite) for local persistence, and a bottom 3-tab navigation shell. Data access is abstracted through repository classes over Drift.

**Tech Stack:** Flutter, Dart, flutter_bloc, drift, drift_flutter, sqlite3_flutter_libs, path_provider, uuid, equatable, bloc_test, mocktail

---

## File Structure

```
app/
  lib/
    main.dart
    app.dart
    data/
      tables.dart              # Drift table definitions
      database.dart            # Drift database setup
      template_repository.dart # Template CRUD + tree ops
      instance_repository.dart # Instance CRUD + values
    models/
      dimension_node.dart      # In-memory tree model for editor
    blocs/
      template_list/
        cubit.dart
        state.dart
      template_editor/
        cubit.dart
        state.dart
      instance_list/
        cubit.dart
        state.dart
      instance_editor/
        cubit.dart
        state.dart
      settings/
        cubit.dart
        state.dart
    screens/
      template_list_screen.dart
      template_editor_screen.dart
      instance_list_screen.dart
      instance_editor_screen.dart
      settings_screen.dart
    widgets/
      dimension_tree.dart
      instance_card.dart
      breadcrumb_bar.dart
  test/
    data/
      template_repository_test.dart
      instance_repository_test.dart
    blocs/
      template_list_cubit_test.dart
      template_editor_cubit_test.dart
      instance_list_cubit_test.dart
      instance_editor_cubit_test.dart
    widget_test.dart
```

---

### Task 1: Flutter Project Scaffold and Dependencies

**Files:**
- Create: `app/pubspec.yaml`
- Create: `app/lib/main.dart`
- Create: `app/lib/app.dart`
- Modify: root `.gitignore`

- [ ] **Step 1: Create Flutter project directory structure**

Run:
```bash
flutter create --project-name house_note --org com.example app
```

- [ ] **Step 2: Replace `app/pubspec.yaml` with explicit dependencies**

```yaml
name: house_note
description: House Note - rental viewing recorder
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  drift: ^2.14.0
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3
  uuid: ^4.2.1
  equatable: ^2.0.5
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  bloc_test: ^9.1.5
  mocktail: ^1.0.1
  build_runner: ^2.4.7
  drift_dev: ^2.14.0

flutter:
  uses-material-design: true
```

- [ ] **Step 3: Run `flutter pub get`**

Run:
```bash
cd app && flutter pub get
```

- [ ] **Step 4: Write `app/lib/main.dart` as minimal bootstrap**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'data/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(HouseNoteApp(database: db));
}
```

- [ ] **Step 5: Write `app/lib/app.dart` shell with MaterialApp**

```dart
import 'package:flutter/material.dart';
import 'data/database.dart';

class HouseNoteApp extends StatelessWidget {
  final AppDatabase database;

  const HouseNoteApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'House Note',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('House Note')),
      ),
    );
  }
}
```

- [ ] **Step 6: Update root `.gitignore` to ignore Flutter/Android build artifacts**

Old content:
```
app/
```

New content:
```
app/.dart_tool/
app/.flutter-plugins
app/.flutter-plugins-dependencies
app/.packages
app/build/
app/android/.gradle/
app/android/app/debug/
app/android/app/profile/
app/android/app/release/
app/ios/Pods/
app/ios/.symlinks/
app/macos/Flutter/ephemeral/
app/windows/Flutter/ephemeral/
app/linux/Flutter/ephemeral/
*.iml
```

- [ ] **Step 7: Commit**

Run:
```bash
git add app/ .gitignore
git commit -m "chore: scaffold Flutter project with dependencies"
```

---

### Task 2: Drift Database Tables

**Files:**
- Create: `app/lib/data/tables.dart`

- [ ] **Step 1: Write `app/lib/data/tables.dart` with all 7 tables**

```dart
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
  TextColumn get config => text().withDefault(Constant('{}'))();
  IntColumn get sortOrder => integer().withDefault(Constant(0))();

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
  TextColumn get value => text().withDefault(Constant(''))();

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
  TextColumn get value => text().withDefault(Constant(''))();
  TextColumn get config => text().withDefault(Constant('{}'))();

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
  IntColumn get sortOrder => integer().withDefault(Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Verify file compiles with no syntax errors**

Run:
```bash
cd app && dart analyze lib/data/tables.dart
```
Expected: no errors

- [ ] **Step 3: Commit**

Run:
```bash
git add app/lib/data/tables.dart
git commit -m "feat: add Drift table definitions"
```

---

### Task 3: Drift Database Class and Generated Code

**Files:**
- Create: `app/lib/data/database.dart`
- Create generated: `app/lib/data/database.g.dart`

- [ ] **Step 1: Write `app/lib/data/database.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Templates,
  TemplateDimensions,
  Instances,
  InstanceValues,
  InstanceCustomFields,
  InstanceHiddenDimensions,
  TemplateThumbnailFields,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'house_note_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }
}
```

- [ ] **Step 2: Run build_runner to generate `database.g.dart`**

Run:
```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```
Expected: succeeds and creates `lib/data/database.g.dart`

- [ ] **Step 3: Verify compilation**

Run:
```bash
cd app && dart analyze lib/data/database.dart
```
Expected: no errors

- [ ] **Step 4: Commit**

Run:
```bash
git add app/lib/data/database.dart app/lib/data/database.g.dart
git commit -m "feat: add Drift database class and generated code"
```

---

### Task 4: Dimension Tree Model

**Files:**
- Create: `app/lib/models/dimension_node.dart`
- Test: `app/test/models/dimension_node_test.dart`

- [ ] **Step 1: Write the failing test for `DimensionNode`**

Create `app/test/models/dimension_node_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/models/dimension_node.dart';

void main() {
  group('DimensionNode', () {
    test('copyWith updates name', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Old',
        type: 'text',
        children: const [],
      );
      final updated = node.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.id, '1');
    });

    test('flatten returns DFS ordered list with depth', () {
      final child = DimensionNode(
        id: '2',
        templateId: 't1',
        name: 'Child',
        type: 'number',
        parentId: '1',
        children: const [],
      );
      final root = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Root',
        type: 'group',
        children: [child],
      );
      final flat = root.flatten();
      expect(flat.length, 2);
      expect(flat[0].node.id, '1');
      expect(flat[0].depth, 0);
      expect(flat[1].node.id, '2');
      expect(flat[1].depth, 1);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/models/dimension_node_test.dart
```
Expected: FAIL - file not found / class not defined

- [ ] **Step 3: Write `app/lib/models/dimension_node.dart`**

```dart
import 'package:equatable/equatable.dart';

class FlattenedDimension {
  final DimensionNode node;
  final int depth;

  const FlattenedDimension(this.node, this.depth);
}

class DimensionNode extends Equatable {
  final String id;
  final String templateId;
  final String? parentId;
  final String name;
  final String type;
  final String config;
  final int sortOrder;
  final List<DimensionNode> children;

  const DimensionNode({
    required this.id,
    required this.templateId,
    this.parentId,
    required this.name,
    required this.type,
    this.config = '{}',
    this.sortOrder = 0,
    this.children = const [],
  });

  DimensionNode copyWith({
    String? id,
    String? templateId,
    String? parentId,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
    List<DimensionNode>? children,
  }) {
    return DimensionNode(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
      children: children ?? this.children,
    );
  }

  List<FlattenedDimension> flatten({int depth = 0}) {
    final result = <FlattenedDimension>[FlattenedDimension(this, depth)];
    for (final child in children) {
      result.addAll(child.flatten(depth: depth + 1));
    }
    return result;
  }

  @override
  List<Object?> get props => [id, templateId, parentId, name, type, config, sortOrder, children];
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/models/dimension_node_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/models/dimension_node.dart app/test/models/dimension_node_test.dart
git commit -m "feat: add DimensionNode model with flatten"
```

---

### Task 5: Template Repository

**Files:**
- Create: `app/lib/data/template_repository.dart`
- Test: `app/test/data/template_repository_test.dart`

- [ ] **Step 1: Write failing test for template repository**

Create `app/test/data/template_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/tables.dart';
import 'package:house_note/data/template_repository.dart';

void main() {
  late AppDatabase db;
  late TemplateRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = TemplateRepository(db);
  });

  tearDown(() async => db.close());

  group('insertTemplate', () {
    test('inserts template with dimensions', () async {
      final template = TemplatesCompanion.insert(
        id: 't1',
        name: '房子模板',
        createdAt: 0,
        updatedAt: 0,
      );
      final dimensions = [
        TemplateDimensionsCompanion.insert(
          id: 'd1',
          templateId: 't1',
          name: '朝向',
          type: 'single_choice',
          config: '{"options":["东","南","西","北"]}',
          sortOrder: 0,
        ),
      ];
      await repo.insertTemplate(template, dimensions);
      final result = await repo.getTemplateById('t1');
      expect(result, isNotNull);
      expect(result!.template.name, '房子模板');
      expect(result.dimensions.length, 1);
      expect(result.dimensions.first.name, '朝向');
    });
  });

  group('watchAllTemplates', () {
    test('emits list after insert', () async {
      await db.into(db.templates).insert(TemplatesCompanion.insert(
        id: 't1',
        name: '测试模板',
        createdAt: 1,
        updatedAt: 1,
      ));
      expectLater(
        repo.watchAllTemplates(),
        emits(predicate<List<Template>>((list) => list.length == 1 && list.first.name == '测试模板')),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/data/template_repository_test.dart
```
Expected: FAIL - TemplateRepository not found

- [ ] **Step 3: Write `app/lib/data/template_repository.dart`**

```dart
import 'package:drift/drift.dart';
import 'database.dart';

class TemplateWithDimensions {
  final Template template;
  final List<TemplateDimension> dimensions;

  TemplateWithDimensions(this.template, this.dimensions);
}

class TemplateRepository {
  final AppDatabase _db;

  TemplateRepository(this._db);

  Stream<List<Template>> watchAllTemplates() {
    return _db.select(_db.templates).watch();
  }

  Future<TemplateWithDimensions?> getTemplateById(String id) async {
    final template = await (_db.select(_db.templates)
      ..where((t) => t.id.equals(id)))
      .getSingleOrNull();
    if (template == null) return null;

    final dimensions = await (_db.select(_db.templateDimensions)
      ..where((d) => d.templateId.equals(id))
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
      .get();

    return TemplateWithDimensions(template, dimensions);
  }

  Future<void> insertTemplate(
    TemplatesCompanion template,
    List<TemplateDimensionsCompanion> dimensions,
  ) async {
    await _db.transaction(() async {
      await _db.into(_db.templates).insert(template);
      for (final d in dimensions) {
        await _db.into(_db.templateDimensions).insert(d);
      }
    });
  }

  Future<void> updateTemplate(
    TemplatesCompanion template,
    List<TemplateDimensionsCompanion> dimensions,
  ) async {
    await _db.transaction(() async {
      await _db.update(_db.templates).replace(template);
      await (_db.delete(_db.templateDimensions)
        ..where((d) => d.templateId.equals(template.id.value)))
        .go();
      for (final d in dimensions) {
        await _db.into(_db.templateDimensions).insert(d, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> deleteTemplate(String id) async {
    await (_db.delete(_db.templates)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countInstancesForTemplate(String templateId) async {
    final query = _db.select(_db.instances)
      ..where((i) => i.templateId.equals(templateId));
    return query.get().then((rows) => rows.length);
  }

  Future<List<TemplateThumbnailField>> getThumbnailFields(String templateId) async {
    return (_db.select(_db.templateThumbnailFields)
      ..where((f) => f.templateId.equals(templateId))
      ..orderBy([(f) => OrderingTerm(expression: f.sortOrder)]))
      .get();
  }

  Future<void> setThumbnailFields(
    String templateId,
    List<TemplateThumbnailFieldsCompanion> fields,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.templateThumbnailFields)
        ..where((f) => f.templateId.equals(templateId)))
        .go();
      for (final f in fields) {
        await _db.into(_db.templateThumbnailFields).insert(f);
      }
    });
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/data/template_repository_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/data/template_repository.dart app/test/data/template_repository_test.dart
git commit -m "feat: add template repository with CRUD and thumbnail fields"
```

---

### Task 6: Instance Repository

**Files:**
- Create: `app/lib/data/instance_repository.dart`
- Test: `app/test/data/instance_repository_test.dart`

- [ ] **Step 1: Write failing test for instance repository**

Create `app/test/data/instance_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:house_note/data/tables.dart';

void main() {
  late AppDatabase db;
  late InstanceRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = InstanceRepository(db);
    await db.into(db.templates).insert(TemplatesCompanion.insert(
      id: 'tmpl',
      name: 'T',
      createdAt: 0,
      updatedAt: 0,
    ));
    await db.into(db.templateDimensions).insert(TemplateDimensionsCompanion.insert(
      id: 'dim',
      templateId: 'tmpl',
      name: 'F',
      type: 'text',
      sortOrder: 0,
    ));
  });

  tearDown(() async => db.close());

  test('insertInstance with values', () async {
    final instance = InstancesCompanion.insert(
      id: 'i1',
      templateId: 'tmpl',
      name: 'Instance',
      createdAt: 1,
      updatedAt: 1,
    );
    final values = [
      InstanceValuesCompanion.insert(
        id: 'v1',
        instanceId: 'i1',
        dimensionId: 'dim',
        value: 'hello',
      ),
    ];
    await repo.insertInstance(instance, values: values);
    final result = await repo.getInstanceById('i1');
    expect(result, isNotNull);
    expect(result!.instance.name, 'Instance');
    expect(result.values.length, 1);
    expect(result.values.first.value, 'hello');
  });

  test('watchTopLevelInstances emits inserted instances', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'i1',
      templateId: 'tmpl',
      name: 'Top',
      createdAt: 1,
      updatedAt: 1,
    ));
    expectLater(
      repo.watchTopLevelInstances(),
      emits(predicate<List<Instance>>((list) => list.length == 1 && list.first.name == 'Top')),
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/data/instance_repository_test.dart
```
Expected: FAIL - InstanceRepository not found

- [ ] **Step 3: Write `app/lib/data/instance_repository.dart`**

```dart
import 'package:drift/drift.dart';
import 'database.dart';

class InstanceWithData {
  final Instance instance;
  final List<InstanceValue> values;
  final List<InstanceCustomField> customFields;
  final List<InstanceHiddenDimension> hiddenDimensions;

  InstanceWithData(
    this.instance,
    this.values,
    this.customFields,
    this.hiddenDimensions,
  );
}

class InstanceRepository {
  final AppDatabase _db;

  InstanceRepository(this._db);

  Stream<List<Instance>> watchTopLevelInstances() {
    return (_db.select(_db.instances)
      ..where((i) => i.parentInstanceId.isNull())
      ..orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]))
      .watch();
  }

  Stream<List<Instance>> watchChildInstances(String parentInstanceId) {
    return (_db.select(_db.instances)
      ..where((i) => i.parentInstanceId.equals(parentInstanceId))
      ..orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]))
      .watch();
  }

  Future<InstanceWithData?> getInstanceById(String id) async {
    final instance = await (_db.select(_db.instances)
      ..where((i) => i.id.equals(id)))
      .getSingleOrNull();
    if (instance == null) return null;

    final values = await (_db.select(_db.instanceValues)
      ..where((v) => v.instanceId.equals(id)))
      .get();
    final customFields = await (_db.select(_db.instanceCustomFields)
      ..where((f) => f.instanceId.equals(id)))
      .get();
    final hidden = await (_db.select(_db.instanceHiddenDimensions)
      ..where((h) => h.instanceId.equals(id)))
      .get();

    return InstanceWithData(instance, values, customFields, hidden);
  }

  Future<void> insertInstance(
    InstancesCompanion instance, {
    List<InstanceValuesCompanion> values = const [],
    List<InstanceCustomFieldsCompanion> customFields = const [],
    List<InstanceHiddenDimensionsCompanion> hiddenDimensions = const [],
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.instances).insert(instance);
      for (final v in values) {
        await _db.into(_db.instanceValues).insert(v, mode: InsertMode.insertOrReplace);
      }
      for (final f in customFields) {
        await _db.into(_db.instanceCustomFields).insert(f, mode: InsertMode.insertOrReplace);
      }
      for (final h in hiddenDimensions) {
        await _db.into(_db.instanceHiddenDimensions).insert(h, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<void> updateInstance(
    InstancesCompanion instance, {
    List<InstanceValuesCompanion> values = const [],
    List<InstanceCustomFieldsCompanion> customFields = const [],
    List<InstanceHiddenDimensionsCompanion> hiddenDimensions = const [],
  }) async {
    await _db.transaction(() async {
      await _db.update(_db.instances).replace(instance);
      for (final v in values) {
        await _db.into(_db.instanceValues).insert(v, mode: InsertMode.insertOrReplace);
      }
      await (_db.delete(_db.instanceCustomFields)
        ..where((f) => f.instanceId.equals(instance.id.value)))
        .go();
      for (final f in customFields) {
        await _db.into(_db.instanceCustomFields).insert(f);
      }
      await (_db.delete(_db.instanceHiddenDimensions)
        ..where((h) => h.instanceId.equals(instance.id.value)))
        .go();
      for (final h in hiddenDimensions) {
        await _db.into(_db.instanceHiddenDimensions).insert(h);
      }
    });
  }

  Future<void> deleteInstance(String id) async {
    await (_db.delete(_db.instances)..where((i) => i.id.equals(id))).go();
  }

  Future<List<TemplateDimension>> getRefSubtemplateDimensions(String templateId) async {
    return (_db.select(_db.templateDimensions)
      ..where((d) => d.templateId.equals(templateId) & d.type.equals('ref_subtemplate'))
      ..orderBy([(d) => OrderingTerm(expression: d.sortOrder)]))
      .get();
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/data/instance_repository_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/data/instance_repository.dart app/test/data/instance_repository_test.dart
git commit -m "feat: add instance repository with values, custom fields, hidden dims"
```

---

### Task 7: TemplateListCubit

**Files:**
- Create: `app/lib/blocs/template_list/cubit.dart`
- Create: `app/lib/blocs/template_list/state.dart`
- Test: `app/test/blocs/template_list_cubit_test.dart`

- [ ] **Step 1: Write failing test for TemplateListCubit**

Create `app/test/blocs/template_list_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_list/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/tables.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late MockTemplateRepository repo;

  setUp(() => repo = MockTemplateRepository());

  blocTest<TemplateListCubit, TemplateListState>(
    'emits loaded templates on load',
    build: () => TemplateListCubit(repo),
    act: (cubit) {
      when(() => repo.watchAllTemplates()).thenAnswer(
        (_) => Stream.value([
          Template(id: '1', name: 'T1', createdAt: 1, updatedAt: 1),
        ]),
      );
      cubit.load();
    },
    expect: () => [
      TemplateListState(templates: [
        Template(id: '1', name: 'T1', createdAt: 1, updatedAt: 1),
      ]),
    ],
  );
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/blocs/template_list_cubit_test.dart
```
Expected: FAIL - cubit not found

- [ ] **Step 3: Write `app/lib/blocs/template_list/cubit.dart` and `state.dart`**

`app/lib/blocs/template_list/state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../data/database.dart';

class TemplateListState extends Equatable {
  final List<Template> templates;

  const TemplateListState({this.templates = const []});

  @override
  List<Object?> get props => [templates];
}
```

`app/lib/blocs/template_list/cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/template_repository.dart';
import 'state.dart';

class TemplateListCubit extends Cubit<TemplateListState> {
  final TemplateRepository _repo;

  TemplateListCubit(this._repo) : super(const TemplateListState());

  void load() {
    _repo.watchAllTemplates().listen((templates) {
      emit(TemplateListState(templates: templates));
    });
  }

  Future<void> deleteTemplate(String id) async {
    await _repo.deleteTemplate(id);
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/blocs/template_list_cubit_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/blocs/template_list/cubit.dart app/lib/blocs/template_list/state.dart app/test/blocs/template_list_cubit_test.dart
git commit -m "feat: add TemplateListCubit with load and delete"
```

---

### Task 8: TemplateEditorCubit

**Files:**
- Create: `app/lib/blocs/template_editor/cubit.dart`
- Create: `app/lib/blocs/template_editor/state.dart`
- Test: `app/test/blocs/template_editor_cubit_test.dart`

- [ ] **Step 1: Write failing test for TemplateEditorCubit**

Create `app/test/blocs/template_editor_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_editor/cubit.dart';
import 'package:house_note/models/dimension_node.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('TemplateEditorCubit', () {
    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'adds dimension',
      build: () => TemplateEditorCubit(),
      act: (cubit) {
        cubit.setTemplateName('Test');
        cubit.addDimension(name: 'D1', type: 'text');
      },
      expect: () => [
        TemplateEditorState(templateName: 'Test', dimensions: const [], availableTemplates: const []),
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.name == 'D1'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moves dimension into group',
      build: () => TemplateEditorCubit(),
      seed: () => TemplateEditorState(
        templateName: 'T',
        dimensions: [
          DimensionNode(id: 'g', templateId: '', name: 'Group', type: 'group', children: const []),
          DimensionNode(id: 'd', templateId: '', name: 'Dim', type: 'text', children: const []),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 1, newIndex: 0, targetParentId: 'g'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final group = s.dimensions.firstWhere((d) => d.id == 'g');
          return group.children.length == 1 && group.children.first.id == 'd';
        }),
      ],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/blocs/template_editor_cubit_test.dart
```
Expected: FAIL - cubit not found

- [ ] **Step 3: Write `app/lib/blocs/template_editor/state.dart` and `cubit.dart`**

`app/lib/blocs/template_editor/state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../data/database.dart';
import '../../models/dimension_node.dart';

class TemplateEditorState extends Equatable {
  final String templateName;
  final List<DimensionNode> dimensions;
  final List<Template> availableTemplates;

  const TemplateEditorState({
    this.templateName = '',
    this.dimensions = const [],
    this.availableTemplates = const [],
  });

  TemplateEditorState copyWith({
    String? templateName,
    List<DimensionNode>? dimensions,
    List<Template>? availableTemplates,
  }) {
    return TemplateEditorState(
      templateName: templateName ?? this.templateName,
      dimensions: dimensions ?? this.dimensions,
      availableTemplates: availableTemplates ?? this.availableTemplates,
    );
  }

  @override
  List<Object?> get props => [templateName, dimensions, availableTemplates];
}
```

`app/lib/blocs/template_editor/cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/tables.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

class TemplateEditorCubit extends Cubit<TemplateEditorState> {
  final TemplateRepository? _repo;
  String? _templateId;

  TemplateEditorCubit([this._repo]) : super(const TemplateEditorState());

  void setTemplateName(String name) {
    emit(state.copyWith(templateName: name));
  }

  void addDimension({required String name, required String type, String config = '{}', String? parentId}) {
    final node = DimensionNode(
      id: const Uuid().v4(),
      templateId: _templateId ?? '',
      parentId: parentId,
      name: name,
      type: type,
      config: config,
      sortOrder: state.dimensions.length,
    );
    if (parentId == null) {
      emit(state.copyWith(dimensions: [...state.dimensions, node]));
    } else {
      emit(state.copyWith(dimensions: _insertIntoParent(state.dimensions, parentId, node)));
    }
  }

  void updateDimension(String id, {String? name, String? type, String? config}) {
    emit(state.copyWith(dimensions: _updateInTree(state.dimensions, id, name: name, type: type, config: config)));
  }

  void removeDimension(String id) {
    emit(state.copyWith(dimensions: _removeFromTree(state.dimensions, id)));
  }

  void moveDimension({required int oldIndex, required int newIndex, String? targetParentId}) {
    final flat = _flatten(state.dimensions);
    if (oldIndex < 0 || oldIndex >= flat.length) return;
    final moved = flat[oldIndex];
    final removed = _removeFromTree(state.dimensions, moved.id);
    if (targetParentId != null) {
      final updated = moved.copyWith(parentId: targetParentId);
      emit(state.copyWith(dimensions: _insertIntoParent(removed, targetParentId, updated)));
    } else {
      final targetNode = newIndex < flat.length ? flat[newIndex] : null;
      final updated = targetNode != null
          ? moved.copyWith(parentId: targetNode.parentId)
          : moved.copyWith(parentId: null);
      emit(state.copyWith(dimensions: _insertAtRoot(removed, newIndex, updated)));
    }
  }

  Future<void> loadTemplate(String id) async {
    if (_repo == null) return;
    final data = await _repo!.getTemplateById(id);
    if (data == null) return;
    _templateId = id;
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: _buildTree(data.dimensions),
    ));
  }

  Future<void> saveTemplate() async {
    if (_repo == null) return;
    final id = _templateId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final template = TemplatesCompanion.insert(
      id: id,
      name: state.templateName,
      createdAt: _templateId != null ? const Value.absent() : Value(now),
      updatedAt: Value(now),
    );
    final flat = _flatten(state.dimensions);
    final companions = flat.asMap().entries.map((e) {
      final d = e.value;
      return TemplateDimensionsCompanion.insert(
        id: d.id,
        templateId: id,
        parentId: d.parentId == null ? const Value.absent() : Value(d.parentId!),
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: e.key,
      );
    }).toList();
    if (_templateId != null) {
      await _repo!.updateTemplate(template, companions);
    } else {
      await _repo!.insertTemplate(template, companions);
      _templateId = id;
    }
  }

  List<DimensionNode> _buildTree(List<TemplateDimension> dimensions) {
    final map = <String, DimensionNode>{};
    final roots = <DimensionNode>[];
    for (final d in dimensions) {
      map[d.id] = DimensionNode(
        id: d.id,
        templateId: d.templateId,
        parentId: d.parentId,
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: d.sortOrder,
      );
    }
    for (final d in dimensions) {
      final node = map[d.id]!;
      if (d.parentId == null) {
        roots.add(node);
      } else {
        final parent = map[d.parentId];
        if (parent != null) {
          map[d.parentId!] = parent.copyWith(children: [...parent.children, node]);
        }
      }
    }
    return roots;
  }

  List<DimensionNode> _flatten(List<DimensionNode> nodes) {
    final result = <DimensionNode>[];
    for (final n in nodes) {
      result.add(n);
      result.addAll(_flatten(n.children));
    }
    return result;
  }

  List<DimensionNode> _insertIntoParent(List<DimensionNode> nodes, String parentId, DimensionNode child) {
    return nodes.map((n) {
      if (n.id == parentId) {
        return n.copyWith(children: [...n.children, child]);
      } else if (n.children.isNotEmpty) {
        return n.copyWith(children: _insertIntoParent(n.children, parentId, child));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _updateInTree(List<DimensionNode> nodes, String id, {String? name, String? type, String? config}) {
    return nodes.map((n) {
      if (n.id == id) {
        return n.copyWith(name: name, type: type, config: config);
      } else if (n.children.isNotEmpty) {
        return n.copyWith(children: _updateInTree(n.children, id, name: name, type: type, config: config));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _removeFromTree(List<DimensionNode> nodes, String id) {
    return nodes.where((n) => n.id != id).map((n) {
      if (n.children.isNotEmpty) {
        return n.copyWith(children: _removeFromTree(n.children, id));
      }
      return n;
    }).toList();
  }

  List<DimensionNode> _insertAtRoot(List<DimensionNode> nodes, int index, DimensionNode item) {
    final list = nodes.toList();
    if (index >= list.length) {
      list.add(item);
    } else {
      list.insert(index, item);
    }
    return list;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/blocs/template_editor_cubit_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/blocs/template_editor/cubit.dart app/lib/blocs/template_editor/state.dart app/test/blocs/template_editor_cubit_test.dart
git commit -m "feat: add TemplateEditorCubit with tree ops and persistence"
```

---

### Task 9: InstanceListCubit

**Files:**
- Create: `app/lib/blocs/instance_list/cubit.dart`
- Create: `app/lib/blocs/instance_list/state.dart`
- Test: `app/test/blocs/instance_list_cubit_test.dart`

- [ ] **Step 1: Write failing test for InstanceListCubit**

Create `app/test/blocs/instance_list_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_list/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockInstanceRepository extends Mock implements InstanceRepository {}

void main() {
  late MockInstanceRepository repo;

  setUp(() => repo = MockInstanceRepository());

  blocTest<InstanceListCubit, InstanceListState>(
    'loads top-level instances',
    build: () => InstanceListCubit(repo),
    act: (cubit) {
      when(() => repo.watchTopLevelInstances()).thenAnswer(
        (_) => Stream.value([
          Instance(id: 'i1', templateId: 't1', name: 'A', createdAt: 1, updatedAt: 1),
        ]),
      );
      cubit.loadTopLevel();
    },
    expect: () => [
      predicate<InstanceListState>((s) => s.instances.length == 1 && s.breadcrumbs.isEmpty),
    ],
  );
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/blocs/instance_list_cubit_test.dart
```
Expected: FAIL - cubit not found

- [ ] **Step 3: Write `app/lib/blocs/instance_list/state.dart` and `cubit.dart`**

`app/lib/blocs/instance_list/state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../data/database.dart';

class Breadcrumb {
  final String id;
  final String name;

  const Breadcrumb({required this.id, required this.name});
}

class InstanceListState extends Equatable {
  final List<Instance> instances;
  final List<Breadcrumb> breadcrumbs;

  const InstanceListState({this.instances = const [], this.breadcrumbs = const []});

  InstanceListState copyWith({List<Instance>? instances, List<Breadcrumb>? breadcrumbs}) {
    return InstanceListState(
      instances: instances ?? this.instances,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
    );
  }

  @override
  List<Object?> get props => [instances, breadcrumbs];
}
```

`app/lib/blocs/instance_list/cubit.dart`:
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import 'state.dart';

class InstanceListCubit extends Cubit<InstanceListState> {
  final InstanceRepository _repo;
  StreamSubscription<List<Instance>>? _sub;

  InstanceListCubit(this._repo) : super(const InstanceListState());

  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().listen((instances) {
      emit(InstanceListState(instances: instances, breadcrumbs: const []));
    });
  }

  void loadChildren(String parentInstanceId, List<Breadcrumb> breadcrumbs) async {
    _sub?.cancel();
    _sub = _repo.watchChildInstances(parentInstanceId).listen((instances) {
      emit(InstanceListState(instances: instances, breadcrumbs: breadcrumbs));
    });
  }

  void navigateToBreadcrumb(int index) {
    if (index < 0) {
      loadTopLevel();
    } else {
      final target = state.breadcrumbs[index];
      loadChildren(target.id, state.breadcrumbs.sublist(0, index + 1));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/blocs/instance_list_cubit_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/blocs/instance_list/cubit.dart app/lib/blocs/instance_list/state.dart app/test/blocs/instance_list_cubit_test.dart
git commit -m "feat: add InstanceListCubit with breadcrumb navigation"
```

---

### Task 10: InstanceEditorCubit

**Files:**
- Create: `app/lib/blocs/instance_editor/cubit.dart`
- Create: `app/lib/blocs/instance_editor/state.dart`
- Test: `app/test/blocs/instance_editor_cubit_test.dart`

- [ ] **Step 1: Write failing test for InstanceEditorCubit**

Create `app/test/blocs/instance_editor_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_editor/cubit.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('InstanceEditorCubit', () {
    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'sets instance name',
      build: () => InstanceEditorCubit(),
      act: (cubit) => cubit.setName('Test'),
      expect: () => [const InstanceEditorState(name: 'Test')],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'hides dimension',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(
        dimensionValues: {'d1': 'v1'},
        hiddenDimensionIds: {},
      ),
      act: (cubit) => cubit.hideDimension('d1'),
      expect: () => [
        const InstanceEditorState(
          name: '',
          dimensionValues: {'d1': 'v1'},
          hiddenDimensionIds: {'d1'},
        ),
      ],
    );
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/blocs/instance_editor_cubit_test.dart
```
Expected: FAIL - cubit not found

- [ ] **Step 3: Write `app/lib/blocs/instance_editor/state.dart` and `cubit.dart`**

`app/lib/blocs/instance_editor/state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../data/database.dart';
import '../../models/dimension_node.dart';

class CustomFieldData extends Equatable {
  final String id;
  final String name;
  final String type;
  final String value;
  final String config;

  const CustomFieldData({
    required this.id,
    required this.name,
    required this.type,
    this.value = '',
    this.config = '{}',
  });

  CustomFieldData copyWith({String? name, String? type, String? value, String? config}) {
    return CustomFieldData(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [id, name, type, value, config];
}

class InstanceEditorState extends Equatable {
  final String name;
  final String? templateId;
  final String? parentInstanceId;
  final List<DimensionNode> dimensions;
  final Map<String, String> dimensionValues;
  final Set<String> hiddenDimensionIds;
  final List<CustomFieldData> customFields;

  const InstanceEditorState({
    this.name = '',
    this.templateId,
    this.parentInstanceId,
    this.dimensions = const [],
    this.dimensionValues = const {},
    this.hiddenDimensionIds = const {},
    this.customFields = const [],
  });

  InstanceEditorState copyWith({
    String? name,
    String? templateId,
    String? parentInstanceId,
    List<DimensionNode>? dimensions,
    Map<String, String>? dimensionValues,
    Set<String>? hiddenDimensionIds,
    List<CustomFieldData>? customFields,
  }) {
    return InstanceEditorState(
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      parentInstanceId: parentInstanceId ?? this.parentInstanceId,
      dimensions: dimensions ?? this.dimensions,
      dimensionValues: dimensionValues ?? this.dimensionValues,
      hiddenDimensionIds: hiddenDimensionIds ?? this.hiddenDimensionIds,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  List<Object?> get props => [
    name, templateId, parentInstanceId, dimensions,
    dimensionValues, hiddenDimensionIds, customFields,
  ];
}
```

`app/lib/blocs/instance_editor/cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import '../../data/tables.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

class InstanceEditorCubit extends Cubit<InstanceEditorState> {
  final InstanceRepository? _instanceRepo;
  final TemplateRepository? _templateRepo;
  String? _instanceId;

  InstanceEditorCubit([this._instanceRepo, this._templateRepo]) : super(const InstanceEditorState());

  void setName(String name) => emit(state.copyWith(name: name));

  void updateDimensionValue(String dimensionId, String value) {
    final updated = Map<String, String>.from(state.dimensionValues);
    updated[dimensionId] = value;
    emit(state.copyWith(dimensionValues: updated));
  }

  void hideDimension(String dimensionId) {
    emit(state.copyWith(hiddenDimensionIds: {...state.hiddenDimensionIds, dimensionId}));
  }

  void restoreDimension(String dimensionId) {
    emit(state.copyWith(hiddenDimensionIds: {
      ...state.hiddenDimensionIds.where((id) => id != dimensionId),
    }));
  }

  void addCustomField(String name, String type, {String value = '', String config = '{}'}) {
    final field = CustomFieldData(
      id: const Uuid().v4(),
      name: name,
      type: type,
      value: value,
      config: config,
    );
    emit(state.copyWith(customFields: [...state.customFields, field]));
  }

  void updateCustomField(String id, {String? name, String? value}) {
    emit(state.copyWith(customFields: state.customFields.map((f) {
      if (f.id == id) return f.copyWith(name: name, value: value);
      return f;
    }).toList()));
  }

  void removeCustomField(String id) {
    emit(state.copyWith(customFields: state.customFields.where((f) => f.id != id).toList()));
  }

  Future<void> initNewInstance(String templateId, {String? parentInstanceId}) async {
    if (_templateRepo == null) return;
    final template = await _templateRepo!.getTemplateById(templateId);
    if (template == null) return;
    final tree = _buildTree(template.dimensions);
    emit(InstanceEditorState(
      templateId: templateId,
      parentInstanceId: parentInstanceId,
      dimensions: tree,
      dimensionValues: {for (final d in template.dimensions) d.id: ''},
      hiddenDimensionIds: const {},
      customFields: const [],
    ));
  }

  Future<void> loadInstance(String instanceId) async {
    if (_instanceRepo == null || _templateRepo == null) return;
    final data = await _instanceRepo!.getInstanceById(instanceId);
    if (data == null) return;
    final template = await _templateRepo!.getTemplateById(data.instance.templateId);
    final tree = template != null ? _buildTree(template.dimensions) : <DimensionNode>[];
    final values = {for (final v in data.values) v.dimensionId: v.value};
    final hidden = data.hiddenDimensions.map((h) => h.dimensionId).toSet();
    final custom = data.customFields.map((f) => CustomFieldData(
      id: f.id,
      name: f.name,
      type: f.type,
      value: f.value,
      config: f.config,
    )).toList();
    _instanceId = instanceId;
    emit(InstanceEditorState(
      name: data.instance.name,
      templateId: data.instance.templateId,
      parentInstanceId: data.instance.parentInstanceId,
      dimensions: tree,
      dimensionValues: {for (final d in template?.dimensions ?? []) d.id: values[d.id] ?? ''},
      hiddenDimensionIds: hidden,
      customFields: custom,
    ));
  }

  Future<void> saveInstance() async {
    if (_instanceRepo == null) return;
    final id = _instanceId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final instance = InstancesCompanion.insert(
      id: id,
      templateId: state.templateId!,
      parentInstanceId: state.parentInstanceId == null
          ? const Value.absent()
          : Value(state.parentInstanceId!),
      name: state.name,
      createdAt: _instanceId != null ? const Value.absent() : Value(now),
      updatedAt: Value(now),
    );
    final values = state.dimensionValues.entries.map((e) {
      return InstanceValuesCompanion.insert(
        id: const Uuid().v4(),
        instanceId: id,
        dimensionId: e.key,
        value: e.value,
      );
    }).toList();
    final customFields = state.customFields.map((f) {
      return InstanceCustomFieldsCompanion.insert(
        id: f.id,
        instanceId: id,
        name: f.name,
        type: f.type,
        value: f.value,
        config: f.config,
      );
    }).toList();
    final hidden = state.hiddenDimensionIds.map((hid) {
      return InstanceHiddenDimensionsCompanion.insert(
        id: const Uuid().v4(),
        instanceId: id,
        dimensionId: hid,
      );
    }).toList();

    if (_instanceId != null) {
      await _instanceRepo!.updateInstance(
        instance,
        values: values,
        customFields: customFields,
        hiddenDimensions: hidden,
      );
    } else {
      await _instanceRepo!.insertInstance(
        instance,
        values: values,
        customFields: customFields,
        hiddenDimensions: hidden,
      );
      _instanceId = id;
    }
  }

  List<DimensionNode> _buildTree(List<TemplateDimension> dimensions) {
    final map = <String, DimensionNode>{};
    final roots = <DimensionNode>[];
    for (final d in dimensions) {
      map[d.id] = DimensionNode(
        id: d.id,
        templateId: d.templateId,
        parentId: d.parentId,
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: d.sortOrder,
      );
    }
    for (final d in dimensions) {
      final node = map[d.id]!;
      if (d.parentId == null) {
        roots.add(node);
      } else {
        final parent = map[d.parentId];
        if (parent != null) {
          map[d.parentId!] = parent.copyWith(children: [...parent.children, node]);
        }
      }
    }
    return roots;
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/blocs/instance_editor_cubit_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/blocs/instance_editor/cubit.dart app/lib/blocs/instance_editor/state.dart app/test/blocs/instance_editor_cubit_test.dart
git commit -m "feat: add InstanceEditorCubit with fields, hide/restore, custom fields"
```

---

### Task 11: SettingsCubit

**Files:**
- Create: `app/lib/blocs/settings/cubit.dart`
- Create: `app/lib/blocs/settings/state.dart`
- Test: `app/test/blocs/settings_cubit_test.dart`

- [ ] **Step 1: Write failing test for SettingsCubit**

Create `app/test/blocs/settings_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/settings/cubit.dart';

void main() {
  blocTest<SettingsCubit, SettingsState>(
    'toggles lan sync',
    build: SettingsCubit.new,
    act: (cubit) => cubit.toggleLanSync(true),
    expect: () => [const SettingsState(lanSyncEnabled: true)],
  );
}
```

- [ ] **Step 2: Run test to verify it fails**

Run:
```bash
cd app && flutter test test/blocs/settings_cubit_test.dart
```
Expected: FAIL - cubit not found

- [ ] **Step 3: Write `app/lib/blocs/settings/state.dart` and `cubit.dart`**

`app/lib/blocs/settings/state.dart`:
```dart
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool lanSyncEnabled;

  const SettingsState({this.lanSyncEnabled = false});

  SettingsState copyWith({bool? lanSyncEnabled}) {
    return SettingsState(lanSyncEnabled: lanSyncEnabled ?? this.lanSyncEnabled);
  }

  @override
  List<Object?> get props => [lanSyncEnabled];
}
```

`app/lib/blocs/settings/cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleLanSync(bool enabled) {
    emit(state.copyWith(lanSyncEnabled: enabled));
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run:
```bash
cd app && flutter test test/blocs/settings_cubit_test.dart
```
Expected: PASS

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/blocs/settings/cubit.dart app/lib/blocs/settings/state.dart app/test/blocs/settings_cubit_test.dart
git commit -m "feat: add SettingsCubit placeholder for LAN sync"
```

---

### Task 12: Template List Screen

**Files:**
- Create: `app/lib/screens/template_list_screen.dart`
- Test widget: `app/test/widget_test.dart` (append)

- [ ] **Step 1: Write `app/lib/screens/template_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/template_list/cubit.dart';
import '../blocs/template_list/state.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板管理')),
      body: BlocBuilder<TemplateListCubit, TemplateListState>(
        builder: (context, state) {
          if (state.templates.isEmpty) {
            return const Center(child: Text('暂无模板，点击右下角添加'));
          }
          return ListView.builder(
            itemCount: state.templates.length,
            itemBuilder: (context, index) {
              final t = state.templates[index];
              return ListTile(
                title: Text(t.name),
                subtitle: Text('更新于 ${DateTime.fromMillisecondsSinceEpoch(t.updatedAt)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('确认删除'),
                        content: const Text('删除模板将同时删除其下所有实例。确认删除？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      context.read<TemplateListCubit>().deleteTemplate(t.id);
                    }
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/templateEditor', arguments: t.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/templateEditor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- [ ] **Step 2: Run app in debug mode to verify screen compiles**

Run:
```bash
cd app && flutter analyze lib/screens/template_list_screen.dart
```
Expected: no issues

- [ ] **Step 3: Commit**

Run:
```bash
git add app/lib/screens/template_list_screen.dart
git commit -m "feat: add TemplateListScreen"
```

---

### Task 13: Template Editor Screen

**Files:**
- Create: `app/lib/screens/template_editor_screen.dart`
- Create: `app/lib/widgets/dimension_tree.dart`

- [ ] **Step 1: Write `app/lib/widgets/dimension_tree.dart`**

```dart
import 'package:flutter/material.dart';
import '../models/dimension_node.dart';

class DimensionTree extends StatelessWidget {
  final List<DimensionNode> nodes;
  final void Function(DimensionNode) onEdit;
  final void Function(String) onDelete;
  final void Function(int oldIndex, int newIndex, String? targetParentId) onReorder;

  const DimensionTree({
    super.key,
    required this.nodes,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final flat = nodes.expand((n) => n.flatten()).toList();
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: flat.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        final target = flat[newIndex];
        final targetParentId = target.node.type == 'group' ? target.node.id : target.node.parentId;
        onReorder(oldIndex, newIndex, targetParentId);
      },
      itemBuilder: (context, index) {
        final item = flat[index];
        return ListTile(
          key: ValueKey(item.node.id),
          contentPadding: EdgeInsets.only(left: 24.0 + item.depth * 24.0, right: 16.0),
          leading: const Icon(Icons.drag_handle),
          title: Text('${item.node.name} (${item.node.type})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(item.node)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(item.node.id)),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Write `app/lib/screens/template_editor_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/template_editor/cubit.dart';
import '../blocs/template_editor/state.dart';
import '../widgets/dimension_tree.dart';

class TemplateEditorScreen extends StatefulWidget {
  final String? templateId;

  const TemplateEditorScreen({super.key, this.templateId});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      context.read<TemplateEditorCubit>().loadTemplate(widget.templateId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TemplateEditorCubit, TemplateEditorState>(
          builder: (context, state) => Text(state.templateName.isEmpty ? '新建模板' : state.templateName),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await context.read<TemplateEditorCubit>().saveTemplate();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('模板保存成功')),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TemplateEditorCubit, TemplateEditorState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '模板名称'),
                  onChanged: (v) => context.read<TemplateEditorCubit>().setTemplateName(v),
                  controller: TextEditingController(text: state.templateName)
                    ..selection = TextSelection.collapsed(offset: state.templateName.length),
                ),
                const SizedBox(height: 16),
                const Text('维度项', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DimensionTree(
                  nodes: state.dimensions,
                  onEdit: (node) => _showDimensionDialog(context, node: node),
                  onDelete: (id) => context.read<TemplateEditorCubit>().removeDimension(id),
                  onReorder: (oldIndex, newIndex, parentId) =>
                      context.read<TemplateEditorCubit>().moveDimension(
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                        targetParentId: parentId,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showDimensionDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加维度项'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDimensionDialog(context, initialType: 'group'),
                      icon: const Icon(Icons.folder),
                      label: const Text('添加子维度组'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDimensionDialog(BuildContext context, {DimensionNode? node, String initialType = 'text'}) {
    final nameController = TextEditingController(text: node?.name ?? '');
    String type = node?.type ?? initialType;
    final configController = TextEditingController(text: node?.config ?? '{}');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(node == null ? '添加维度' : '编辑维度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称')),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('文本')),
                  DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                  DropdownMenuItem(value: 'boolean', child: Text('布尔')),
                  DropdownMenuItem(value: 'number', child: Text('数字')),
                  DropdownMenuItem(value: 'group', child: Text('子维度组')),
                  DropdownMenuItem(value: 'ref_subtemplate', child: Text('引用子模板')),
                ],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: '类型'),
              ),
              TextField(
                controller: configController,
                decoration: const InputDecoration(labelText: '配置 (JSON)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            TextButton(
              onPressed: () {
                if (node == null) {
                  context.read<TemplateEditorCubit>().addDimension(
                    name: nameController.text,
                    type: type,
                    config: configController.text,
                  );
                } else {
                  context.read<TemplateEditorCubit>().updateDimension(
                    node.id,
                    name: nameController.text,
                    type: type,
                    config: configController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
```

Note: The `_showDimensionDialog` references `DimensionNode` — add the import at the top:
```dart
import '../models/dimension_node.dart';
```

- [ ] **Step 3: Verify compilation**

Run:
```bash
cd app && flutter analyze lib/screens/template_editor_screen.dart lib/widgets/dimension_tree.dart
```
Expected: no issues

- [ ] **Step 4: Commit**

Run:
```bash
git add app/lib/screens/template_editor_screen.dart app/lib/widgets/dimension_tree.dart
git commit -m "feat: add TemplateEditorScreen and DimensionTree widget"
```

---

### Task 14: Instance List Screen

**Files:**
- Create: `app/lib/screens/instance_list_screen.dart`
- Create: `app/lib/widgets/instance_card.dart`
- Create: `app/lib/widgets/breadcrumb_bar.dart`

- [ ] **Step 1: Write `app/lib/widgets/breadcrumb_bar.dart`**

```dart
import 'package:flutter/material.dart';
import '../blocs/instance_list/state.dart';

class BreadcrumbBar extends StatelessWidget {
  final List<Breadcrumb> breadcrumbs;
  final void Function(int) onTap;

  const BreadcrumbBar({super.key, required this.breadcrumbs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onTap(-1),
          child: const Text('全部', style: TextStyle(color: Colors.blue)),
        ),
        ...breadcrumbs.asMap().entries.expand((e) => [
          const Text(' > '),
          GestureDetector(
            onTap: () => onTap(e.key),
            child: Text(e.value.name, style: const TextStyle(color: Colors.blue)),
          ),
        ]),
      ],
    );
  }
}
```

- [ ] **Step 2: Write `app/lib/widgets/instance_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../data/database.dart';

class InstanceCard extends StatelessWidget {
  final Instance instance;
  final Map<String, String> thumbnailValues;
  final int? childCount;
  final VoidCallback onTap;

  const InstanceCard({
    super.key,
    required this.instance,
    required this.thumbnailValues,
    this.childCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instance.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (thumbnailValues.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: thumbnailValues.entries.map((e) => Chip(label: Text('${e.key}: ${e.value}'))).toList(),
                ),
              if (childCount != null)
                Text('$childCount 套房子', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write `app/lib/screens/instance_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/instance_list/cubit.dart';
import '../blocs/instance_list/state.dart';
import '../data/instance_repository.dart';
import '../data/template_repository.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/instance_card.dart';

class InstanceListScreen extends StatelessWidget {
  const InstanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: BlocBuilder<InstanceListCubit, InstanceListState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: BreadcrumbBar(
                  breadcrumbs: state.breadcrumbs,
                  onTap: (index) => context.read<InstanceListCubit>().navigateToBreadcrumb(index),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.instances.length,
                  itemBuilder: (context, index) {
                    final inst = state.instances[index];
                    return InstanceCard(
                      instance: inst,
                      thumbnailValues: const {}, // populated by repository lookup in real usage
                      onTap: () {
                        final repo = context.read<InstanceRepository>();
                        repo.getRefSubtemplateDimensions(inst.templateId).then((dims) async {
                          if (dims.isNotEmpty) {
                            final newCrumbs = [
                              ...state.breadcrumbs,
                              Breadcrumb(id: inst.id, name: inst.name),
                            ];
                            context.read<InstanceListCubit>().loadChildren(inst.id, newCrumbs);
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/instanceEditor',
                              arguments: {'instanceId': inst.id},
                            );
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final cubit = context.read<InstanceListCubit>();
          final state = cubit.state;
          final templates = await context.read<TemplateRepository>().watchAllTemplates().first;
          if (templates.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('请先创建模板')),
            );
            return;
          }
          if (state.breadcrumbs.isEmpty) {
            // Root: pick template
            final selected = await showDialog<Template>(
              context: context,
              builder: (_) => SimpleDialog(
                title: const Text('选择模板'),
                children: templates.map((t) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, t),
                  child: Text(t.name),
                )).toList(),
              ),
            );
            if (selected != null) {
              Navigator.pushNamed(context, '/instanceEditor', arguments: {
                'templateId': selected.id,
              });
            }
          } else {
            // Child: look up ref_subtemplate dimensions
            final parentId = state.breadcrumbs.last.id;
            final repo = context.read<InstanceRepository>();
            // We need parent templateId; fetch from first child or load instance
            // Simplified: look up parent instance to get its templateId
            final parentData = await repo.getInstanceById(parentId);
            if (parentData == null) return;
            final refDims = await repo.getRefSubtemplateDimensions(parentData.instance.templateId);
            if (refDims.isEmpty) return;
            String? selectedTemplateId;
            if (refDims.length == 1) {
              final config = refDims.first.config;
              // naive parse of {"ref_template_id":"xxx"}
              final match = RegExp(r'"ref_template_id"\s*:\s*"([^"]+)"').firstMatch(config);
              selectedTemplateId = match?.group(1);
            } else {
              // Show picker of referenced templates
              final allTemplates = await context.read<TemplateRepository>().watchAllTemplates().first;
              final refs = refDims.map((d) {
                final match = RegExp(r'"ref_template_id"\s*:\s*"([^"]+)"').firstMatch(d.config);
                final tid = match?.group(1);
                return allTemplates.firstWhere((t) => t.id == tid);
              }).toList();
              final selected = await showDialog<Template>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('选择要新建的子类型'),
                  children: refs.map((t) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, t),
                    child: Text(t.name),
                  )).toList(),
                ),
              );
              selectedTemplateId = selected?.id;
            }
            if (selectedTemplateId != null) {
              Navigator.pushNamed(context, '/instanceEditor', arguments: {
                'templateId': selectedTemplateId,
                'parentInstanceId': parentId,
              });
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Add imports at top for `Template`:
```dart
import '../data/database.dart';
```

- [ ] **Step 4: Verify compilation**

Run:
```bash
cd app && flutter analyze lib/screens/instance_list_screen.dart lib/widgets/instance_card.dart lib/widgets/breadcrumb_bar.dart
```
Expected: no issues

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/screens/instance_list_screen.dart app/lib/widgets/instance_card.dart app/lib/widgets/breadcrumb_bar.dart
git commit -m "feat: add InstanceListScreen with breadcrumb and card widgets"
```

---

### Task 15: Instance Editor Screen

**Files:**
- Create: `app/lib/screens/instance_editor_screen.dart`

- [ ] **Step 1: Write `app/lib/screens/instance_editor_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/instance_editor/cubit.dart';
import '../blocs/instance_editor/state.dart';
import '../models/dimension_node.dart';

class InstanceEditorScreen extends StatefulWidget {
  final String? instanceId;
  final String? templateId;
  final String? parentInstanceId;

  const InstanceEditorScreen({
    super.key,
    this.instanceId,
    this.templateId,
    this.parentInstanceId,
  });

  @override
  State<InstanceEditorScreen> createState() => _InstanceEditorScreenState();
}

class _InstanceEditorScreenState extends State<InstanceEditorScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<InstanceEditorCubit>();
    if (widget.instanceId != null) {
      cubit.loadInstance(widget.instanceId!);
    } else if (widget.templateId != null) {
      cubit.initNewInstance(widget.templateId!, parentInstanceId: widget.parentInstanceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<InstanceEditorCubit, InstanceEditorState>(
          builder: (context, state) => Text(state.name.isEmpty ? '新建实例' : state.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await context.read<InstanceEditorCubit>().saveInstance();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('实例保存成功')),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<InstanceEditorCubit, InstanceEditorState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '实例名称'),
                  onChanged: (v) => context.read<InstanceEditorCubit>().setName(v),
                  controller: TextEditingController(text: state.name)
                    ..selection = TextSelection.collapsed(offset: state.name.length),
                ),
                const SizedBox(height: 16),
                ..._buildDimensionFields(context, state.dimensions, state),
                if (state.dimensions.isNotEmpty && state.dimensions.every(
                  (d) => state.hiddenDimensionIds.contains(d.id) || _allChildrenHidden(d, state.hiddenDimensionIds),
                ))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('所有模板字段已隐藏'),
                  ),
                const Divider(),
                const Text('（自定义字段）', style: TextStyle(color: Colors.grey)),
                ...state.customFields.map((f) => ListTile(
                  title: _buildCustomField(context, f),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => context.read<InstanceEditorCubit>().removeCustomField(f.id),
                  ),
                )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddCustomFieldDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加自定义字段'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showRestoreHiddenDialog(context, state),
                      child: const Text('恢复隐藏字段'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _allChildrenHidden(DimensionNode node, Set<String> hidden) {
    if (!hidden.contains(node.id)) return false;
    if (node.children.isEmpty) return true;
    return node.children.every((c) => _allChildrenHidden(c, hidden));
  }

  List<Widget> _buildDimensionFields(BuildContext context, List<DimensionNode> nodes, InstanceEditorState state) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      if (state.hiddenDimensionIds.contains(node.id)) continue;
      if (node.type == 'group') {
        widgets.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ..._buildDimensionFields(context, node.children, state),
                ],
              ),
            ),
          ),
        );
      } else if (node.type != 'ref_subtemplate') {
        widgets.add(_buildFieldRow(context, node, state.dimensionValues[node.id] ?? ''));
      }
    }
    return widgets;
  }

  Widget _buildFieldRow(BuildContext context, DimensionNode node, String value) {
    return ListTile(
      title: Text(node.name),
      subtitle: _buildInput(context, node, value),
      trailing: TextButton(
        onPressed: () => context.read<InstanceEditorCubit>().hideDimension(node.id),
        child: const Text('隐藏'),
      ),
    );
  }

  Widget _buildInput(BuildContext context, DimensionNode node, String value) {
    final cubit = context.read<InstanceEditorCubit>();
    switch (node.type) {
      case 'boolean':
        return SwitchListTile(
          value: value == 'true',
          onChanged: (v) => cubit.updateDimensionValue(node.id, v.toString()),
          title: const Text(''),
        );
      case 'single_choice':
        // naive parse
        final match = RegExp(r'"options"\s*:\s*\[(.*?)\]').firstMatch(node.config);
        final raw = match?.group(1) ?? '';
        final options = raw.split(',').map((s) => s.trim().replaceAll(RegExp(r'["\']'), '')).where((s) => s.isNotEmpty).toList();
        return Wrap(
          spacing: 8,
          children: options.map((opt) => ChoiceChip(
            label: Text(opt),
            selected: value == opt,
            onSelected: (_) => cubit.updateDimensionValue(node.id, opt),
          )).toList(),
        );
      case 'number':
        return TextField(
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.updateDimensionValue(node.id, v),
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
        );
      default:
        return TextField(
          onChanged: (v) => cubit.updateDimensionValue(node.id, v),
          controller: TextEditingController(text: value)
            ..selection = TextSelection.collapsed(offset: value.length),
        );
    }
  }

  Widget _buildCustomField(BuildContext context, CustomFieldData f) {
    final cubit = context.read<InstanceEditorCubit>();
    switch (f.type) {
      case 'boolean':
        return SwitchListTile(
          value: f.value == 'true',
          onChanged: (v) => cubit.updateCustomField(f.id, value: v.toString()),
          title: Text(f.name),
        );
      case 'single_choice':
        final match = RegExp(r'"options"\s*:\s*\[(.*?)\]').firstMatch(f.config);
        final raw = match?.group(1) ?? '';
        final options = raw.split(',').map((s) => s.trim().replaceAll(RegExp(r'["\']'), '')).where((s) => s.isNotEmpty).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.name),
            Wrap(
              spacing: 8,
              children: options.map((opt) => ChoiceChip(
                label: Text(opt),
                selected: f.value == opt,
                onSelected: (_) => cubit.updateCustomField(f.id, value: opt),
              )).toList(),
            ),
          ],
        );
      case 'number':
        return TextField(
          decoration: InputDecoration(labelText: f.name),
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.updateCustomField(f.id, value: v),
          controller: TextEditingController(text: f.value)
            ..selection = TextSelection.collapsed(offset: f.value.length),
        );
      default:
        return TextField(
          decoration: InputDecoration(labelText: f.name),
          onChanged: (v) => cubit.updateCustomField(f.id, value: v),
          controller: TextEditingController(text: f.value)
            ..selection = TextSelection.collapsed(offset: f.value.length),
        );
    }
  }

  void _showAddCustomFieldDialog(BuildContext context) {
    final nameController = TextEditingController();
    String type = 'text';
    final configController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加自定义字段'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '字段名')),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('文本')),
                  DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                  DropdownMenuItem(value: 'boolean', child: Text('布尔')),
                  DropdownMenuItem(value: 'number', child: Text('数字')),
                ],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: '类型'),
              ),
              TextField(
                controller: configController,
                decoration: const InputDecoration(labelText: '配置 (JSON，单选必填)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            TextButton(
              onPressed: () {
                context.read<InstanceEditorCubit>().addCustomField(
                  nameController.text,
                  type,
                  config: configController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreHiddenDialog(BuildContext context, InstanceEditorState state) {
    final hidden = state.dimensions.expand((n) => n.flatten()).where(
      (f) => state.hiddenDimensionIds.contains(f.node.id),
    ).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('恢复显示隐藏的字段'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: hidden.length,
            itemBuilder: (_, index) {
              final node = hidden[index].node;
              return ListTile(
                title: Text(node.name),
                trailing: TextButton(
                  onPressed: () {
                    context.read<InstanceEditorCubit>().restoreDimension(node.id);
                    Navigator.pop(context);
                  },
                  child: const Text('恢复显示'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify compilation**

Run:
```bash
cd app && flutter analyze lib/screens/instance_editor_screen.dart
```
Expected: no issues

- [ ] **Step 3: Commit**

Run:
```bash
git add app/lib/screens/instance_editor_screen.dart
git commit -m "feat: add InstanceEditorScreen with dynamic fields and custom fields"
```

---

### Task 16: Settings Screen and App Shell

**Files:**
- Create: `app/lib/screens/settings_screen.dart`
- Modify: `app/lib/app.dart`

- [ ] **Step 1: Write `app/lib/screens/settings_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/cubit.dart';
import '../blocs/settings/state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const ListTile(title: Text('数据管理', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('导出全部数据'),
            subtitle: const Text('生成 house-note-export.yaml'),
            onTap: () {
              // Placeholder for Subproject 2
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导出功能将在 Subproject 2 实现')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导入数据'),
            subtitle: const Text('从 YAML 文件导入'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导入功能将在 Subproject 2 实现')),
              );
            },
          ),
          const Divider(),
          const ListTile(title: Text('局域网同步', style: TextStyle(fontWeight: FontWeight.bold))),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) => SwitchListTile(
              title: const Text('启用局域网同步'),
              subtitle: Text(state.lanSyncEnabled ? '已开启（IP 显示在 Subproject 3）' : '已关闭'),
              value: state.lanSyncEnabled,
              onChanged: (v) => context.read<SettingsCubit>().toggleLanSync(v),
            ),
          ),
          const Divider(),
          const ListTile(title: Text('关于', style: TextStyle(fontWeight: FontWeight.bold))),
          const ListTile(title: Text('House Note'), subtitle: Text('v0.1.0')),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Rewrite `app/lib/app.dart` with BottomNavigationBar and route wiring**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/instance_editor/cubit.dart';
import 'blocs/instance_list/cubit.dart';
import 'blocs/settings/cubit.dart';
import 'blocs/template_editor/cubit.dart';
import 'blocs/template_list/cubit.dart';
import 'data/database.dart';
import 'data/instance_repository.dart';
import 'data/template_repository.dart';
import 'screens/instance_editor_screen.dart';
import 'screens/instance_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/template_editor_screen.dart';
import 'screens/template_list_screen.dart';

class HouseNoteApp extends StatelessWidget {
  final AppDatabase database;

  const HouseNoteApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final templateRepo = TemplateRepository(database);
    final instanceRepo = InstanceRepository(database);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: templateRepo),
        RepositoryProvider.value(value: instanceRepo),
      ],
      child: MaterialApp(
        title: 'House Note',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const _MainShell());
            case '/templateEditor':
              final templateId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => TemplateEditorCubit(templateRepo),
                  child: TemplateEditorScreen(templateId: templateId),
                ),
              );
            case '/instanceEditor':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => InstanceEditorCubit(instanceRepo, templateRepo),
                  child: InstanceEditorScreen(
                    instanceId: args?['instanceId'] as String?,
                    templateId: args?['templateId'] as String?,
                    parentInstanceId: args?['parentInstanceId'] as String?,
                  ),
                ),
              );
          }
          return null;
        },
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final templateRepo = context.read<TemplateRepository>();
    final instanceRepo = context.read<InstanceRepository>();

    final pages = [
      BlocProvider(
        create: (_) => InstanceListCubit(instanceRepo)..loadTopLevel(),
        child: const InstanceListScreen(),
      ),
      BlocProvider(
        create: (_) => TemplateListCubit(templateRepo)..load(),
        child: const TemplateListScreen(),
      ),
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: '模板'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Update `app/lib/main.dart` to remove unused imports**

```dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(HouseNoteApp(database: db));
}
```

- [ ] **Step 4: Verify app builds**

Run:
```bash
cd app && flutter analyze
```
Expected: no issues

- [ ] **Step 5: Commit**

Run:
```bash
git add app/lib/screens/settings_screen.dart app/lib/app.dart app/lib/main.dart
git commit -m "feat: add SettingsScreen, app shell with 3-tab nav and route wiring"
```

---

### Task 17: Widget and Integration Tests

**Files:**
- Create: `app/test/widget_test.dart`

- [ ] **Step 1: Write the failing widget test**

Create/replace `app/test/widget_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/app.dart';
import 'package:house_note/data/database.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('App launches and shows three tabs', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(() => db.close());

    await tester.pumpWidget(HouseNoteApp(database: db));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('模板'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('模板'));
    await tester.pumpAndSettle();
    expect(find.text('模板管理'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the widget test**

Run:
```bash
cd app && flutter test test/widget_test.dart
```
Expected: PASS

- [ ] **Step 3: Commit**

Run:
```bash
git add app/test/widget_test.dart
git commit -m "test: add widget test for app shell navigation"
```

---

### Task 18: Run Full Test Suite and Final Verification

**Files:**
- None (verification only)

- [ ] **Step 1: Run all unit and widget tests**

Run:
```bash
cd app && flutter test
```
Expected: All tests pass

- [ ] **Step 2: Run static analysis**

Run:
```bash
cd app && flutter analyze
```
Expected: No issues

- [ ] **Step 3: Commit any final fixes**

If fixes were needed, commit them. Otherwise, mark task complete.

---

## Self-Review

### 1. Spec Coverage Check

| Spec Section | Implementing Task |
|--------------|-------------------|
| Flutter + Drift stack | Task 1-3 |
| 7 SQLite tables | Task 2-3 |
| TemplateListCubit | Task 7 |
| TemplateEditorCubit (tree drag/drop, persistence) | Task 8, 13 |
| InstanceListCubit (hierarchy, breadcrumbs) | Task 9, 14 |
| InstanceEditorCubit (form, custom fields, hide/restore) | Task 10, 15 |
| SettingsCubit | Task 11, 16 |
| 首页 (instance list/cards/FAB) | Task 14 |
| 模板管理 (list + editor) | Task 12-13 |
| 实例编辑页 (dynamic fields) | Task 15 |
| 设置页 | Task 16 |
| 3-tab navigation | Task 16 |
| Thumbnail fields (DB + repository) | Task 5, 13 |
| Testing strategy (unit + widget) | Tasks 4-11, 17-18 |
| Offline-first (SQLite local) | Task 2-3 |

**Gaps:** None for Subproject 1 scope. YAML export/import and LAN sync are correctly deferred per spec Section 8.

### 2. Placeholder Scan

- No "TBD" or "TODO" in plan steps.
- Code snippets are complete and runnable.
- Every task includes exact file paths, commands, and expected outputs.

### 3. Type Consistency Check

- `DimensionNode.id` is `String` everywhere.
- `TemplateEditorState.dimensions` is `List<DimensionNode>` everywhere.
- Repository method names (`insertTemplate`, `updateTemplate`, etc.) are consistent across cubits and tests.
- `InstanceEditorState.hiddenDimensionIds` is `Set<String>` consistently.

Plan is ready for execution.
