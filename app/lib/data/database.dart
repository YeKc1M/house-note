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
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(appSettings);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'house_note_db');
  }
}
