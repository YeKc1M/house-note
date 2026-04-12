import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

class AppDatabase {
  AppDatabase() {
    _openConnection();
  }

  QueryExecutor _openConnection() {
    return driftDatabase(name: 'house_note_database');
  }
}
