import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/settings/cubit.dart';
import '../widgets/tutorial_mockups.dart';
import '../widgets/tutorial_page.dart';

class TutorialScreen extends StatefulWidget {
  final bool isFirstRun;

  const TutorialScreen({super.key, this.isFirstRun = false});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  static const _pageCount = 7;

  final List<_PageData> _pages = const [
    _PageData(
      title: '欢迎来到 House Note',
      description: 'House Note 是一款帮你结构化记录租房看房信息的工具。',
      illustration: _WelcomeIllustration(),
    ),
    _PageData(
      title: '第一步：创建模板',
      description: '模板定义了你看房时要记录哪些维度。比如「房子模板」可以包含朝向、楼层、户型等字段。',
      illustration: MockTemplateEditor(),
    ),
    _PageData(
      title: '第二步：建立层级关系',
      description: '通过「引用子模板」维度，可以把多个模板串联起来。比如：小区 → 房子 → 房间。',
      illustration: MockFlowDiagram(),
    ),
    _PageData(
      title: '第三步：设置卡片缩略图',
      description: '在模板编辑器中点击眼睛图标，可以选择在实例卡片上显示哪些字段，方便快速对比。',
      illustration: MockInstanceCard(),
    ),
    _PageData(
      title: '第四步：录入看房记录',
      description: '在首页选择模板创建记录。点击进入实例后，可以继续添加子实例，按层级记录每一套房子的信息。',
      illustration: MockBreadcrumbList(),
    ),
    _PageData(
      title: '删除与管理',
      description: '左滑实例卡片可删除。删除父实例会同时删除其下所有子实例。删除模板则会删除该模板下的全部数据，请谨慎操作。',
      illustration: MockSwipeCard(),
    ),
    _PageData(
      title: '开始记录吧',
      description: '你已经了解了 House Note 的核心功能。快去创建你的第一个模板吧！',
      illustration: _DoneIllustration(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _finish() {
    if (widget.isFirstRun) {
      context.read<SettingsCubit>().markTutorialSeen();
    }
    Navigator.pop(context);
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _controller.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('快速入门'),
        actions: [
          TextButton(
            onPressed: _finish,
            child: const Text('跳过'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: _onPageChanged,
              itemCount: _pageCount,
              itemBuilder: (context, index) => TutorialPage(
                title: _pages[index].title,
                description: _pages[index].description,
                illustration: _pages[index].illustration,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(_pageCount, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
                if (_currentPage < _pageCount - 1)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('下一页'),
                  )
                else
                  ElevatedButton(
                    onPressed: _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('完成'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  final String title;
  final String description;
  final Widget illustration;

  const _PageData({
    required this.title,
    required this.description,
    required this.illustration,
  });
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.layers, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 8),
              Text('模板', style: TextStyle(color: Colors.deepPurple.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Icon(Icons.arrow_downward, color: Colors.grey),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home, size: 40, color: Colors.green),
              const SizedBox(height: 8),
              Text('实例', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DoneIllustration extends StatelessWidget {
  const _DoneIllustration();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_circle,
      size: 100,
      color: Colors.green.shade400,
    );
  }
}
