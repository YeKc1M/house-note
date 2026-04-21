# 实例删除（含级联删除）实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在实例列表页支持左滑删除卡片，删除父实例时递归级联删除所有子实例，并在删除前弹出确认对话框提示子实例数量。

**Architecture:** Repository 层修正 `deleteInstance` 为递归深度优先删除（先删后代再删自己，利用 SQLite `onDelete: cascade` 自动清理关联数据）。BLoC 层暴露 `deleteInstance` 入口。UI 层用 Flutter 内置 `Dismissible` 包裹卡片，`confirmDismiss` 中弹出 `AlertDialog` 确认。全部行为由 Repository 测试、BLoC 测试、E2E 测试覆盖。

**Tech Stack:** Flutter, Drift (SQLite), flutter_bloc, mocktail, bloc_test, integration_test

---

## 文件结构

| 文件 | 变更类型 | 职责 |
|------|---------|------|
| `app/lib/data/instance_repository.dart` | 修改 | 修正 `deleteInstance` 为递归级联；新增 `countDescendants` |
| `app/lib/blocs/instance_list/cubit.dart` | 修改 | 新增 `deleteInstance(String id)` 方法 |
| `app/lib/screens/instance_list_screen.dart` | 修改 | `Dismissible` 包裹 `InstanceCard`，实现确认对话框 |
| `app/test/data/instance_repository_test.dart` | 修改 | 更新现有 deleteInstance 测试为深层级联；新增 `countDescendants` 测试 |
| `app/test/blocs/instance_list_cubit_test.dart` | 修改 | 新增 `deleteInstance` 调用验证测试 |
| `app/integration_test/e2e_test.dart` | 修改 | 新增 E2E 测试：创建三层实例 -> 左滑删除父实例 -> 验证确认对话框 -> 确认删除 -> 验证级联消失 |

---

### Task 1: 修正 `InstanceRepository.deleteInstance` 为递归级联删除

**Files:**
- Modify: `app/lib/data/instance_repository.dart:105-112`

当前实现只删除直接子实例。`Instances.parentInstanceId` 未配置 `onDelete: cascade`，深层子实例会导致外键约束失败。改为先递归删除所有后代，再删除目标实例。`InstanceValues` / `InstanceCustomFields` / `InstanceHiddenDimensions` 已配置 `onDelete: cascade`，关联数据自动清理。

- [ ] **Step 1: 替换 `deleteInstance` 实现**

```dart
  Future<void> deleteInstance(String id) async {
    await _db.transaction(() async {
      await _deleteInstanceRecursive(id);
    });
  }

  Future<void> _deleteInstanceRecursive(String id) async {
    final children = await (_db.select(_db.instances)
          ..where((i) => i.parentInstanceId.equals(id)))
        .get();
    for (final child in children) {
      await _deleteInstanceRecursive(child.id);
    }
    await (_db.delete(_db.instances)..where((i) => i.id.equals(id))).go();
  }
```

- [ ] **Step 2: 运行现有 Repository 测试确保未破坏**

Run: `cd app && flutter test test/data/instance_repository_test.dart`
Expected: 全部通过（包括已有的 `'deleteInstance deletes instance and child instances'`）

- [ ] **Step 3: Commit**

```bash
cd app && git add lib/data/instance_repository.dart
git commit -m "fix: make deleteInstance recursively cascade to all descendants"
```

---

### Task 2: 新增 `InstanceRepository.countDescendants`

**Files:**
- Modify: `app/lib/data/instance_repository.dart`

- [ ] **Step 1: 在 `InstanceRepository` 类末尾新增方法**

在 `deleteInstance` 方法之后插入：

```dart
  Future<int> countDescendants(String id) async {
    final children = await (_db.select(_db.instances)
          ..where((i) => i.parentInstanceId.equals(id)))
        .get();
    int count = children.length;
    for (final child in children) {
      count += await countDescendants(child.id);
    }
    return count;
  }
```

- [ ] **Step 2: 在 `app/test/data/instance_repository_test.dart` 末尾新增测试**

在文件最后一个 `test(...)` 之后（第 253 行之后）、`}` 之前插入：

```dart

  test('deleteInstance recursively deletes grandchild instances', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'parent',
      templateId: 'tmpl',
      name: 'Parent',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'child',
      templateId: 'tmpl',
      parentInstanceId: Value('parent'),
      name: 'Child',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'grandchild',
      templateId: 'tmpl',
      parentInstanceId: Value('child'),
      name: 'Grandchild',
      createdAt: 1,
      updatedAt: 1,
    ));

    await repo.deleteInstance('parent');

    expect(await repo.getInstanceById('parent'), isNull);
    expect(await repo.getInstanceById('child'), isNull);
    expect(await repo.getInstanceById('grandchild'), isNull);
  });

  test('countDescendants returns total descendant count', () async {
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'p',
      templateId: 'tmpl',
      name: 'P',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'c1',
      templateId: 'tmpl',
      parentInstanceId: Value('p'),
      name: 'C1',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'c2',
      templateId: 'tmpl',
      parentInstanceId: Value('p'),
      name: 'C2',
      createdAt: 1,
      updatedAt: 1,
    ));
    await repo.insertInstance(InstancesCompanion.insert(
      id: 'gc',
      templateId: 'tmpl',
      parentInstanceId: Value('c1'),
      name: 'GC',
      createdAt: 1,
      updatedAt: 1,
    ));

    expect(await repo.countDescendants('p'), 3);
    expect(await repo.countDescendants('c1'), 1);
    expect(await repo.countDescendants('c2'), 0);
    expect(await repo.countDescendants('gc'), 0);
  });
```

- [ ] **Step 3: 运行 Repository 测试**

Run: `cd app && flutter test test/data/instance_repository_test.dart`
Expected: 全部 8 个测试通过

- [ ] **Step 4: Commit**

```bash
cd app && git add lib/data/instance_repository.dart test/data/instance_repository_test.dart
git commit -m "feat: add countDescendants and recursive cascade deletion tests"
```

---

### Task 3: `InstanceListCubit` 暴露 `deleteInstance` 入口

**Files:**
- Modify: `app/lib/blocs/instance_list/cubit.dart`

- [ ] **Step 1: 在 `InstanceListCubit` 类中新增方法**

在 `navigateToBreadcrumb` 方法之后（第 39 行之后）插入：

```dart

  Future<void> deleteInstance(String id) async {
    await _repo.deleteInstance(id);
  }
```

- [ ] **Step 2: 在 `app/test/blocs/instance_list_cubit_test.dart` 末尾新增测试**

在文件最后一个 `blocTest` 之后（第 59 行之后）、`}` 之前插入：

```dart

  blocTest<InstanceListCubit, InstanceListState>(
    'deleteInstance calls repository delete',
    build: () => InstanceListCubit(repo, templateRepo),
    setUp: () {
      when(() => repo.deleteInstance('i1')).thenAnswer((_) async {});
    },
    act: (cubit) => cubit.deleteInstance('i1'),
    verify: (_) {
      verify(() => repo.deleteInstance('i1')).called(1);
    },
  );
```

- [ ] **Step 3: 运行 BLoC 测试**

Run: `cd app && flutter test test/blocs/instance_list_cubit_test.dart`
Expected: 全部 3 个测试通过

- [ ] **Step 4: Commit**

```bash
cd app && git add lib/blocs/instance_list/cubit.dart test/blocs/instance_list_cubit_test.dart
git commit -m "feat: expose deleteInstance on InstanceListCubit"
```

---

### Task 4: `InstanceListScreen` 左滑删除 + 确认对话框

**Files:**
- Modify: `app/lib/screens/instance_list_screen.dart:28-58`

将 `ListView.builder` 中的 `InstanceCard` 用 `Dismissible` 包裹。`confirmDismiss` 中调用 `countDescendants` 获取子实例数量，弹出确认对话框，用户确认后调用 `cubit.deleteInstance(id)` 并显示 SnackBar。

- [ ] **Step 1: 修改 `itemBuilder` 中的 `InstanceCard` 为 `Dismissible` 包裹**

替换 `app/lib/screens/instance_list_screen.dart` 中第 31-58 行：

```dart
                    return Dismissible(
                      key: Key(inst.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        final instanceRepo = context.read<InstanceRepository>();
                        final cubit = context.read<InstanceListCubit>();
                        final messenger = ScaffoldMessenger.of(context);
                        final count = await instanceRepo.countDescendants(inst.id);
                        if (!context.mounted) return false;
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('确认删除'),
                            content: Text(
                              count > 0
                                  ? '确定要删除「${inst.name}」吗？将同时删除 $count 个子实例，此操作不可撤销。'
                                  : '确定要删除「${inst.name}」吗？此操作不可撤销。',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext, true),
                                child: const Text('删除'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await cubit.deleteInstance(inst.id);
                          if (context.mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('实例已删除')),
                            );
                          }
                        }
                        return false;
                      },
                      child: InstanceCard(
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
                      ),
                    );
```

- [ ] **Step 2: 编译检查**

Run: `cd app && flutter analyze lib/screens/instance_list_screen.dart`
Expected: 无错误

- [ ] **Step 3: Commit**

```bash
cd app && git add lib/screens/instance_list_screen.dart
git commit -m "feat: add swipe-to-delete with confirm dialog in instance list"
```

---

### Task 5: E2E 测试覆盖删除级联

**Files:**
- Modify: `app/integration_test/e2e_test.dart`

在现有 `group('E2E User Stories', ()` 的最后一个 `testWidgets` 之后（第 702 行之后）、`});` 之前插入新测试。

- [ ] **Step 1: 在 E2E 文件末尾新增删除测试**

```dart

    testWidgets('Story 4.1 - Swipe to delete parent instance cascades to children',
        (WidgetTester tester) async {
      await tester.pumpWidget(HouseNoteApp(database: db));
      await tester.pumpAndSettle();

      // Pre-create a 3-level hierarchy directly in DB
      final communityTemplateId = await _insertTemplate(db, '小区模板', [
        _dim('d1', null, '小区名', 'text', '{}'),
        _dim('d2', null, '房子列表', 'ref_subtemplate', '{"ref_template_id":"house_tpl"}'),
      ]);
      final houseTemplateId = await _insertTemplate(db, '房子模板', [
        _dim('d3', null, '朝向', 'single_choice', '{"options":["东","南"]}'),
        _dim('d4', null, '房间列表', 'ref_subtemplate', '{"ref_template_id":"room_tpl"}'),
      ]);
      final roomTemplateId = await _insertTemplate(db, '房间模板', [
        _dim('d5', null, '面积', 'number', '{}'),
      ]);
      // Fix refs to actual IDs
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d2')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$houseTemplateId"}')));
      await (db.update(db.templateDimensions)..where((td) => td.id.equals('d4')))
          .write(TemplateDimensionsCompanion(config: Value('{"ref_template_id":"$roomTemplateId"}')));

      final communityId = await _insertInstance(db, communityTemplateId, null, '华润二十四城', {'d1': '华润二十四城'});
      final houseId = await _insertInstance(db, houseTemplateId, communityId, '7栋-1203', {'d3': '南'});
      await _insertInstance(db, roomTemplateId, houseId, '主卧', {'d5': '20'});

      // Navigate to 首页
      await tester.tap(bottomNavItem('首页'));
      await tester.pumpAndSettle();

      // Verify parent instance is visible
      expect(find.text('华润二十四城'), findsOneWidget);

      // Swipe left on the instance card to trigger delete
      final cardFinder = find.widgetWithText(InstanceCard, '华润二十四城');
      await tester.fling(cardFinder, const Offset(-400, 0), 300);
      await tester.pumpAndSettle();

      // Verify confirm dialog appears with descendant count
      expect(find.text('确认删除'), findsOneWidget);
      expect(find.textContaining('将同时删除 2 个子实例'), findsOneWidget);

      // Tap delete
      await tester.tap(find.widgetWithText(TextButton, '删除'));
      await tester.pumpAndSettle();

      // Verify SnackBar and card disappearance
      await pumpUntilFound(tester, find.text('实例已删除'));
      await pumpUntilAbsent(tester, find.text('华润二十四城'));

      // Verify all instances are deleted from DB (cascade)
      final allInstances = await db.select(db.instances).get();
      expect(allInstances, isEmpty);
    });
```

- [ ] **Step 2: 运行 E2E 测试**

Run: `cd app && flutter test integration_test/e2e_test.dart`
Expected: 全部 6 个 E2E 测试通过（含新增的 Story 4.1）

- [ ] **Step 3: Commit**

```bash
cd app && git add integration_test/e2e_test.dart
git commit -m "test(e2e): add swipe-to-delete cascade test"
```

---

## Self-Review

### 1. Spec Coverage

| 需求 | 对应 Task |
|------|----------|
| 左滑删除卡片 | Task 4 |
| 递归级联删除所有子实例 | Task 1 |
| 删除前确认对话框 | Task 4 |
| 确认对话框提示子实例数量 | Task 2 + Task 4 |
| E2E 测试覆盖 | Task 5 |

全部需求已覆盖，无遗漏。

### 2. Placeholder Scan

- 无 "TBD"、"TODO"、"implement later"、"fill in details"。
- 无 "add appropriate error handling" / "add validation" 等模糊描述。
- 每个测试步骤包含完整代码。
- 每个任务包含精确的命令和预期输出。

### 3. Type Consistency

- `deleteInstance(String id)` 在 Repository、Cubit、UI 三层签名一致。
- `countDescendants(String id)` 返回 `Future<int>`，在 UI 中直接使用 `await` 结果。
- `confirmDismiss` 返回 `false`（不执行 Dismissible 动画），由 Stream 重建完成卡片移除，行为一致。

无类型不一致问题。
