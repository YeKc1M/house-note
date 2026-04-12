import 'package:equatable/equatable.dart';
import '../../data/database.dart';
import '../../models/dimension_node.dart';

class TemplateEditorState extends Equatable {
  final String templateName;
  final List<DimensionNode> dimensions;
  final List<Template> availableTemplates;

  const TemplateEditorState({
    this.templateName = '',
    this.dimensions = const [],
    this.availableTemplates = const [],
  });

  TemplateEditorState copyWith({
    String? templateName,
    List<DimensionNode>? dimensions,
    List<Template>? availableTemplates,
  }) {
    return TemplateEditorState(
      templateName: templateName ?? this.templateName,
      dimensions: dimensions ?? this.dimensions,
      availableTemplates: availableTemplates ?? this.availableTemplates,
    );
  }

  @override
  List<Object?> get props => [templateName, dimensions, availableTemplates];
}
