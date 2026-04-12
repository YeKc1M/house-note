import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Templates,
  TemplateDimensions,
  Instances,
  InstanceValues,
  InstanceCustomFields,
  InstanceHiddenDimensions,
  TemplateThumbnailFields,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'house_note_db');
  }
}
