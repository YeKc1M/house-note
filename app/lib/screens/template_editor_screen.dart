import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/template_editor/cubit.dart';
import '../data/database.dart';
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
          if (_nameController.text.isEmpty && state.templateName.isNotEmpty) {
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
                if (state.thumbnailDimensionIds.isNotEmpty) ...[
                  const Text('缩略图显示字段', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: state.thumbnailDimensionIds.asMap().entries.map((e) {
                      final dim = state.dimensions
                          .expand((n) => n.flatten())
                          .map((f) => f.node)
                          .firstWhereOrNull((n) => n.id == e.value);
                      if (dim == null) return const SizedBox.shrink();
                      return Chip(
                        label: Text(dim.name),
                        deleteIcon: const Icon(Icons.arrow_back),
                        onDeleted: e.key == 0
                            ? null
                            : () => context.read<TemplateEditorCubit>().reorderThumbnailDimensions(e.key, e.key - 1),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
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
                  thumbnailDimensionIds: state.thumbnailDimensionIds.toSet(),
                  onToggleThumbnail: (id) => context.read<TemplateEditorCubit>().toggleThumbnailDimension(id),
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
    showDialog(
      context: context,
      builder: (_) => _DimensionDialog(
        node: node,
        initialType: initialType,
        cubit: context.read<TemplateEditorCubit>(),
      ),
    );
  }
}

class _DimensionDialog extends StatefulWidget {
  final DimensionNode? node;
  final String initialType;
  final TemplateEditorCubit cubit;

  const _DimensionDialog({this.node, this.initialType = 'text', required this.cubit});

  @override
  State<_DimensionDialog> createState() => _DimensionDialogState();
}

class _DimensionDialogState extends State<_DimensionDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _configController;
  late final TextEditingController _optionController;
  late String _type;
  List<String> _options = [];
  List<Template> _templates = [];
  String? _selectedTemplateId;
  bool _templatesLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.node?.name ?? '');
    _type = widget.node?.type ?? widget.initialType;
    _configController = TextEditingController(text: widget.node?.config ?? '{}');
    _optionController = TextEditingController();
    if (widget.node?.config != null && widget.node!.config.isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.node!.config) as Map<String, dynamic>;
        if (decoded['options'] is List) {
          _options = (decoded['options'] as List).cast<String>();
        }
        if (decoded['ref_template_id'] is String) {
          _selectedTemplateId = decoded['ref_template_id'] as String;
        }
      } catch (_) {}
    }
    if (_type == 'ref_subtemplate') {
      _loadTemplates();
    }
  }

  Future<void> _loadTemplates() async {
    setState(() => _templatesLoading = true);
    final templates = await widget.cubit.getAllTemplates();
    setState(() {
      _templates = templates;
      _templatesLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _configController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  String _buildConfig() {
    if (_type == 'single_choice') {
      return jsonEncode({'options': _options});
    }
    if (_type == 'ref_subtemplate' && _selectedTemplateId != null) {
      return jsonEncode({'ref_template_id': _selectedTemplateId});
    }
    return _configController.text;
  }

  @override
  Widget build(BuildContext context) {
    Widget configWidget;
    if (_type == 'single_choice') {
      configWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _optionController,
                  decoration: const InputDecoration(labelText: '选项'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final text = _optionController.text.trim();
                  if (text.isNotEmpty && !_options.contains(text)) {
                    setState(() => _options.add(text));
                    _optionController.clear();
                  }
                },
                child: const Text('添加'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _options
                .map((o) => InputChip(
                      label: Text(o),
                      onDeleted: () => setState(() => _options.remove(o)),
                    ))
                .toList(),
          ),
        ],
      );
    } else if (_type == 'ref_subtemplate') {
      configWidget = _templatesLoading
          ? const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            )
          : DropdownButtonFormField<String>(
              value: _selectedTemplateId,
              items: _templates
                  .where((t) => t.id != widget.cubit.currentTemplateId)
                  .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedTemplateId = v),
              decoration: const InputDecoration(labelText: '选择引用的模板'),
              isExpanded: true,
            );
    } else {
      configWidget = const SizedBox.shrink();
    }
    return AlertDialog(
      title: Text(widget.node == null ? '添加维度' : '编辑维度'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '名称')),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: 'text', child: Text('文本')),
                DropdownMenuItem(value: 'single_choice', child: Text('单选')),
                DropdownMenuItem(value: 'boolean', child: Text('布尔')),
                DropdownMenuItem(value: 'number', child: Text('数字')),
                DropdownMenuItem(value: 'group', child: Text('子维度组')),
                DropdownMenuItem(value: 'ref_subtemplate', child: Text('引用子模板')),
              ],
              onChanged: (v) {
                setState(() => _type = v!);
                if (_type == 'ref_subtemplate') {
                  _loadTemplates();
                }
              },
              decoration: const InputDecoration(labelText: '类型'),
            ),
            if (configWidget is! SizedBox) ...[
              const SizedBox(height: 8),
              configWidget,
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        TextButton(
          onPressed: () {
            final config = _buildConfig();
            if (widget.node == null) {
              widget.cubit.addDimension(
                name: _nameController.text,
                type: _type,
                config: config,
              );
            } else {
              widget.cubit.updateDimension(
                widget.node!.id,
                name: _nameController.text,
                type: _type,
                config: config,
              );
            }
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
