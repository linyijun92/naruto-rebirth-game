import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String _saveBoxName = 'saves';
  static const String _settingsBoxName = 'settings';

  static late Box _saveBox;
  static late Box _settingsBox;

  // 初始化Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    _saveBox = await Hive.openBox(_saveBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // 保存数据
  static Future<void> save(String key, dynamic value) async {
    await _saveBox.put(key, value);
  }

  // 获取数据
  static dynamic get(String key) {
    return _saveBox.get(key);
  }

  // 删除数据
  static Future<void> delete(String key) async {
    await _saveBox.delete(key);
  }

  // 检查是否存在
  static bool containsKey(String key) {
    return _saveBox.containsKey(key);
  }

  // 获取所有键
  static List<dynamic> getAllKeys() {
    return _saveBox.keys.toList();
  }

  // 清空所有数据
  static Future<void> clear() async {
    await _saveBox.clear();
  }

  // 保存设置
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  // 获取设置
  static dynamic getSetting(String key) {
    return _settingsBox.get(key);
  }

  // 关闭Hive
  static Future<void> close() async {
    await _saveBox.close();
    await _settingsBox.close();
  }
}
