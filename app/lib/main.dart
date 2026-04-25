import 'package:flutter/material.dart';
import 'app.dart';
import 'data/database.dart';
import 'data/default_template_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await DefaultTemplateLoader(db).loadIfNeeded();
  runApp(HouseNoteApp(database: db));
}
