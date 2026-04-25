# House Note — Interactive Tutorial Design Spec

**Date:** 2026-04-25
**Feature:** First-Run Interactive Tutorial (新手指引)
**Approach:** TutorialCubit + Custom Overlay with GlobalKeys

---

## 1. Overview

A hands-on interactive tutorial overlay that guides first-time users through creating templates, instances, and navigating the app's hierarchy. The tutorial runs on the actual UI — users perform real actions (tapping, typing, swiping) while the overlay highlights relevant widgets and explains what to do.

### Key Behaviors

- **First-run prompt:** On first app launch, a dialog asks if the user wants the tutorial. Skip means never ask again.
- **Settings access:** A "查看教程" button in Settings allows re-running the tutorial at any time.
- **Exit with cleanup:** Users can exit anytime. On exit, they can choose to delete all tutorial-created data or keep it.
- **Suggested inputs:** Text fields are pre-filled with demo names (e.g., "房子模板") that the user can accept or override.

---

## 2. Architecture

### 2.1 Components

```
┌─────────────────────────────────────────┐
│           TutorialOverlay               │
│  (Stack widget, wraps _MainShell)       │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │      CustomPainter spotlight    │    │
│  │      + dark background          │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │      Tooltip card               │    │
│  └─────────────────────────────────┘    │
│  ┌─────────────────────────────────┐    │
│  │      "退出教程" button           │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│           TutorialCubit                 │
│  - currentStepIndex                     │
│  - startTimestamp (for cleanup)         │
│  - createdTemplateIds                   │
│  - createdInstanceIds                   │
│  - isActive, showExitDialog             │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│         SharedPreferences               │
│  - "has_seen_tutorial": bool            │
│  - "tutorial_was_active": bool          │
└─────────────────────────────────────────┘
```

### 2.2 Data Flow

1. **App startup:** `main.dart` checks `SharedPreferences.getBool('has_seen_tutorial')`.
   - If `null` or `false`: show `WelcomeDialog` with "开始教程" and "跳过".
   - If `true`: normal app launch.

2. **Tutorial start:** `TutorialCubit.startTutorial()` sets:
   - `isActive = true`
   - `currentStepIndex = 0`
   - `startTimestamp = DateTime.now().millisecondsSinceEpoch`
   - Saves `tutorial_was_active = true` to SharedPreferences.

3. **Step progression:** The overlay listens to `TutorialCubit` state. For each step:
   - Finds the target widget via its `GlobalKey`.
   - Computes `RenderBox` bounds for spotlight positioning.
   - Renders tooltip with title, description, and action hint.
   - Advances when the expected user action is detected (tap, route change, etc.).
   - After advancing, saves `tutorial_last_step = currentStepIndex` to SharedPreferences.

4. **Tutorial end:** `TutorialCubit.completeTutorial()` sets:
   - `isActive = false`
   - `has_seen_tutorial = true`
   - `tutorial_was_active = false`

5. **Exit with cleanup:** `TutorialCubit.exitAndCleanup()`:
   - Queries DB for templates/instances with `createdAt >= startTimestamp`.
   - Also deletes by tracked IDs in `createdTemplateIds` and `createdInstanceIds`.
   - Sets `tutorial_was_active = false`.

### 2.3 Models

```dart
class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? actionHint;        // e.g., "👆 点击高亮区域继续"
  final String targetGlobalKey;    // key to locate target widget
  final TutorialActionType actionType;
  final String? expectedRoute;     // for navigation steps
  final String? defaultInput;      // pre-filled text for type steps
  final bool requiresUserAction;   // false = auto-advance after delay
}

enum TutorialActionType {
  tap,        // user taps target
  type,       // user types into target
  swipe,      // user swipes target
  observe,    // just read, tap "下一步" to continue
  navigate,   // system navigates, user observes
}
```

---

## 3. UI/Overlay Design

### 3.1 Spotlight Effect

- **Background:** `Colors.black.withOpacity(0.75)`
- **Cutout:** Rounded rectangle (`RRect` with `Radius.circular(12)`) matching the target widget's bounds.
- **Border glow:** `Colors.deepPurple.withOpacity(0.5)`, 2px stroke around the cutout.
- **Positioning:** Computed from `targetKey.currentContext?.findRenderObject()` → `RenderBox.localToGlobal` → `size`.
- **Animation:** Smooth tween between cutout positions (300ms, `Curves.easeInOut`).

### 3.2 Tooltip Card

- **Style:** `Card` with `elevation: 4`, `color: Colors.white`, `borderRadius: BorderRadius.circular(12)`.
- **Position:** Near the cutout. Auto-flips to top if the target is in the bottom 40% of the screen.
- **Content:**
  - Title: Bold, `16px`, `Theme.of(context).colorScheme.primary`
  - Description: `14px`, `Colors.black87`
  - Action hint: `12px`, `Colors.grey`, prefixed with `Icons.touch_app`
- **Arrow:** Small triangle pointing from the card toward the cutout center.

### 3.3 Persistent Controls

- **Top-right:** "退出教程" text button. Style: `Colors.white.withOpacity(0.8)`, subtle border.
- **Bottom-center:** "下一步" `ElevatedButton` (shown only for `observe` steps).
- **Progress indicator:** "Step 3 / 23" text below the tooltip card.

---

## 4. Tutorial Step Sequence (23 Steps)

| Step | Tab | Target | Type | Description | Default Input |
|------|-----|--------|------|-------------|---------------|
| 1 | — | Dialog | observe | "欢迎使用 House Note！是否需要新手指引？" → user taps "开始教程" | — |
| 2 | 模板 | Screen | observe | "这里是模板管理页，你可以创建和管理看房维度模板。" | — |
| 3 | 模板 | FAB | tap | "点击右下角按钮，创建你的第一个模板。" | — |
| 4 | 模板编辑 | Name field | type | "输入模板名称。这里已经帮你填好了建议名称。" | "房子模板" |
| 5 | 模板编辑 | "添加维度项" | tap | "点击添加维度项，比如记录房子的朝向、楼层等信息。" | — |
| 6 | 模板编辑 | Dialog fields | type/select | "输入名称「朝向」，选择类型「单选」，添加选项：东、南、西、北，然后保存。" | "朝向" |
| 7 | 模板编辑 | "添加维度项" | tap | "继续添加「楼层」（数字类型）和「户型」（文本类型）。" | — |
| 8 | 模板编辑 | Visibility icon | tap | "点击眼睛图标，设置缩略图显示字段。这些字段会显示在实例卡片上，方便对比。" | — |
| 9 | 模板编辑 | Save icon | tap | "点击右上角保存模板。" | — |
| 10 | 模板 | FAB | tap | "再创建一个小区模板，并在其中引用房子模板，建立层级关系。" | — |
| 11 | 模板编辑 | Various | type/select | "创建「小区模板」，添加「小区名」「位置」，再添加「引用子模板」维度，选择引用「房子模板」。" | "小区模板" |
| 12 | 首页 | Screen | observe | "切换到首页，这里按层级展示你创建的看房实例。" | — |
| 13 | 首页 | FAB | tap | "点击创建第一个实例。选择「小区模板」。" | — |
| 14 | 实例编辑 | Name field | type | "输入小区名称，比如「华润二十四城」，填入位置和通勤信息，然后保存。" | "华润二十四城" |
| 15 | 首页 | Instance card | tap | "点击实例卡片进入下一层。现在你可以在小区下创建房子实例了。" | — |
| 16 | 首页 | FAB | tap | "点击创建子实例，选择「房子模板」，输入「7栋-1203」，填写朝向和楼层，保存。" | "7栋-1203" |
| 17 | 首页 | Instance card | swipe | "向左滑动实例卡片可以删除实例。" | — |
| 18 | 首页 | Dialog | tap | "确认删除「7栋-1203」。因为这个实例下没有子实例，所以直接删除。" | — |
| 19 | 首页 | FAB | tap | "我们再快速创建一个子实例，用来演示父实例的级联删除。" | "8栋-1502" |
| 20 | 首页 | Breadcrumb | tap | "点击面包屑导航的「全部」，回到上一层。" | — |
| 21 | 首页 | Instance card | swipe | "向左滑动删除父实例。系统会提示将同时删除其下的子实例。" | — |
| 22 | 首页 | Dialog | tap | "确认删除。可以看到提示「将同时删除 1 个子实例」，这就是级联删除。" | — |
| 23 | 设置 | Button | observe | "教程完成！以后可以在「设置」→「查看教程」随时重新学习。" | — |

### Step Notes

- **Step 1 (Welcome):** Not part of the overlay. A simple `AlertDialog` shown by `main.dart` before `TutorialOverlay` is activated.
- **Step 6 (Dimension dialog):** The overlay pauses while the dialog is open. It resumes when the dialog closes and the new dimension appears in the list.
- **Step 19 (Quick child):** Minimal input — only name is required. The tutorial pre-fills "8栋-1502" and the user just taps save. If the template has required dimensions, the tutorial should either pre-fill them with defaults or skip validation during tutorial mode.
- **Step 23 (Settings):** The overlay navigates to the Settings tab and highlights the "查看教程" button.

---

## 5. First-Run Detection

### 5.1 Storage

Use `shared_preferences` (already in `pubspec.yaml`):

- **`has_seen_tutorial`** (`bool`): Whether the user has ever seen the welcome dialog. Set to `true` immediately after the welcome dialog is dismissed (whether by "开始教程" or "跳过").
- **`tutorial_was_active`** (`bool`): Whether a tutorial session is currently in progress. Set to `true` when `startTutorial()` is called, `false` on completion or exit.
- **`tutorial_last_step`** (`int`): The last completed step index. Updated after each step transition. Used for crash recovery resume.

### 5.2 Startup Logic

```dart
// In main.dart, before runApp
final prefs = await SharedPreferences.getInstance();
final hasSeen = prefs.getBool('has_seen_tutorial') ?? false;
final wasActive = prefs.getBool('tutorial_was_active') ?? false;

if (wasActive) {
  // Show recovery dialog
  final lastStep = prefs.getInt('tutorial_last_step') ?? 0;
  showTutorialRecoveryDialog(resumeStep: lastStep);
} else if (!hasSeen) {
  // Show welcome dialog
  showWelcomeDialog();
}
```

### 5.3 Recovery Dialog

If `tutorial_was_active` is true on startup, show a dialog using the stored `tutorial_last_step`:

> "上次教程未结束，是否继续？"
> - "继续教程" → Resume from `tutorial_last_step + 1`
> - "重新开始" → Reset and start from step 2 (skipping welcome)
> - "退出并清理" → Delete tutorial data by timestamp, clear flags, skip

---

## 6. Settings Integration

A new **"查看教程"** list tile is added to the Settings screen, below the "关于" section:

```dart
ListTile(
  leading: const Icon(Icons.school),
  title: const Text('查看教程'),
  subtitle: const Text('重新运行新手指引'),
  onTap: () => _showRestartConfirmation(context),
)
```

**Restart flow:**
1. Confirmation dialog: "重新开始教程？教程中创建的数据可以在退出时删除。"
2. If confirmed: `prefs.setBool('has_seen_tutorial', true)` (prevents welcome dialog), then `TutorialCubit.startTutorial()`.
3. Tutorial starts from step 2 (skipping the welcome prompt).

**Disabled during active tutorial:** The button is hidden or disabled when `TutorialState.isActive` is true.

---

## 7. Cleanup Mechanism

### 7.1 Timestamp-Based Cleanup

When the user exits and chooses "删除教程数据":

```sql
DELETE FROM templates WHERE created_at >= ?;
DELETE FROM instances WHERE created_at >= ?;
-- TemplateDimensions, InstanceValues, etc. cascade via FK
```

The `startTimestamp` is recorded in `TutorialCubit.startTutorial()`.

### 7.2 ID Tracking (Fallback)

The cubit also maintains:
- `Set<String> createdTemplateIds`
- `Set<String> createdInstanceIds`

These are populated by observing the app's state after creation steps. If timestamp cleanup fails or is imprecise, ID-based cleanup is used as a fallback.

### 7.3 Exit Dialog

When the user taps "退出教程":

> "确定要退出教程吗？"
> - "退出并删除数据" → Run cleanup, end tutorial
> - "退出并保留数据" → End tutorial without cleanup
> - "取消" → Resume tutorial

---

## 8. GlobalKeys Required

The following widgets need `GlobalKey` assignments for the tutorial to target them:

| Widget | Key Name | Used In Steps |
|--------|----------|---------------|
| TemplateList FAB | `templateListFabKey` | 3, 10 |
| InstanceList FAB | `instanceListFabKey` | 13, 16, 19 |
| Template name field | `templateNameFieldKey` | 4 |
| "添加维度项" button | `addDimensionButtonKey` | 5, 7 |
| Save icon (template) | `templateSaveButtonKey` | 9 |
| Save icon (instance) | `instanceSaveButtonKey` | 14 |
| Breadcrumb "全部" | `breadcrumbRootKey` | 20 |
| Settings "查看教程" button | `settingsTutorialButtonKey` | 23 |

For list items (instance cards, visibility icons), dynamic keys are generated:
- `instanceCardKey(instanceId)`
- `visibilityIconKey(dimensionId)`

---

## 9. Error Handling

| Scenario | Behavior |
|----------|----------|
| **Target widget not found** | Overlay shows a "定位中..." spinner for up to 3 seconds. If still not found, displays: "请按教程指引操作" with a "重试" button. |
| **User navigates unexpectedly** | Tutorial pauses. Overlay dims the full screen with a message: "请返回上一步继续教程" and a "返回" button that pops navigation back to the expected route. |
| **Template/instance save fails** | Tutorial detects the error via `ScaffoldMessenger` snackbar. Shows an error tooltip: "保存失败，请重试" with "重试" and "跳过此步" buttons. |
| **App crashes during tutorial** | On next launch, the recovery dialog (Section 5.3) is shown. |
| **User skips first-run dialog** | `has_seen_tutorial = true` is set. Welcome dialog never shows again. Tutorial can only be started from Settings. |

---

## 10. Testing

### 10.1 Unit Tests (`test/blocs/tutorial/cubit_test.dart`)

- `startTutorial` → `isActive = true`, timestamp recorded
- `nextStep` → `currentStepIndex` increments
- `completeTutorial` → `isActive = false`, prefs updated
- `exitAndCleanup` → calls repo delete with correct timestamp
- `exitWithoutCleanup` → `isActive = false`, no deletion

### 10.2 Widget Tests (`test/widgets/tutorial_overlay_test.dart`)

- Spotlight renders at target widget's bounds
- Tooltip auto-positions above target when target is in bottom half
- "退出教程" button is always visible during active tutorial
- "下一步" button only appears for `observe` steps

### 10.3 E2E Test (`integration_test/e2e_test.dart`)

Add a new test group:

```gherkin
Scenario: First-run tutorial flow
Given 应用首次启动（has_seen_tutorial = false）
When 用户看到欢迎弹窗并点击「开始教程」
Then 教程覆盖层出现，第 2 步高亮「模板」页面
When 用户按教程完成全部 23 步
Then 设置页面中显示「查看教程」按钮
When 用户退出教程并选择「删除数据」
Then 模板列表和实例列表均为空
```

---

## 11. Files to Create / Modify

### New Files

| Path | Purpose |
|------|---------|
| `lib/blocs/tutorial/cubit.dart` | TutorialCubit |
| `lib/blocs/tutorial/state.dart` | TutorialState |
| `lib/widgets/tutorial_overlay.dart` | TutorialOverlay widget |
| `lib/widgets/tutorial_spotlight_painter.dart` | CustomPainter for spotlight |
| `lib/models/tutorial_step.dart` | TutorialStep model |
| `lib/utils/tutorial_steps.dart` | Step definitions (23 steps) |
| `test/blocs/tutorial/cubit_test.dart` | Cubit unit tests |
| `test/widgets/tutorial_overlay_test.dart` | Overlay widget tests |

### Modified Files

| Path | Changes |
|------|---------|
| `lib/main.dart` | Check `has_seen_tutorial` on startup, show welcome dialog |
| `lib/app.dart` | Wrap `_MainShell` with `TutorialOverlay`, add GlobalKeys |
| `lib/screens/settings_screen.dart` | Add "查看教程" button |
| `lib/screens/template_list_screen.dart` | Add `GlobalKey` to FAB |
| `lib/screens/instance_list_screen.dart` | Add `GlobalKey` to FAB, cards, breadcrumb |
| `lib/screens/template_editor_screen.dart` | Add `GlobalKey` to name field, add-dim button, save icon |
| `lib/screens/instance_editor_screen.dart` | Add `GlobalKey` to save icon |
| `lib/widgets/dimension_tree.dart` | Add `GlobalKey` to visibility icons |
| `integration_test/e2e_test.dart` | Add tutorial E2E test |

---

## 12. Open Questions (Resolved)

| Question | Decision |
|----------|----------|
| Tutorial format | Interactive overlay with spotlights on real UI (Approach 1) |
| Hands-on vs. observation | Hands-on — user creates real data |
| First-run skip behavior | Ask once only; Settings is the only way back |
| Input style | Suggested names pre-filled, user can override |
| Exit behavior | Exit anytime, with optional cleanup of tutorial-created data |
| Deletion steps | Added steps 17–22: simple child deletion + cascade parent deletion |
