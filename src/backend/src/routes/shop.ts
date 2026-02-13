import { Router, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import { authenticate } from '../middleware/auth';
import Item from '../models/Item';
import Player from '../models/Player';
import { createSuccessResponse, createErrorResponse } from '../utils/responseHandler';

const router = Router();

router.use(authenticate);

/**
 * @route   GET /api/shop/categories
 * @desc    获取商品分类
 * @access  Private
 */
router.get('/categories', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    // 获取所有不重复的 type 和 category 组合
    const items = await Item.distinct('type');

    const categories = [
      { id: 'all', name: '全部' },
      ...items.map((type: string) => ({
        id: type,
        name: _getTypeName(type),
      })),
    ];

    res.json(createSuccessResponse({ categories }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/shop/items
 * @desc    获取商品列表
 * @access  Private
 */
router.get('/items', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const {
      category,
      type,
      rarity,
      page = 1,
      pageSize = 20,
    } = req.query;

    const pageNumber = parseInt(page as string, 10);
    const pageSizeNumber = parseInt(pageSize as string, 10);

    // 构建查询条件
    const query: any = {};

    // 如果指定了 category（不是 'all'），则按 type 查询
    if (category && category !== 'all') {
      query.type = category;
    }

    // 如果单独指定了 type，按 type 查询
    if (type) {
      query.type = type;
    }

    // 如果指定了 rarity，按稀有度查询
    if (rarity) {
      query.rarity = rarity;
    }

    // 查询总数
    const total = await Item.countDocuments(query);

    // 查询商品列表
    const items = await Item.find(query)
      .skip((pageNumber - 1) * pageSizeNumber)
      .limit(pageSizeNumber)
      .sort({ rarity: -1, price: 1 });

    res.json(createSuccessResponse({
      items,
      total,
      page: pageNumber,
      pageSize: pageSizeNumber,
      totalPages: Math.ceil(total / pageSizeNumber),
    }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/shop/purchase
 * @desc    购买商品
 * @access  Private
 */
router.post('/purchase', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { itemId, quantity = 1 } = req.body;

    // 验证输入
    if (!itemId) {
      return res.json(createErrorResponse('请提供商品ID'));
    }

    if (quantity <= 0 || quantity > 99) {
      return res.json(createErrorResponse('购买数量需要在1-99之间'));
    }

    // 获取商品信息
    const item = await Item.findOne({ itemId });
    if (!item) {
      return res.json(createErrorResponse('商品不存在'));
    }

    // 计算总价
    const totalPrice = item.price * quantity;

    // 获取玩家信息
    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 检查金币是否足够
    if (player.gold < totalPrice) {
      return res.json(createErrorResponse(`金币不足，需要 ${totalPrice} 金币`));
    }

    // 检查库存空间
    if (item.maxStack > 0) {
      const existingItemIndex = player.inventory.findIndex(
        (invItem: any) => invItem.itemId === itemId
      );

      if (existingItemIndex !== -1) {
        // 物品已存在，增加数量
        const currentQuantity = player.inventory[existingItemIndex].quantity;
        const newQuantity = currentQuantity + quantity;

        if (newQuantity > item.maxStack) {
          return res.json(
            createErrorResponse(`库存已满，最大堆叠数量为 ${item.maxStack}`)
          );
        }

        player.inventory[existingItemIndex].quantity = newQuantity;
      } else {
        // 物品不存在，添加到库存
        player.inventory.push({
          itemId,
          quantity,
          equipped: false,
        });
      }
    } else {
      // 不可堆叠的物品，直接添加多个
      for (let i = 0; i < quantity; i++) {
        player.inventory.push({
          itemId,
          quantity: 1,
          equipped: false,
        });
      }
    }

    // 扣除金币
    player.gold -= totalPrice;
    player.stats.itemsCollected += quantity;
    player.updatedAt = new Date();

    await player.save();

    res.json(createSuccessResponse({
      gold: player.gold,
      inventory: player.inventory,
      totalPrice,
    }, `购买成功！花费 ${totalPrice} 金币`));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/shop/sell
 * @desc    出售商品
 * @access  Private
 */
router.post('/sell', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { itemId, quantity = 1 } = req.body;

    // 验证输入
    if (!itemId) {
      return res.json(createErrorResponse('请提供商品ID'));
    }

    if (quantity <= 0) {
      return res.json(createErrorResponse('出售数量需要大于0'));
    }

    // 获取商品信息
    const item = await Item.findOne({ itemId });
    if (!item) {
      return res.json(createErrorResponse('商品不存在'));
    }

    // 获取玩家信息
    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 查找库存中的物品
    const inventoryIndex = player.inventory.findIndex(
      (invItem: any) => invItem.itemId === itemId && !invItem.equipped
    );

    if (inventoryIndex === -1) {
      return res.json(createErrorResponse('库存中没有该物品'));
    }

    const invItem = player.inventory[inventoryIndex];

    // 检查数量是否足够
    if (invItem.quantity < quantity) {
      return res.json(createErrorResponse(`库存数量不足，当前数量：${invItem.quantity}`));
    }

    // 计算总价
    const totalPrice = item.sellPrice * quantity;

    // 减少库存
    invItem.quantity -= quantity;
    if (invItem.quantity <= 0) {
      player.inventory.splice(inventoryIndex, 1);
    }

    // 增加金币
    player.gold += totalPrice;
    player.updatedAt = new Date();

    await player.save();

    res.json(createSuccessResponse({
      gold: player.gold,
      inventory: player.inventory,
      totalPrice,
    }, `出售成功！获得 ${totalPrice} 金币`));
  } catch (error) {
    next(error);
  }
});

/**
 * 辅助函数：获取类型中文名
 */
function _getTypeName(type: string): string {
  const typeMap: Record<string, string> = {
    tool: '忍具',
    medicine: '药品',
    equipment: '装备',
    material: '材料',
  };
  return typeMap[type] || type;
}

export default router;
