import 'package:equatable/equatable.dart';
import '../../data/database.dart';

class TemplateListState extends Equatable {
  final List<Template> templates;

  const TemplateListState({this.templates = const []});

  @override
  List<Object?> get props => [templates];
}
