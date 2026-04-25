import 'package:equatable/equatable.dart';

class TutorialState extends Equatable {
  final bool isActive;
  final int currentStepIndex;
  final int? startTimestamp;
  final bool showExitDialog;

  const TutorialState({
    this.isActive = false,
    this.currentStepIndex = 0,
    this.startTimestamp,
    this.showExitDialog = false,
  });

  TutorialState copyWith({
    bool? isActive,
    int? currentStepIndex,
    int? startTimestamp,
    bool? showExitDialog,
  }) {
    return TutorialState(
      isActive: isActive ?? this.isActive,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      startTimestamp: startTimestamp ?? this.startTimestamp,
      showExitDialog: showExitDialog ?? this.showExitDialog,
    );
  }

  @override
  List<Object?> get props => [
        isActive,
        currentStepIndex,
        startTimestamp,
        showExitDialog,
      ];
}
