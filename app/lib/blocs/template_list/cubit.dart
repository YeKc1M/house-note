import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/database.dart';
import '../../data/template_repository.dart';
import 'state.dart';

export 'state.dart';

class TemplateListCubit extends Cubit<TemplateListState> {
  final TemplateRepository _repo;
  StreamSubscription<List<Template>>? _sub;

  TemplateListCubit(this._repo) : super(const TemplateListState());

  void load() {
    _sub?.cancel();
    _sub = _repo.watchAllTemplates().listen(
      (templates) => emit(TemplateListState(templates: templates)),
      onError: (_) => emit(const TemplateListState(templates: [])),
    );
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _repo.deleteTemplate(id);
    } catch (_) {
      // silently ignore for now; stream will refresh state
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
