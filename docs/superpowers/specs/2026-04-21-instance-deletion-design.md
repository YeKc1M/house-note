# 实例删除（含级联删除）设计文档

## 背景

目前 App 中实例创建后无法删除。需要支持删除实例，删除父实例时级联删除其下所有子实例，并在删除前向用户确认。

## 目标

- 在实例列表页支持左滑删除卡片。
- 删除父实例时，递归删除其下所有子实例。
- 删除前弹出确认对话框，提示将删除的子实例数量。
- 功能通过 E2E 测试覆盖。

## 架构概述

| 层级 | 变更 | 说明 |
|------|------|------|
| Repository | `InstanceRepository` | 修正递归级联删除逻辑 |
| BLoC | `InstanceListCubit` | 新增 `deleteInstance` 入口 |
| UI | `InstanceListScreen` | `Dismissible` 包裹卡片，提供确认对话框 |

## 数据层

### 修正 `deleteInstance` 为递归级联

`Instances` 表的 `parentInstanceId` 外键未配置 `onDelete: cascade`，原实现只删除直接子实例，深层子实例会导致外键约束失败。

改为先递归删除所有后代，再删除目标实例本身：`InstanceValues` / `InstanceCustomFields` / `InstanceHiddenDimensions` 已配置 `onDelete: cascade`，无需手动清理。整个删除在外层 `transaction` 内完成，保证原子性。

### 新增辅助方法

`countDescendants(String id)`：递归统计指定实例下所有后代子实例数量，用于确认对话框提示。

## BLoC 层

`InstanceListCubit` 新增 `deleteInstance(String id)`：
- 调用 `InstanceRepository.deleteInstance(id)` 执行删除。
- 无需手动刷新列表，`watchTopLevelInstances` / `watchChildInstances` 的 Stream 会自动重新 emit。

## UI 层

`InstanceListScreen` 中 `ListView.builder` 的每一项用 `Dismissible` 包裹 `InstanceCard`：
- `direction: DismissDirection.endToStart`（左滑）
- `background` 为红色删除提示背景
- `confirmDismiss` 中执行确认流程：
  1. 调用 `countDescendants` 获取子实例数量
  2. 弹出 `AlertDialog`，根据子实例数量显示不同提示文案
  3. 用户点击「删除」后调用 `cubit.deleteInstance(id)`
  4. 显示 SnackBar 提示「实例已删除」
  5. 返回 `false` 让 `Dismissible` 动画自动回弹（由 Stream 重建完成卡片移除）

## 确认对话框文案

- 无子实例：`确定要删除「{name}」吗？此操作不可撤销。`
- 有子实例：`确定要删除「{name}」吗？将同时删除 {count} 个子实例，此操作不可撤销。`

## 测试策略

- E2E 测试覆盖：创建父实例及若干子实例 → 左滑删除父实例 → 验证确认对话框文案 → 确认删除 → 验证父实例及所有子实例均已消失。

## 依赖

无新增第三方包。使用 Flutter 内置 `Dismissible` 和 `AlertDialog`。
