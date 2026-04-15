# 模板编辑器体验改进设计文档

> 日期：2026-04-15  
> 范围：House Note App（Flutter）

---

## 1. 背景与目标

当前模板编辑器存在两个问题：
1. **单选维度配置不友好**：用户需要手动输入 JSON 字符串来定义单选项，学习成本高且容易出错。
2. **缩略图设置入口分散且不够直观**：用户无法直接在编辑模板时决定哪些字段显示在首页卡片上。

本次改进目标：
- 单选类型提供可视化 Tag 编辑器（输入框 + 添加按钮 + 可删除 Chip）。
- 在模板编辑器内直接勾选/取消勾选「显示在缩略图」，并支持调整顺序。
- 去掉用户可见的 JSON 配置输入。

---

## 2. 功能设计

### 2.1 单选选项可视化编辑

#### 交互流程
1. 用户进入「模板编辑器」→ 添加/编辑维度 → 类型选择「单选」。
2. 弹窗内出现选项输入区：
   - 一个 `TextField` 用于输入新选项文本。
   - 一个「添加」按钮（`IconButton` + 号）。
   - 下方 `Wrap` 区域展示已添加选项，每个选项渲染为 `Chip`，右侧带删除图标。
3. 点击「保存」后，选项列表在内存中被 `jsonEncode` 为 `{"options": [...]}` 写入 `config` 字段。

#### 数据结构（底层不变，上层隐藏）
- `TemplateDimensions.config` 仍存储 JSON 字符串，但仅作为内部序列化格式，用户不可见。
- 示例：`{"options": ["东", "南", "西", "北"]}`

#### 代码改动点
- `template_editor_screen.dart`：
  - `_showDimensionDialog` 中，当 `type == 'single_choice'` 时隐藏 `configController` 对应的输入框。
  - 替换为本地状态 `List<String> options` 和对应的增删 UI。
  - 保存前把 `options` encode 为 JSON 字符串传给 cubit。

---

### 2.2 缩略图显示字段集成到模板编辑器

#### 交互流程
1. 用户在模板编辑页面看到维度树 `DimensionTree`。
2. 每个维度节点右侧出现 visibility toggle 图标：
   - 已勾选：`Icons.visibility`
   - 未勾选：`Icons.visibility_off`
3. 点击图标切换该维度是否显示在缩略图。
4. 页面顶部（维度树上方）出现「缩略图显示字段」区域：
   - 以 `ReorderableWrap` 或简单 Chip 列表展示已选字段。
   - 支持上下箭头按钮调整顺序。
5. 保存模板时，缩略图字段配置与模板维度一并持久化。

#### 数据结构
复用现有 `TemplateThumbnailFields` 表：
- `id` (PK)
- `templateId`
- `dimensionId`
- `sortOrder`

#### 代码改动点

**State 层**
- `TemplateEditorState`：新增字段 `thumbnailDimensionIds: List<String>`。

**Cubit 层**
- `loadTemplate`：
  - 加载模板后，通过 `TemplateRepository.getThumbnailFields` 读取缩略图字段，初始化 `thumbnailDimensionIds` 并按 `sortOrder` 排序。
- `saveTemplate`：
  - 在保存 `TemplateDimensions` 之后，根据 `thumbnailDimensionIds` 生成 `TemplateThumbnailFieldsCompanion` 列表并写入数据库。
  - 先 `DELETE` 再 `INSERT`（覆盖式更新）。
- 新增方法：
  - `toggleThumbnailDimension(String dimensionId)`：在列表中增删 ID。
  - `reorderThumbnailDimensions(int oldIndex, int newIndex)`：调整列表顺序。

**UI 层**
- `template_editor_screen.dart`：
  - 在 `DimensionTree` 上方添加「缩略图显示字段」预览区（可排序 Chip 列表）。
  - 维度树节点右侧增加 visibility 图标按钮。
- `DimensionTree` / `dimension_tree.dart`：
  - 扩展回调参数，支持传入每个节点的「是否在缩略图中」状态和点击回调。

---

## 3. 不在本次范围内的功能

- **实例删除**：明确延后实现。
- **JSON 配置编辑**：完全从 UI 层移除，用户不再直接编辑 `config` 文本。

---

## 4. 验收标准

- [ ] 模板编辑器中，单选维度的配置区替换为 Tag 编辑器，用户无需输入 JSON。
- [ ] 单选选项的增删保存后，底层 `config` 正确存储为 `{"options": [...]}` 格式。
- [ ] 模板编辑页面的维度树中，每个维度项带有 visibility 图标，点击可切换缩略图显示状态。
- [ ] 已勾选的缩略图字段在页面上方以可排序列表展示，顺序调整后能正确保存。
- [ ] 保存模板时，缩略图字段配置与模板维度一起持久化到数据库。
- [ ] 实例列表页（`InstanceListScreen`）中的卡片能根据新的缩略图配置正确显示字段值。
