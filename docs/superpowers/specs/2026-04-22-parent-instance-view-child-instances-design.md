# 父实例编辑页查看和编辑子实例 — 设计文档

## 日期
2026-04-22

## 背景

当前实例编辑页（`InstanceEditorScreen`）遇到 `ref_subtemplate` 类型的维度时会直接跳过不渲染。这意味着在编辑父实例（如"华润二十四城"）时，完全看不到也操作不了其下的子实例（如"7栋-1203"）。用户希望在父实例编辑页中能够查看和编辑子实例。

## 目标

- 在父实例编辑页中，按 `ref_subtemplate` 维度分组展示对应的子实例卡片列表
- 点击子实例卡片可跳转到独立编辑页进行编辑
- 在父实例编辑页中可直接新建子实例
- 编辑父实例字段或子实例字段后，页面状态保持一致

---

## 1. UI 交互设计

在 `InstanceEditorScreen` 中，`ref_subtemplate` 维度不再被跳过，而是渲染为一个带标题的 Card 区域：

```
┌─────────────────────────────┐
│ 房子列表                     │  ← 维度名称作为 Card 标题
├─────────────────────────────┤
│ ┌─────┐  ┌─────┐           │
│ │7栋- │  │8栋- │  ...      │  ← 子实例卡片（复用 InstanceCard）
│ │1203 │  │1502 │            │     显示名称 + 缩略图值
│ └─────┘  └─────┘           │
│ [ + 添加子实例 ]             │  ← 按钮
└─────────────────────────────┘
```

**多种子实例分组：** 若模板包含多个 `ref_subtemplate` 维度（如"房子列表"和"配套设施"），每个维度独立渲染一个 Card 区域，只显示属于该维度的子实例。

**点击行为：**
- **点击子实例卡片** → `Navigator.pushNamed(context, '/instanceEditor', arguments: {'instanceId': childId})`
- **点击"添加子实例"** → 若维度引用单个模板则直接新建；若引用多个模板则弹出选择框，再导航到 `/instanceEditor?templateId=xxx&parentInstanceId=currentId`
- **从子实例编辑页返回** → 父实例编辑页自动刷新该维度下的子实例列表

**空状态：** 某维度下暂无子实例时，Card 内显示"暂无子实例"文案，仍然保留"添加"按钮。

---

## 2. 数据流与状态管理

### State 扩展

```dart
class InstanceEditorState extends Equatable {
  // ... existing fields ...

  /// 按维度 ID 分组的子实例摘要
  /// Map<dimensionId, List<ChildInstanceSummary>>
  final Map<String, List<ChildInstanceSummary>> childInstances;
}

class ChildInstanceSummary {
  final String id;
  final String name;
  final String templateId;
  final Map<String, String> thumbnailValues;
}
```

### Cubit 新增方法

- `loadChildInstances(String parentInstanceId)` — 在 `loadInstance` 完成后调用：
  1. 获取当前模板的所有 `ref_subtemplate` 维度（含维度 ID 和引用的模板 ID）
  2. 查询 `parentInstanceId = currentId` 的所有子实例
  3. 按子实例的 `templateId` 匹配到对应的维度，分组放入 state
  4. 对每个子实例，通过 `TemplateRepository.getThumbnailValues()` 加载缩略图值
- `refreshChildInstances()` — 子实例编辑页返回时触发，重新执行上述查询

---

## 3. 路由与返回刷新机制

采用 **Navigator.pop 返回值检测** 方案，无生命周期监听开销：

```dart
// 父实例编辑页：点击子实例卡片或"添加"按钮
final result = await Navigator.pushNamed(
  context,
  '/instanceEditor',
  arguments: {/* instanceId 或 templateId + parentInstanceId */},
);
if (result == true && mounted) {
  context.read<InstanceEditorCubit>().refreshChildInstances();
}
```

```dart
// 子实例编辑页：保存成功后返回
await cubit.saveInstance();
if (mounted) {
  messenger.showSnackBar(const SnackBar(content: Text('实例保存成功')));
  navigator.pop(true); // 传 true 表示有变更，触发父页刷新
}
```

**多模板选择逻辑：** 复用现有 `instance_list_screen.dart` 中的选择逻辑——单模板时直接取模板 ID 导航，多模板时弹出 `SimpleDialog` 让用户选择后再导航。

---

## 4. 测试策略

### 单元测试（Cubit）

- `loadInstance` 加载父实例时，同时正确填充 `childInstances` 分组数据
- `refreshChildInstances` 重新加载后能正确更新 state

### Widget 测试

- 父实例编辑页中，`ref_subtemplate` 维度区域正确渲染子实例卡片列表
- 点击卡片触发导航到 `/instanceEditor`（带 `instanceId`）
- 点击"添加"触发导航（带 `templateId` + `parentInstanceId`）
- 空状态显示"暂无子实例"
- 父实例字段编辑后保存，子实例列表区域不受影响（不丢失、不闪烁）
- 子实例卡片列表的渲染不干扰父实例维度的输入/隐藏/恢复逻辑

### E2E 测试

#### 用例 1：编辑子实例（从父实例编辑页跳转）

```gherkin
Scenario: 在父实例编辑页点击子实例卡片并编辑
Given 系统中已存在"小区模板"，包含"房子列表"维度引用"房子模板"
And 已存在小区实例"华润二十四城"，其下有房子实例"7栋-1203"
When 用户从首页点击进入"华润二十四城"的编辑页
Then 页面中"房子列表"区域显示子实例卡片"7栋-1203"
When 用户点击"7栋-1203"卡片
Then 进入该房子实例的编辑页
When 用户修改"朝向"为"东南"并保存
Then 系统提示"实例保存成功"
And 自动返回"华润二十四城"编辑页
And "房子列表"区域仍显示"7栋-1203"
```

#### 用例 2：编辑父实例（父字段修改不影响子实例列表）

```gherkin
Scenario: 在父实例编辑页编辑父字段后子实例仍正常显示
Given 系统中已存在"小区模板"，包含"房子列表"维度引用"房子模板"
And 已存在小区实例"华润二十四城"，其下有房子实例"7栋-1203"
When 用户进入"华润二十四城"的编辑页
And 用户在"位置"字段中修改为"成华区双庆路6号"
And 用户点击「保存实例」
Then 系统提示"实例保存成功"
And 页面中"房子列表"区域仍正确显示"7栋-1203"
And 返回首页后重新进入编辑页，"位置"值仍为"成华区双庆路6号"
```

---

## 5. 关键文件变更

| 文件 | 变更 |
|------|------|
| `lib/blocs/instance_editor/state.dart` | 新增 `ChildInstanceSummary`，`InstanceEditorState` 增加 `childInstances` 字段 |
| `lib/blocs/instance_editor/cubit.dart` | 新增 `loadChildInstances()`、`refreshChildInstances()`，在 `loadInstance` 中调用 |
| `lib/screens/instance_editor_screen.dart` | `_buildDimensionFields` 中处理 `ref_subtemplate` 类型，渲染子实例卡片区域和"添加"按钮 |
| `integration_test/e2e_test.dart` | 新增上述两个 E2E 用例 |

---

## 6. 边界情况

- **父实例为新建状态（无 ID）**：此时 `ref_subtemplate` 维度区域不显示子实例列表（因为子实例需要 `parentInstanceId`），仅显示"请先保存父实例后再添加子实例"提示。
- **模板变更后子实例模板 ID 不匹配**：如果模板编辑后移除了某个 `ref_subtemplate` 维度，已存在的子实例在父编辑页中将不再显示（因为它们没有对应的维度来挂载）。这是预期行为，子实例本身数据不丢失，仍可在列表页中访问。
- **深层嵌套**：子实例本身也可能有 `ref_subtemplate` 维度，在其编辑页中同样会递归显示孙实例，无层级限制。
