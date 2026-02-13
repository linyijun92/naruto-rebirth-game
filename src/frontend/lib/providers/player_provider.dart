import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class PlayerProvider extends ChangeNotifier {
  // 玩家属性
  Map<String, int> _attributes = Map.from(AppConfig.defaultAttributes);

  // 玩家等级
  int _level = 1;

  // 经验值
  int _experience = 0;

  // 当前章节
  String _currentChapter = 'chapter_01_01';

  // 货币
  int _currency = AppConfig.startingCurrency;

  // Getters
  Map<String, int> get attributes => _attributes;
  int get level => _level;
  int get experience => _experience;
  String get currentChapter => _currentChapter;
  int get currency => _currency;

  // 获取特定属性
  int getAttribute(String key) {
    return _attributes[key] ?? 0;
  }

  // 更新属性
  void updateAttribute(String key, int value) {
    final max = AppConfig.maxAttributes[key] ?? 999;
    _attributes[key] = value.clamp(0, max);
    notifyListeners();
  }

  // 增加属性
  void addAttribute(String key, int amount) {
    final currentValue = _attributes[key] ?? 0;
    updateAttribute(key, currentValue + amount);
  }

  // 升级
  void levelUp() {
    _level++;
    notifyListeners();
  }

  // 增加经验
  void addExperience(int amount) {
    _experience += amount;
    notifyListeners();
  }

  // 更新章节
  void updateChapter(String chapterId) {
    _currentChapter = chapterId;
    notifyListeners();
  }

  // 增加货币
  void addCurrency(int amount) {
    _currency += amount;
    notifyListeners();
  }

  // 扣除货币
  void spendCurrency(int amount) {
    if (_currency >= amount) {
      _currency -= amount;
      notifyListeners();
    }
  }

  // 重置玩家数据
  void resetPlayer() {
    _attributes = Map.from(AppConfig.defaultAttributes);
    _level = 1;
    _experience = 0;
    _currentChapter = 'chapter_01_01';
    _currency = AppConfig.startingCurrency;
    notifyListeners();
  }
}
