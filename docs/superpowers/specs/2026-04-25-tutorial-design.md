# House Note — 首次使用教程设计文档

**日期:** 2026-04-25  
**对应 PRD:** House Note PRD v1.0  
**作者:** Claude Code  

---

## 1. 目标

为首次安装并运行 House Note 的用户提供快速入门教程。用户首次打开应用时询问是否需要教程，用户可选择查看或跳过。已安装用户也可随时在「设置」中重新查看教程。

教程采用**演示式滑动页面**（Demo Walkthrough）形式：用户通过左右滑动浏览一系列说明页面，每个页面使用 Flutter 组件构建的示意界面来解释核心功能，用户无需与真实数据交互。

---

## 2. 用户流程

### 2.1 首次启动流程

```
启动 App
  └── 加载首页 (_MainShell)
        └── 首帧渲染完成后
              └── 检查 SettingsCubit.tutorialSeen
                    ├── false (未看过) → 弹出询问对话框
                    │                      ├── 「查看教程」→ 进入 TutorialScreen
                    │                      └── 「跳过」    → 标记为已看，留在首页
                    └── true (已看过)  → 不做任何事，正常显示首页
```

### 2.2 设置页重放流程

```
进入「设置」页
  └── 点击「查看教程」
        └── 进入 TutorialScreen（不修改 tutorialSeen 状态）
              └── 看完或点击「跳过」→ 返回设置页
```

---

## 3. 状态管理

### 3.1 SettingsState 扩展

在现有 `SettingsState` 中新增 `tutorialSeen` 字段：

```dart
class SettingsState extends Equatable {
  final bool lanSyncEnabled;
  final bool tutorialSeen;  // NEW

  const SettingsState({
    this.lanSyncEnabled = false,
    this.tutorialSeen = false,  // 默认未看过
  });

  SettingsState copyWith({bool? lanSyncEnabled, bool? tutorialSeen}) {
    return SettingsState(
      lanSyncEnabled: lanSyncEnabled ?? this.lanSyncEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  @override
  List<Object?> get props => [lanSyncEnabled, tutorialSeen];
}
```

### 3.2 SettingsCubit 扩展

`SettingsCubit` 新增 `SharedPreferences` 依赖：

```dart
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs)
      : super(const SettingsState()) {
    _load();
  }

  void _load() {
    final lanSync = _prefs.getBool('lan_sync_enabled') ?? false;
    final tutorialSeen = _prefs.getBool('tutorial_seen') ?? false;
    emit(SettingsState(lanSyncEnabled: lanSync, tutorialSeen: tutorialSeen));
  }

  void markTutorialSeen() {
    _prefs.setBool('tutorial_seen', true);
    emit(state.copyWith(tutorialSeen: true));
  }

  void toggleLanSync(bool enabled) {
    _prefs.setBool('lan_sync_enabled', enabled);
    emit(state.copyWith(lanSyncEnabled: enabled));
  }
}
```

### 3.3 App 启动时注入

在 `main.dart` 中预先初始化 `SharedPreferences`，注入到 `HouseNoteApp`：

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  runApp(HouseNoteApp(database: db, prefs: prefs));
}
```

`HouseNoteApp` 的构造函数新增 `SharedPreferences` 参数，在 `_MainShell` 中通过 `BlocProvider` 提供 `SettingsCubit`。

---

## 4. UI 设计

### 4.1 首次启动询问对话框

在 `_MainShellState.initState` 中，使用 `WidgetsBinding.instance.addPostFrameCallback` 延迟检查：

- **标题:** 「欢迎使用 House Note」
- **内容:** 「这是您第一次使用。是否查看快速入门教程？」
- **按钮:**
  - 「查看教程」→ `Navigator.pushNamed(context, '/tutorial')`
  - 「跳过」   → `context.read<SettingsCubit>().markTutorialSeen()`，关闭对话框

### 4.2 TutorialScreen 结构

`TutorialScreen` 是一个 `StatefulWidget`，核心布局：

```
Scaffold
├── AppBar
│   ├── Title: 「快速入门」
│   └── Action: 「跳过」TextButton（始终可见）
├── Body
│   └── PageView.builder
│       ├── Page 1: 欢迎
│       ├── Page 2: 创建与编辑模板
│       ├── Page 3: 子模板引用
│       ├── Page 4: 缩略图显示
│       ├── Page 5: 创建实例与子实例
│       ├── Page 6: 删除实例与模板
│       └── Page 7: 完成
└── BottomNavigationArea
    ├── 页面指示器 dots (7 个圆点)
    └── 底部操作按钮
        ├── 非末页: 「下一页」
        └── 末页: 「完成」
```

- `PageView` 使用 `physics: const ClampingScrollPhysics()`，支持左右滑动。
- 页面切换时，dots 和底部按钮状态同步更新。
- 「跳过」按钮：调用 `markTutorialSeen()`（首次运行时）并退出页面。
- 「完成」按钮：调用 `markTutorialSeen()`（首次运行时）并退出页面。

### 4.3 路由

在 `app.dart` 的 `onGenerateRoute` 中新增：

```dart
case '/tutorial':
  return MaterialPageRoute(builder: (_) => const TutorialScreen());
```

---

## 5. 教程页面内容（7 页）

每一页使用 Flutter 组件构建示意界面，不使用真实业务逻辑或真实数据。

### Page 1 — 欢迎

- **标题:** 「欢迎来到 House Note」
- **说明文字:** 「House Note 是一款帮你结构化记录租房看房信息的工具。」
- **核心概念示意图:**
  - 两个上下排列的卡片：「模板」（定义结构）和「实例」（实际记录）
  - 中间用箭头连接，文字标注：模板 → 实例

### Page 2 — 创建与编辑模板

- **标题:** 「第一步：创建模板」
- **说明文字:** 「模板定义了你看房时要记录哪些维度。比如「房子模板」可以包含朝向、楼层、户型等字段。」
- **示意组件:**
  - 一个模拟的文本输入框，placeholder「模板名称」
  - 3 个模拟的维度行：「朝向 / 单选」「楼层 / 数字」「户型 / 文本」

### Page 3 — 子模板引用

- **标题:** 「第二步：建立层级关系」
- **说明文字:** 「通过「引用子模板」维度，可以把多个模板串联起来。比如：小区 → 房子 → 房间。」
- **示意组件:**
  - 水平流程图：「小区模板」→ 「房子列表(引用)」→ 「房子模板」
  - 使用卡片 + 箭头图标组合展示

### Page 4 — 缩略图显示

- **标题:** 「第三步：设置卡片缩略图」
- **说明文字:** 「在模板编辑器中点击眼睛图标，可以选择在实例卡片上显示哪些字段，方便快速对比。」
- **示意组件:**
  - 一个模拟的 `InstanceCard`，标题「华润二十四城」
  - 下方显示 chip：「成华区」「是」
  - 旁边注释箭头指向 chip 区域

### Page 5 — 创建实例与子实例

- **标题:** 「第四步：录入看房记录」
- **说明文字:** 「在首页选择模板创建记录。点击进入实例后，可以继续添加子实例，按层级记录每一套房子的信息。」
- **示意组件:**
  - 模拟面包屑：「全部 > 华润二十四城」
  - 两个模拟实例卡片：「7栋-1203」「8栋-1501」

### Page 6 — 删除实例与模板

- **标题:** 「删除与管理」
- **说明文字:**
  - 「左滑实例卡片可删除。删除父实例会同时删除其下所有子实例。」
  - 「删除模板则会删除该模板下的全部数据，请谨慎操作。」
- **示意组件:**
  - 一个模拟卡片，左侧有红色背景 + 删除图标，表示滑动删除
  - 下方小字注释说明级联删除

### Page 7 — 完成

- **标题:** 「开始记录吧」
- **说明文字:** 「你已经了解了 House Note 的核心功能。快去创建你的第一个模板吧！」
- **示意组件:** 一个大的勾选图标（`Icons.check_circle`）
- **底部按钮:** 「完成」（高亮主按钮）

---

## 6. 组件设计

### 6.1 TutorialScreen

```dart
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const _pageCount = 7;

  // ... build, dispose, onPageChanged, skip, finish
}
```

### 6.2 TutorialPage 基类

每个页面继承一个统一的布局结构：

```dart
class TutorialPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget illustration;

  const TutorialPage({
    required this.title,
    required this.description,
    required this.illustration,
  });

  // 统一布局：顶部标题 + 中部示意图 + 底部说明文字
}
```

### 6.3 示意组件（Mock Widgets）

为保持可维护性，所有示意界面使用轻量级的自定义 Widget 构建，不依赖真实业务组件：

- `MockTemplateEditor` — 模拟模板编辑器的静态展示
- `MockInstanceCard` — 模拟实例卡片的静态展示
- `MockBreadcrumb` — 模拟面包屑导航
- `MockSwipeCard` — 模拟滑动删除示意
- `MockFlowDiagram` — 模拟模板引用流程图

这些组件仅用于教程页面，内部使用 `Container`、`Card`、`Text`、`Icon` 等基础组件拼接，无业务逻辑。

---

## 7. 依赖

新增 `pubspec.yaml` 依赖：

```yaml
dependencies:
  shared_preferences: ^2.5.0
```

---

## 8. 测试策略

### 8.1 单元测试

**SettingsCubit 测试：**
- `load()` 从 mock `SharedPreferences` 正确读取 `tutorial_seen` 和 `lan_sync_enabled`。
- `markTutorialSeen()` 向 prefs 写入 `true` 并发射 `tutorialSeen: true`。
- `toggleLanSync()` 保持原有行为不变。

使用 `mocktail` 创建 `MockSharedPreferences`。

### 8.2 Widget 测试

**首次启动对话框测试：**
- Pump `HouseNoteApp` 且 `tutorialSeen: false` → 验证欢迎对话框出现。
- 点击「跳过」→ 对话框消失，`markTutorialSeen` 被调用。
- 点击「查看教程」→ 导航到 `TutorialScreen`。

**TutorialScreen 测试：**
- Pump `TutorialScreen`。
- 滑动/点击浏览全部 7 页，验证每页的标题和说明文字。
- 验证页面指示器 dots 随页码同步更新。
- 验证末页的「完成」按钮和 AppBar 的「跳过」按钮均能退出页面。

### 8.3 E2E 测试

在 `integration_test/e2e_test.dart` 中新增 story：

```gherkin
Story: 首次使用教程
Given 用户首次安装并启动 App
When 应用加载完成
Then 弹出欢迎对话框「是否查看快速入门教程」
When 用户点击「查看教程」
Then 进入教程页面，显示「欢迎来到 House Note」
When 用户滑动浏览全部 7 页教程
And 点击「完成」
Then 返回首页
And 再次启动 App 时不再显示教程对话框
```

---

## 9. 文件变更清单

| 操作 | 文件路径 | 说明 |
|------|----------|------|
| 修改 | `pubspec.yaml` | 添加 `shared_preferences` 依赖 |
| 修改 | `lib/main.dart` | 初始化 `SharedPreferences` 并传入 `HouseNoteApp` |
| 修改 | `lib/app.dart` | 新增 `/tutorial` 路由，注入 `SettingsCubit` |
| 修改 | `lib/blocs/settings/state.dart` | 新增 `tutorialSeen` 字段 |
| 修改 | `lib/blocs/settings/cubit.dart` | 新增 `SharedPreferences` 依赖和 `markTutorialSeen()` |
| 修改 | `lib/screens/settings_screen.dart` | 新增「查看教程」入口按钮 |
| 新增 | `lib/screens/tutorial_screen.dart` | 教程主页面 |
| 新增 | `lib/widgets/tutorial_page.dart` | 教程页面统一布局组件 |
| 新增 | `lib/widgets/mock_*.dart` | 各示意组件（约 4–5 个） |
| 修改 | `test/blocs/settings_cubit_test.dart` | 补充 tutorial 相关单元测试 |
| 新增 | `test/screens/tutorial_screen_test.dart` | 教程页面 Widget 测试 |
| 修改 | `integration_test/e2e_test.dart` | 新增首次教程 E2E 测试 |

---

## 10. 范围边界

**包含:**
- 首次启动询问对话框
- 7 页滑动教程（创建/编辑模板、子模板引用、缩略图设置、创建实例、删除管理、完成）
- 设置页「查看教程」入口
- `tutorialSeen` 持久化到 `SharedPreferences`
- 完整的单元测试、Widget 测试、E2E 测试

**不包含:**
- 示例数据预创建（用户教程结束后直接进入空白首页）
- 交互式实时引导（如高亮真实 UI 元素的 coach marks）
- 多语言支持（教程文字为中文，与 App 现有语言一致）
- 教程页面动画过渡效果（保持简单，仅基础滑动）
