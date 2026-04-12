import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/template_repository.dart';
import 'state.dart';

export 'state.dart';

class TemplateListCubit extends Cubit<TemplateListState> {
  final TemplateRepository _repo;

  TemplateListCubit(this._repo) : super(const TemplateListState());

  void load() {
    _repo.watchAllTemplates().listen((templates) {
      emit(TemplateListState(templates: templates));
    });
  }

  Future<void> deleteTemplate(String id) async {
    await _repo.deleteTemplate(id);
  }
}
