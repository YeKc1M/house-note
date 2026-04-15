import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_editor/cubit.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:house_note/models/dimension_node.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  group('TemplateEditorCubit', () {
    late MockTemplateRepository repo;

    setUp(() {
      repo = MockTemplateRepository();
    });

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'setTemplateName updates state',
      build: () => TemplateEditorCubit(repo),
      act: (cubit) => cubit.setTemplateName('Test'),
      expect: () => [
        const TemplateEditorState(templateName: 'Test'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'adds dimension',
      build: () => TemplateEditorCubit(repo),
      act: (cubit) {
        cubit.setTemplateName('Test');
        cubit.addDimension(name: 'D1', type: 'text');
      },
      expect: () => [
        const TemplateEditorState(templateName: 'Test'),
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.name == 'D1'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'updateDimension updates name type config',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'd', templateId: '', name: 'Dim', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.updateDimension('d', name: 'Updated', type: 'number', config: '{"max":10}'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final d = s.dimensions.first;
          return d.name == 'Updated' && d.type == 'number' && d.config == '{"max":10}';
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'removeDimension removes node',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
          DimensionNode(id: 'b', templateId: '', name: 'B', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.removeDimension('a'),
      expect: () => [
        predicate<TemplateEditorState>((s) => s.dimensions.length == 1 && s.dimensions.first.id == 'b'),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moves dimension at root level with flat list divergence',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(
            id: 'g',
            templateId: '',
            name: 'Group',
            type: 'group',
            children: [
              DimensionNode(id: 'c1', templateId: '', parentId: 'g', name: 'C1', type: 'text'),
            ],
          ),
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 0, newIndex: 1),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          return s.dimensions.length == 2 &&
              s.dimensions[0].id == 'a' &&
              s.dimensions[0].parentId == null &&
              s.dimensions[1].id == 'g' &&
              s.dimensions[1].parentId == null &&
              s.dimensions[1].children.length == 1;
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moves dimension into group at specified child index',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        templateName: 'T',
        dimensions: [
          DimensionNode(
            id: 'g',
            templateId: '',
            name: 'Group',
            type: 'group',
            children: [
              DimensionNode(id: 'c1', templateId: '', parentId: 'g', name: 'C1', type: 'text'),
            ],
          ),
          DimensionNode(id: 'd', templateId: '', name: 'Dim', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 2, newIndex: 0, targetParentId: 'g'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final group = s.dimensions.firstWhere((d) => d.id == 'g');
          return group.children.length == 2 &&
              group.children[0].id == 'd' &&
              group.children[1].id == 'c1';
        }),
      ],
    );
  });
}
