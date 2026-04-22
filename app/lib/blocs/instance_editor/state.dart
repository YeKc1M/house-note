import 'package:equatable/equatable.dart';
import '../../models/dimension_node.dart';

class CustomFieldData extends Equatable {
  final String id;
  final String name;
  final String type;
  final String value;
  final String config;

  const CustomFieldData({
    required this.id,
    required this.name,
    required this.type,
    this.value = '',
    this.config = '{}',
  });

  CustomFieldData copyWith({String? name, String? type, String? value, String? config}) {
    return CustomFieldData(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [id, name, type, value, config];
}

class ChildInstanceSummary extends Equatable {
  final String id;
  final String name;
  final String templateId;
  final Map<String, String> thumbnailValues;

  const ChildInstanceSummary({
    required this.id,
    required this.name,
    required this.templateId,
    this.thumbnailValues = const {},
  });

  ChildInstanceSummary copyWith({
    String? id,
    String? name,
    String? templateId,
    Map<String, String>? thumbnailValues,
  }) {
    return ChildInstanceSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      thumbnailValues: thumbnailValues ?? this.thumbnailValues,
    );
  }

  @override
  List<Object?> get props => [id, name, templateId, thumbnailValues];
}

class InstanceEditorState extends Equatable {
  final String name;
  final String? templateId;
  final String? parentInstanceId;
  final List<DimensionNode> dimensions;
  final Map<String, String> dimensionValues;
  final Set<String> hiddenDimensionIds;
  final List<CustomFieldData> customFields;
  final Map<String, List<ChildInstanceSummary>> childInstances;

  const InstanceEditorState({
    this.name = '',
    this.templateId,
    this.parentInstanceId,
    this.dimensions = const [],
    this.dimensionValues = const {},
    this.hiddenDimensionIds = const {},
    this.customFields = const [],
    this.childInstances = const {},
  });

  InstanceEditorState copyWith({
    String? name,
    String? templateId,
    String? parentInstanceId,
    List<DimensionNode>? dimensions,
    Map<String, String>? dimensionValues,
    Set<String>? hiddenDimensionIds,
    List<CustomFieldData>? customFields,
    Map<String, List<ChildInstanceSummary>>? childInstances,
  }) {
    return InstanceEditorState(
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      parentInstanceId: parentInstanceId ?? this.parentInstanceId,
      dimensions: dimensions ?? this.dimensions,
      dimensionValues: dimensionValues ?? this.dimensionValues,
      hiddenDimensionIds: hiddenDimensionIds ?? this.hiddenDimensionIds,
      customFields: customFields ?? this.customFields,
      childInstances: childInstances ?? this.childInstances,
    );
  }

  @override
  List<Object?> get props => [
    name, templateId, parentInstanceId, dimensions,
    dimensionValues, hiddenDimensionIds, customFields, childInstances,
  ];
}
