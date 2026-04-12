import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  runApp(HouseNoteApp(database: db));
}
