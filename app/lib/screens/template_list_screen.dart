import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/template_list/cubit.dart';
import '../utils/tutorial_keys.dart';

class TemplateListScreen extends StatelessWidget {
  const TemplateListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模板管理')),
      body: BlocBuilder<TemplateListCubit, TemplateListState>(
        builder: (context, state) {
          if (state.templates.isEmpty) {
            return const Center(child: Text('暂无模板，点击右下角添加'));
          }
          return ListView.builder(
            itemCount: state.templates.length,
            itemBuilder: (context, index) {
              final t = state.templates[index];
              return ListTile(
                title: Text(t.name),
                subtitle: Text('更新于 ${DateTime.fromMillisecondsSinceEpoch(t.updatedAt)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final cubit = context.read<TemplateListCubit>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('确认删除'),
                        content: const Text('删除模板将同时删除其下所有实例。确认删除？'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('删除')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      cubit.deleteTemplate(t.id);
                    }
                  },
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/templateEditor', arguments: t.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: TutorialKeys.templateListFab,
        heroTag: 'templateListFab',
        onPressed: () => Navigator.pushNamed(context, '/templateEditor'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
