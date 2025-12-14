import 'package:hive/hive.dart';

class LocalePreference {
  static const String _boxName = 'localeBox';
  static const String _key = 'isEnglish';

  static Future<bool> getIsEnglish() async {
    final box = await Hive.openBox<bool>(_boxName);
    return box.get(_key) ?? false; // Pakai null coalescing operator
  }

  static Future<void> setIsEnglish(bool value) async {
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_key, value);
  }
}