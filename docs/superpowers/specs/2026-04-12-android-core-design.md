# House Note — Subproject 1: Android Local Core Application Design

**Date:** 2026-04-12  
**Scope:** Epic 1-3 (Template management, Instance creation/editing, Hierarchical browsing, Thumbnail customization) + Offline constraint  
**Platform:** Android (Flutter), extensible to Windows Desktop later  
**Corresponding PRD:** `house-note-prd.md` v1.0  
**Corresponding User Stories:** Story 1.1, 1.2, 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 6.1

---

## 1. Technology Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| Framework | Flutter | Single codebase covers Android now and Windows Desktop later. |
| State Management | `flutter_bloc` | Predictable, testable, scales with nested UI states. |
| Local Persistence | Drift (SQLite) | Relational model naturally fits templates, nested dimensions, cross-template references, and instance deviations. |
| Internal Storage Format | SQLite DB | **Not limited to YAML.** YAML is treated strictly as an import/export translation layer. |
| Tree UI | Custom `ReorderableListView` with indentation | Full control over drag-and-drop and nesting depth (no hard limit). |

---

## 2. Navigation Architecture

Bottom 3-tab navigation:

- **首页 (Home)** — Hierarchical instance browsing + FAB for creating instances.
- **模板 (Templates)** — Template list → Template editor (tree drag-and-drop + thumbnail field config).
- **设置 (Settings)** — Data export, data import, LAN sync toggle, about.

Thumbnail configuration lives inside the **Template Editor** (not Settings) because it is template-scoped.

---

## 3. Data Model (Drift/SQLite)

### 3.1 `templates`
Stores the root definition of a template.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `name` | TEXT | User-defined template name |
| `created_at` | INTEGER | Unix ms |
| `updated_at` | INTEGER | Unix ms |

### 3.2 `template_dimensions`
Tree table representing dimensions inside a template. Self-referencing `parent_id` enables unlimited nesting.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `template_id` | TEXT | FK → `templates.id`, CASCADE DELETE |
| `parent_id` | TEXT \| NULL | FK → `template_dimensions.id`. NULL = root level. |
| `name` | TEXT | Dimension display name |
| `type` | TEXT | `text` / `single_choice` / `boolean` / `number` / `group` / `ref_subtemplate` |
| `config` | TEXT (JSON) | Type-specific config: `{options: [...]}` for single_choice; `{ref_template_id: ...}` for ref_subtemplate. Empty object `{}` for others. |
| `sort_order` | INTEGER | Display order among siblings |

**Constraints:**
- `group` and `ref_subtemplate` dimensions may have children (for `group`) or reference another template (for `ref_subtemplate`).
- No hardcoded depth limit enforced by the application.

### 3.3 `instances`
Represents a concrete record (e.g., a specific residential compound or apartment).
Self-referencing `parent_instance_id` builds the instance hierarchy that mirrors template `ref_subtemplate` relationships.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `template_id` | TEXT | FK → `templates.id` |
| `parent_instance_id` | TEXT \| NULL | FK → `instances.id`. NULL = top-level instance. |
| `name` | TEXT | User-given instance name (e.g., "华润二十四城") |
| `created_at` | INTEGER | Unix ms |
| `updated_at` | INTEGER | Unix ms |

### 3.4 `instance_values`
Stores the actual values filled in for each template dimension of an instance.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `instance_id` | TEXT | FK → `instances.id`, CASCADE DELETE |
| `dimension_id` | TEXT | FK → `template_dimensions.id` |
| `value` | TEXT | Serialized value. For boolean: `"true"` / `"false"`. For number: numeric string. For single_choice: selected option string. |

**Constraint:** Composite unique on `(instance_id, dimension_id)`.

### 3.5 `instance_custom_fields`
Per-instance fields that were NOT defined in the template. Scoped strictly to the instance.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `instance_id` | TEXT | FK → `instances.id`, CASCADE DELETE |
| `name` | TEXT | Field label |
| `type` | TEXT | `text` / `single_choice` / `boolean` / `number` |
| `value` | TEXT | Serialized value |
| `config` | TEXT (JSON) | For `single_choice`, stores `{options: [...]}` |

### 3.6 `instance_hidden_dimensions`
Tracks which template-defined dimensions are hidden for a specific instance.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `instance_id` | TEXT | FK → `instances.id`, CASCADE DELETE |
| `dimension_id` | TEXT | FK → `template_dimensions.id` |

**Constraint:** Composite unique on `(instance_id, dimension_id)`.

### 3.7 `template_thumbnail_fields`
Configures which fields appear on instance cards for a given template.

| Column | Type | Notes |
|--------|------|-------|
| `id` | TEXT (UUID) | Primary key |
| `template_id` | TEXT | FK → `templates.id`, CASCADE DELETE |
| `dimension_id` | TEXT | FK → `template_dimensions.id` |
| `sort_order` | INTEGER | Display priority on card |

---

## 4. Screen Designs

### 4.1 首页 (Instance List / Hierarchy Browser)

**Behavior:**
- Root view displays all top-level instances (`parent_instance_id IS NULL`) as cards.
- Tapping a card drills down to the next level (the children instances created under the tapped instance's `ref_subtemplate` dimension).
- Breadcrumb trail is shown at the top: `全部 > 华润二十四城 > 7栋-1203`.
- Tapping a breadcrumb segment jumps back to that level.

**Card Content:**
- Title: `instance.name`
- Subtitle chips: values of dimensions configured in `template_thumbnail_fields` for the instance's template.
- If the tapped instance's template contains a `ref_subtemplate` dimension, the card also shows a count of child instances (e.g., "3 套房子").

**FAB:**
- Floating Action Button (`+`) in the bottom-right corner.
- If at root: creates a top-level instance. User must first pick a top-level template.
- If inside a parent instance: the FAB creates a child instance. The app looks up the `ref_subtemplate` dimension(s) on the parent template:
  - If exactly one `ref_subtemplate` exists, use it directly.
  - If multiple exist, show a picker: "选择要新建的子类型".

---

### 4.2 模板管理 (Template List)

**Behavior:**
- List of all templates with name and last-updated time.
- Tap to edit; long-press or trailing icon to delete (with confirmation if instances already use the template).
- "新建模板" FAB at bottom-right.

---

### 4.3 模板编辑页 (Template Editor)

**Structure:**
- **AppBar:** Template name (editable inline or in a header field).
- **Dimension Tree:** A vertically draggable list where each row represents a dimension.
  - Drag handle (`≡`) on the left.
  - Indentation visualizes nesting depth.
  - Tap a row to open a bottom sheet for editing: `name`, `type`, `config`.
  - Swipe or trailing icon to delete a dimension.
- **Action Buttons:**
  - `+ 添加维度项` — adds a leaf dimension at the end.
  - `+ 添加子维度组` — adds a `group` type dimension at the end.
- **Thumbnail Config Section** (at the bottom):
  - Title: "列表卡片缩略图"
  - Subtitle: "选择要在实例列表卡片上显示的字段"
  - Multi-select chip list of all non-group leaf dimensions in this template.
  - Selected chips are persisted to `template_thumbnail_fields`.

**Drag-and-Drop Nesting Rules:**
- Dropping an item onto another item with `type = 'group'` makes it a child of that group.
- Dropping an item between two items at the same visual indent level makes it a sibling at that level.
- No hardcoded depth limit. UI indentation simply increases by a fixed offset per level.

---

### 4.4 实例编辑页 (Instance Editor)

**Structure:**
- **AppBar:** Instance name (editable).
- **Form Body:** Renders dimensions dynamically based on `template_dimensions` structure:
  - `text` → text field
  - `number` → number keyboard field
  - `boolean` → SwitchListTile
  - `single_choice` → horizontal ChoiceChips
  - `group` → visual grouping container (non-editable itself)
  - `ref_subtemplate` → not rendered as an editable field in the instance editor (it is the structural bridge for hierarchy)
- **Per-Field Actions:**
  - Every template-defined field row has a trailing "隐藏" text button.
  - Tapping it inserts a record into `instance_hidden_dimensions` and removes the field from the form UI immediately.
- **Custom Fields Section:**
  - After all template fields, custom fields are rendered inside a dashed-border card with a subtle "（自定义字段）" label.
- **Bottom Action Bar:**
  - `+ 添加自定义字段` — opens a dialog to define `name`, `type`, [options if applicable], and initial `value`.
  - `恢复隐藏字段` — opens a dialog listing currently hidden template fields for this instance; tapping "恢复显示" deletes the corresponding `instance_hidden_dimensions` record and re-renders the field with its last known value (or empty if none).

**Save Behavior:**
- "保存实例" persists `instance_values` (upsert per dimension). Empty or untouched fields are still stored with an empty string value so that "恢复显示" can show the field even if it had no value.

---

### 4.5 设置页 (Settings)

**Sections:**
1. **数据管理**
   - "导出全部数据" → generates `house-note-export.yaml` and triggers system share sheet.
   - "导入数据" → file picker for YAML, then conflict-resolution flow (see Subproject 2 spec for details).
2. **局域网同步**
   - Toggle switch to enable LAN sync server.
   - Displays current IP address and port when active.
3. **关于**
   - App version, attribution.

---

## 5. State Management (BLoC)

Recommended cubits/blocs:

- `TemplateListCubit` — loads, filters, deletes templates.
- `TemplateEditorCubit` — manages the in-memory tree of dimensions during editing, handles drag-and-drop reordering, and persists to Drift on save.
- `InstanceListCubit` — loads instances for the current hierarchy level, handles breadcrumb navigation state.
- `InstanceEditorCubit` — loads template structure + instance values + custom fields + hidden dimensions, manages form state, persists on save.
- `SettingsCubit` — manages export/import/ LAN sync toggles.

---

## 6. Error Handling & Edge Cases

| Scenario | Behavior |
|----------|----------|
| Delete template with existing instances | Show confirmation: "该模板下还有 N 个实例，删除将一并清除。确认删除？" If confirmed, CASCADE DELETE handles cleanup. |
| Change a dimension's type in template | Existing `instance_values` are left as-is. The UI parses what it can; invalid values render as empty until user re-saves. No automatic migration. |
| Hide all template fields in an instance | Allowed. The form body shows only custom fields (if any) and a placeholder message: "所有模板字段已隐藏". |
| Root-level `ref_subtemplate` with no target selected | Not possible at schema level: `ref_subtemplate` config must contain a valid `ref_template_id` before saving the template. |
| Circular template references | Guard against creating A→B→A loops at the save-validation layer in `TemplateEditorCubit`. |

---

## 7. Testing Strategy

- **Unit tests:** Cubit state transitions, drag-and-drop tree reordering logic, YAML serialization round-trips.
- **Widget tests:** Template editor render, instance form field type mapping, breadcrumb navigation.
- **E2E tests (mobile-mcp):** Execute the Gherkin stories in `docs/e2e-user-stories.md` on the Android emulator after Subproject 1 completion. This will validate the happy paths for Epic 1-3.

---

## 8. Deferred to Later Subprojects

The following are **explicitly out of scope** for Subproject 1 and will be covered in subsequent specs:

- YAML import/export implementation details (Subproject 2)
- Conflict resolution UI for import (Subproject 2)
- LAN sync server / IP discovery / Windows client pairing (Subproject 3)
- Full mobile-mcp E2E automation harness (Subproject 4)

---

## 9. Summary of Key Decisions

1. **Flutter + Drift (SQLite)** for cross-platform potential and relational data integrity.
2. **Internal storage = SQLite DB.** YAML is reserved for import/export translation only.
3. **Bottom 3-tab navigation** with thumbnail config inside Template Editor.
4. **Tree drag-and-drop** for template dimensions, with no hardcoded nesting depth limit.
5. **Inline "隐藏" actions** on instance editor fields plus bottom-bar buttons for custom fields and restoring hidden fields.
6. **Self-referencing tables** (`template_dimensions.parent_id`, `instances.parent_instance_id`) model both template nesting and instance hierarchy.
