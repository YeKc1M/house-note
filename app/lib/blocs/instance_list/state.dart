import 'package:equatable/equatable.dart';
import '../../data/database.dart';

class Breadcrumb {
  final String id;
  final String name;

  const Breadcrumb({required this.id, required this.name});
}

class InstanceListState extends Equatable {
  final List<Instance> instances;
  final List<Breadcrumb> breadcrumbs;

  const InstanceListState({this.instances = const [], this.breadcrumbs = const []});

  InstanceListState copyWith({List<Instance>? instances, List<Breadcrumb>? breadcrumbs}) {
    return InstanceListState(
      instances: instances ?? this.instances,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
    );
  }

  @override
  List<Object?> get props => [instances, breadcrumbs];
}
