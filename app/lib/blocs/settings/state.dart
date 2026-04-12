import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool lanSyncEnabled;

  const SettingsState({this.lanSyncEnabled = false});

  SettingsState copyWith({bool? lanSyncEnabled}) {
    return SettingsState(lanSyncEnabled: lanSyncEnabled ?? this.lanSyncEnabled);
  }

  @override
  List<Object?> get props => [lanSyncEnabled];
}
