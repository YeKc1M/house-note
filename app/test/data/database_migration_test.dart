import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_note/data/database.dart';

void main() {
  test('AppSettings table exists after migration to schema v2', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    final result = await db.select(db.appSettings).get();
    expect(result, isEmpty);
    await db.into(db.appSettings).insert(
      AppSettingsCompanion.insert(key: 'test_key', value: 'test_value'),
    );
    final rows = await db.select(db.appSettings).get();
    expect(rows.length, 1);
    expect(rows.first.key, 'test_key');
    expect(rows.first.value, 'test_value');
    await db.close();
  });
}
