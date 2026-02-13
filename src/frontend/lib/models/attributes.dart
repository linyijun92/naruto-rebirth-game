import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attributes.g.dart';

/// 核心属性枚举
enum AttributeType {
  chakra, // 查克拉
  ninjutsu, // 忍术
  taijutsu, // 体术
  intelligence, // 智力
  speed, // 速度
  luck, // 幸运
}

/// 属性信息
class AttributeInfo {
  final AttributeType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int defaultValue;
  final int maxValue;

  const AttributeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.defaultValue = 50,
    this.maxValue = 999,
  });

  /// 获取所有属性信息
  static const List<AttributeInfo> allAttributes = [
    AttributeInfo(
      type: AttributeType.chakra,
      name: '查克拉',
      description: '体内能量，决定忍术使用次数和质量',
      icon: Icons.flash_on,
      color: Colors.blue,
      defaultValue: 100,
    ),
    AttributeInfo(
      type: AttributeType.ninjutsu,
      name: '忍术',
      description: '忍术造诣，影响忍术威力和学习速度',
      icon: Icons.auto_awesome,
      color: Colors.purple,
    ),
    AttributeInfo(
      type: AttributeType.taijutsu,
      name: '体术',
      description: '近战能力，影响物理攻击和防御',
      icon: Icons.fitness_center,
      color: Colors.red,
    ),
    AttributeInfo(
      type: AttributeType.intelligence,
      name: '智力',
      description: '智慧和策略，影响决策和计划',
      icon: Icons.psychology,
      color: Colors.teal,
    ),
    AttributeInfo(
      type: AttributeType.speed,
      name: '速度',
      description: '移动和反应速度，影响闪避和先手',
      icon: Icons.speed,
      color: Colors.orange,
    ),
    AttributeInfo(
      type: AttributeType.luck,
      name: '幸运',
      description: '运气值，影响稀有事件和掉落',
      icon: Icons.stars,
      color: Colors.amber,
    ),
  ];

  /// 根据类型获取属性信息
  static AttributeInfo fromType(AttributeType type) {
    return allAttributes.firstWhere((attr) => attr.type == type);
  }
}

/// 属性值变化
@JsonSerializable()
class AttributeChange {
  final AttributeType type;
  final int oldValue;
  final int newValue;
  final String? reason;
  final DateTime timestamp;

  AttributeChange({
    required this.type,
    required this.oldValue,
    required this.newValue,
    this.reason,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AttributeChange.fromJson(Map<String, dynamic> json) =>
      _$AttributeChangeFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeChangeToJson(this);
}

/// 属性等级
enum AttributeLevel {
  novice, // 新手 (0-49)
  apprentice, // 见习 (50-99)
  journeyman, // 熟练 (100-199)
  expert, // 专家 (200-399)
  master, // 大师 (400-599)
  grandMaster, // 宗师 (600-799)
  legend, // 传说 (800-999)
}

/// 属性扩展
class AttributeExtension {
  /// 获取属性等级
  static AttributeLevel getLevel(int value) {
    if (value < 50) return AttributeLevel.novice;
    if (value < 100) return AttributeLevel.apprentice;
    if (value < 200) return AttributeLevel.journeyman;
    if (value < 400) return AttributeLevel.expert;
    if (value < 600) return AttributeLevel.master;
    if (value < 800) return AttributeLevel.grandMaster;
    return AttributeLevel.legend;
  }

  /// 获取等级名称
  static String getLevelName(AttributeLevel level) {
    switch (level) {
      case AttributeLevel.novice:
        return '新手';
      case AttributeLevel.apprentice:
        return '见习';
      case AttributeLevel.journeyman:
        return '熟练';
      case AttributeLevel.expert:
        return '专家';
      case AttributeLevel.master:
        return '大师';
      case AttributeLevel.grandMaster:
        return '宗师';
      case AttributeLevel.legend:
        return '传说';
    }
  }

  /// 获取等级颜色
  static Color getLevelColor(AttributeLevel level) {
    switch (level) {
      case AttributeLevel.novice:
        return Colors.grey;
      case AttributeLevel.apprentice:
        return Colors.green;
      case AttributeLevel.journeyman:
        return Colors.blue;
      case AttributeLevel.expert:
        return Colors.purple;
      case AttributeLevel.master:
        return Colors.orange;
      case AttributeLevel.grandMaster:
        return Colors.red;
      case AttributeLevel.legend:
        return const Color(0xFFFFD700); // 金色
    }
  }

  /// 获取属性描述文本
  static String getDescription(AttributeType type, int value) {
    final level = getLevel(value);
    final levelName = getLevelName(level);
    final attrName = AttributeInfo.fromType(type).name;

    switch (level) {
      case AttributeLevel.novice:
        return '$attrName 还处于入门阶段';
      case AttributeLevel.apprentice:
        return '$attrName 初窥门径';
      case AttributeLevel.journeyman:
        return '$attrName 熟练运用';
      case AttributeLevel.expert:
        return '$attrName 精通造诣';
      case AttributeLevel.master:
        return '$attrName 大师风范';
      case AttributeLevel.grandMaster:
        return '$attrName 宗师境界';
      case AttributeLevel.legend:
        return '$attrName 传说级别';
    }
  }
}

/// 属性评分
@JsonSerializable()
class AttributeRating {
  final AttributeType type;
  final int value;
  final int rank; // 排名
  final int percentile; // 百分位

  AttributeRating({
    required this.type,
    required this.value,
    required this.rank,
    required this.percentile,
  });

  factory AttributeRating.fromJson(Map<String, dynamic> json) =>
      _$AttributeRatingFromJson(json);

  Map<String, dynamic> toJson() => _$AttributeRatingToJson(this);

  /// 获取评级 (S, A, B, C, D)
  String get grade {
    if (percentile >= 95) return 'S';
    if (percentile >= 80) return 'A';
    if (percentile >= 60) return 'B';
    if (percentile >= 40) return 'C';
    return 'D';
  }
}
