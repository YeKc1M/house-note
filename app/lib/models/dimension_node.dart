import 'package:equatable/equatable.dart';

class FlattenedDimension {
  final DimensionNode node;
  final int depth;

  const FlattenedDimension(this.node, this.depth);
}

class DimensionNode extends Equatable {
  final String id;
  final String templateId;
  final String? parentId;
  final String name;
  final String type;
  final String config;
  final int sortOrder;
  final List<DimensionNode> children;

  const DimensionNode({
    required this.id,
    required this.templateId,
    this.parentId,
    required this.name,
    required this.type,
    this.config = '{}',
    this.sortOrder = 0,
    this.children = const [],
  });

  DimensionNode copyWith({
    String? id,
    String? templateId,
    String? parentId,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
    List<DimensionNode>? children,
  }) {
    return DimensionNode(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      type: type ?? this.type,
      config: config ?? this.config,
      sortOrder: sortOrder ?? this.sortOrder,
      children: children ?? this.children,
    );
  }

  List<FlattenedDimension> flatten({int depth = 0}) {
    final result = <FlattenedDimension>[FlattenedDimension(this, depth)];
    for (final child in children) {
      result.addAll(child.flatten(depth: depth + 1));
    }
    return result;
  }

  @override
  List<Object?> get props => [id, templateId, parentId, name, type, config, sortOrder, children];
}
