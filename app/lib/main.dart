import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/database.dart';
import 'data/default_template_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final prefs = await SharedPreferences.getInstance();
  await DefaultTemplateLoader(db).loadIfNeeded();
  runApp(HouseNoteApp(database: db, prefs: prefs));
}
