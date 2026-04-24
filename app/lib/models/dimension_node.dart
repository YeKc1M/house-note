import 'package:equatable/equatable.dart';

class DimensionNode extends Equatable {
  final String id;
  final String templateId;
  final String name;
  final String type;
  final String config;
  final int sortOrder;

  const DimensionNode({
    required this.id,
    required this.templateId,
    required this.name,
    required this.type,
    this.config = '{}',
    this.sortOrder = 0,
  });

  DimensionNode copyWith({
    String? id,
    String? templateId,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
  }) {
    return DimensionNode(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [id, templateId, name, type, config, sortOrder];
}
