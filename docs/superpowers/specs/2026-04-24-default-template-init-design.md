# First-Install Default Template Initialization — Design

## Overview

When House Note is first installed and launched, the app automatically seeds four default templates (小区模板, 房子模板, 客厅模板, 卧室模板) so users can start recording rental viewing notes immediately without manually creating templates from scratch.

Users may edit or delete these templates afterward; their changes persist across app restarts. The initialization runs only once.

---

## Goals

- Eliminate the blank-slate problem on first launch.
- Provide templates that match the PRD's core use case (community → house → room hierarchy).
- Allow users to freely edit or delete default templates.
- Support manual template restoration via Settings for testing.

---

## Non-Goals

- Do not recreate deleted templates on subsequent launches.
- Do not pre-configure thumbnail fields for default templates.
- Do not create sample/demo instances.

---

## Architecture

### New Components

| Component | Purpose |
|-----------|---------|
| `AppSettings` table | Key-value store in Drift for tracking `default_templates_initialized`. |
| `DefaultTemplateLoader` | Service class that reads the YAML asset and inserts templates via `TemplateRepository`. |
| `assets/default_templates.yaml` | Flutter asset containing the structured template definitions. |

### Schema Change

Bump `AppDatabase.schemaVersion` from `1` → `2`. Migration creates the `AppSettings` table:

```dart
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

---

## First-Run Detection

On app startup, `DefaultTemplateLoader.loadIfNeeded()` queries `AppSettings` for key `default_templates_initialized`.

- **Absent** → run initialization, insert templates, set flag.
- **Present** → skip silently.

This ensures deletion is permanent: even if a user deletes all templates, the flag stays set, so re-seeding never happens again.

---

## YAML Asset Structure

`assets/default_templates.yaml` defines four templates with their dimensions. Templates are processed in list order so that subtemplates exist before parent templates reference them.

```yaml
templates:
  - id: community_template
    name: 小区模板
    dimensions:
      - name: 地址
        type: text
      - name: 建成年份
        type: number
      - name: 通勤
        type: text
      - name: 周边
        type: text
      - name: 物业费
        type: number
      - name: 房子
        type: ref_subtemplate
        ref_template_id: house_template

  - id: house_template
    name: 房子模板
    dimensions:
      - name: 房租
        type: number
      - name: 梯户
        type: text
      - name: 户型
        type: text
      - name: 民水民电
        type: single_choice
        options: [是, 否]
      - name: 安静
        type: single_choice
        options: [是, 否]
      - name: 邻居
        type: text
      - name: 电梯
        type: single_choice
        options: [有, 无]
      - name: 能否听到电梯声音
        type: single_choice
        options: [是, 否]
      - name: 客厅
        type: ref_subtemplate
        ref_template_id: living_room_template
      - name: 卧室
        type: ref_subtemplate
        ref_template_id: bedroom_template
      - name: 洗衣机状态
        type: text
      - name: 微波炉状态
        type: text

  - id: living_room_template
    name: 客厅模板
    dimensions:
      - name: 电视状态
        type: text
      - name: 空调状态
        type: text

  - id: bedroom_template
    name: 卧室模板
    dimensions:
      - name: 空调状态
        type: text
      - name: 床垫状态
        type: text
```

### YAML → App Type Mapping

| YAML `type` | App `type` | Config JSON |
|-------------|-----------|-------------|
| `text` | `text` | `{}` |
| `number` | `number` | `{}` |
| `single_choice` | `single_choice` | `{"options": ["opt1", "opt2"]}` |
| `ref_subtemplate` | `ref_subtemplate` | `{"ref_template_id": "<resolved-uuid>"}` |

Note: the app does **not** have a `boolean` dimension type. All binary choices are modeled as `single_choice` with two options.

---

## Initialization Flow

1. `main()` creates `AppDatabase()`. Drift opens the DB and runs migrations (creates `AppSettings` if v1 → v2).
2. `main()` calls `await DefaultTemplateLoader(db).loadIfNeeded()`.
3. Inside `loadIfNeeded()`:
   - Query `AppSettings` for `default_templates_initialized`.
   - If not set:
     a. Load `assets/default_templates.yaml` via `rootBundle.loadString()`.
     b. Parse YAML with `package:yaml`.
     c. Maintain a map of YAML `id` → generated UUID.
     d. For each template in order:
        - Generate a UUID for the template.
        - Build `TemplatesCompanion` with current timestamp.
        - Build `List<TemplateDimensionsCompanion>`:
          - For `ref_subtemplate`, look up the referenced template's generated UUID from the map.
          - Build `config` string according to the type mapping table above.
          - Assign `sortOrder` sequentially (0, 1, 2, ...).
        - Call `TemplateRepository.insertTemplate()`.
     e. Insert `AppSettings` record: `key = 'default_templates_initialized'`, `value = 'true'`.
4. `runApp(HouseNoteApp(...))` proceeds normally.

---

## Manual Restore (Settings)

A **"恢复默认模板"** button in `SettingsScreen` enables testing the seeding logic without reinstalling the app.

**Behavior:**
- Calls `await DefaultTemplateLoader(db).restoreDefaults()`.
- Uses the same YAML parsing and insertion logic.
- For each template: checks if a template with that exact **name** already exists in the DB.
  - **Exists** → skip (preserves user edits and deletions).
  - **Missing** → create it with its dimensions.
- Shows a `SnackBar` with the result, e.g. `"已恢复 1 个模板"` or `"所有默认模板已存在，无需恢复"`.

**Why check by name:** Avoids tracking which DB records are "default" vs user-created. If a user renamed "小区模板", restore creates a fresh "小区模板" alongside it — harmless for testing.

---

## Error Handling

- **YAML parse error or missing asset**: Log error via `debugPrint`, set the initialization flag anyway, and let the app launch. The user gets an empty template list and can create templates manually. Never block app launch on seeding failure.
- **DB insert error**: Same — log, set flag, continue. Prevents infinite retry loops on corrupt DBs.
- **Manual restore error**: Log error, show `"恢复失败"` SnackBar. Do not set the auto-init flag.

---

## Testing

### Unit Test

Test `DefaultTemplateLoader` with a mock `TemplateRepository` and a fake YAML string. Verify:
- It inserts 4 templates with correct dimension counts.
- `ref_subtemplate` configs contain the correct resolved UUIDs.
- `single_choice` configs contain the correct options JSON.
- After `loadIfNeeded()`, the settings flag is set.
- A second call to `loadIfNeeded()` performs no inserts.

### E2E Test — First Launch Seeding

```gherkin
Given 应用首次启动
When 用户进入「模板」页面
Then 模板列表中显示「小区模板」「房子模板」「客厅模板」「卧室模板」
And 进入「小区模板」编辑页，可见维度项包含「房子」（类型：引用子模板）
And 进入「房子模板」编辑页，可见维度项「民水民电」（类型：单选，选项：是/否）
```

### E2E Test — Deletion Permanence

```gherkin
Given 应用已初始化默认模板
When 用户删除「客厅模板」
And 用户完全关闭应用并重新启动
Then 模板列表中不显示「客厅模板」
```

### E2E Test — Manual Restore

```gherkin
Given 应用已初始化默认模板
And 用户已删除「客厅模板」
When 用户进入「设置」页面
And 用户点击「恢复默认模板」
Then 系统提示「已恢复 1 个模板」
And 模板列表中重新显示「客厅模板」
```

---

## Files to Modify / Create

| Action | Path |
|--------|------|
| Create | `assets/default_templates.yaml` |
| Create | `lib/data/default_template_loader.dart` |
| Modify | `lib/data/tables.dart` — add `AppSettings` table |
| Modify | `lib/data/database.dart` — add `AppSettings` to tables list, bump schemaVersion, add migration |
| Modify | `lib/main.dart` — call `DefaultTemplateLoader.loadIfNeeded()` before `runApp` |
| Modify | `lib/screens/settings_screen.dart` — add restore button |
| Modify | `pubspec.yaml` — add `yaml` dependency; add `assets/default_templates.yaml` to flutter.assets |
| Modify | `integration_test/e2e_test.dart` — add E2E tests |
| Create | `test/data/default_template_loader_test.dart` — unit tests |
