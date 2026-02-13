import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

/// 物品类型枚举
enum ItemType {
  @JsonValue('tool')
  tool, // 忍具
  @JsonValue('medicine')
  medicine, // 药品
  @JsonValue('equipment')
  equipment, // 装备
  @JsonValue('material')
  material, // 材料
}

/// 稀有度枚举
enum ItemRarity {
  @JsonValue('common')
  common, // N 普通
  @JsonValue('uncommon')
  uncommon, // R 稀有
  @JsonValue('rare')
  rare, // SR 史诗
  @JsonValue('epic')
  epic, // SSR 传说
  @JsonValue('legendary')
  legendary, // UR 神话
}

/// 物品效果接口
@JsonSerializable()
class ItemEffect {
  final String type; // 'attribute' | 'recover' | 'special'
  final String target; // 效果目标
  final num value; // 效果数值

  ItemEffect({
    required this.type,
    required this.target,
    required this.value,
  });

  factory ItemEffect.fromJson(Map<String, dynamic> json) => _$ItemEffectFromJson(json);
  Map<String, dynamic> toJson() => _$ItemEffectToJson(this);
}

/// 物品模型
@JsonSerializable()
class Item {
  final String itemId;
  final String name;
  final String description;
  final ItemType type;
  final String category;
  final ItemRarity rarity;
  final ItemEffect? effect;
  final int price;
  final int sellPrice;
  final int maxStack;
  final String? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.itemId,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.rarity,
    this.effect,
    required this.price,
    required this.sellPrice,
    this.maxStack = 99,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);

  /// 获取稀有度显示颜色
  String get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return '🔵'; // 普通 - 蓝色
      case ItemRarity.uncommon:
        return '🟢'; // 稀有 - 绿色
      case ItemRarity.rare:
        return '🟣'; // 史诗 - 紫色
      case ItemRarity.epic:
        return '🟠'; // 传说 - 橙色
      case ItemRarity.legendary:
        return '🔴'; // 神话 - 红色
    }
  }

  /// 获取稀有度中文名
  String get rarityName {
    switch (rarity) {
      case ItemRarity.common:
        return 'N 普通';
      case ItemRarity.uncommon:
        return 'R 稀有';
      case ItemRarity.rare:
        return 'SR 史诗';
      case ItemRarity.epic:
        return 'SSR 传说';
      case ItemRarity.legendary:
        return 'UR 神话';
    }
  }

  /// 获取物品类型中文名
  String get typeName {
    switch (type) {
      case ItemType.tool:
        return '忍具';
      case ItemType.medicine:
        return '药品';
      case ItemType.equipment:
        return '装备';
      case ItemType.material:
        return '材料';
    }
  }

  /// 是否可以堆叠
  bool get canStack => type == ItemType.medicine || type == ItemType.tool || type == ItemType.material;

  /// 是否可以装备
  bool get canEquip => type == ItemType.equipment;

  /// 是否可以使用
  bool get canUse => type == ItemType.medicine;
}

/// 库存物品模型（包含数量）
@JsonSerializable()
class InventoryItem {
  final Item item;
  final int quantity;
  final bool equipped;

  InventoryItem({
    required this.item,
    required this.quantity,
    this.equipped = false,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) => _$InventoryItemFromJson(json);
  Map<String, dynamic> toJson() => _$InventoryItemToJson(this);

  InventoryItem copyWith({
    Item? item,
    int? quantity,
    bool? equipped,
  }) {
    return InventoryItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      equipped: equipped ?? this.equipped,
    );
  }
}
