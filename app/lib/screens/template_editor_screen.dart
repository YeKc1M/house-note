import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/template_editor/cubit.dart';
import '../models/dimension_node.dart';
import '../widgets/dimension_tree.dart';

class TemplateEditorScreen extends StatefulWidget {
  final String? templateId;

  const TemplateEditorScreen({super.key, this.templateId});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      context.read<TemplateEditorCubit>().loadTemplate(widget.templateId!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<TemplateEditorCubit, TemplateEditorState>(
          builder: (context, state) => Text(state.templateName.isEmpty ? '新建模板' : state.templateName),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final cubit = context.read<TemplateEditorCubit>();
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              await cubit.saveTemplate();
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('模板保存成功')),
                );
                navigator.pop();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TemplateEditorCubit, TemplateEditorState>(
        builder: (context, state) {
          if (_nameController.text != state.templateName) {
            _nameController.text = state.templateName;
            _nameController.selection = TextSelection.collapsed(offset: state.templateName.length);
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '模板名称'),
                  onChanged: (v) => context.read<TemplateEditorCubit>().setTemplateName(v),
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                const Text('维度项', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DimensionTree(
                  nodes: state.dimensions,
                  onEdit: (node) => _showDimensionDialog(context, node: node),
                  onDelete: (id) => context.read<TemplateEditorCubit>().removeDimension(id),
                  onReorder: (oldIndex, newIndex, parentId) =>
                      context.read<TemplateEditorCubit>().moveDimension(
                        oldIndex: oldIndex,
                        newIndex: newIndex,
                        targetParentId: parentId,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showDimensionDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('添加维度项'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDimensionDialog(context, initialType: 'group'),
                      icon: const Icon(Icons.folder),
                      label: const Text('添加子维度组'),
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

  void _showDimensionDialog(BuildContext context, {DimensionNode? node, String initialType = 'text'}) {
    final nameController = TextEditingController(text: node?.name ?? '');
    String type = node?.type ?? initialType;
    final configController = TextEditingController(text: node?.config ?? '{}');
    final cubit = context.read<TemplateEditorCubit>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(node == null ? '添加维度' : '编辑维度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称')),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'text', child: Text('文本')),
                  DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                  DropdownMenuItem(value: 'boolean', child: Text('布尔')),
                  DropdownMenuItem(value: 'number', child: Text('数字')),
                  DropdownMenuItem(value: 'group', child: Text('子维度组')),
                  DropdownMenuItem(value: 'ref_subtemplate', child: Text('引用子模板')),
                ],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: '类型'),
              ),
              TextField(
                controller: configController,
                decoration: const InputDecoration(labelText: '配置 (JSON)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('取消')),
            TextButton(
              onPressed: () {
                if (node == null) {
                  cubit.addDimension(
                    name: nameController.text,
                    type: type,
                    config: configController.text,
                  );
                } else {
                  cubit.updateDimension(
                    node.id,
                    name: nameController.text,
                    type: type,
                    config: configController.text,
                  );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
