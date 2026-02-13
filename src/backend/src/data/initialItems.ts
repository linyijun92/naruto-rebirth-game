import Item from '../models/Item';

/**
 * 初始化商店物品数据
 */
export async function initializeItems() {
  const items = [
    // 忍具 - 普通
    {
      itemId: 'tool_shuriken_n',
      name: '手里剑',
      description: '基础的投掷武器，命中率一般。',
      type: 'tool',
      category: 'shuriken',
      rarity: 'common',
      effect: { type: 'attribute', target: 'attack', value: 5 },
      price: 50,
      sellPrice: 20,
      maxStack: 99,
    },
    {
      itemId: 'tool_kunai_n',
      name: '苦无',
      description: '忍者常用的短刀，可以近战也可以投掷。',
      type: 'tool',
      category: 'kunai',
      rarity: 'common',
      effect: { type: 'attribute', target: 'attack', value: 8 },
      price: 80,
      sellPrice: 30,
      maxStack: 99,
    },
    {
      itemId: 'tool_explosive_tag_n',
      name: '起爆符',
      description: '贴上去就会爆炸的符咒，威力可观。',
      type: 'tool',
      category: 'explosive',
      rarity: 'common',
      effect: { type: 'attribute', target: 'explosion', value: 30 },
      price: 100,
      sellPrice: 40,
      maxStack: 50,
    },

    // 忍具 - 稀有
    {
      itemId: 'tool_shuriken_r',
      name: '精制手里剑',
      description: '经过精心打磨的手里剑，命中率更高。',
      type: 'tool',
      category: 'shuriken',
      rarity: 'uncommon',
      effect: { type: 'attribute', target: 'attack', value: 10 },
      price: 150,
      sellPrice: 60,
      maxStack: 99,
    },
    {
      itemId: 'tool_smoke_bomb_r',
      name: '烟雾弹',
      description: '投掷后产生浓烟，可用于逃脱或偷袭。',
      type: 'tool',
      category: 'utility',
      rarity: 'uncommon',
      effect: { type: 'special', target: 'escape', value: 100 },
      price: 200,
      sellPrice: 80,
      maxStack: 20,
    },

    // 药品 - 普通
    {
      itemId: 'medicine_heal_n',
      name: '治疗药',
      description: '恢复50点生命值。',
      type: 'medicine',
      category: 'heal',
      rarity: 'common',
      effect: { type: 'recover', target: 'health', value: 50 },
      price: 100,
      sellPrice: 40,
      maxStack: 20,
    },
    {
      itemId: 'medicine_chakra_n',
      name: '查克拉药',
      description: '恢复50点查克拉。',
      type: 'medicine',
      category: 'chakra',
      rarity: 'common',
      effect: { type: 'recover', target: 'chakra', value: 50 },
      price: 100,
      sellPrice: 40,
      maxStack: 20,
    },

    // 药品 - 稀有
    {
      itemId: 'medicine_heal_r',
      name: '高级治疗药',
      description: '恢复100点生命值。',
      type: 'medicine',
      category: 'heal',
      rarity: 'uncommon',
      effect: { type: 'recover', target: 'health', value: 100 },
      price: 250,
      sellPrice: 100,
      maxStack: 20,
    },
    {
      itemId: 'medicine_chakra_r',
      name: '高级查克拉药',
      description: '恢复100点查克拉。',
      type: 'medicine',
      category: 'chakra',
      rarity: 'uncommon',
      effect: { type: 'recover', target: 'chakra', value: 100 },
      price: 250,
      sellPrice: 100,
      maxStack: 20,
    },

    // 药品 - 史诗
    {
      itemId: 'medicine_revive_sr',
      name: '复活药',
      description: '战斗失败后使用，可以恢复部分状态继续战斗。',
      type: 'medicine',
      category: 'special',
      rarity: 'rare',
      effect: { type: 'special', target: 'revive', value: 50 },
      price: 1000,
      sellPrice: 400,
      maxStack: 5,
    },

    // 装备 - 普通
    {
      itemId: 'equipment_ninja_bag_n',
      name: '基础忍具袋',
      description: '可以携带更多忍具，增加携带数量+10。',
      type: 'equipment',
      category: 'bag',
      rarity: 'common',
      effect: { type: 'attribute', target: 'inventory', value: 10 },
      price: 500,
      sellPrice: 200,
      maxStack: 1,
    },
    {
      itemId: 'equipment_armor_n',
      name: '基础防具',
      description: '提供基础保护，增加防御力+5。',
      type: 'equipment',
      category: 'armor',
      rarity: 'common',
      effect: { type: 'attribute', target: 'defense', value: 5 },
      price: 800,
      sellPrice: 320,
      maxStack: 1,
    },
    {
      itemId: 'equipment_weapon_n',
      name: '基础短刀',
      description: '普通的短刀，增加攻击力+10。',
      type: 'equipment',
      category: 'weapon',
      rarity: 'common',
      effect: { type: 'attribute', target: 'attack', value: 10 },
      price: 1000,
      sellPrice: 400,
      maxStack: 1,
    },

    // 装备 - 稀有
    {
      itemId: 'equipment_ninja_bag_r',
      name: '精制忍具袋',
      description: '空间更大，增加携带数量+20。',
      type: 'equipment',
      category: 'bag',
      rarity: 'uncommon',
      effect: { type: 'attribute', target: 'inventory', value: 20 },
      price: 1500,
      sellPrice: 600,
      maxStack: 1,
    },
    {
      itemId: 'equipment_armor_r',
      name: '防弹背心',
      description: '经过特殊处理的防具，增加防御力+15。',
      type: 'equipment',
      category: 'armor',
      rarity: 'uncommon',
      effect: { type: 'attribute', target: 'defense', value: 15 },
      price: 2000,
      sellPrice: 800,
      maxStack: 1,
    },
    {
      itemId: 'equipment_weapon_r',
      name: '合金短刀',
      description: '使用特殊合金打造，增加攻击力+25。',
      type: 'equipment',
      category: 'weapon',
      rarity: 'uncommon',
      effect: { type: 'attribute', target: 'attack', value: 25 },
      price: 2500,
      sellPrice: 1000,
      maxStack: 1,
    },

    // 装备 - 史诗
    {
      itemId: 'equipment_ninja_bag_sr',
      name: '封印忍具袋',
      name: '使用封印术的忍具袋，携带数量+50。',
      type: 'equipment',
      category: 'bag',
      rarity: 'rare',
      effect: { type: 'attribute', target: 'inventory', value: 50 },
      price: 5000,
      sellPrice: 2000,
      maxStack: 1,
    },
    {
      itemId: 'equipment_armor_sr',
      name: '查克拉护甲',
      description: '用查克拉强化的护甲，增加防御力+40。',
      type: 'equipment',
      category: 'armor',
      rarity: 'rare',
      effect: { type: 'attribute', target: 'defense', value: 40 },
      price: 8000,
      sellPrice: 3200,
      maxStack: 1,
    },
    {
      itemId: 'equipment_weapon_sr',
      name: '查克拉刀',
      description: '可以传导查克拉的武器，增加攻击力+60。',
      type: 'equipment',
      category: 'weapon',
      rarity: 'rare',
      effect: { type: 'attribute', target: 'attack', value: 60 },
      price: 10000,
      sellPrice: 4000,
      maxStack: 1,
    },

    // 装备 - 传说
    {
      itemId: 'equipment_weapon_ssr',
      name: '草薙剑',
      description: '传说中的名刀，增加攻击力+100。',
      type: 'equipment',
      category: 'weapon',
      rarity: 'epic',
      effect: { type: 'attribute', target: 'attack', value: 100 },
      price: 50000,
      sellPrice: 20000,
      maxStack: 1,
    },

    // 装备 - 神话
    {
      itemId: 'equipment_weapon_ur',
      name: '十拳剑',
      description: '神话级的神器，增加攻击力+200。',
      type: 'equipment',
      category: 'weapon',
      rarity: 'legendary',
      effect: { type: 'attribute', target: 'attack', value: 200 },
      price: 200000,
      sellPrice: 80000,
      maxStack: 1,
    },
  ];

  // 批量插入或更新
  for (const item of items) {
    await Item.findOneAndUpdate(
      { itemId: item.itemId },
      item,
      { upsert: true, new: true }
    );
  }

  console.log(`初始化完成，共 ${items.length} 件物品`);
}
