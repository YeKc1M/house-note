import 'package:equatable/equatable.dart';
import '../../models/dimension_node.dart';

class TemplateEditorState extends Equatable {
  final String templateName;
  final List<DimensionNode> dimensions;

  const TemplateEditorState({
    this.templateName = '',
    this.dimensions = const [],
  });

  TemplateEditorState copyWith({
    String? templateName,
    List<DimensionNode>? dimensions,
  }) {
    return TemplateEditorState(
      templateName: templateName ?? this.templateName,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  @override
  List<Object?> get props => [templateName, dimensions];
}
