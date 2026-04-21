# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

House Note (看房记录) is a Flutter application for recording and organizing rental property viewing notes. It supports custom dimension templates with infinite nesting, hierarchical instance browsing, thumbnail field configuration, and offline-first local storage.

## Development Workflow

This is a **vibe coding** project. The workflow is:

1. **Confirm spec with the user** — refer to `house-note-prd.md` and `docs/e2e-user-stories.md`
2. **Implement without confirming code details** — the user does not want to review implementation choices
3. **Accept via e2e tests** — new features must have corresponding e2e test coverage in `integration_test/e2e_test.dart`

Before starting a new feature, check the PRD acceptance criteria and e2e user stories to understand what needs to be built.

To avoid interfering with other in-progress features, create a new [git worktree](https://git-scm.com/docs/git-worktree) for each feature and develop there.

## Common Commands

All Flutter commands run from the `app/` directory:

```bash
cd app

# Install dependencies
flutter pub get

# Run the app (defaults to Android/linux depending on platform)
flutter run

# Run linter
flutter analyze

# Run all unit tests
flutter test

# Run a single test file
flutter test test/data/instance_repository_test.dart

# Run a single test by name
flutter test --name "deleteInstance deletes instance and child instances"

# Run integration/E2E tests
flutter test integration_test/e2e_test.dart

# Generate Drift database code (after modifying tables.dart)
dart run build_runner build

# Format code
dart format .
```

## Architecture

### State Management
The app uses **Cubit** (flutter_bloc) with `bloc_test` and `mocktail` for testing. Each major feature has a cubit + state pair in `lib/blocs/<feature>/`.

### Data Layer
- **Drift** (SQLite) provides local persistence via `lib/data/database.dart`
- `lib/data/tables.dart` defines all database tables; run `build_runner` after modifying
- Repositories (`TemplateRepository`, `InstanceRepository`) encapsulate all DB access
- `AppDatabase.forTesting(NativeDatabase.memory())` creates an in-memory DB for tests

### Navigation
- `lib/app.dart` sets up `MaterialApp` with `onGenerateRoute`
- Bottom nav has 3 tabs: 首页 (InstanceList), 模板 (TemplateList), 设置 (Settings)
- `/templateEditor` — create/edit template (optional `templateId` arg)
- `/instanceEditor` — create/edit instance (args: `instanceId`, `templateId`, `parentInstanceId`)

### Core Domain Concepts

**Templates** define the structure for recording. A template has **dimensions** (字段/维度项) that can be:
- `text`, `number`, `boolean`, `single_choice` — basic field types
- `group` — container for nested dimensions (supports infinite nesting)
- `ref_subtemplate` — references another template to create parent-child hierarchies

**Instances** are concrete records. The hierarchy works like:
- Template A has a `ref_subtemplate` dimension pointing to Template B
- An instance of A can have child instances of B beneath it
- Navigation follows this chain: e.g., 小区 → 房子 → 房间

**Thumbnail fields** are per-template configurable dimensions whose values appear as chips on instance cards. Configured in the template editor via visibility toggle icons.

### Key Files

| Purpose | Path |
|---------|------|
| Entry point | `lib/main.dart` |
| App shell & routing | `lib/app.dart` |
| DB tables | `lib/data/tables.dart` |
| DB generated code | `lib/data/database.g.dart` |
| Dimension tree model | `lib/models/dimension_node.dart` |
| Tree builder utility | `lib/utils/dimension_tree_builder.dart` |

### Instance Deletion
`InstanceRepository.deleteInstance` recursively deletes all descendants (cascade in Dart code, not DB-level). The UI shows a confirmation dialog with the descendant count.

## Testing Patterns

- **Unit tests**: Mock repositories with `mocktail`, test cubits with `blocTest`
- **Repository tests**: Use `AppDatabase.forTesting(NativeDatabase.memory())` with `PRAGMA foreign_keys = ON`
- **Widget tests**: Pump `HouseNoteApp(database: testDb)` and interact via finders
- **E2E tests**: Full app flows in `integration_test/e2e_test.dart` using a file-backed test DB

When testing cubits that call repo methods, register `Fake` fallback values for Drift companion classes:
```dart
registerFallbackValue(FakeTemplatesCompanion());
```

### E2E Test Helpers (`integration_test/e2e_test.dart`)

The E2E suite uses a file-backed SQLite DB (not in-memory) to match production behavior:
```dart
final dbFile = File(p.join(tempDir.path, 'e2e_test_${DateTime.now().millisecondsSinceEpoch}.db'));
db = AppDatabase.forTesting(NativeDatabase.createInBackground(dbFile));
```

Common helpers:
- `bottomNavItem(label)` — finder for bottom nav by text
- `instanceListFab()` / `templateListFab()` — find FABs by `heroTag`
- `dialogTextField(index)` — find text fields inside AlertDialog
- `selectDimensionType(tester, label)` — select from dimension type dropdown
- `pumpUntilFound(tester, finder)` / `pumpUntilAbsent(tester, finder)` — poll with timeout
- `_insertTemplate(db, name, dims)` / `_insertInstance(db, ...)` — seed DB directly to skip UI setup

Tests frequently `pumpWidget(HouseNoteApp(database: db))` to rebuild and force fresh state loads after DB mutations.

**Debugging e2e failures:** If a test fails or the app crashes during e2e, check the test runner output logs to identify the exact error location.

## Important Notes

- The app is entirely offline/local; no cloud sync or auth
- `ref_subtemplate` config stores the referenced template ID as JSON: `{"ref_template_id": "..."}`
- Single-choice options are parsed from config via regex in the UI layer (both template editor and instance editor)
- Drift-generated code (`database.g.dart`) must be kept in sync with `tables.dart`
- The project uses `flutter_lints` for analysis
