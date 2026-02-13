import 'package:flutter/foundation.dart';
import '../models/attributes.dart';
import '../config/app_config.dart';

class AttributesProvider extends ChangeNotifier {
  /// 属性值映射
  Map<String, int> _attributes = Map.from(AppConfig.defaultAttributes);

  /// 属性变化历史
  final List<AttributeChange> _changeHistory = [];

  /// 获取所有属性
  Map<String, int> get attributes => Map.unmodifiable(_attributes);

  /// 获取属性值
  int getAttribute(String key) {
    return _attributes[key] ?? 0;
  }

  /// 获取属性值（使用枚举）
  int getAttributeByType(AttributeType type) {
    return _attributes[_getAttributeKey(type)] ?? 0;
  }

  /// 设置属性值
  void setAttribute(String key, int value) {
    final oldValue = _attributes[key] ?? 0;
    final maxValue = AppConfig.maxAttributes[key] ?? 999;
    final newValue = value.clamp(0, maxValue);

    _attributes[key] = newValue;
    notifyListeners();

    // 记录变化
    if (oldValue != newValue) {
      _addChangeHistory(AttributeType.values.firstWhere(
        (t) => _getAttributeKey(t) == key,
        orElse: () => AttributeType.intelligence,
      ), oldValue, newValue);
    }
  }

  /// 更新属性值
  void updateAttribute(String key, int delta) {
    final currentValue = getAttribute(key);
    setAttribute(key, currentValue + delta);
  }

  /// 增加属性
  void addAttribute(String key, int amount) {
    updateAttribute(key, amount);
  }

  /// 减少属性
  void subtractAttribute(String key, int amount) {
    updateAttribute(key, -amount);
  }

  /// 批量更新属性
  void updateAttributes(Map<String, int> updates) {
    updates.forEach((key, value) {
      final maxValue = AppConfig.maxAttributes[key] ?? 999;
      _attributes[key] = value.clamp(0, maxValue);
    });
    notifyListeners();
  }

  /// 批量增加属性
  void addAttributes(Map<String, int> additions) {
    additions.forEach((key, amount) {
      updateAttribute(key, amount);
    });
  }

  /// 批量减少属性
  void subtractAttributes(Map<String, int> subtractions) {
    subtractions.forEach((key, amount) {
      updateAttribute(key, -amount);
    });
  }

  /// 重置所有属性
  void resetAttributes() {
    _attributes = Map.from(AppConfig.defaultAttributes);
    notifyListeners();
  }

  /// 获取属性等级
  AttributeLevel getAttributeLevel(String key) {
    return AttributeExtension.getLevel(getAttribute(key));
  }

  /// 获取属性等级（使用枚举）
  AttributeLevel getAttributeLevelByType(AttributeType type) {
    return AttributeExtension.getLevel(getAttributeByType(type));
  }

  /// 获取属性等级名称
  String getAttributeLevelName(String key) {
    return AttributeExtension.getLevelName(getAttributeLevel(key));
  }

  /// 获取属性描述
  String getAttributeDescription(String key) {
    final type = _getAttributeType(key);
    return AttributeExtension.getDescription(type, getAttribute(key));
  }

  /// 获取属性变化历史
  List<AttributeChange> get changeHistory => List.unmodifiable(_changeHistory);

  /// 清空变化历史
  void clearChangeHistory() {
    _changeHistory.clear();
    notifyListeners();
  }

  /// 获取最近N条变化记录
  List<AttributeChange> getRecentChanges(int count) {
    return _changeHistory.reversed.take(count).toList();
  }

  /// 计算属性总和
  int getTotalAttributes() {
    return _attributes.values.fold(0, (sum, value) => sum + value);
  }

  /// 获取最强属性
  MapEntry<String, int> getStrongestAttribute() {
    if (_attributes.isEmpty) {
      return MapEntry('', 0);
    }
    return _attributes.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  /// 获取最弱属性
  MapEntry<String, int> getWeakestAttribute() {
    if (_attributes.isEmpty) {
      return MapEntry('', 0);
    }
    return _attributes.entries.reduce((a, b) => a.value < b.value ? a : b);
  }

  /// 属性加成（基于其他属性）
  double getBonusRate(AttributeType type) {
    double bonus = 0.0;

    switch (type) {
      case AttributeType.intelligence:
        // 智力受忍术和速度影响
        final ninjutsu = getAttributeByType(AttributeType.ninjutsu);
        final speed = getAttributeByType(AttributeType.speed);
        bonus = (ninjutsu + speed) / 400; // 每点增加0.25%
        break;
      case AttributeType.ninjutsu:
        // 忍术受查克拉和智力影响
        final chakra = getAttributeByType(AttributeType.chakra);
        final intelligence = getAttributeByType(AttributeType.intelligence);
        bonus = (chakra + intelligence) / 400;
        break;
      case AttributeType.taijutsu:
        // 体术受速度和幸运影响
        final speed = getAttributeByType(AttributeType.speed);
        final luck = getAttributeByType(AttributeType.luck);
        bonus = (speed + luck) / 400;
        break;
      case AttributeType.speed:
        // 速度受体术和智力影响
        final taijutsu = getAttributeByType(AttributeType.taijutsu);
        final intelligence = getAttributeByType(AttributeType.intelligence);
        bonus = (taijutsu + intelligence) / 400;
        break;
      case AttributeType.luck:
        // 幸运独立，但受智力小幅影响
        final intelligence = getAttributeByType(AttributeType.intelligence);
        bonus = intelligence / 1000; // 每点增加0.1%
        break;
      case AttributeType.chakra:
        // 查克拉独立，但受忍术小幅影响
        final ninjutsu = getAttributeByType(AttributeType.ninjutsu);
        bonus = ninjutsu / 1000;
        break;
    }

    return bonus;
  }

  /// 获取最终属性值（包含加成）
  int getFinalAttribute(AttributeType type) {
    final baseValue = getAttributeByType(type);
    final bonus = getBonusRate(type);
    return (baseValue * (1 + bonus)).round();
  }

  /// 检查属性是否达到要求
  bool checkRequirements(Map<String, int> requirements) {
    for (final entry in requirements.entries) {
      if (getAttribute(entry.key) < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// 导出属性为Map
  Map<String, dynamic> exportToMap() {
    return Map<String, dynamic>.from(_attributes);
  }

  /// 从Map导入属性
  void importFromMap(Map<String, dynamic> data) {
    data.forEach((key, value) {
      if (value is int) {
        _attributes[key] = value;
      }
    });
    notifyListeners();
  }

  // 私有方法

  void _addChangeHistory(AttributeType type, int oldValue, int newValue, {String? reason}) {
    final change = AttributeChange(
      type: type,
      oldValue: oldValue,
      newValue: newValue,
      reason: reason,
    );
    _changeHistory.add(change);

    // 限制历史记录数量
    if (_changeHistory.length > 100) {
      _changeHistory.removeRange(0, _changeHistory.length - 100);
    }

    notifyListeners();
  }

  String _getAttributeKey(AttributeType type) {
    switch (type) {
      case AttributeType.chakra:
        return 'chakra';
      case AttributeType.ninjutsu:
        return 'ninjutsu';
      case AttributeType.taijutsu:
        return 'taijutsu';
      case AttributeType.intelligence:
        return 'intelligence';
      case AttributeType.speed:
        return 'speed';
      case AttributeType.luck:
        return 'luck';
    }
  }

  AttributeType _getAttributeType(String key) {
    switch (key) {
      case 'chakra':
        return AttributeType.chakra;
      case 'ninjutsu':
        return AttributeType.ninjutsu;
      case 'taijutsu':
        return AttributeType.taijutsu;
      case 'intelligence':
        return AttributeType.intelligence;
      case 'speed':
        return AttributeType.speed;
      case 'luck':
        return AttributeType.luck;
      default:
        return AttributeType.intelligence;
    }
  }
}
