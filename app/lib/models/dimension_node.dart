import 'package:equatable/equatable.dart';

class FlattenedDimension extends Equatable {
  final DimensionNode node;
  final int depth;

  const FlattenedDimension(this.node, this.depth);

  @override
  List<Object?> get props => [node, depth];
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

  static const _sentinel = Object();

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
    Object? parentId = _sentinel,
    String? name,
    String? type,
    String? config,
    int? sortOrder,
    List<DimensionNode>? children,
  }) {
    return DimensionNode(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      parentId: parentId == _sentinel ? this.parentId : parentId as String?,
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
