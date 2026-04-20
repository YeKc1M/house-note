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
  final Map<String, Map<String, String>> thumbnailValues;

  const InstanceListState({
    this.instances = const [],
    this.breadcrumbs = const [],
    this.thumbnailValues = const {},
  });

  InstanceListState copyWith({
    List<Instance>? instances,
    List<Breadcrumb>? breadcrumbs,
    Map<String, Map<String, String>>? thumbnailValues,
  }) {
    return InstanceListState(
      instances: instances ?? this.instances,
      breadcrumbs: breadcrumbs ?? this.breadcrumbs,
      thumbnailValues: thumbnailValues ?? this.thumbnailValues,
    );
  }

  @override
  List<Object?> get props => [instances, breadcrumbs, thumbnailValues];
}
