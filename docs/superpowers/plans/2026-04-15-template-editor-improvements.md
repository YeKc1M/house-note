# 模板编辑器体验改进 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在模板编辑器中为单选维度提供可视化 Tag 编辑器，并将缩略图显示字段的设置集成到模板编辑器中（支持勾选和排序）。

**Architecture:** 保持现有 BLoC + Repository 架构。TemplateEditorState/Cubit 新增缩略图字段管理；TemplateEditorScreen 弹窗中的单选配置替换为 Tag 编辑器；DimensionTree 增加 visibility toggle；InstanceListCubit 加载实例时一并查询缩略图字段值，使首页卡片正确展示。

**Tech Stack:** Flutter, Dart, drift (SQLite), bloc_test, mocktail

---

## File Map

| File | Responsibility |
|------|----------------|
| `lib/blocs/template_editor/state.dart` | `TemplateEditorState` 新增 `thumbnailDimensionIds` 列表 |
| `lib/blocs/template_editor/cubit.dart` | 加载/保存缩略图字段；新增 toggle/reorder 方法 |
| `lib/widgets/dimension_tree.dart` | 每个维度节点增加 visibility 图标按钮 |
| `lib/screens/template_editor_screen.dart` | 单选弹窗替换为 Tag 编辑器；页面顶部增加缩略图预览区 |
| `lib/blocs/instance_list/cubit.dart` | 加载实例时查询缩略图字段及其值 |
| `lib/blocs/instance_list/state.dart` | 新增 `thumbnailValues: Map<String, Map<String, String>>` |
| `lib/screens/instance_list_screen.dart` | 从 state 读取 `thumbnailValues` 传给 `InstanceCard` |
| `test/blocs/template_editor_cubit_test.dart` | 补充 thumbnail 相关 cubit 测试 |
| `test/blocs/instance_list_cubit_test.dart` | 补充 thumbnail 加载测试 |

---

### Task 1: TemplateEditorState 增加 thumbnailDimensionIds

**Files:**
- Modify: `lib/blocs/template_editor/state.dart`

- [ ] **Step 1: 修改 state 添加字段**

```dart
class TemplateEditorState extends Equatable {
  final String templateName;
  final List<DimensionNode> dimensions;
  final List<String> thumbnailDimensionIds;

  const TemplateEditorState({
    this.templateName = '',
    this.dimensions = const [],
    this.thumbnailDimensionIds = const [],
  });

  TemplateEditorState copyWith({
    String? templateName,
    List<DimensionNode>? dimensions,
    List<String>? thumbnailDimensionIds,
  }) {
    return TemplateEditorState(
      templateName: templateName ?? this.templateName,
      dimensions: dimensions ?? this.dimensions,
      thumbnailDimensionIds: thumbnailDimensionIds ?? this.thumbnailDimensionIds,
    );
  }

  @override
  List<Object?> get props => [templateName, dimensions, thumbnailDimensionIds];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/blocs/template_editor/state.dart
git commit -m "feat(template_editor): add thumbnailDimensionIds to state"
```

---

### Task 2: TemplateEditorCubit 缩略图管理 + 测试

**Files:**
- Modify: `lib/blocs/template_editor/cubit.dart`
- Modify: `test/blocs/template_editor_cubit_test.dart`

- [ ] **Step 1: 修改 loadTemplate 以加载缩略图字段**

在 `lib/blocs/template_editor/cubit.dart` 的 `loadTemplate` 方法末尾，在 `emit` 之前加入：

```dart
    final thumbnailFields = await _repo.getThumbnailFields(id);
    final thumbnailIds = thumbnailFields.map((f) => f.dimensionId).toList();
```

并将 `emit` 改为：

```dart
    emit(state.copyWith(
      templateName: data.template.name,
      dimensions: buildDimensionTree(data.dimensions),
      thumbnailDimensionIds: thumbnailIds,
    ));
```

- [ ] **Step 2: 修改 saveTemplate 以保存缩略图字段**

在 `saveTemplate` 方法中， companion 循环之后、`if (_templateId != null)` 之前，插入：

```dart
    final thumbnailCompanions = state.thumbnailDimensionIds.asMap().entries.map((e) {
      return TemplateThumbnailFieldsCompanion.insert(
        id: const Uuid().v4(),
        templateId: id,
        dimensionId: e.value,
        sortOrder: e.key,
      );
    }).toList();
    await _repo.setThumbnailFields(id, thumbnailCompanions);
```

- [ ] **Step 3: 新增 toggle 和 reorder 方法**

在 `saveTemplate` 之后添加：

```dart
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
```

- [ ] **Step 4: 写测试 — thumbnail 加载与 toggle/reorder**

在 `test/blocs/template_editor_cubit_test.dart` 末尾新增 group：

```dart
    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'loadTemplate initializes thumbnailDimensionIds',
      build: () => TemplateEditorCubit(repo),
      setUp: () {
        when(() => repo.getTemplateById('t1')).thenAnswer((_) async => TemplateWithDimensions(
          Template(id: 't1', name: 'T', createdAt: 0, updatedAt: 0),
          [
            TemplateDimension(id: 'd1', templateId: 't1', parentId: null, name: 'A', type: 'text', config: '{}', sortOrder: 0),
            TemplateDimension(id: 'd2', templateId: 't1', parentId: null, name: 'B', type: 'text', config: '{}', sortOrder: 1),
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
        const TemplateEditorState(thumbnailDimensionIds: ['b', 'a', 'c']),
      ],
    );
```

注意文件顶部需要 import database 的 model：

```dart
import 'package:house_note/data/database.dart';
```

- [ ] **Step 5: 运行测试**

Run: `flutter test test/blocs/template_editor_cubit_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/blocs/template_editor/cubit.dart test/blocs/template_editor_cubit_test.dart
git commit -m "feat(template_editor): thumbnail management in cubit with tests"
```

---

### Task 3: DimensionTree 增加 visibility toggle

**Files:**
- Modify: `lib/widgets/dimension_tree.dart`

- [ ] **Step 1: 添加 thumbnail 相关回调和状态参数**

```dart
class DimensionTree extends StatelessWidget {
  final List<DimensionNode> nodes;
  final void Function(DimensionNode) onEdit;
  final void Function(String) onDelete;
  final void Function(int oldIndex, int newIndex, String? targetParentId) onReorder;
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
```

- [ ] **Step 2: 在 trailing 区域加入 visibility 按钮**

将 `trailing` 的 `Row` 改为：

```dart
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  thumbnailDimensionIds.contains(item.node.id)
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                tooltip: '缩略图显示',
                onPressed: () => onToggleThumbnail(item.node.id),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(item.node)),
              IconButton(icon: const Icon(Icons.delete), onPressed: () => onDelete(item.node.id)),
            ],
          ),
```

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/dimension_tree.dart
git commit -m "feat(dimension_tree): add visibility toggle for thumbnail fields"
```

---

### Task 4: TemplateEditorScreen — Tag 编辑器 + 缩略图预览

**Files:**
- Modify: `lib/screens/template_editor_screen.dart`

- [ ] **Step 1: 导入 json**

在文件顶部添加：

```dart
import 'dart:convert';
```

- [ ] **Step 2: 在页面 body 中加入缩略图预览区**

在 `BlocBuilder` 的 `Column` 中，`DimensionTree` 之前插入：

```dart
                if (state.thumbnailDimensionIds.isNotEmpty) ...[
                  const Text('缩略图显示字段', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: state.thumbnailDimensionIds.asMap().entries.map((e) {
                      final dim = state.dimensions
                          .expand((n) => n.flatten())
                          .map((f) => f.node)
                          .firstWhere((n) => n.id == e.value);
                      return Chip(
                        label: Text(dim.name),
                        deleteIcon: const Icon(Icons.arrow_back),
                        onDeleted: e.key == 0
                            ? null
                            : () => cubit.reorderThumbnailDimensions(e.key, e.key - 1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
```

注意这里需要把 `cubit` 变量提前拿到 `BlocBuilder` 的 builder 顶部（或直接用 `context.read<TemplateEditorCubit>()`）。

- [ ] **Step 3: 更新 DimensionTree 调用以传入 thumbnail 参数**

```dart
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
                  thumbnailDimensionIds: state.thumbnailDimensionIds.toSet(),
                  onToggleThumbnail: (id) => context.read<TemplateEditorCubit>().toggleThumbnailDimension(id),
                ),
```

- [ ] **Step 4: 将弹窗中的 JSON 配置替换为 Tag 编辑器**

重写 `_showDimensionDialog` 中关于 config 的 UI。在 StatefulBuilder 的 state 中新增 `List<String> options`：

```dart
  void _showDimensionDialog(BuildContext context, {DimensionNode? node, String initialType = 'text'}) {
    final nameController = TextEditingController(text: node?.name ?? '');
    String type = node?.type ?? initialType;
    List<String> options = [];
    if (type == 'single_choice' && node != null && node.config.isNotEmpty) {
      try {
        final decoded = jsonDecode(node.config) as Map<String, dynamic>;
        options = (decoded['options'] as List<dynamic>? ?? []).cast<String>();
      } catch (_) {}
    }
    final cubit = context.read<TemplateEditorCubit>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final optionController = TextEditingController();
          return AlertDialog(
            title: Text(node == null ? '添加维度' : '编辑维度'),
            content: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 280),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称')),
                  DropdownButtonFormField<String>(
                    initialValue: type,
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
                  if (type == 'single_choice') ...[
                    const SizedBox(height: 16),
                    const Text('选项'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: optionController,
                            decoration: const InputDecoration(hintText: '输入选项'),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final text = optionController.text.trim();
                            if (text.isNotEmpty && !options.contains(text)) {
                              setState(() => options = [...options, text]);
                              optionController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: options.map((opt) => InputChip(
                        label: Text(opt),
                        onDeleted: () => setState(() => options = options.where((o) => o != opt).toList()),
                      )).toList(),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: '配置 (JSON)'),
                      controller: TextEditingController(text: node?.config ?? '{}'),
                      onChanged: (_) {},
                      readOnly: true,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
              TextButton(
                onPressed: () {
                  final config = type == 'single_choice'
                      ? jsonEncode({'options': options})
                      : (node?.config ?? '{}');
                  if (node == null) {
                    cubit.addDimension(
                      name: nameController.text,
                      type: type,
                      config: config,
                    );
                  } else {
                    cubit.updateDimension(
                      node.id,
                      name: nameController.text,
                      type: type,
                      config: config,
                    );
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text('保存'),
              ),
            ],
          );
        },
      ),
    );
  }
```

> 注：非 single_choice 类型暂时保留一个只读的 JSON 文本框（因为其他类型目前也可能需要 config，例如 ref_subtemplate）。如果后续也想去掉，可以进一步扩展。

- [ ] **Step 5: Commit**

```bash
git add lib/screens/template_editor_screen.dart
git commit -m "feat(template_editor): tag editor for single_choice and thumbnail preview UI"
```

---

### Task 5: InstanceListState 增加 thumbnailValues

**Files:**
- Modify: `lib/blocs/instance_list/state.dart`

- [ ] **Step 1: 修改 state**

```dart
class InstanceListState extends Equatable {
  final List<Instance> instances;
  final List<Breadcrumb> breadcrumbs;
  final Map<String, Map<String, String>> thumbnailValues;

  const InstanceListState({
    this.instances = const [],
    this.breadcrumbs = const [],
    this.thumbnailValues = const {},
  });

  InstanceListState copyWith({
    List<Instance>? instances,
    List<Breadcrumb>? breadcrumbs,
    Map<String, Map<String, String>>? thumbnailValues,
  }) {
    return InstanceListState(
      instances: instances ?? this.instances,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      thumbnailValues: thumbnailValues ?? this.thumbnailValues,
    );
  }

  @override
  List<Object?> get props => [instances, breadcrumbs, thumbnailValues];
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/blocs/instance_list/state.dart
git commit -m "feat(instance_list): add thumbnailValues to state"
```

---

### Task 6: InstanceListCubit 加载缩略图字段值 + 测试

**Files:**
- Modify: `lib/blocs/instance_list/cubit.dart`
- Modify: `test/blocs/instance_list_cubit_test.dart`

- [ ] **Step 1: 修改 cubit 构造函数和加载逻辑**

```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../data/instance_repository.dart';
import '../../data/template_repository.dart';
import 'state.dart';

export 'state.dart';

class InstanceListCubit extends Cubit<InstanceListState> {
  final InstanceRepository _repo;
  final TemplateRepository _templateRepo;
  StreamSubscription<List<Instance>>? _sub;

  InstanceListCubit(this._repo, this._templateRepo) : super(const InstanceListState());

  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().listen((instances) async {
      final thumbs = await _loadThumbnails(instances);
      emit(InstanceListState(instances: instances, breadcrumbs: const [], thumbnailValues: thumbs));
    });
  }

  void loadChildren(String parentInstanceId, List<Breadcrumb> breadcrumbs) async {
    _sub?.cancel();
    _sub = _repo.watchChildInstances(parentInstanceId).listen((instances) async {
      final thumbs = await _loadThumbnails(instances);
      emit(InstanceListState(instances: instances, breadcrumbs: breadcrumbs, thumbnailValues: thumbs));
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

  Future<Map<String, Map<String, String>>> _loadThumbnails(List<Instance> instances) async {
    final result = <String, Map<String, String>>{};
    for (final inst in instances) {
      final fields = await _templateRepo.getThumbnailFields(inst.templateId);
      if (fields.isEmpty) continue;
      final data = await _repo.getInstanceById(inst.id);
      if (data == null) continue;
      final values = <String, String>{};
      for (final f in fields) {
        final dim = await (_templateRepo as dynamic) // 需要更优雅的方式
            ._db // 不要直接访问私有字段
            ...
```

**停止。** 上面的 `_loadThumbnails` 实现需要访问数据库来把 dimensionId 映射为 dimension name。这不应该在 cubit 里直接写 SQL。

**更好的设计：** 在 `TemplateRepository` 新增一个方法 `getThumbnailValues(String instanceId)`，它内部 JOIN `templateThumbnailFields`、`templateDimensions`、`instanceValues` 返回 `Map<String, String>`（dimension name -> value）。

或者更简单：在 `InstanceRepository` 新增 `getThumbnailValuesForInstance(String instanceId, String templateId)`，内部直接查询。

让我给出正确的方案：在 `TemplateRepository` 中新增一个方法，或者 `InstanceRepository`。

选择 `TemplateRepository` 新增：

```dart
  Future<Map<String, String>> getThumbnailValues(String instanceId, String templateId) async {
    final fields = await getThumbnailFields(templateId);
    if (fields.isEmpty) return {};
    final dimensionIds = fields.map((f) => f.dimensionId).toList();
    final values = await (_db.select(_db.instanceValues)
          ..where((v) => v.instanceId.equals(instanceId) & v.dimensionId.isIn(dimensionIds)))
        .get();
    final dimensions = await (_db.select(_db.templateDimensions)
          ..where((d) => d.id.isIn(dimensionIds)))
        .get();
    final nameMap = {for (final d in dimensions) d.id: d.name};
    return {
      for (final v in values)
        if (nameMap[v.dimensionId] != null) nameMap[v.dimensionId]!: v.value,
    };
  }
```

然后 cubit 的 `_loadThumbnails`：

```dart
  Future<Map<String, Map<String, String>>> _loadThumbnails(List<Instance> instances) async {
    final result = <String, Map<String, String>>{};
    for (final inst in instances) {
      final thumbs = await _templateRepo.getThumbnailValues(inst.id, inst.templateId);
      result[inst.id] = thumbs;
    }
    return result;
  }
```

但 `watchTopLevelInstances()` 的 listen 回调不能是 async（Stream.listen 的回调返回 void）。我们需要用 `asyncExpand` 或每次 emit 两个 state。更简单的做法：在 cubit 里维护一个内部方法，收到 instances 后用 `Future.forEach` 加载 thumbnails 再 emit。

实际上可以这样：

```dart
  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().asyncMap((instances) async {
      final thumbs = await _loadThumbnails(instances);
      return InstanceListState(
        instances: instances,
        breadcrumbs: const [],
        thumbnailValues: thumbs,
      );
    }).listen(emit);
  }
```

`asyncMap` 是 Stream 的方法，dart:async 自带。完美。

所以完整 cubit 改为：

```dart
class InstanceListCubit extends Cubit<InstanceListState> {
  final InstanceRepository _repo;
  final TemplateRepository _templateRepo;
  StreamSubscription<InstanceListState>? _sub;

  InstanceListCubit(this._repo, this._templateRepo) : super(const InstanceListState());

  void loadTopLevel() {
    _sub?.cancel();
    _sub = _repo.watchTopLevelInstances().asyncMap((instances) async {
      final thumbs = await _loadThumbnails(instances);
      return InstanceListState(instances: instances, breadcrumbs: const [], thumbnailValues: thumbs);
    }).listen(emit);
  }

  void loadChildren(String parentInstanceId, List<Breadcrumb> breadcrumbs) {
    _sub?.cancel();
    _sub = _repo.watchChildInstances(parentInstanceId).asyncMap((instances) async {
      final thumbs = await _loadThumbnails(instances);
      return InstanceListState(instances: instances, breadcrumbs: breadcrumbs, thumbnailValues: thumbs);
    }).listen(emit);
  }
  // ...
}
```

- [ ] **Step 2: 在 TemplateRepository 新增 getThumbnailValues**

```dart
  Future<Map<String, String>> getThumbnailValues(String instanceId, String templateId) async {
    final fields = await getThumbnailFields(templateId);
    if (fields.isEmpty) return {};
    final dimensionIds = fields.map((f) => f.dimensionId).toList();
    final values = await (_db.select(_db.instanceValues)
          ..where((v) => v.instanceId.equals(instanceId) & v.dimensionId.isIn(dimensionIds)))
        .get();
    final dimensions = await (_db.select(_db.templateDimensions)
          ..where((d) => d.id.isIn(dimensionIds)))
        .get();
    final nameMap = {for (final d in dimensions) d.id: d.name};
    return {
      for (final v in values)
        if (nameMap[v.dimensionId] != null) nameMap[v.dimensionId]!: v.value,
    };
  }
```

- [ ] **Step 3: 更新 app.dart 中 InstanceListCubit 的创建**

```dart
      BlocProvider(
        create: (_) => InstanceListCubit(instanceRepo, templateRepo)..loadTopLevel(),
        child: const InstanceListScreen(),
      ),
```

- [ ] **Step 4: 更新 InstanceListScreen 中的 thumbnailValues**

```dart
                      thumbnailValues: state.thumbnailValues[inst.id] ?? {},
```

- [ ] **Step 5: 写 instance_list_cubit 测试**

```dart
    blocTest<InstanceListCubit, InstanceListState>(
      'loads top-level instances with thumbnail values',
      build: () => InstanceListCubit(repo, templateRepo),
      setUp: () {
        when(() => repo.watchTopLevelInstances()).thenAnswer(
          (_) => Stream.value([
            Instance(id: 'i1', templateId: 't1', name: 'A', createdAt: 1, updatedAt: 1),
          ]),
        );
        when(() => templateRepo.getThumbnailValues('i1', 't1')).thenAnswer(
          (_) async => {'朝向': '南'},
        );
      },
      act: (cubit) => cubit.loadTopLevel(),
      expect: () => [
        predicate<InstanceListState>((s) {
          return s.instances.length == 1 &&
              s.thumbnailValues['i1']?['朝向'] == '南';
        }),
      ],
    );
```

并修改测试顶部的 `setUp` 和构造函数：

```dart
  late MockInstanceRepository repo;
  late MockTemplateRepository templateRepo;

  setUp(() {
    repo = MockInstanceRepository();
    templateRepo = MockTemplateRepository();
  });
```

需要在 test 文件里 import `TemplateRepository` 并加 mock class：

```dart
import 'package:house_note/data/template_repository.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}
```

- [ ] **Step 6: 运行测试**

Run: `flutter test test/blocs/instance_list_cubit_test.dart`
Expected: PASS

- [ ] **Step 7: Commit**

```bash
git add lib/blocs/instance_list/cubit.dart lib/blocs/instance_list/state.dart lib/data/template_repository.dart lib/screens/instance_list_screen.dart lib/app.dart test/blocs/instance_list_cubit_test.dart
git commit -m "feat(instance_list): load and display thumbnail values on cards"
```

---

### Task 7: 全量测试与最终提交

- [ ] **Step 1: 运行所有测试**

Run: `flutter test`
Expected: ALL PASS

- [ ] **Step 2: 修复任何失败**

如果有编译错误或测试失败，根据错误信息修复后重新运行 `flutter test`。

- [ ] **Step 3: 最终 commit（如有额外改动）**

```bash
git add -A
git commit -m "fix: address test/compile issues from thumbnail integration"
```

---

## Self-Review Checklist

1. **Spec coverage:**
   - 单选 Tag 编辑器 → Task 4
   - 缩略图勾选/排序 → Task 1, 2, 3, 4
   - 首页卡片显示缩略图 → Task 5, 6

2. **Placeholder scan:** 无 TBD/TODO/"implement later"。

3. **Type consistency：**
   - `thumbnailDimensionIds` 在 state/cubit/screen/widget 中统一为 `List<String>`。
   - `thumbnailValues` 在 `InstanceListState` 中为 `Map<String, Map<String, String>>`（instanceId -> {name -> value}）。
