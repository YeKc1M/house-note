import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/blocs/template_list/cubit.dart';
import 'package:house_note/data/database.dart';
import 'package:house_note/data/template_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  late MockTemplateRepository repo;

  setUp(() => repo = MockTemplateRepository());

  blocTest<TemplateListCubit, TemplateListState>(
    'emits loaded templates on load',
    build: () => TemplateListCubit(repo),
    act: (cubit) {
      when(() => repo.watchAllTemplates()).thenAnswer(
        (_) => Stream.value([
          Template(id: '1', name: 'T1', createdAt: 1, updatedAt: 1),
        ]),
      );
      cubit.load();
    },
    expect: () => [
      TemplateListState(templates: [
        Template(id: '1', name: 'T1', createdAt: 1, updatedAt: 1),
      ]),
    ],
  );
}
