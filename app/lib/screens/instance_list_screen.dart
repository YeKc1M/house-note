import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/instance_list/cubit.dart';
import '../data/database.dart';
import '../data/instance_repository.dart';
import '../data/template_repository.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/instance_card.dart';

class InstanceListScreen extends StatelessWidget {
  const InstanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: BlocBuilder<InstanceListCubit, InstanceListState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: BreadcrumbBar(
                  breadcrumbs: state.breadcrumbs,
                  onTap: (index) => context.read<InstanceListCubit>().navigateToBreadcrumb(index),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.instances.length,
                  itemBuilder: (context, index) {
                    final inst = state.instances[index];
                    return InstanceCard(
                      instance: inst,
                      thumbnailValues: const {}, // populated by repository lookup in real usage
                      onTap: () {
                        final templateRepo = context.read<TemplateRepository>();
                        templateRepo.getRefSubtemplateDimensions(inst.templateId).then((dims) async {
                          if (dims.isNotEmpty) {
                            final newCrumbs = [
                              ...state.breadcrumbs,
                              Breadcrumb(id: inst.id, name: inst.name),
                            ];
                            if (context.mounted) {
                              context.read<InstanceListCubit>().loadChildren(inst.id, newCrumbs);
                            }
                          } else {
                            if (context.mounted) {
                              Navigator.pushNamed(
                                context,
                                '/instanceEditor',
                                arguments: {'instanceId': inst.id},
                              );
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'instanceListFab',
        onPressed: () async {
          final cubit = context.read<InstanceListCubit>();
          final state = cubit.state;
          final templateRepo = context.read<TemplateRepository>();
          final instanceRepo = context.read<InstanceRepository>();
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          final templates = await templateRepo.watchAllTemplates().first;
          if (templates.isEmpty) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('请先创建模板')),
            );
            return;
          }
          if (state.breadcrumbs.isEmpty) {
            // Root: pick template
            if (!context.mounted) return;
            final selected = await showDialog<Template>(
              context: context,
              builder: (_) => SimpleDialog(
                title: const Text('选择模板'),
                children: templates.map((t) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, t),
                  child: Text(t.name),
                )).toList(),
              ),
            );
            if (selected != null && context.mounted) {
              navigator.pushNamed('/instanceEditor', arguments: {
                'templateId': selected.id,
              });
            }
          } else {
            // Child: look up ref_subtemplate dimensions
            final parentId = state.breadcrumbs.last.id;
            final parentData = await instanceRepo.getInstanceById(parentId);
            if (parentData == null) return;
            final refDims = await templateRepo.getRefSubtemplateDimensions(parentData.instance.templateId);
            if (refDims.isEmpty) return;
            String? selectedTemplateId;
            if (refDims.length == 1) {
              final config = refDims.first.config;
              final match = RegExp(r'"ref_template_id"\s*:\s*"([^"]+)"').firstMatch(config);
              selectedTemplateId = match?.group(1);
            } else {
              if (!context.mounted) return;
              final allTemplates = await templateRepo.watchAllTemplates().first;
              final refs = refDims.map((d) {
                final match = RegExp(r'"ref_template_id"\s*:\s*"([^"]+)"').firstMatch(d.config);
                final tid = match?.group(1);
                return allTemplates.firstWhere((t) => t.id == tid);
              }).toList();
              if (!context.mounted) return;
              final selected = await showDialog<Template>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('选择要新建的子类型'),
                  children: refs.map((t) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, t),
                    child: Text(t.name),
                  )).toList(),
                ),
              );
              selectedTemplateId = selected?.id;
            }
            if (selectedTemplateId != null && context.mounted) {
              navigator.pushNamed('/instanceEditor', arguments: {
                'templateId': selectedTemplateId,
                'parentInstanceId': parentId,
              });
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
