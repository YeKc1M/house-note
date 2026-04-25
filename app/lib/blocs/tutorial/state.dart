import 'package:equatable/equatable.dart';

class TutorialState extends Equatable {
  final bool isActive;
  final int currentStepIndex;
  final int? startTimestamp;
  final bool showExitDialog;
  final Set<String> createdTemplateIds;
  final Set<String> createdInstanceIds;

  const TutorialState({
    this.isActive = false,
    this.currentStepIndex = 0,
    this.startTimestamp,
    this.showExitDialog = false,
    this.createdTemplateIds = const {},
    this.createdInstanceIds = const {},
  });

  TutorialState copyWith({
    bool? isActive,
    int? currentStepIndex,
    int? startTimestamp,
    bool? showExitDialog,
    Set<String>? createdTemplateIds,
    Set<String>? createdInstanceIds,
  }) {
    return TutorialState(
      isActive: isActive ?? this.isActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      showExitDialog: showExitDialog ?? this.showExitDialog,
      createdTemplateIds: createdTemplateIds ?? this.createdTemplateIds,
      createdInstanceIds: createdInstanceIds ?? this.createdInstanceIds,
    );
  }

  @override
  List<Object?> get props => [
        isActive,
        currentStepIndex,
        startTimestamp,
        showExitDialog,
        createdTemplateIds,
        createdInstanceIds,
      ];
}
