import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/cubit.dart';
import '../blocs/tutorial/cubit.dart';
import '../data/database.dart';
import '../data/default_template_loader.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          const ListTile(title: Text('数据管理', style: TextStyle(fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('导出全部数据'),
            subtitle: const Text('生成 house-note-export.yaml'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导出功能将在 Subproject 2 实现')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('导入数据'),
            subtitle: const Text('从 YAML 文件导入'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('导入功能将在 Subproject 2 实现')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('恢复默认模板'),
            subtitle: const Text('重新创建被删除的默认模板'),
            onTap: () async {
              final db = context.read<AppDatabase>();
              final loader = DefaultTemplateLoader(db);
              final count = await loader.restoreDefaults();
              if (context.mounted) {
                final message = count > 0
                    ? '已恢复 $count 个模板'
                    : '所有默认模板已存在，无需恢复';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
          ),
          const Divider(),
          const ListTile(title: Text('局域网同步', style: TextStyle(fontWeight: FontWeight.bold))),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) => SwitchListTile(
              title: const Text('启用局域网同步'),
              subtitle: Text(state.lanSyncEnabled ? '已开启（IP 显示在 Subproject 3）' : '已关闭'),
              value: state.lanSyncEnabled,
              onChanged: (v) => context.read<SettingsCubit>().toggleLanSync(v),
            ),
          ),
          const Divider(),
          const ListTile(title: Text('帮助', style: TextStyle(fontWeight: FontWeight.bold))),
          BlocBuilder<TutorialCubit, TutorialState>(
            builder: (context, tutorialState) {
              return ListTile(
                leading: const Icon(Icons.school),
                title: const Text('查看教程'),
                subtitle: const Text('重新运行新手指引'),
                enabled: !tutorialState.isActive,
                onTap: () async {
                  final cubit = context.read<TutorialCubit>();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('重新开始教程'),
                      content: const Text('教程中创建的数据可以在退出时删除。确定开始？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('开始'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    cubit.startTutorial();
                  }
                },
              );
            },
          ),
          const Divider(),
          const ListTile(title: Text('关于', style: TextStyle(fontWeight: FontWeight.bold))),
          const ListTile(title: Text('House Note'), subtitle: Text('v0.1.0')),
        ],
      ),
    );
  }
}
