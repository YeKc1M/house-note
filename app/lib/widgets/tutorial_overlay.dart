import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/tutorial/cubit.dart';
import '../models/tutorial_step.dart';
import '../utils/tutorial_steps.dart';
import 'tutorial_spotlight_painter.dart';

class TutorialOverlay extends StatelessWidget {
  final Widget child;

  const TutorialOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        BlocBuilder<TutorialCubit, TutorialState>(
          builder: (context, state) {
            if (!state.isActive) return const SizedBox.shrink();
            return _TutorialLayer(state: state);
          },
        ),
      ],
    );
  }
}

class _TutorialLayer extends StatefulWidget {
  final TutorialState state;

  const _TutorialLayer({required this.state});

  @override
  State<_TutorialLayer> createState() => _TutorialLayerState();
}

class _TutorialLayerState extends State<_TutorialLayer> {
  Rect? _targetRect;

  @override
  void didUpdateWidget(_TutorialLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentStepIndex != widget.state.currentStepIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateTargetRect());
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTargetRect());
  }

  void _updateTargetRect() {
    final step = _getCurrentStep();
    final newRect = _resolveRect(step);
    if (_targetRect == newRect) return;
    if (_targetRect != null &&
        newRect != null &&
        _targetRect!.size == newRect.size &&
        _targetRect!.topLeft == newRect.topLeft) {
      return;
    }
    setState(() => _targetRect = newRect);
  }

  Rect? _resolveRect(TutorialStep? step) {
    if (step?.targetKey == null) return null;

    final context = step!.targetKey!.currentContext;
    if (context == null) return null;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
  }

  TutorialStep? _getCurrentStep() {
    final index = widget.state.currentStepIndex;
    if (index < 0 || index >= tutorialSteps.length) return null;
    return tutorialSteps[index];
  }

  @override
  Widget build(BuildContext context) {
    final step = _getCurrentStep();
    final rect = _targetRect;

    return Stack(
      children: [
        if (rect != null)
          IgnorePointer(
            child: CustomPaint(
              size: MediaQuery.of(context).size,
              painter: TutorialSpotlightPainter(targetRect: rect),
            ),
          )
        else
          IgnorePointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.75),
            ),
          ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: TextButton(
            onPressed: () {
              context.read<TutorialCubit>().showExitDialog();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withValues(alpha: 0.8),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('退出教程'),
          ),
        ),
        if (step != null)
          _TooltipCard(
            step: step,
            targetRect: rect,
            currentStep: widget.state.currentStepIndex + 1,
            totalSteps: tutorialSteps.length,
          ),
        if (widget.state.showExitDialog)
          const _ExitDialog(),
      ],
    );
  }
}

class _TooltipCard extends StatelessWidget {
  final TutorialStep step;
  final Rect? targetRect;
  final int currentStep;
  final int totalSteps;

  const _TooltipCard({
    required this.step,
    required this.targetRect,
    required this.currentStep,
    required this.totalSteps,
  });

  double _computeTop(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safePadding = MediaQuery.of(context).padding;
    const cardHeight = 220.0;

    double top;
    if (targetRect != null) {
      final targetBottom = targetRect!.bottom;
      final targetTop = targetRect!.top;
      if (targetBottom + cardHeight + 20 < screenSize.height - safePadding.bottom) {
        top = targetBottom + 20;
      } else {
        top = targetTop - cardHeight - 20;
      }
    } else {
      top = screenSize.height - cardHeight - safePadding.bottom - 20;
    }

    return top.clamp(
      safePadding.top + 10,
      screenSize.height - cardHeight - safePadding.bottom - 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNextButton = step.actionType != TutorialActionType.tap;

    return Positioned(
      top: _computeTop(context),
      left: 24,
      right: 24,
      child: Stack(
        children: [
          IgnorePointer(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.description,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    if (step.actionHint != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.touch_app, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            step.actionHint!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currentStep / $totalSteps',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (showNextButton)
                          const SizedBox(
                            height: 36,
                            width: 72,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showNextButton)
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {
                  context.read<TutorialCubit>().nextStep();
                },
                child: const Text('下一步'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExitDialog extends StatelessWidget {
  const _ExitDialog();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: AlertDialog(
          title: const Text('退出教程'),
          content: const Text('确定要退出教程吗？'),
          actions: [
            TextButton(
              onPressed: () {
                context.read<TutorialCubit>().hideExitDialog();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                context.read<TutorialCubit>().exitWithoutCleanup();
              },
              child: const Text('退出并保留数据'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TutorialCubit>().exitAndCleanup();
              },
              child: const Text('退出并删除数据'),
            ),
          ],
        ),
      ),
    );
  }
}
