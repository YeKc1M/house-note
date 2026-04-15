import 'package:equatable/equatable.dart';
import '../../models/dimension_node.dart';

class TemplateEditorState extends Equatable {
  final String templateName;
  final List<DimensionNode> dimensions;
  final List<String> thumbnailDimensionIds;

  const TemplateEditorState({
    this.templateName = '',
    this.dimensions = const [],
    this.thumbnailDimensionIds = const [],
  });

  TemplateEditorState copyWith({
    String? templateName,
    List<DimensionNode>? dimensions,
    List<String>? thumbnailDimensionIds,
  }) {
    return TemplateEditorState(
      templateName: templateName ?? this.templateName,
      dimensions: dimensions ?? this.dimensions,
      thumbnailDimensionIds: thumbnailDimensionIds ?? this.thumbnailDimensionIds,
    );
  }

  @override
  List<Object?> get props => [templateName, dimensions, thumbnailDimensionIds];
}
