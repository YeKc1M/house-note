import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/instance_editor/cubit.dart';
import 'blocs/instance_list/cubit.dart';
import 'blocs/settings/cubit.dart';
import 'blocs/template_editor/cubit.dart';
import 'blocs/template_list/cubit.dart';
import 'data/database.dart';
import 'data/instance_repository.dart';
import 'data/template_repository.dart';
import 'screens/instance_editor_screen.dart';
import 'screens/instance_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/template_editor_screen.dart';
import 'screens/template_list_screen.dart';

class HouseNoteApp extends StatelessWidget {
  final AppDatabase database;

  const HouseNoteApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    final templateRepo = TemplateRepository(database);
    final instanceRepo = InstanceRepository(database);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: templateRepo),
        RepositoryProvider.value(value: instanceRepo),
      ],
      child: MaterialApp(
        title: 'House Note',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const _MainShell());
            case '/templateEditor':
              final templateId = settings.arguments as String?;
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => TemplateEditorCubit(templateRepo),
                  child: TemplateEditorScreen(templateId: templateId),
                ),
              );
            case '/instanceEditor':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => InstanceEditorCubit(instanceRepo, templateRepo),
                  child: InstanceEditorScreen(
                    instanceId: args?['instanceId'] as String?,
                    templateId: args?['templateId'] as String?,
                    parentInstanceId: args?['parentInstanceId'] as String?,
                  ),
                ),
              );
          }
          return null;
        },
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final templateRepo = context.read<TemplateRepository>();
    final instanceRepo = context.read<InstanceRepository>();

    final pages = [
      BlocProvider(
        create: (_) => InstanceListCubit(instanceRepo)..loadTopLevel(),
        child: const InstanceListScreen(),
      ),
      BlocProvider(
        create: (_) => TemplateListCubit(templateRepo)..load(),
        child: const TemplateListScreen(),
      ),
      BlocProvider(
        create: (_) => SettingsCubit(),
        child: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.layers), label: '模板'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
