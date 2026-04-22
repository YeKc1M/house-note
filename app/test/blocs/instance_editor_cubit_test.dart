import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_editor/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:mocktail/mocktail.dart';

class FakeInstancesCompanion extends Fake implements InstancesCompanion {}
class FakeInstanceValuesCompanion extends Fake implements InstanceValuesCompanion {}
class FakeInstanceCustomFieldsCompanion extends Fake implements InstanceCustomFieldsCompanion {}
class FakeInstanceHiddenDimensionsCompanion extends Fake implements InstanceHiddenDimensionsCompanion {}

class MockInstanceRepository extends Mock implements InstanceRepository {}
class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeInstancesCompanion());
    registerFallbackValue(FakeInstanceValuesCompanion());
    registerFallbackValue(FakeInstanceCustomFieldsCompanion());
    registerFallbackValue(FakeInstanceHiddenDimensionsCompanion());
  });
  group('InstanceEditorCubit', () {
    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'sets instance name',
      build: () => InstanceEditorCubit(),
      act: (cubit) => cubit.setName('Test'),
      expect: () => [const InstanceEditorState(name: 'Test')],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'hides dimension',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(
        dimensionValues: {'d1': 'v1'},
        hiddenDimensionIds: {},
      ),
      act: (cubit) => cubit.hideDimension('d1'),
      expect: () => [
        const InstanceEditorState(
          name: '',
          dimensionValues: {'d1': 'v1'},
          hiddenDimensionIds: {'d1'},
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'adds custom field',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(customFields: []),
      act: (cubit) => cubit.addCustomField('Field1', 'text'),
      expect: () => [
        isA<InstanceEditorState>().having(
          (s) => s.customFields.length,
          'customFields length',
          1,
        ).having(
          (s) => s.customFields.first.name,
          'customFields first name',
          'Field1',
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'updates custom field',
      build: () => InstanceEditorCubit(),
      seed: () {
        const field = CustomFieldData(
          id: 'cf1',
          name: 'Field1',
          type: 'text',
          value: 'old',
          config: '{}',
        );
        return const InstanceEditorState(customFields: [field]);
      },
      act: (cubit) => cubit.updateCustomField('cf1', name: 'Updated', value: 'new'),
      expect: () => [
        isA<InstanceEditorState>().having(
          (s) => s.customFields.first.name,
          'name',
          'Updated',
        ).having(
          (s) => s.customFields.first.value,
          'value',
          'new',
        ),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'removes custom field',
      build: () => InstanceEditorCubit(),
      seed: () {
        const field = CustomFieldData(
          id: 'cf1',
          name: 'Field1',
          type: 'text',
          value: '',
          config: '{}',
        );
        return const InstanceEditorState(customFields: [field]);
      },
      act: (cubit) => cubit.removeCustomField('cf1'),
      expect: () => [const InstanceEditorState(customFields: [])],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'restores dimension',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(hiddenDimensionIds: {'d1'}),
      act: (cubit) => cubit.restoreDimension('d1'),
      expect: () => [const InstanceEditorState(hiddenDimensionIds: {})],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'updates dimension value',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(dimensionValues: {'d1': ''}),
      act: (cubit) => cubit.updateDimensionValue('d1', 'v1'),
      expect: () => [
        const InstanceEditorState(dimensionValues: {'d1': 'v1'}),
      ],
    );

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'state equality with childInstances',
      build: () => InstanceEditorCubit(),
      seed: () => const InstanceEditorState(
        childInstances: {
          'dim1': [
            ChildInstanceSummary(id: 'i1', name: 'A', templateId: 't1'),
          ],
        },
      ),
      act: (cubit) {},
      expect: () => [],
      verify: (cubit) {
        final s1 = cubit.state;
        final s2 = s1.copyWith(
          childInstances: {
            'dim1': [
              const ChildInstanceSummary(id: 'i1', name: 'A', templateId: 't1'),
            ],
          },
        );
        expect(s1, s2);
      },
    );
  });

  group('with mocks', () {
    late MockInstanceRepository mockInstanceRepo;
    late MockTemplateRepository mockTemplateRepo;
    late InstanceEditorCubit cubit;

    setUp(() {
      mockInstanceRepo = MockInstanceRepository();
      mockTemplateRepo = MockTemplateRepository();
      cubit = InstanceEditorCubit(mockInstanceRepo, mockTemplateRepo);
    });

    blocTest<InstanceEditorCubit, InstanceEditorState>(
      'loadInstance loads child instances grouped by ref_subtemplate dimension',
      build: () => cubit,
      setUp: () {
        const instance = Instance(
          id: 'parent',
          templateId: 'tmpl',
          parentInstanceId: null,
          name: 'Parent',
          createdAt: 1,
          updatedAt: 1,
        );
        when(() => mockInstanceRepo.getInstanceById('parent'))
            .thenAnswer((_) async => InstanceWithData(
                  instance,
                  [],
                  [],
                  [],
                ));
        when(() => mockTemplateRepo.getTemplateById('tmpl')).thenAnswer(
          (_) async => TemplateWithDimensions(
            const Template(id: 'tmpl', name: 'T', createdAt: 1, updatedAt: 1),
            const [
              TemplateDimension(
                id: 'dim1',
                templateId: 'tmpl',
                name: '房子列表',
                type: 'ref_subtemplate',
                config: '{"ref_template_id": "house_tmpl"}',
                sortOrder: 0,
              ),
            ],
          ),
        );
        when(() => mockTemplateRepo.getRefSubtemplateDimensions('tmpl'))
            .thenAnswer((_) async => const [
                  TemplateDimension(
                    id: 'dim1',
                    templateId: 'tmpl',
                    name: '房子列表',
                    type: 'ref_subtemplate',
                    config: '{"ref_template_id": "house_tmpl"}',
                    sortOrder: 0,
                  ),
                ]);
        when(() => mockInstanceRepo.getChildInstances('parent')).thenAnswer(
          (_) async => const [
            Instance(
              id: 'child1',
              templateId: 'house_tmpl',
              parentInstanceId: 'parent',
              name: '7栋-1203',
              createdAt: 2,
              updatedAt: 2,
            ),
          ],
        );
        when(() => mockTemplateRepo.getThumbnailValues('child1', 'house_tmpl'))
            .thenAnswer((_) async => {'朝向': '南'});
      },
      act: (cubit) => cubit.loadInstance('parent'),
      expect: () => [
        isA<InstanceEditorState>().having(
          (s) => s.childInstances,
          'childInstances before load',
          isEmpty,
        ),
        isA<InstanceEditorState>().having(
          (s) => s.childInstances['dim1']?.length,
          'childInstances count for dim1',
          1,
        ).having(
          (s) => s.childInstances['dim1']?.first.name,
          'child name',
          '7栋-1203',
        ).having(
          (s) => s.childInstances['dim1']?.first.thumbnailValues['朝向'],
          'thumbnail',
          '南',
        ),
      ],
    );
  });
}
