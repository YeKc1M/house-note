import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool lanSyncEnabled;
  final bool tutorialSeen;

  const SettingsState({
    this.lanSyncEnabled = false,
    this.tutorialSeen = false,
  });

  SettingsState copyWith({bool? lanSyncEnabled, bool? tutorialSeen}) {
    return SettingsState(
      lanSyncEnabled: lanSyncEnabled ?? this.lanSyncEnabled,
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  @override
  List<Object?> get props => [lanSyncEnabled, tutorialSeen];
}
