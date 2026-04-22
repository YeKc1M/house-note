import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/instance_editor/cubit.dart';
import '../models/dimension_node.dart';

class InstanceEditorScreen extends StatefulWidget {
  final String? instanceId;
  final String? templateId;
  final String? parentInstanceId;

  const InstanceEditorScreen({
    super.key,
    this.instanceId,
    this.templateId,
    this.parentInstanceId,
  });

  @override
  State<InstanceEditorScreen> createState() => _InstanceEditorScreenState();
}

class _InstanceEditorScreenState extends State<InstanceEditorScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<InstanceEditorCubit>();
    if (widget.instanceId != null) {
      cubit.loadInstance(widget.instanceId!);
    } else if (widget.templateId != null) {
      cubit.initNewInstance(
        widget.templateId!,
        parentInstanceId: widget.parentInstanceId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<InstanceEditorCubit, InstanceEditorState>(
          builder: (context, state) =>
              Text(state.name.isEmpty ? '新建实例' : state.name),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final cubit = context.read<InstanceEditorCubit>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              await cubit.saveInstance();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('实例保存成功')),
                );
                navigator.pop();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<InstanceEditorCubit, InstanceEditorState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: state.name,
                  decoration: const InputDecoration(labelText: '实例名称'),
                  onChanged: (v) => context.read<InstanceEditorCubit>().setName(v),
                ),
                const SizedBox(height: 16),
                ..._buildDimensionFields(context, state.dimensions, state),
                if (state.dimensions.isNotEmpty &&
                    state.dimensions.every(
                      (d) =>
                          state.hiddenDimensionIds.contains(d.id) ||
                          _allChildrenHidden(d, state.hiddenDimensionIds),
                    ))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('所有模板字段已隐藏'),
                  ),
                const Divider(),
                const Text('（自定义字段）', style: TextStyle(color: Colors.grey)),
                ...state.customFields.map(
                  (f) => ListTile(
                    title: _buildCustomField(context, f),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          context.read<InstanceEditorCubit>().removeCustomField(f.id),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showAddCustomFieldDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加自定义字段'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showRestoreHiddenDialog(context, state),
                      child: const Text('恢复隐藏字段'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _allChildrenHidden(DimensionNode node, Set<String> hidden) {
    if (!hidden.contains(node.id)) return false;
    if (node.children.isEmpty) return true;
    return node.children.every((c) => _allChildrenHidden(c, hidden));
  }

  List<Widget> _buildDimensionFields(
    BuildContext context,
    List<DimensionNode> nodes,
    InstanceEditorState state,
  ) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      if (state.hiddenDimensionIds.contains(node.id)) continue;
      if (node.type == 'group') {
        widgets.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ..._buildDimensionFields(context, node.children, state),
                ],
              ),
            ),
          ),
        );
      } else if (node.type != 'ref_subtemplate') {
        widgets.add(
          _buildFieldRow(
            context,
            node,
            state.dimensionValues[node.id] ?? '',
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildFieldRow(BuildContext context, DimensionNode node, String value) {
    return ListTile(
      title: Text(node.name),
      subtitle: _buildInput(context, node, value),
      trailing: TextButton(
        onPressed: () =>
            context.read<InstanceEditorCubit>().hideDimension(node.id),
        child: const Text('隐藏'),
      ),
    );
  }

  Widget _buildInput(BuildContext context, DimensionNode node, String value) {
    final cubit = context.read<InstanceEditorCubit>();
    switch (node.type) {
      case 'single_choice':
        final match =
            RegExp(r'"options"\s*:\s*\[(.*?)\]').firstMatch(node.config);
        final raw = match?.group(1) ?? '';
        final options = raw
            .split(',')
            .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
            .where((s) => s.isNotEmpty)
            .toList();
        return Wrap(
          spacing: 8,
          children: options
              .map(
                (opt) => ChoiceChip(
                  label: Text(opt),
                  selected: value == opt,
                  onSelected: (_) =>
                      cubit.updateDimensionValue(node.id, opt),
                ),
              )
              .toList(),
        );
      case 'number':
        return TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.updateDimensionValue(node.id, v),
        );
      default:
        return TextFormField(
          initialValue: value,
          onChanged: (v) => cubit.updateDimensionValue(node.id, v),
        );
    }
  }

  Widget _buildCustomField(BuildContext context, CustomFieldData f) {
    final cubit = context.read<InstanceEditorCubit>();
    switch (f.type) {
      case 'single_choice':
        final match =
            RegExp(r'"options"\s*:\s*\[(.*?)\]').firstMatch(f.config);
        final raw = match?.group(1) ?? '';
        final options = raw
            .split(',')
            .map((s) => s.trim().replaceAll('"', '').replaceAll("'", ''))
            .where((s) => s.isNotEmpty)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.name),
            Wrap(
              spacing: 8,
              children: options
                  .map(
                    (opt) => ChoiceChip(
                      label: Text(opt),
                      selected: f.value == opt,
                      onSelected: (_) =>
                          cubit.updateCustomField(f.id, value: opt),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      case 'number':
        return TextFormField(
          decoration: InputDecoration(labelText: f.name),
          initialValue: f.value,
          keyboardType: TextInputType.number,
          onChanged: (v) => cubit.updateCustomField(f.id, value: v),
        );
      default:
        return TextFormField(
          decoration: InputDecoration(labelText: f.name),
          initialValue: f.value,
          onChanged: (v) => cubit.updateCustomField(f.id, value: v),
        );
    }
  }

  void _showAddCustomFieldDialog(BuildContext context) {
    final cubit = context.read<InstanceEditorCubit>();
    final nameController = TextEditingController();
    final optionController = TextEditingController();
    String type = 'text';
    List<String> options = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setState) {
          Widget configWidget;
          if (type == 'single_choice') {
            configWidget = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: optionController,
                        decoration: const InputDecoration(labelText: '选项'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final text = optionController.text.trim();
                        if (text.isNotEmpty && !options.contains(text)) {
                          setState(() => options.add(text));
                          optionController.clear();
                        }
                      },
                      child: const Text('添加'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: options
                      .map((o) => InputChip(
                            label: Text(o),
                            onDeleted: () =>
                                setState(() => options.remove(o)),
                          ))
                      .toList(),
                ),
              ],
            );
          } else {
            configWidget = const SizedBox.shrink();
          }

          return AlertDialog(
            title: const Text('添加自定义字段'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '字段名'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(value: 'text', child: Text('文本')),
                    DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                    DropdownMenuItem(value: 'number', child: Text('数字')),
                  ],
                  onChanged: (v) => setState(() => type = v!),
                  decoration: const InputDecoration(labelText: '类型'),
                ),
                if (configWidget is! SizedBox) configWidget,
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  final config = type == 'single_choice'
                      ? jsonEncode({'options': options})
                      : '{}';
                  cubit.addCustomField(
                    nameController.text,
                    type,
                    config: config,
                  );
                  Navigator.pop(dialogContext);
                },
                child: const Text('添加'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRestoreHiddenDialog(
    BuildContext context,
    InstanceEditorState state,
  ) {
    final cubit = context.read<InstanceEditorCubit>();
    final hidden = state.dimensions
        .expand((n) => n.flatten())
        .where((f) => state.hiddenDimensionIds.contains(f.node.id))
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('恢复显示隐藏的字段'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: hidden.length,
            itemBuilder: (_, index) {
              final node = hidden[index].node;
              return ListTile(
                title: Text(node.name),
                trailing: TextButton(
                  onPressed: () {
                    cubit.restoreDimension(node.id);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('恢复显示'),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
