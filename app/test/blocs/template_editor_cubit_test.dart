import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_editor/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:house_note/models/dimension_node.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

class FakeTemplatesCompanion extends Fake implements TemplatesCompanion {}

class FakeTemplateDimensionsCompanion extends Fake implements TemplateDimensionsCompanion {}

class FakeTemplateThumbnailFieldsCompanion extends Fake implements TemplateThumbnailFieldsCompanion {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTemplatesCompanion());
    registerFallbackValue(FakeTemplateDimensionsCompanion());
    registerFallbackValue(FakeTemplateThumbnailFieldsCompanion());
  });

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

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'loadTemplate initializes thumbnailDimensionIds',
      build: () => TemplateEditorCubit(repo),
      setUp: () {
        when(() => repo.getTemplateById('t1')).thenAnswer((_) async => TemplateWithDimensions(
          Template(id: 't1', name: 'T', createdAt: 0, updatedAt: 0),
          [
            TemplateDimension(id: 'd1', templateId: 't1', parentId: null, name: 'A', type: 'text', config: '{}', sortOrder: 0),
            TemplateDimension(id: 'd2', templateId: 't1', parentId: null, name: 'B', type: 'text', config: '{}', sortOrder: 1),
          ],
        ));
        when(() => repo.getThumbnailFields('t1')).thenAnswer((_) async => [
          TemplateThumbnailField(id: 'f1', templateId: 't1', dimensionId: 'd2', sortOrder: 0),
        ]);
      },
      act: (cubit) => cubit.loadTemplate('t1'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          return s.templateName == 'T' && s.thumbnailDimensionIds.length == 1 && s.thumbnailDimensionIds.first == 'd2';
        }),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'toggleThumbnailDimension adds and removes id',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(),
      act: (cubit) {
        cubit.toggleThumbnailDimension('d1');
        cubit.toggleThumbnailDimension('d2');
        cubit.toggleThumbnailDimension('d1');
      },
      expect: () => [
        const TemplateEditorState(thumbnailDimensionIds: ['d1']),
        const TemplateEditorState(thumbnailDimensionIds: ['d1', 'd2']),
        const TemplateEditorState(thumbnailDimensionIds: ['d2']),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'reorderThumbnailDimensions moves items',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(thumbnailDimensionIds: ['a', 'b', 'c']),
      act: (cubit) => cubit.reorderThumbnailDimensions(0, 2),
      expect: () => [
        const TemplateEditorState(thumbnailDimensionIds: ['b', 'c', 'a']),
      ],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'saveTemplate inserts new template and sets thumbnail fields',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        templateName: 'New Template',
        dimensions: [
          DimensionNode(id: 'd1', templateId: '', name: 'A', type: 'text'),
        ],
        thumbnailDimensionIds: ['d1'],
      ),
      setUp: () {
        when(() => repo.insertTemplate(any(), any())).thenAnswer((_) async {});
        when(() => repo.setThumbnailFields(any(), any())).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.saveTemplate(),
      verify: (_) {
        final insertCalls = verify(() => repo.insertTemplate(captureAny(), captureAny())).captured;
        final capturedTemplate = insertCalls[0] as TemplatesCompanion;
        final capturedDimensions = insertCalls[1] as List<TemplateDimensionsCompanion>;
        expect(capturedTemplate.name.value, 'New Template');
        expect(capturedDimensions.length, 1);
        expect(capturedDimensions.first.name.value, 'A');

        final thumbCalls = verify(() => repo.setThumbnailFields(captureAny(), captureAny())).captured;
        final thumbTemplateId = thumbCalls[0] as String;
        final thumbFields = thumbCalls[1] as List<TemplateThumbnailFieldsCompanion>;
        expect(thumbTemplateId, capturedTemplate.id.value);
        expect(thumbFields.length, 1);
        expect(thumbFields.first.dimensionId.value, 'd1');
      },
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'saveTemplate updates existing template and sets thumbnail fields',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        templateName: 'Updated Template',
        dimensions: [
          DimensionNode(id: 'd1', templateId: '', name: 'A', type: 'text'),
        ],
        thumbnailDimensionIds: ['d1'],
      ),
      setUp: () {
        when(() => repo.getTemplateById('t1')).thenAnswer((_) async => TemplateWithDimensions(
          Template(id: 't1', name: 'Old', createdAt: 0, updatedAt: 0),
          [TemplateDimension(id: 'd1', templateId: 't1', parentId: null, name: 'A', type: 'text', config: '{}', sortOrder: 0)],
        ));
        when(() => repo.getThumbnailFields('t1')).thenAnswer((_) async => [
          TemplateThumbnailField(id: 'f1', templateId: 't1', dimensionId: 'd1', sortOrder: 0),
        ]);
        when(() => repo.updateTemplate(any(), any())).thenAnswer((_) async {});
        when(() => repo.setThumbnailFields(any(), any())).thenAnswer((_) async {});
      },
      act: (cubit) async {
        await cubit.loadTemplate('t1');
        cubit.setTemplateName('Updated Template');
        await cubit.saveTemplate();
      },
      verify: (_) {
        final updateCalls = verify(() => repo.updateTemplate(captureAny(), captureAny())).captured;
        final capturedTemplate = updateCalls[0] as TemplatesCompanion;
        final capturedDimensions = updateCalls[1] as List<TemplateDimensionsCompanion>;
        expect(capturedTemplate.name.value, 'Updated Template');
        expect(capturedTemplate.id.value, 't1');
        expect(capturedDimensions.length, 1);

        final thumbCalls = verify(() => repo.setThumbnailFields(captureAny(), captureAny())).captured;
        final thumbTemplateId = thumbCalls[0] as String;
        final thumbFields = thumbCalls[1] as List<TemplateThumbnailFieldsCompanion>;
        expect(thumbTemplateId, 't1');
        expect(thumbFields.length, 1);
        expect(thumbFields.first.dimensionId.value, 'd1');
      },
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'moveDimension with invalid oldIndex is no-op',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(id: 'a', templateId: '', name: 'A', type: 'text'),
        ],
      ),
      act: (cubit) => cubit.moveDimension(oldIndex: 5, newIndex: 0),
      expect: () => [],
    );

    blocTest<TemplateEditorCubit, TemplateEditorState>(
      'addDimension into nested group',
      build: () => TemplateEditorCubit(repo),
      seed: () => const TemplateEditorState(
        dimensions: [
          DimensionNode(
            id: 'g1',
            templateId: '',
            name: 'Group1',
            type: 'group',
            children: [
              DimensionNode(
                id: 'g2',
                templateId: '',
                parentId: 'g1',
                name: 'Group2',
                type: 'group',
                children: [],
              ),
            ],
          ),
        ],
      ),
      act: (cubit) => cubit.addDimension(name: 'Nested', type: 'text', parentId: 'g2'),
      expect: () => [
        predicate<TemplateEditorState>((s) {
          final g1 = s.dimensions.firstWhere((d) => d.id == 'g1');
          final g2 = g1.children.firstWhere((d) => d.id == 'g2');
          return g2.children.length == 1 && g2.children.first.name == 'Nested';
        }),
      ],
    );
  });
}
