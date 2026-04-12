import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_editor/cubit.dart';
import 'package:house_note/models/dimension_node.dart';

void main() {
  group('TemplateEditorCubit', () {
    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'adds dimension',
      build: () => TemplateEditorCubit(),
      act: (cubit) {
        cubit.setTemplateName('Test');
        cubit.addDimension(name: 'D1', type: 'text');
      },
      expect: () => [
        TemplateEditorState(templateName: 'Test', dimensions: const [], availableTemplates: const []),
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.name == 'D1'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moves dimension into group',
      build: () => TemplateEditorCubit(),
      seed: () => TemplateEditorState(
        templateName: 'T',
        dimensions: [
          DimensionNode(id: 'g', templateId: '', name: 'Group', type: 'group', children: const []),
          DimensionNode(id: 'd', templateId: '', name: 'Dim', type: 'text', children: const []),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 1, newIndex: 0, targetParentId: 'g'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final group = s.dimensions.firstWhere((d) => d.id == 'g');
          return group.children.length == 1 && group.children.first.id == 'd';
        }),
      ],
    );
  });
}
