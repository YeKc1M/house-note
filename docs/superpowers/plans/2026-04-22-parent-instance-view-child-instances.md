# Parent Instance View/Edit Child Instances Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow parent instances to display and edit child instances within the instance editor screen, and provide an edit entry point from the instance list for all instances (including parents).

**Architecture:** Extend `InstanceEditorState`/`Cubit` to load and group child instances by `ref_subtemplate` dimension. Render them as `InstanceCard` widgets inside the editor. Add `onEdit` to `InstanceCard` so parent instances are editable from the list. Use `Navigator.pop(true)` to trigger refresh when returning from child editor.

**Tech Stack:** Flutter, Drift/SQLite, flutter_bloc, bloc_test, mocktail

---

## File Structure

| File | Responsibility |
|------|---------------|
| `lib/blocs/instance_editor/state.dart` | `ChildInstanceSummary` model + `childInstances` field on `InstanceEditorState` |
| `lib/blocs/instance_editor/cubit.dart` | Load/refresh child instances; `_loadChildInstances` private helper |
| `lib/data/instance_repository.dart` | `getChildInstances(parentInstanceId)` — one-shot Future query |
| `lib/widgets/instance_card.dart` | Optional `onEdit` callback + edit icon button |
| `lib/screens/instance_list_screen.dart` | Pass `onEdit` to `InstanceCard` for all instances |
| `lib/screens/instance_editor_screen.dart` | Render `ref_subtemplate` as child instance card area; handle nav/refresh |
| `test/blocs/instance_editor_cubit_test.dart` | Cubit tests for child instance loading |
| `test/data/instance_repository_test.dart` | `getChildInstances` repository test |
| `integration_test/e2e_test.dart` | E2E: edit child from parent editor; edit parent fields with children visible |

---

## Setup Note

Per `CLAUDE.md`, develop in a dedicated git worktree:

```bash
git worktree add ../house-note-parent-child-edit -b feat/parent-instance-child-view
cd ../house-note-parent-child-edit/app
flutter pub get
```

Run all commands from `app/` directory.

---

## Task 1: Extend InstanceEditorState with ChildInstanceSummary

**Files:**
- Modify: `lib/blocs/instance_editor/state.dart`
- Test: `test/blocs/instance_editor_cubit_test.dart`

- [ ] **Step 1: Add ChildInstanceSummary and extend state**

Add to `lib/blocs/instance_editor/state.dart` **after** `CustomFieldData` and **before** `InstanceEditorState`:

```dart
class ChildInstanceSummary extends Equatable {
  final String id;
  final String name;
  final String templateId;
  final Map<String, String> thumbnailValues;

  const ChildInstanceSummary({
    required this.id,
    required this.name,
    required this.templateId,
    this.thumbnailValues = const {},
  });

  ChildInstanceSummary copyWith({
    String? id,
    String? name,
    String? templateId,
    Map<String, String>? thumbnailValues,
  }) {
    return ChildInstanceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      thumbnailValues: thumbnailValues ?? this.thumbnailValues,
    );
  }

  @override
  List<Object?> get props => [id, name, templateId, thumbnailValues];
}
```

Extend `InstanceEditorState`:
- Add `final Map<String, List<ChildInstanceSummary>> childInstances;` to fields
- Add `childInstances: const {}` to default constructor
- Add `childInstances` parameter to `copyWith` and merge logic
- Add `childInstances` to `props`

The full updated `InstanceEditorState`:

```dart
class InstanceEditorState extends Equatable {
  final String name;
  final String? templateId;
  final String? parentInstanceId;
  final List<DimensionNode> dimensions;
  final Map<String, String> dimensionValues;
  final Set<String> hiddenDimensionIds;
  final List<CustomFieldData> customFields;
  final Map<String, List<ChildInstanceSummary>> childInstances;

  const InstanceEditorState({
    this.name = '',
    this.templateId,
    this.parentInstanceId,
    this.dimensions = const [],
    this.dimensionValues = const {},
    this.hiddenDimensionIds = const {},
    this.customFields = const [],
    this.childInstances = const {},
  });

  InstanceEditorState copyWith({
    String? name,
    String? templateId,
    String? parentInstanceId,
    List<DimensionNode>? dimensions,
    Map<String, String>? dimensionValues,
    Set<String>? hiddenDimensionIds,
    List<CustomFieldData>? customFields,
    Map<String, List<ChildInstanceSummary>>? childInstances,
  }) {
    return InstanceEditorState(
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      parentInstanceId: parentInstanceId ?? this.parentInstanceId,
      dimensions: dimensions ?? this.dimensions,
      dimensionValues: dimensionValues ?? this.dimensionValues,
      hiddenDimensionIds: hiddenDimensionIds ?? this.hiddenDimensionIds,
      customFields: customFields ?? this.customFields,
      childInstances: childInstances ?? this.childInstances,
    );
  }

  @override
  List<Object?> get props => [
    name, templateId, parentInstanceId, dimensions,
    dimensionValues, hiddenDimensionIds, customFields, childInstances,
  ];
}
```

- [ ] **Step 2: Write equality test**

Add to `test/blocs/instance_editor_cubit_test.dart` inside the `group`:

```dart
blocTest<InstanceEditorCubit, InstanceEditorState>(
  'state equality with childInstances',
  build: () => InstanceEditorCubit(),
  seed: () => const InstanceEditorState(
    childInstances: {
      'dim1': [
        ChildInstanceSummary(id: 'i1', name: 'A', templateId: 't1'),
      ],
    },
  ),
  act: (cubit) {},
  expect: () => [],
  verify: (cubit) {
    final s1 = cubit.state;
    final s2 = s1.copyWith(
      childInstances: {
        'dim1': [
          ChildInstanceSummary(id: 'i1', name: 'A', templateId: 't1'),
        ],
      },
    );
    expect(s1, s2);
  },
);
```

- [ ] **Step 3: Run test**

```bash
flutter test test/blocs/instance_editor_cubit_test.dart --name "state equality with childInstances"
```
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add lib/blocs/instance_editor/state.dart test/blocs/instance_editor_cubit_test.dart
git commit -m "feat: add ChildInstanceSummary to InstanceEditorState"
```

---

## Task 2: Add getChildInstances to InstanceRepository

**Files:**
- Modify: `lib/data/instance_repository.dart`
- Test: `test/data/instance_repository_test.dart`

- [ ] **Step 1: Write failing test**

Add to `test/data/instance_repository_test.dart`:

```dart
test('getChildInstances returns children ordered by createdAt desc', () async {
  await repo.insertInstance(InstancesCompanion.insert(
    id: 'parent',
    templateId: 'tmpl',
    name: 'Parent',
    createdAt: 1,
    updatedAt: 1,
  ));
  await repo.insertInstance(InstancesCompanion.insert(
    id: 'child1',
    templateId: 'tmpl',
    parentInstanceId: 'parent',
    name: 'Child1',
    createdAt: 2,
    updatedAt: 2,
  ));
  await repo.insertInstance(InstancesCompanion.insert(
    id: 'child2',
    templateId: 'tmpl',
    parentInstanceId: 'parent',
    name: 'Child2',
    createdAt: 3,
    updatedAt: 3,
  ));
  final children = await repo.getChildInstances('parent');
  expect(children.length, 2);
  expect(children.first.name, 'Child2');
  expect(children.last.name, 'Child1');
});
```

- [ ] **Step 2: Run test to verify failure**

```bash
flutter test test/data/instance_repository_test.dart --name "getChildInstances returns children ordered by createdAt desc"
```
Expected: FAIL — `getChildInstances` not defined

- [ ] **Step 3: Implement getChildInstances**

Add to `lib/data/instance_repository.dart` inside `InstanceRepository`:

```dart
Future<List<Instance>> getChildInstances(String parentInstanceId) async {
  return (_db.select(_db.instances)
    ..where((i) => i.parentInstanceId.equals(parentInstanceId))
    ..orderBy([(i) => OrderingTerm(expression: i.createdAt, mode: OrderingMode.desc)]))
    .get();
}
```

- [ ] **Step 4: Run test to verify pass**

```bash
flutter test test/data/instance_repository_test.dart --name "getChildInstances returns children ordered by createdAt desc"
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/data/instance_repository.dart test/data/instance_repository_test.dart
git commit -m "feat: add getChildInstances to InstanceRepository"
```

---

## Task 3: Extend InstanceEditorCubit to load child instances

**Files:**
- Modify: `lib/blocs/instance_editor/cubit.dart`
- Test: `test/blocs/instance_editor_cubit_test.dart`

- [ ] **Step 1: Register mock fallbacks for tests**

At the top of `test/blocs/instance_editor_cubit_test.dart` (after imports, before `void main()`), add:

```dart
class FakeInstancesCompanion extends Fake implements InstancesCompanion {}
class FakeInstanceValuesCompanion extends Fake implements InstanceValuesCompanion {}
class FakeInstanceCustomFieldsCompanion extends Fake implements InstanceCustomFieldsCompanion {}
class FakeInstanceHiddenDimensionsCompanion extends Fake implements InstanceHiddenDimensionsCompanion {}

class MockInstanceRepository extends Mock implements InstanceRepository {}
class MockTemplateRepository extends Mock implements TemplateRepository {}
```

In `setUpAll` or at top level:

```dart
setUpAll(() {
  registerFallbackValue(FakeInstancesCompanion());
  registerFallbackValue(FakeInstanceValuesCompanion());
  registerFallbackValue(FakeInstanceCustomFieldsCompanion());
  registerFallbackValue(FakeInstanceHiddenDimensionsCompanion());
});
```

- [ ] **Step 2: Write failing test for loadChildInstances**

Add a new group to `test/blocs/instance_editor_cubit_test.dart`:

```dart
group('with mocks', () {
  late MockInstanceRepository mockInstanceRepo;
  late MockTemplateRepository mockTemplateRepo;
  late InstanceEditorCubit cubit;

  setUp(() {
    mockInstanceRepo = MockInstanceRepository();
    mockTemplateRepo = MockTemplateRepository();
    cubit = InstanceEditorCubit(mockInstanceRepo, mockTemplateRepo);
  });

  blocTest<InstanceEditorCubit, InstanceEditorState>(
    'loadInstance loads child instances grouped by ref_subtemplate dimension',
    build: () => cubit,
    setUp: () {
      final instance = Instance(
        id: 'parent',
        templateId: 'tmpl',
        parentInstanceId: null,
        name: 'Parent',
        createdAt: 1,
        updatedAt: 1,
      );
      when(() => mockInstanceRepo.getInstanceById('parent'))
          .thenAnswer((_) async => InstanceWithData(
                instance,
                [],
                [],
                [],
              ));
      when(() => mockTemplateRepo.getTemplateById('tmpl')).thenAnswer(
        (_) async => TemplateWithDimensions(
          Template(id: 'tmpl', name: 'T', createdAt: 1, updatedAt: 1),
          [
            TemplateDimension(
              id: 'dim1',
              templateId: 'tmpl',
              name: '房子列表',
              type: 'ref_subtemplate',
              config: '{"ref_template_id": "house_tmpl"}',
              sortOrder: 0,
            ),
          ],
        ),
      );
      when(() => mockTemplateRepo.getRefSubtemplateDimensions('tmpl'))
          .thenAnswer((_) async => [
                TemplateDimension(
                  id: 'dim1',
                  templateId: 'tmpl',
                  name: '房子列表',
                  type: 'ref_subtemplate',
                  config: '{"ref_template_id": "house_tmpl"}',
                  sortOrder: 0,
                ),
              ]);
      when(() => mockInstanceRepo.getChildInstances('parent')).thenAnswer(
        (_) async => [
          Instance(
            id: 'child1',
            templateId: 'house_tmpl',
            parentInstanceId: 'parent',
            name: '7栋-1203',
            createdAt: 2,
            updatedAt: 2,
          ),
        ],
      );
      when(() => mockTemplateRepo.getThumbnailValues('child1', 'house_tmpl'))
          .thenAnswer((_) async => {'朝向': '南'});
    },
    act: (cubit) => cubit.loadInstance('parent'),
    expect: () => [
      isA<InstanceEditorState>().having(
        (s) => s.childInstances['dim1']?.length,
        'childInstances count for dim1',
        1,
      ).having(
        (s) => s.childInstances['dim1']?.first.name,
        'child name',
        '7栋-1203',
      ).having(
        (s) => s.childInstances['dim1']?.first.thumbnailValues['朝向'],
        'thumbnail',
        '南',
      ),
    ],
  );
});
```

- [ ] **Step 3: Run test to verify failure**

```bash
flutter test test/blocs/instance_editor_cubit_test.dart --name "loadInstance loads child instances grouped by ref_subtemplate dimension"
```
Expected: FAIL — `_loadChildInstances` or related methods not implemented

- [ ] **Step 4: Implement child instance loading in cubit**

Modify `lib/blocs/instance_editor/cubit.dart`:

1. Add `_loadChildInstances` private method at the bottom of the class:

```dart
Future<void> _loadChildInstances(String parentInstanceId, String templateId) async {
  if (_instanceRepo == null || _templateRepo == null) return;

  final refDims = await _templateRepo!.getRefSubtemplateDimensions(templateId);
  if (refDims.isEmpty) {
    emit(state.copyWith(childInstances: const {}));
    return;
  }

  final children = await _instanceRepo!.getChildInstances(parentInstanceId);
  final result = <String, List<ChildInstanceSummary>>{};

  for (final dim in refDims) {
    final match = RegExp(r'"ref_template_id"\s*:\s*"([^"]+)"').firstMatch(dim.config);
    final refTemplateId = match?.group(1);
    if (refTemplateId == null) continue;

    final dimChildren = children.where((c) => c.templateId == refTemplateId).toList();
    final summaries = <ChildInstanceSummary>[];

    for (final child in dimChildren) {
      final thumbs = await _templateRepo!.getThumbnailValues(child.id, child.templateId);
      summaries.add(ChildInstanceSummary(
        id: child.id,
        name: child.name,
        templateId: child.templateId,
        thumbnailValues: thumbs,
      ));
    }

    result[dim.id] = summaries;
  }

  emit(state.copyWith(childInstances: result));
}
```

2. Modify `loadInstance` to call `_loadChildInstances` after emitting state:

Replace the `emit(InstanceEditorState(...))` call in `loadInstance` with:

```dart
emit(InstanceEditorState(
  name: data.instance.name,
  templateId: data.instance.templateId,
  parentInstanceId: data.instance.parentInstanceId,
  dimensions: tree,
  dimensionValues: {for (final d in template?.dimensions ?? []) d.id: values[d.id] ?? ''},
  hiddenDimensionIds: hidden,
  customFields: custom,
));
await _loadChildInstances(instanceId, data.instance.templateId);
```

3. Add `refreshChildInstances` public method:

```dart
Future<void> refreshChildInstances() async {
  if (_instanceId == null || _instanceRepo == null) return;
  final data = await _instanceRepo!.getInstanceById(_instanceId!);
  if (data == null) return;
  await _loadChildInstances(_instanceId!, data.instance.templateId);
}
```

- [ ] **Step 5: Run test to verify pass**

```bash
flutter test test/blocs/instance_editor_cubit_test.dart --name "loadInstance loads child instances grouped by ref_subtemplate dimension"
```
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/blocs/instance_editor/cubit.dart test/blocs/instance_editor_cubit_test.dart
git commit -m "feat: load child instances in InstanceEditorCubit"
```

---

## Task 4: Add onEdit to InstanceCard

**Files:**
- Modify: `lib/widgets/instance_card.dart`

- [ ] **Step 1: Add onEdit parameter**

Modify `lib/widgets/instance_card.dart`:

```dart
class InstanceCard extends StatelessWidget {
  final Instance instance;
  final Map<String, String> thumbnailValues;
  final int? childCount;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const InstanceCard({
    super.key,
    required this.instance,
    required this.thumbnailValues,
    this.childCount,
    required this.onTap,
    this.onEdit,
  });
```

- [ ] **Step 2: Add edit icon to build**

Modify the `build` method to wrap the title row with an edit button:

```dart
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    instance.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (thumbnailValues.isNotEmpty)
              Wrap(
                spacing: 8,
                children: thumbnailValues.entries
                    .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
                    .toList(),
              ),
            if (childCount != null)
              Text(
                '$childCount 套房子',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/instance_card.dart
git commit -m "feat: add onEdit callback to InstanceCard"
```

---

## Task 5: Wire onEdit in InstanceListScreen

**Files:**
- Modify: `lib/screens/instance_list_screen.dart`

- [ ] **Step 1: Pass onEdit to InstanceCard**

In `lib/screens/instance_list_screen.dart`, modify the `InstanceCard` invocation inside `itemBuilder`:

```dart
InstanceCard(
  instance: inst,
  thumbnailValues: state.thumbnailValues[inst.id] ?? {},
  onTap: () {
    final templateRepo = context.read<TemplateRepository>();
    templateRepo.getRefSubtemplateDimensions(inst.templateId).then((dims) async {
      if (dims.isNotEmpty) {
        final newCrumbs = [
          ...state.breadcrumbs,
          Breadcrumb(id: inst.id, name: inst.name),
        ];
        if (context.mounted) {
          context.read<InstanceListCubit>().loadChildren(inst.id, newCrumbs);
        }
      } else {
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/instanceEditor',
            arguments: {'instanceId': inst.id},
          );
        }
      }
    });
  },
  onEdit: () {
    Navigator.pushNamed(
      context,
      '/instanceEditor',
      arguments: {'instanceId': inst.id},
    );
  },
),
```

- [ ] **Step 2: Run app smoke test**

```bash
flutter analyze
```
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add lib/screens/instance_list_screen.dart
git commit -m "feat: wire onEdit into InstanceListScreen for all instances"
```

---

## Task 6: Render ref_subtemplate with child instance cards in InstanceEditorScreen

**Files:**
- Modify: `lib/screens/instance_editor_screen.dart`

- [ ] **Step 1: Add Instance import**

Add to imports at top of `lib/screens/instance_editor_screen.dart`:

```dart
import '../data/database.dart' show Instance;
```

- [ ] **Step 2: Modify _buildDimensionFields to handle ref_subtemplate**

In `_buildDimensionFields`, replace the `else if (node.type != 'ref_subtemplate')` block with:

```dart
} else if (node.type == 'ref_subtemplate') {
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
```

- [ ] **Step 3: Add _buildRefSubtemplateCard method**

Add this method to `_InstanceEditorScreenState`:

```dart
Widget _buildRefSubtemplateCard(
  BuildContext context,
  DimensionNode node,
  List<ChildInstanceSummary> children,
) {
  final cubit = context.read<InstanceEditorCubit>();
  final isNewInstance = widget.instanceId == null;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (isNewInstance)
            const Text(
              '请先保存父实例后再添加子实例',
              style: TextStyle(color: Colors.grey),
            )
          else if (children.isEmpty)
            const Text(
              '暂无子实例',
              style: TextStyle(color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: children.map((child) {
                return SizedBox(
                  width: 160,
                  child: InstanceCard(
                    instance: Instance(
                      id: child.id,
                      templateId: child.templateId,
                      parentInstanceId: widget.instanceId,
                      name: child.name,
                      createdAt: 0,
                      updatedAt: 0,
                    ),
                    thumbnailValues: child.thumbnailValues,
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/instanceEditor',
                        arguments: {'instanceId': child.id},
                      );
                      if (result == true && mounted) {
                        cubit.refreshChildInstances();
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          if (!isNewInstance)
            TextButton.icon(
              onPressed: () async {
                final match = RegExp(
                  r'"ref_template_id"\s*:\s*"([^"]+)"',
                ).firstMatch(node.config);
                final refTemplateId = match?.group(1);
                if (refTemplateId == null) return;

                final result = await Navigator.pushNamed(
                  context,
                  '/instanceEditor',
                  arguments: {
                    'templateId': refTemplateId,
                    'parentInstanceId': widget.instanceId,
                  },
                );
                if (result == true && mounted) {
                  cubit.refreshChildInstances();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('添加子实例'),
            ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 4: Verify analyzer**

```bash
flutter analyze lib/screens/instance_editor_screen.dart
```
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add lib/screens/instance_editor_screen.dart
git commit -m "feat: render child instance cards for ref_subtemplate in editor"
```

---

## Task 7: Instance editor save returns true to trigger parent refresh

**Files:**
- Modify: `lib/screens/instance_editor_screen.dart`

- [ ] **Step 1: Change Navigator.pop to pop(true)**

In `lib/screens/instance_editor_screen.dart`, find the save `IconButton` and modify:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.save),
    onPressed: () async {
      final cubit = context.read<InstanceEditorCubit>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      await cubit.saveInstance();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('实例保存成功')),
        );
        navigator.pop(true);
      }
    },
  ),
],
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/instance_editor_screen.dart
git commit -m "feat: return true on save to trigger parent refresh"
```

---

## Task 8: E2E Test — Edit child instance from parent editor

**Files:**
- Modify: `integration_test/e2e_test.dart`

- [ ] **Step 1: Write E2E test**

Add a new `testWidgets` inside the `group('E2E User Stories')` at the end:

```dart
testWidgets('Story 5.1 - Edit child instance from parent instance editor',
    (WidgetTester tester) async {
  // Seed data
  final houseTemplateId = await _insertTemplate(db, '房子模板', [
    TemplateDimensionsCompanion(
      id: const Value('d1'),
      name: const Value('朝向'),
      type: const Value('single_choice'),
      config: const Value('{"options": ["东", "南", "西", "北"]}'),
    ),
  ]);
  final communityTemplateId = await _insertTemplate(db, '小区模板', [
    TemplateDimensionsCompanion(
      id: const Value('d2'),
      name: const Value('小区名'),
      type: const Value('text'),
    ),
    TemplateDimensionsCompanion(
      id: const Value('d3'),
      name: const Value('房子列表'),
      type: const Value('ref_subtemplate'),
      config: Value('{"ref_template_id": "$houseTemplateId"}'),
    ),
  ]);
  final communityId = await _insertInstance(
    db, communityTemplateId, null, '华润二十四城', {'d2': '华润二十四城'},
  );
  final houseId = await _insertInstance(
    db, houseTemplateId, communityId, '7栋-1203', {'d1': '南'},
  );

  await tester.pumpWidget(HouseNoteApp(database: db));
  await tester.pumpAndSettle();

  // Tap edit icon on community instance card
  final editButton = find.descendant(
    of: find.widgetWithText(InstanceCard, '华润二十四城'),
    matching: find.byIcon(Icons.edit),
  );
  await tester.tap(editButton);
  await tester.pumpAndSettle();

  // Verify child instance card is visible
  expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

  // Tap child instance card to edit
  await tester.tap(find.widgetWithText(InstanceCard, '7栋-1203'));
  await tester.pumpAndSettle();

  // Change orientation to "东南"
  await tester.tap(find.text('东南'));
  await tester.pumpAndSettle();

  // Save
  await tester.tap(find.byIcon(Icons.save));
  await tester.pumpAndSettle();

  // Verify back on parent editor and child card still visible
  expect(find.text('华润二十四城'), findsOneWidget);
  expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

  // Verify child was updated
  await tester.tap(find.widgetWithText(InstanceCard, '7栋-1203'));
  await tester.pumpAndSettle();
  expect(find.text('东南'), findsOneWidget);
});
```

- [ ] **Step 2: Run E2E test**

```bash
flutter test integration_test/e2e_test.dart --name "Story 5.1"
```
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add integration_test/e2e_test.dart
git commit -m "test: e2e for editing child instance from parent editor"
```

---

## Task 9: E2E Test — Edit parent fields with child instances visible

**Files:**
- Modify: `integration_test/e2e_test.dart`

- [ ] **Step 1: Write E2E test**

Add a new `testWidgets` inside the `group('E2E User Stories')` at the end:

```dart
testWidgets('Story 5.2 - Edit parent fields with child instances visible',
    (WidgetTester tester) async {
  // Seed data
  final houseTemplateId = await _insertTemplate(db, '房子模板', [
    TemplateDimensionsCompanion(
      id: const Value('d1'),
      name: const Value('朝向'),
      type: const Value('single_choice'),
      config: const Value('{"options": ["东", "南", "西", "北"]}'),
    ),
  ]);
  final communityTemplateId = await _insertTemplate(db, '小区模板', [
    TemplateDimensionsCompanion(
      id: const Value('d2'),
      name: const Value('小区名'),
      type: const Value('text'),
    ),
    TemplateDimensionsCompanion(
      id: const Value('d3'),
      name: const Value('位置'),
      type: const Value('text'),
    ),
    TemplateDimensionsCompanion(
      id: const Value('d4'),
      name: const Value('房子列表'),
      type: const Value('ref_subtemplate'),
      config: Value('{"ref_template_id": "$houseTemplateId"}'),
    ),
  ]);
  final communityId = await _insertInstance(
    db, communityTemplateId, null, '华润二十四城',
    {'d2': '华润二十四城', 'd3': '成华区双庆路'},
  );
  await _insertInstance(
    db, houseTemplateId, communityId, '7栋-1203', {'d1': '南'},
  );

  await tester.pumpWidget(HouseNoteApp(database: db));
  await tester.pumpAndSettle();

  // Tap edit icon on community instance card
  final editButton = find.descendant(
    of: find.widgetWithText(InstanceCard, '华润二十四城'),
    matching: find.byIcon(Icons.edit),
  );
  await tester.tap(editButton);
  await tester.pumpAndSettle();

  // Verify child instance card is visible
  expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);

  // Edit parent field "位置"
  final locationField = find.widgetWithText(TextFormField, '成华区双庆路');
  await tester.enterText(locationField, '成华区双庆路6号');
  await tester.pumpAndSettle();

  // Save
  await tester.tap(find.byIcon(Icons.save));
  await tester.pumpAndSettle();

  // Verify back on list page, then re-enter editor
  expect(find.text('首页'), findsOneWidget);

  await tester.tap(find.descendant(
    of: find.widgetWithText(InstanceCard, '华润二十四城'),
    matching: find.byIcon(Icons.edit),
  ));
  await tester.pumpAndSettle();

  // Verify child card still visible and parent field updated
  expect(find.widgetWithText(InstanceCard, '7栋-1203'), findsOneWidget);
  expect(find.widgetWithText(TextFormField, '成华区双庆路6号'), findsOneWidget);
});
```

- [ ] **Step 2: Run E2E test**

```bash
flutter test integration_test/e2e_test.dart --name "Story 5.2"
```
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add integration_test/e2e_test.dart
git commit -m "test: e2e for editing parent fields with children visible"
```

---

## Self-Review

**1. Spec coverage:**
- UI interaction: Task 6 handles rendering `ref_subtemplate` as card area with add button — covered
- Data flow: Task 3 handles cubit loading/refresh — covered
- Navigation/refresh: Task 7 handles `pop(true)`, Task 6 handles `await pushNamed` + refresh — covered
- Multiple child types: Task 3 groups by dimension ID — covered
- Edit parent from list: Task 4 + 5 add `onEdit` to `InstanceCard` — covered
- E2E tests: Task 8 (edit child) and Task 9 (edit parent) — covered

**2. Placeholder scan:** No TBD/TODO, all steps have code/commands.

**3. Type consistency:**
- `ChildInstanceSummary` has `thumbnailValues: Map<String, String>` — consistent across state, cubit, screen
- `childInstances` key is `String` (dimension ID) — consistent
- `InstanceRepository.getChildInstances` returns `List<Instance>` — consistent with cubit usage

No issues found.
