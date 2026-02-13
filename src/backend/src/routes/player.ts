import { Router, Response, NextFunction } from 'express';
import User, { IUser } from '../models/User';
import { AuthRequest } from '../middleware/auth';
import { generateToken } from '../config/jwt';
import { createSuccessResponse, createErrorResponse } from '../utils/responseHandler';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import Item from '../models/Item';
import Player from '../models/Player';

const router = Router();

/**
 * @route   POST /api/player/register
 * @desc    用户注册
 * @access  Public
 */
router.post('/register', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { username, email, password } = req.body;

    // 验证输入
    if (!username || !email || !password) {
      return res.json(createErrorResponse('请填写完整的注册信息'));
    }

    // 验证用户名长度
    if (username.length < 3 || username.length > 20) {
      return res.json(createErrorResponse('用户名长度需要在3-20个字符之间'));
    }

    // 验证密码长度
    if (password.length < 6) {
      return res.json(createErrorResponse('密码至少需要6位'));
    }

    // 验证邮箱格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.json(createErrorResponse('邮箱格式不正确'));
    }

    // 检查用户名是否已存在
    const existingUsername = await User.findOne({ username });
    if (existingUsername) {
      return res.json(createErrorResponse('用户名已被使用'));
    }

    // 检查邮箱是否已存在
    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      return res.json(createErrorResponse('邮箱已被注册'));
    }

    // 加密密码
    const hashedPassword = await bcrypt.hash(password, 10);

    // 生成用户ID
    const userId = `user_${uuidv4()}`;

    // 创建用户
    const user = new User({
      userId,
      username,
      email: email.toLowerCase(),
      password: hashedPassword,
    });

    await user.save();

    // 创建玩家数据
    const player = new Player({
      playerId: userId,
      userId,
      level: 1,
      experience: 0,
      gold: 1000, // 初始金币
      chakra: 100,
      maxChakra: 100,
      health: 100,
      maxHealth: 100,
      inventory: [],
      equipment: {},
      attributes: {
        strength: 10,
        agility: 10,
        intelligence: 10,
        chakra: 10,
      },
      currentChapter: 'chapter_1',
      flags: {},
      stats: {
        totalPlayTime: 0,
        missionsCompleted: 0,
        enemiesDefeated: 0,
        itemsCollected: 0,
      },
    });

    await player.save();

    // 生成token
    const token = generateToken({
      userId,
      username,
    });

    res.json(createSuccessResponse({
      token,
      user: {
        userId,
        username,
        email: user.email,
      },
      player: {
        level: player.level,
        gold: player.gold,
      },
    }, '注册成功'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/player/login
 * @desc    用户登录
 * @access  Public
 */
router.post('/login', async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { email, password } = req.body;

    // 验证输入
    if (!email || !password) {
      return res.json(createErrorResponse('请输入邮箱和密码'));
    }

    // 查找用户
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.json(createErrorResponse('邮箱或密码错误'));
    }

    // 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return res.json(createErrorResponse('邮箱或密码错误'));
    }

    // 生成token
    const token = generateToken({
      userId: user.userId,
      username: user.username,
    });

    // 获取玩家数据
    const player = await Player.findOne({ playerId: user.userId });

    res.json(createSuccessResponse({
      token,
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
      },
      player: player ? {
        level: player.level,
        gold: player.gold,
        experience: player.experience,
      } : null,
    }, '登录成功'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/player/logout
 * @desc    用户登出
 * @access  Private
 */
router.post('/logout', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  // JWT是无状态的，客户端删除token即可
  // 这里可以添加token黑名单逻辑（可选）
  res.json(createSuccessResponse(null, '登出成功'));
});

/**
 * @route   GET /api/player
 * @desc    获取玩家信息
 * @access  Private
 */
router.get('/', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;

    // 获取用户信息
    const user = await User.findOne({ userId }).select('-password');
    if (!user) {
      return res.json(createErrorResponse('用户不存在'));
    }

    // 获取玩家数据
    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    res.json(createSuccessResponse({
      user: {
        userId: user.userId,
        username: user.username,
        email: user.email,
        createdAt: user.createdAt,
      },
      player: {
        level: player.level,
        experience: player.experience,
        gold: player.gold,
        chakra: player.chakra,
        maxChakra: player.maxChakra,
        health: player.health,
        maxHealth: player.maxHealth,
        attributes: player.attributes,
        currentChapter: player.currentChapter,
        stats: player.stats,
      },
    }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   PUT /api/player/attributes
 * @desc    更新玩家属性
 * @access  Private
 */
router.put('/attributes', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { attributes } = req.body;

    if (!attributes) {
      return res.json(createErrorResponse('请提供属性数据'));
    }

    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 更新属性
    player.attributes = { ...player.attributes, ...attributes };
    player.updatedAt = new Date();

    await player.save();

    res.json(createSuccessResponse({
      attributes: player.attributes,
    }, '属性更新成功'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   GET /api/player/inventory
 * @desc    获取玩家库存
 * @access  Private
 */
router.get('/inventory', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;

    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 获取物品详情
    const itemIds = player.inventory.map((invItem: any) => invItem.itemId);
    const items = await Item.find({ itemId: { $in: itemIds } });

    // 合并物品详情
    const inventory = player.inventory.map((invItem: any) => {
      const item = items.find(i => i.itemId === invItem.itemId);
      return {
        item,
        quantity: invItem.quantity,
        equipped: invItem.equipped || false,
      };
    });

    res.json(createSuccessResponse({ inventory }));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/player/inventory/use
 * @desc    使用物品
 * @access  Private
 */
router.post('/inventory/use', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { itemId } = req.body;

    if (!itemId) {
      return res.json(createErrorResponse('请提供物品ID'));
    }

    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 查找库存中的物品
    const inventoryIndex = player.inventory.findIndex((invItem: any) => invItem.itemId === itemId);
    if (inventoryIndex === -1) {
      return res.json(createErrorResponse('物品不存在'));
    }

    const invItem = player.inventory[inventoryIndex];
    if (invItem.quantity <= 0) {
      return res.json(createErrorResponse('物品数量不足'));
    }

    // 获取物品详情
    const item = await Item.findOne({ itemId });
    if (!item) {
      return res.json(createErrorResponse('物品数据不存在'));
    }

    // 检查是否可以使用
    if (item.type !== 'medicine') {
      return res.json(createErrorResponse('该物品不可使用'));
    }

    // 应用物品效果
    if (item.effect) {
      switch (item.effect.type) {
        case 'recover':
          if (item.effect.target === 'health') {
            player.health = Math.min(player.maxHealth, player.health + item.effect.value);
          } else if (item.effect.target === 'chakra') {
            player.chakra = Math.min(player.maxChakra, player.chakra + item.effect.value);
          }
          break;
      }
    }

    // 减少数量
    invItem.quantity -= 1;
    if (invItem.quantity <= 0) {
      player.inventory.splice(inventoryIndex, 1);
    }

    player.updatedAt = new Date();
    await player.save();

    res.json(createSuccessResponse({
      health: player.health,
      chakra: player.chakra,
    }, '使用成功'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/player/inventory/equip
 * @desc    装备物品
 * @access  Private
 */
router.post('/inventory/equip', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { itemId } = req.body;

    if (!itemId) {
      return res.json(createErrorResponse('请提供物品ID'));
    }

    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 查找库存中的物品
    const inventoryItem = player.inventory.find((invItem: any) => invItem.itemId === itemId);
    if (!inventoryItem) {
      return res.json(createErrorResponse('物品不存在'));
    }

    // 获取物品详情
    const item = await Item.findOne({ itemId });
    if (!item) {
      return res.json(createErrorResponse('物品数据不存在'));
    }

    // 检查是否可以装备
    if (item.type !== 'equipment') {
      return res.json(createErrorResponse('该物品不可装备'));
    }

    // 如果已经有同类型的装备，先卸下
    if (player.equipment[item.category]) {
      const oldEquippedItemId = player.equipment[item.category];
      const oldEquippedIndex = player.inventory.findIndex(
        (invItem: any) => invItem.itemId === oldEquippedItemId
      );
      if (oldEquippedIndex !== -1) {
        player.inventory[oldEquippedIndex].equipped = false;
      }
    }

    // 装备新物品
    player.equipment[item.category] = itemId;
    inventoryItem.equipped = true;

    player.updatedAt = new Date();
    await player.save();

    res.json(createSuccessResponse({
      equipment: player.equipment,
    }, '装备成功'));
  } catch (error) {
    next(error);
  }
});

/**
 * @route   POST /api/player/inventory/unequip
 * @desc    卸下装备
 * @access  Private
 */
router.post('/inventory/unequip', authenticate, async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const { userId } = req;
    const { itemId } = req.body;

    if (!itemId) {
      return res.json(createErrorResponse('请提供物品ID'));
    }

    const player = await Player.findOne({ playerId: userId });
    if (!player) {
      return res.json(createErrorResponse('玩家数据不存在'));
    }

    // 获取物品详情
    const item = await Item.findOne({ itemId });
    if (!item) {
      return res.json(createErrorResponse('物品数据不存在'));
    }

    // 检查该装备是否已装备
    if (player.equipment[item.category] !== itemId) {
      return res.json(createErrorResponse('该物品未装备'));
    }

    // 卸下装备
    delete player.equipment[item.category];

    const inventoryIndex = player.inventory.findIndex((invItem: any) => invItem.itemId === itemId);
    if (inventoryIndex !== -1) {
      player.inventory[inventoryIndex].equipped = false;
    }

    player.updatedAt = new Date();
    await player.save();

    res.json(createSuccessResponse({
      equipment: player.equipment,
    }, '卸下成功'));
  } catch (error) {
    next(error);
  }
});

// 认证中间件导入
import { authenticate } from '../middleware/auth';

export default router;
