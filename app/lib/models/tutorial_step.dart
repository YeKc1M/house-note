import 'package:flutter/widgets.dart';

enum TutorialActionType {
  tap,
  type,
  swipe,
  observe,
  navigate,
}

class TutorialStep {
  final String id;
  final String title;
  final String description;
  final String? actionHint;
  final GlobalKey? targetKey;
  final TutorialActionType actionType;
  final String? expectedRoute;
  final String? defaultInput;
  final bool requiresUserAction;

  const TutorialStep({
    required this.id,
    required this.title,
    required this.description,
    this.actionHint,
    this.targetKey,
    required this.actionType,
    this.expectedRoute,
    this.defaultInput,
    this.requiresUserAction = true,
  });
}
