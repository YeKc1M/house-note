import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/instance_list/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/instance_repository.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockInstanceRepository extends Mock implements InstanceRepository {}

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late MockInstanceRepository repo;
  late MockTemplateRepository templateRepo;

  setUp(() {
    repo = MockInstanceRepository();
    templateRepo = MockTemplateRepository();
  });

  blocTest<InstanceListCubit, InstanceListState>(
    'loads top-level instances',
    build: () => InstanceListCubit(repo, templateRepo),
    act: (cubit) {
      when(() => repo.watchTopLevelInstances()).thenAnswer(
        (_) => Stream.value([
          Instance(id: 'i1', templateId: 't1', name: 'A', createdAt: 1, updatedAt: 1),
        ]),
      );
      when(() => templateRepo.getThumbnailValues(any(), any())).thenAnswer((_) async => {});
      cubit.loadTopLevel();
    },
    expect: () => [
      predicate<InstanceListState>((s) => s.instances.length == 1 && s.breadcrumbs.isEmpty),
    ],
  );

  blocTest<InstanceListCubit, InstanceListState>(
    'loads top-level instances with thumbnail values',
    build: () => InstanceListCubit(repo, templateRepo),
    setUp: () {
      when(() => repo.watchTopLevelInstances()).thenAnswer(
        (_) => Stream.value([
          Instance(id: 'i1', templateId: 't1', name: 'A', createdAt: 1, updatedAt: 1),
        ]),
      );
      when(() => templateRepo.getThumbnailValues('i1', 't1')).thenAnswer(
        (_) async => {'朝向': '南'},
      );
    },
    act: (cubit) => cubit.loadTopLevel(),
    expect: () => [
      predicate<InstanceListState>((s) {
        return s.instances.length == 1 &&
            s.thumbnailValues['i1']?['朝向'] == '南';
      }),
    ],
  );
}
