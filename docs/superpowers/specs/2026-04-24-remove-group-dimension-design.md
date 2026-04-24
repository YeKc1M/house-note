# 删除子维度组（group）功能设计

## 背景

当前模板支持 `group`（子维度组）维度类型，允许维度项无限嵌套。实际使用体验不佳，决定彻底移除该功能。所有维度项恢复为扁平列表，不再有嵌套层次。

## 前提条件

- 当前没有任何用户数据，无需数据迁移
- `ref_subtemplate` 维度的子实例关系通过 `Instances.parentInstanceId` 维护，与 `group` 无关

## 改动范围

### 1. 数据层

**`lib/data/tables.dart`**
- 从 `TemplateDimensions` 表中删除 `parentId` 字段

**`lib/data/database.g.dart`**
- 重新运行 `dart run build_runner build` 生成

### 2. 模型层

**`lib/models/dimension_node.dart`**
- 删除 `FlattenedDimension` 类
- 从 `DimensionNode` 中删除 `children`、`parentId` 字段
- 删除 `flatten()` 方法
- `copyWith` 中删除 `parentId` 和 `children` 参数

### 3. 工具层

**`lib/utils/dimension_tree_builder.dart`**
- 删除此文件。所有维度直接是扁平列表，不再需要树构建。

### 4. Bloc 层

**`lib/blocs/template_editor/cubit.dart`**
- `addDimension`：删除 `parentId` 参数
- `moveDimension`：删除 `targetParentId` 参数，只剩扁平列表重排
- `saveTemplate`：删除 `_flatten` 和 `parentCounters` 逻辑，直接按列表索引设置 `sortOrder`
- 删除树操作辅助函数：`_flatten`、`_insertIntoParent`、`_insertIntoParentAtIndex`
- `_removeFromTree` 和 `_updateInTree` 简化为扁平列表操作（`List.where` / `List.map`）

**`lib/blocs/instance_editor/cubit.dart`**
- `initNewInstance` / `loadInstance`：移除 `buildDimensionTree` 调用，直接将 `template.dimensions` 映射为扁平 `DimensionNode` 列表

### 5. UI 层

**`lib/screens/template_editor_screen.dart`**
- 删除「添加子维度组」按钮
- 从维度类型下拉中删除「子维度组」选项

**`lib/screens/instance_editor_screen.dart`**
- 删除 `group` 类型的 Card 渲染逻辑
- 删除 `_allChildrenHidden` 方法（不再有子节点）

**`lib/widgets/dimension_tree.dart`**
- `onReorder` 回调签名简化为 `(int oldIndex, int newIndex)`
- 删除基于 `group` 的拖拽嵌套判断
- 删除 `depth` 缩进（所有项左对齐）

### 6. 测试层

**`test/models/dimension_node_test.dart`**
- 删除 `flatten`、多级树、`parentId` 相关测试
- 保留基本的 `copyWith` 和 `Equatable` 测试

**`test/blocs/template_editor_cubit_test.dart`**
- 删除 group 相关测试（移入 group、嵌套 group 添加等）
- 简化 `moveDimension` 测试为扁平重排

**`integration_test/e2e_test.dart`**
- 修改 Story 1.1：删除「通勤」子维度组创建步骤，把「是否靠近地铁站」和「上班通勤」改为根级维度

**其他测试**
- 修复因 `DimensionNode` 构造函数签名变化导致的编译失败

## 验收标准

1. 模板编辑器中不再显示「添加子维度组」按钮和「子维度组」类型选项
2. 实例编辑器中不再渲染 group 类型的 Card
3. 维度拖拽排序只支持扁平重排，不再有嵌套行为
4. 所有单元测试和 widget 测试通过
5. E2E 测试通过
6. `flutter analyze` 无错误
