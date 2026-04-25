import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blocs/instance_editor/cubit.dart';
import 'blocs/instance_list/cubit.dart';
import 'blocs/settings/cubit.dart';
import 'blocs/template_editor/cubit.dart';
import 'blocs/template_list/cubit.dart';
import 'blocs/tutorial/cubit.dart';
import 'data/database.dart';
import 'data/instance_repository.dart';
import 'data/template_repository.dart';
import 'screens/instance_editor_screen.dart';
import 'screens/instance_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/template_editor_screen.dart';
import 'screens/template_list_screen.dart';
import 'utils/tutorial_route_observer.dart';
import 'utils/tutorial_steps.dart';
import 'widgets/tutorial_overlay.dart';

class HouseNoteApp extends StatelessWidget {
  final AppDatabase database;
  final SharedPreferences prefs;

  const HouseNoteApp({super.key, required this.database, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final templateRepo = TemplateRepository(database);
    final instanceRepo = InstanceRepository(database);
    final tutorialCubit = TutorialCubit(prefs, database);
    final routeObserver = TutorialRouteObserver(tutorialCubit);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: database),
        RepositoryProvider.value(value: templateRepo),
        RepositoryProvider.value(value: instanceRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: tutorialCubit),
        ],
        child: MaterialApp(
          title: 'House Note',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: '/',
          builder: (context, child) => TutorialOverlay(child: child!),
          navigatorObservers: [routeObserver],
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => BlocProvider(
                    create: (_) => SettingsCubit(prefs),
                    child: _MainShell(
                      prefs: prefs,
                      tutorialCubit: tutorialCubit,
                    ),
                  ),
                );
              case '/templateEditor':
                final templateId = settings.arguments as String?;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => BlocProvider(
                    create: (_) => TemplateEditorCubit(templateRepo),
                    child: TemplateEditorScreen(templateId: templateId),
                  ),
                );
              case '/instanceEditor':
                final args = settings.arguments as Map<String, dynamic>?;
                return MaterialPageRoute(
                  settings: settings,
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
      ),
    );
  }
}

class _MainShell extends StatefulWidget {
  final SharedPreferences prefs;
  final TutorialCubit tutorialCubit;

  const _MainShell({
    required this.prefs,
    required this.tutorialCubit,
  });

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _index = 0;
  bool _dialogShown = false;

  int _tabIndexForStep(String? stepId) {
    return switch (stepId) {
      'template_tab_intro' => 1,
      'create_first_template' => 1,
      'enter_template_name' => 1,
      'add_dimension' => 1,
      'configure_dimension' => 1,
      'add_more_dimensions' => 1,
      'set_thumbnail' => 1,
      'save_template' => 1,
      'create_second_template' => 1,
      'configure_community_template' => 1,
      'instance_tab_intro' => 0,
      'create_instance' => 0,
      'enter_instance_details' => 0,
      'navigate_into_instance' => 0,
      'create_child_instance' => 0,
      'swipe_delete_child' => 0,
      'confirm_delete_child' => 0,
      'create_another_child' => 0,
      'navigate_back' => 0,
      'swipe_delete_parent' => 0,
      'confirm_cascade_delete' => 0,
      _ => 0,
    };
  }

  @override
  void initState() {
    super.initState();
    final tutorialState = widget.tutorialCubit.state;
    if (tutorialState.isActive) {
      final steps = getTutorialSteps();
      final stepIndex = tutorialState.currentStepIndex;
      if (stepIndex >= 0 && stepIndex < steps.length) {
        _index = _tabIndexForStep(steps[stepIndex].id);
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _showTutorialPrompt());
  }

  void _showTutorialPrompt() {
    if (_dialogShown) return;
    final settingsCubit = context.read<SettingsCubit>();
    if (settingsCubit.state.tutorialSeen) return;

    _dialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('欢迎使用 House Note'),
        content: const Text('这是您第一次使用。是否查看快速入门教程？'),
        actions: [
          TextButton(
            onPressed: () {
              settingsCubit.markTutorialSeen();
              Navigator.pop(dialogContext);
            },
            child: const Text('跳过'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsCubit.markTutorialSeen();
              Navigator.pop(dialogContext);
              widget.tutorialCubit.startTutorial();
            },
            child: const Text('查看教程'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templateRepo = context.read<TemplateRepository>();
    final instanceRepo = context.read<InstanceRepository>();

    final pages = [
      BlocProvider(
        create: (_) => InstanceListCubit(instanceRepo, templateRepo)..loadTopLevel(),
        child: const InstanceListScreen(),
      ),
      BlocProvider(
        create: (_) => TemplateListCubit(templateRepo)..load(),
        child: const TemplateListScreen(),
      ),
      const SettingsScreen(),
    ];

    return BlocListener<TutorialCubit, TutorialState>(
      listenWhen: (previous, current) =>
          previous.currentStepIndex != current.currentStepIndex,
      listener: (context, state) {
        if (!state.isActive) return;
        final steps = getTutorialSteps();
        if (state.currentStepIndex < 0 ||
            state.currentStepIndex >= steps.length) {
          return;
        }
        final step = steps[state.currentStepIndex];
        final targetIndex = _tabIndexForStep(step.id);
        if (targetIndex != _index) {
          setState(() => _index = targetIndex);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
