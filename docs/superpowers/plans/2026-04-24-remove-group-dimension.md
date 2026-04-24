# Remove Group Dimension Type Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Completely remove the `group` (子维度组) dimension type and all nested dimension tree support, flattening dimensions to a simple list.

**Architecture:** Delete `parentId`/`children` from `TemplateDimensions` table and `DimensionNode` model. Remove `buildDimensionTree` utility. Flatten all Bloc and UI logic that handled tree traversal, drag-and-drop nesting, and group rendering. Update tests to match.

**Tech Stack:** Flutter, Drift (SQLite), flutter_bloc, mocktail, bloc_test

---

## File Structure

| File | Action | Responsibility |
|------|--------|----------------|
| `lib/data/tables.dart` | Modify | Remove `parentId` from `TemplateDimensions` table |
| `lib/data/database.g.dart` | Regenerate | Drift-generated code after schema change |
| `lib/models/dimension_node.dart` | Modify | Remove `children`, `parentId`, `flatten()`, `FlattenedDimension` |
| `lib/utils/dimension_tree_builder.dart` | Delete | No longer needed; dimensions are flat |
| `lib/blocs/template_editor/cubit.dart` | Modify | Flatten dimension list operations, remove tree helpers |
| `lib/blocs/instance_editor/cubit.dart` | Modify | Remove `buildDimensionTree` usage |
| `lib/widgets/dimension_tree.dart` | Modify | Remove nesting logic, flatten drag-and-drop |
| `lib/screens/template_editor_screen.dart` | Modify | Remove "添加子维度组" button and `group` dropdown option |
| `lib/screens/instance_editor_screen.dart` | Modify | Remove `group` Card rendering and `_allChildrenHidden` |
| `test/models/dimension_node_test.dart` | Modify | Remove flatten/parentId/children tests |
| `test/blocs/template_editor_cubit_test.dart` | Modify | Remove group-related tests, simplify moveDimension tests |
| `integration_test/e2e_test.dart` | Modify | Update Story 1.1 to not create group dimensions |

---

### Task 1: Data Layer — Remove parentId from TemplateDimensions

**Files:**
- Modify: `app/lib/data/tables.dart`
- Regenerate: `app/lib/data/database.g.dart`

- [ ] **Step 1: Remove parentId column**

In `app/lib/data/tables.dart`, delete the `parentId` column from `TemplateDimensions`:

```dart
class TemplateDimensions extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(Templates, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get config => text()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 2: Regenerate Drift code**

```bash
cd app && dart run build_runner build --delete-conflicting-outputs
```

Expected: `database.g.dart` regenerates without `parentId`.

- [ ] **Step 3: Commit**

```bash
git add app/lib/data/tables.dart app/lib/data/database.g.dart
git commit -m "feat: remove parentId from TemplateDimensions table"
```

---

### Task 2: Model Layer — Simplify DimensionNode

**Files:**
- Modify: `app/lib/models/dimension_node.dart`
- Delete: `app/lib/utils/dimension_tree_builder.dart`

- [ ] **Step 1: Rewrite DimensionNode as flat data class**

Replace the entire contents of `app/lib/models/dimension_node.dart`:

```dart
import 'package:equatable/equatable.dart';

class DimensionNode extends Equatable {
  final String id;
  final String templateId;
  final String name;
  final String type;
  final String config;
  final int sortOrder;

  const DimensionNode({
    required this.id,
    required this.templateId,
    required this.name,
    required this.type,
    this.config = '{}',
    this.sortOrder = 0,
  });

  DimensionNode copyWith({
    String? id,
    String? templateId,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
  }) {
    return DimensionNode(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, templateId, name, type, config, sortOrder];
}
```

- [ ] **Step 2: Delete dimension_tree_builder.dart**

```bash
rm app/lib/utils/dimension_tree_builder.dart
```

- [ ] **Step 3: Verify no remaining imports**

Search for any remaining imports of `dimension_tree_builder.dart`:

```bash
cd app && grep -rn "dimension_tree_builder" lib/
```

Expected: Only imports in `template_editor/cubit.dart` and `instance_editor/cubit.dart` remain (will be fixed in later tasks).

- [ ] **Step 4: Commit**

```bash
git add app/lib/models/dimension_node.dart
git rm app/lib/utils/dimension_tree_builder.dart
git commit -m "feat: flatten DimensionNode and remove dimension_tree_builder"
```

---

### Task 3: Template Editor Cubit — Flatten Logic

**Files:**
- Modify: `app/lib/blocs/template_editor/cubit.dart`

- [ ] **Step 1: Replace entire cubit file**

Replace `app/lib/blocs/template_editor/cubit.dart` with:

```dart
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';
import '../../data/template_repository.dart';
import '../../models/dimension_node.dart';
import 'state.dart';

export 'state.dart';

class TemplateEditorCubit extends Cubit<TemplateEditorState> {
  final TemplateRepository _repo;
  String? _templateId;

  TemplateEditorCubit(this._repo) : super(const TemplateEditorState());

  Future<List<Template>> getAllTemplates() => _repo.watchAllTemplates().first;

  String? get currentTemplateId => _templateId;

  void setTemplateName(String name) {
    emit(state.copyWith(templateName: name));
  }

  void addDimension({required String name, required String type, String config = '{}'}) {
    final node = DimensionNode(
      id: const Uuid().v4(),
      templateId: _templateId ?? '',
      name: name,
      type: type,
      config: config,
      sortOrder: state.dimensions.length,
    );
    emit(state.copyWith(dimensions: [...state.dimensions, node]));
  }

  void updateDimension(String id, {String? name, String? type, String? config}) {
    emit(state.copyWith(
      dimensions: state.dimensions.map((n) {
        if (n.id == id) {
          return n.copyWith(name: name, type: type, config: config);
        }
        return n;
      }).toList(),
    ));
  }

  void removeDimension(String id) {
    emit(state.copyWith(
      dimensions: state.dimensions.where((n) => n.id != id).toList(),
    ));
  }

  void moveDimension({required int oldIndex, required int newIndex}) {
    final list = state.dimensions.toList();
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), item);
    emit(state.copyWith(dimensions: list));
  }

  Future<void> loadTemplate(String id) async {
    final data = await _repo.getTemplateById(id);
    if (data == null) return;
    _templateId = id;
    final thumbnailFields = await _repo.getThumbnailFields(id);
    final thumbnailIds = thumbnailFields.map((f) => f.dimensionId).toList();
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: data.dimensions.map((d) => DimensionNode(
        id: d.id,
        templateId: d.templateId,
        name: d.name,
        type: d.type,
        config: d.config,
        sortOrder: d.sortOrder,
      )).toList(),
      thumbnailDimensionIds: thumbnailIds,
    ));
  }

  Future<void> saveTemplate() async {
    final id = _templateId ?? const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final template = _templateId != null
        ? TemplatesCompanion(
            id: Value(id),
            name: Value(state.templateName),
            updatedAt: Value(now),
          )
        : TemplatesCompanion.insert(
            id: id,
            name: state.templateName,
            createdAt: now,
            updatedAt: now,
          );
    final companions = state.dimensions.asMap().entries.map((e) {
      return TemplateDimensionsCompanion.insert(
        id: e.value.id,
        templateId: id,
        name: e.value.name,
        type: e.value.type,
        config: e.value.config,
        sortOrder: e.key,
      );
    }).toList();
    final thumbnailCompanions = state.thumbnailDimensionIds.asMap().entries.map((e) {
      return TemplateThumbnailFieldsCompanion.insert(
        id: const Uuid().v4(),
        templateId: id,
        dimensionId: e.value,
        sortOrder: e.key,
      );
    }).toList();
    await _repo.setThumbnailFields(id, thumbnailCompanions);
    if (_templateId != null) {
      await _repo.updateTemplate(template, companions);
    } else {
      await _repo.insertTemplate(template, companions);
      _templateId = id;
    }
  }

  void toggleThumbnailDimension(String dimensionId) {
    final current = state.thumbnailDimensionIds;
    if (current.contains(dimensionId)) {
      emit(state.copyWith(
        thumbnailDimensionIds: current.where((id) => id != dimensionId).toList(),
      ));
    } else {
      emit(state.copyWith(
        thumbnailDimensionIds: [...current, dimensionId],
      ));
    }
  }

  void reorderThumbnailDimensions(int oldIndex, int newIndex) {
    final list = state.thumbnailDimensionIds.toList();
    if (oldIndex < 0 || oldIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex.clamp(0, list.length), item);
    emit(state.copyWith(thumbnailDimensionIds: list));
  }
}
```

- [ ] **Step 2: Run analyzer to check**

```bash
cd app && flutter analyze lib/blocs/template_editor/cubit.dart
```

Expected: No errors (ignoring other files that still reference removed APIs).

- [ ] **Step 3: Commit**

```bash
git add app/lib/blocs/template_editor/cubit.dart
git commit -m "feat: flatten TemplateEditorCubit dimension operations"
```

---

### Task 4: Instance Editor Cubit — Remove buildDimensionTree

**Files:**
- Modify: `app/lib/blocs/instance_editor/cubit.dart`

- [ ] **Step 1: Replace buildDimensionTree calls with direct mapping**

In `app/lib/blocs/instance_editor/cubit.dart`, make these two changes:

1. Remove the import:
```dart
// DELETE this line:
import '../../utils/dimension_tree_builder.dart';
```

2. In `initNewInstance`, replace:
```dart
    final tree = buildDimensionTree(template.dimensions);
```
with:
```dart
    final dims = template.dimensions.map((d) => DimensionNode(
      id: d.id,
      templateId: d.templateId,
      name: d.name,
      type: d.type,
      config: d.config,
      sortOrder: d.sortOrder,
    )).toList();
```

And update the emit to use `dims`:
```dart
    emit(InstanceEditorState(
      templateId: templateId,
      parentInstanceId: parentInstanceId,
      dimensions: dims,
      dimensionValues: {for (final d in template.dimensions) d.id: ''},
      hiddenDimensionIds: const {},
      customFields: const [],
    ));
```

3. In `loadInstance`, replace:
```dart
    final tree = template != null ? buildDimensionTree(template.dimensions) : <DimensionNode>[];
```
with:
```dart
    final dims = template != null
        ? template.dimensions.map((d) => DimensionNode(
            id: d.id,
            templateId: d.templateId,
            name: d.name,
            type: d.type,
            config: d.config,
            sortOrder: d.sortOrder,
          )).toList()
        : <DimensionNode>[];
```

And update the emit to use `dims`:
```dart
      dimensions: dims,
```

- [ ] **Step 2: Run analyzer**

```bash
cd app && flutter analyze lib/blocs/instance_editor/cubit.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add app/lib/blocs/instance_editor/cubit.dart
git commit -m "feat: remove buildDimensionTree from InstanceEditorCubit"
```

---

### Task 5: Template Editor UI — Remove Group Button and Dropdown

**Files:**
- Modify: `app/lib/screens/template_editor_screen.dart`

- [ ] **Step 1: Remove group button and simplify thumbnail lookup**

In `app/lib/screens/template_editor_screen.dart`, make these changes:

1. In the thumbnail chips Wrap (around line 85), replace the `.expand((n) => n.flatten())` with direct list:
```dart
                      final dim = state.dimensions
                          .firstWhereOrNull((n) => n.id == e.value);
```

2. In the Wrap buttons section (around line 117-130), delete the "添加子维度组" button:
```dart
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showDimensionDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加维度项'),
                    ),
                  ],
                ),
```

3. In the `_DimensionDialog` dropdown (around line 287-295), remove the `group` option:
```dart
              items: const [
                DropdownMenuItem(value: 'text', child: Text('文本')),
                DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                DropdownMenuItem(value: 'number', child: Text('数字')),
                DropdownMenuItem(value: 'ref_subtemplate', child: Text('引用子模板')),
              ],
```

4. In the `DimensionTree` widget usage (around line 107-112), remove `targetParentId`:
```dart
                  onReorder: (oldIndex, newIndex) =>
                      context.read<TemplateEditorCubit>().moveDimension(
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                      ),
```

- [ ] **Step 2: Run analyzer**

```bash
cd app && flutter analyze lib/screens/template_editor_screen.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add app/lib/screens/template_editor_screen.dart
git commit -m "feat: remove group UI from template editor"
```

---

### Task 6: Instance Editor UI — Remove Group Rendering

**Files:**
- Modify: `app/lib/screens/instance_editor_screen.dart`

- [ ] **Step 1: Remove _allChildrenHidden and group Card rendering**

In `app/lib/screens/instance_editor_screen.dart`, make these changes:

1. Remove `_allChildrenHidden` method entirely (lines 126-130).

2. Simplify the "all fields hidden" check (around line 82-86) to:
```dart
                if (state.dimensions.isNotEmpty &&
                    state.dimensions.every(
                      (d) => state.hiddenDimensionIds.contains(d.id),
                    ))
```

3. In `_buildDimensionFields` (around line 138-155), remove the `group` branch. The method becomes:
```dart
  List<Widget> _buildDimensionFields(
    BuildContext context,
    List<DimensionNode> nodes,
    InstanceEditorState state,
  ) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      if (state.hiddenDimensionIds.contains(node.id)) continue;
      if (node.type == 'ref_subtemplate') {
        final children = state.childInstances[node.id] ?? [];
        widgets.add(
          _buildRefSubtemplateCard(context, node, children),
        );
      } else {
        widgets.add(
          _buildFieldRow(
            context,
            node,
            state.dimensionValues[node.id] ?? '',
          ),
        );
      }
    }
    return widgets;
  }
```

4. In `_showRestoreHiddenDialog` (around line 468-472), simplify hidden dimension lookup:
```dart
    final hidden = state.dimensions
        .where((d) => state.hiddenDimensionIds.contains(d.id))
        .toList();
```

And update the ListView builder:
```dart
              itemBuilder: (_, index) {
                final node = hidden[index];
                return ListTile(
```

- [ ] **Step 2: Run analyzer**

```bash
cd app && flutter analyze lib/screens/instance_editor_screen.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add app/lib/screens/instance_editor_screen.dart
git commit -m "feat: remove group rendering from instance editor"
```

---

### Task 7: DimensionTree Widget — Remove Nesting Logic

**Files:**
- Modify: `app/lib/widgets/dimension_tree.dart`

- [ ] **Step 1: Rewrite as flat reorderable list**

Replace the entire contents of `app/lib/widgets/dimension_tree.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/dimension_node.dart';

class DimensionTree extends StatelessWidget {
  final List<DimensionNode> nodes;
  final void Function(DimensionNode) onEdit;
  final void Function(String) onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Set<String> thumbnailDimensionIds;
  final void Function(String) onToggleThumbnail;

  const DimensionTree({
    super.key,
    required this.nodes,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
    this.thumbnailDimensionIds = const {},
    required this.onToggleThumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        onReorder(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final node = nodes[index];
        return ListTile(
          key: ValueKey(node.id),
          contentPadding: const EdgeInsets.only(left: 24.0, right: 16.0),
          leading: const Icon(Icons.drag_handle),
          title: Text('${node.name} (${node.type})'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  thumbnailDimensionIds.contains(node.id)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                tooltip: '缩略图显示',
                onPressed: () => onToggleThumbnail(node.id),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(node)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(node.id)),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Run analyzer**

```bash
cd app && flutter analyze lib/widgets/dimension_tree.dart
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add app/lib/widgets/dimension_tree.dart
git commit -m "feat: flatten DimensionTree widget"
```

---

### Task 8: Update Unit Tests

**Files:**
- Modify: `app/test/models/dimension_node_test.dart`
- Modify: `app/test/blocs/template_editor_cubit_test.dart`

- [ ] **Step 1: Rewrite dimension_node_test.dart**

Replace `app/test/models/dimension_node_test.dart`:

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
      );
      final updated = node.copyWith(name: 'New');
      expect(updated.name, 'New');
      expect(updated.id, '1');
    });

    test('Equatable equality on DimensionNode', () {
      final a = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
      );
      final b = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
      );
      final c = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Other',
        type: 'text',
      );
      expect(a, b);
      expect(a, isNot(c));
    });

    test('copyWith leaves unmentioned fields unchanged', () {
      final node = DimensionNode(
        id: '1',
        templateId: 't1',
        name: 'Node',
        type: 'text',
        config: '{"key":"value"}',
        sortOrder: 5,
      );
      final updated = node.copyWith();
      expect(updated.id, '1');
      expect(updated.templateId, 't1');
      expect(updated.name, 'Node');
      expect(updated.type, 'text');
      expect(updated.config, '{"key":"value"}');
      expect(updated.sortOrder, 5);
    });
  });
}
```

- [ ] **Step 2: Rewrite template_editor_cubit_test.dart**

Replace `app/test/blocs/template_editor_cubit_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_editor/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:house_note/models/dimension_node.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

class FakeTemplatesCompanion extends Fake implements TemplatesCompanion {}

class FakeTemplateDimensionsCompanion extends Fake implements TemplateDimensionsCompanion {}

class FakeTemplateThumbnailFieldsCompanion extends Fake implements TemplateThumbnailFieldsCompanion {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTemplatesCompanion());
    registerFallbackValue(FakeTemplateDimensionsCompanion());
    registerFallbackValue(FakeTemplateThumbnailFieldsCompanion());
  });

  group('TemplateEditorCubit', () {
    late MockTemplateRepository repo;

    setUp(() {
      repo = MockTemplateRepository();
    });

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'setTemplateName updates state',
      build: () => TemplateEditorCubit(repo),
      act: (cubit) => cubit.setTemplateName('Test'),
      expect: () => [
        const TemplateEditorState(templateName: 'Test'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'adds dimension',
      build: () => TemplateEditorCubit(repo),
      act: (cubit) {
        cubit.setTemplateName('Test');
        cubit.addDimension(name: 'D1', type: 'text');
      },
      expect: () => [
        const TemplateEditorState(templateName: 'Test'),
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.name == 'D1'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'updateDimension updates name type config',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'd', templateId: '', name: 'Dim', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.updateDimension('d', name: 'Updated', type: 'number', config: '{"max":10}'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final d = s.dimensions.first;
          return d.name == 'Updated' && d.type == 'number' && d.config == '{"max":10}';
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'removeDimension removes node',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
          DimensionNode(id: 'b', templateId: '', name: 'B', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.removeDimension('a'),
      expect: () => [
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.id == 'b'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moveDimension reorders dimensions',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
          DimensionNode(id: 'b', templateId: '', name: 'B', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 0, newIndex: 1),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          return s.dimensions.length == 2 &&
              s.dimensions[0].id == 'b' &&
              s.dimensions[1].id == 'a';
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'loadTemplate initializes thumbnailDimensionIds',
      build: () => TemplateEditorCubit(repo),
      setUp: () {
        when(() => repo.getTemplateById('t1')).thenAnswer((_) async => TemplateWithDimensions(
          Template(id: 't1', name: 'T', createdAt: 0, updatedAt: 0),
          [
            TemplateDimension(id: 'd1', templateId: 't1', name: 'A', type: 'text', config: '{}', sortOrder: 0),
            TemplateDimension(id: 'd2', templateId: 't1', name: 'B', type: 'text', config: '{}', sortOrder: 1),
          ],
        ));
        when(() => repo.getThumbnailFields('t1')).thenAnswer((_) async => [
          TemplateThumbnailField(id: 'f1', templateId: 't1', dimensionId: 'd2', sortOrder: 0),
        ]);
      },
      act: (cubit) => cubit.loadTemplate('t1'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          return s.templateName == 'T' && s.thumbnailDimensionIds.length == 1 && s.thumbnailDimensionIds.first == 'd2';
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'toggleThumbnailDimension adds and removes id',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(),
      act: (cubit) {
        cubit.toggleThumbnailDimension('d1');
        cubit.toggleThumbnailDimension('d2');
        cubit.toggleThumbnailDimension('d1');
      },
      expect: () => [
        const TemplateEditorState(thumbnailDimensionIds: ['d1']),
        const TemplateEditorState(thumbnailDimensionIds: ['d1', 'd2']),
        const TemplateEditorState(thumbnailDimensionIds: ['d2']),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'reorderThumbnailDimensions moves items',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(thumbnailDimensionIds: ['a', 'b', 'c']),
      act: (cubit) => cubit.reorderThumbnailDimensions(0, 2),
      expect: () => [
        const TemplateEditorState(thumbnailDimensionIds: ['b', 'c', 'a']),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'saveTemplate inserts new template and sets thumbnail fields',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        templateName: 'New Template',
        dimensions: [
          DimensionNode(id: 'd1', templateId: '', name: 'A', type: 'text'),
        ],
        thumbnailDimensionIds: ['d1'],
      ),
      setUp: () {
        when(() => repo.insertTemplate(any(), any())).thenAnswer((_) async {});
        when(() => repo.setThumbnailFields(any(), any())).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.saveTemplate(),
      verify: (_) {
        final insertCalls = verify(() => repo.insertTemplate(captureAny(), captureAny())).captured;
        final capturedTemplate = insertCalls[0] as TemplatesCompanion;
        final capturedDimensions = insertCalls[1] as List<TemplateDimensionsCompanion>;
        expect(capturedTemplate.name.value, 'New Template');
        expect(capturedDimensions.length, 1);
        expect(capturedDimensions.first.name.value, 'A');

        final thumbCalls = verify(() => repo.setThumbnailFields(captureAny(), captureAny())).captured;
        final thumbTemplateId = thumbCalls[0] as String;
        final thumbFields = thumbCalls[1] as List<TemplateThumbnailFieldsCompanion>;
        expect(thumbTemplateId, capturedTemplate.id.value);
        expect(thumbFields.length, 1);
        expect(thumbFields.first.dimensionId.value, 'd1');
      },
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'saveTemplate updates existing template and sets thumbnail fields',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        templateName: 'Updated Template',
        dimensions: [
          DimensionNode(id: 'd1', templateId: '', name: 'A', type: 'text'),
        ],
        thumbnailDimensionIds: ['d1'],
      ),
      setUp: () {
        when(() => repo.getTemplateById('t1')).thenAnswer((_) async => TemplateWithDimensions(
          Template(id: 't1', name: 'Old', createdAt: 0, updatedAt: 0),
          [TemplateDimension(id: 'd1', templateId: 't1', name: 'A', type: 'text', config: '{}', sortOrder: 0)],
        ));
        when(() => repo.getThumbnailFields('t1')).thenAnswer((_) async => [
          TemplateThumbnailField(id: 'f1', templateId: 't1', dimensionId: 'd1', sortOrder: 0),
        ]);
        when(() => repo.updateTemplate(any(), any())).thenAnswer((_) async {});
        when(() => repo.setThumbnailFields(any(), any())).thenAnswer((_) async {});
      },
      act: (cubit) async {
        await cubit.loadTemplate('t1');
        cubit.setTemplateName('Updated Template');
        await cubit.saveTemplate();
      },
      verify: (_) {
        final updateCalls = verify(() => repo.updateTemplate(captureAny(), captureAny())).captured;
        final capturedTemplate = updateCalls[0] as TemplatesCompanion;
        final capturedDimensions = updateCalls[1] as List<TemplateDimensionsCompanion>;
        expect(capturedTemplate.name.value, 'Updated Template');
        expect(capturedTemplate.id.value, 't1');
        expect(capturedDimensions.length, 1);

        final thumbCalls = verify(() => repo.setThumbnailFields(captureAny(), captureAny())).captured;
        final thumbTemplateId = thumbCalls[0] as String;
        final thumbFields = thumbCalls[1] as List<TemplateThumbnailFieldsCompanion>;
        expect(thumbTemplateId, 't1');
        expect(thumbFields.length, 1);
        expect(thumbFields.first.dimensionId.value, 'd1');
      },
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moveDimension with invalid oldIndex is no-op',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 5, newIndex: 0),
      expect: () => [],
    );
  });
}
```

- [ ] **Step 3: Run unit tests**

```bash
cd app && flutter test test/models/dimension_node_test.dart test/blocs/template_editor_cubit_test.dart
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git add app/test/models/dimension_node_test.dart app/test/blocs/template_editor_cubit_test.dart
git commit -m "test: update tests for flat dimension model"
```

---

### Task 9: Update E2E Test

**Files:**
- Modify: `app/integration_test/e2e_test.dart`

- [ ] **Step 1: Update Story 1.1 to not use group dimensions**

In `app/integration_test/e2e_test.dart`, find the Story 1.1 section (around line 212-234) and replace the group-related steps:

**Before:**
```dart
      // Add sub-dimension group: 通勤
      await tester.tap(find.text('添加子维度组'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '通勤');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add child dimension under 通勤: 是否靠近地铁站
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '是否靠近地铁站');
      await selectDimensionType(tester, '单选');
      await addSingleChoiceOption(tester, '是');
      await addSingleChoiceOption(tester, '否');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add child dimension under 通勤: 上班通勤 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '上班通勤');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();
```

**After:**
```dart
      // Add dimension: 是否靠近地铁站 (single_choice)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '是否靠近地铁站');
      await selectDimensionType(tester, '单选');
      await addSingleChoiceOption(tester, '是');
      await addSingleChoiceOption(tester, '否');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();

      // Add dimension: 上班通勤 (text)
      await tester.tap(find.text('添加维度项'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogTextField(0), '上班通勤');
      await tester.tap(find.text('保存').last);
      await tester.pumpAndSettle();
```

Also, check if the `_dim` helper in e2e_test uses `parentId` in the `_insertTemplate` helper. Since `TemplateDimension` no longer has `parentId`, update the `_dim` helper if needed.

Search for `_dim(` in e2e_test:
```bash
grep -n "_dim(" app/integration_test/e2e_test.dart
```

If `_dim` includes `parentId` in its signature, remove that parameter. Example pattern to look for:
```dart
TemplateDimension _dim(String id, String? parentId, ...) {
```

Change to:
```dart
TemplateDimension _dim(String id, String name, String type, String config) {
  return TemplateDimension(id: id, templateId: '', name: name, type: type, config: config, sortOrder: 0);
}
```

And update all call sites to remove the `parentId` argument (e.g., change `_dim('d1', null, 'Name', 'text', '{}')` to `_dim('d1', 'Name', 'text', '{}')`).

- [ ] **Step 2: Run E2E test for Story 1.1**

```bash
cd app && flutter test integration_test/e2e_test.dart --name "Story 1.1"
```

Expected: Test passes.

- [ ] **Step 3: Commit**

```bash
git add app/integration_test/e2e_test.dart
git commit -m "test: update e2e tests for flat dimensions"
```

---

### Task 10: Final Verification

- [ ] **Step 1: Run full analyzer**

```bash
cd app && flutter analyze
```

Expected: No errors.

- [ ] **Step 2: Run all unit/widget tests**

```bash
cd app && flutter test
```

Expected: All tests pass.

- [ ] **Step 3: Run E2E tests**

```bash
cd app && flutter test integration_test/e2e_test.dart
```

Expected: All tests pass.

- [ ] **Step 4: Commit**

```bash
git commit --allow-empty -m "chore: verify all tests pass after removing group dimension"
```

---

## Self-Review Checklist

- [ ] **Spec coverage:** Every section of the spec has a corresponding task
- [ ] **Placeholder scan:** No "TBD", "TODO", "similar to Task N", or vague instructions
- [ ] **Type consistency:** `DimensionNode` constructor, `moveDimension` signature, `onReorder` callback all match across tasks
- [ ] **Path accuracy:** All file paths use `app/` prefix and match the project structure
