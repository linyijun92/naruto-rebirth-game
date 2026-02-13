import { Router, Request, Response } from 'express';
import { authenticate } from '../middleware/auth';
import Save, { ISave } from '../models/Save';
import mongoose from 'mongoose';

const router = Router();

// 所有存档接口都需要认证
router.use(authenticate);

/**
 * @route   POST /api/saves
 * @desc    创建新存档
 * @access  Private
 */
router.post('/', async (req: Request, res: Response) => {
  try {
    const { playerId, saveName, gameTime, playerLevel, attributes, currentChapter, inventory, quests, achievements, playTime } = req.body;
    const userId = (req as any).user?.userId;

    // 生成唯一存档ID
    const saveId = `save_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const saveData: Partial<ISave> = {
      saveId,
      playerId: playerId || userId,
      saveName: saveName || `存档 ${new Date().toLocaleString()}`,
      gameTime: gameTime || '火影纪元 1年',
      playerLevel: playerLevel || 1,
      attributes: attributes || {
        chakra: 100,
        ninjutsu: 50,
        taijutsu: 50,
        intelligence: 50,
        speed: 50,
        luck: 50,
      },
      currentChapter: currentChapter || 'chapter_01_01',
      inventory: inventory || [],
      quests: quests || [],
      achievements: achievements || [],
      playTime: playTime || 0,
      isCloud: true,
    };

    const save = new Save(saveData);
    await save.save();

    res.status(201).json({
      code: 201,
      message: '存档创建成功',
      data: save,
    });
  } catch (error) {
    console.error('创建存档失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   GET /api/saves
 * @desc    获取存档列表
 * @access  Private
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.userId;
    const { cloudOnly = 'false' } = req.query;

    const query: any = { playerId: userId };
    if (cloudOnly === 'true') {
      query.isCloud = true;
    }

    const saves = await Save.find(query)
      .sort({ updatedAt: -1 })
      .limit(50)
      .select('-__v');

    res.status(200).json({
      code: 200,
      message: '获取存档列表成功',
      data: {
        total: saves.length,
        saves,
      },
    });
  } catch (error) {
    console.error('获取存档列表失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   GET /api/saves/:saveId
 * @desc    获取存档详情
 * @access  Private
 */
router.get('/:saveId', async (req: Request, res: Response) => {
  try {
    const { saveId } = req.params;
    const userId = (req as any).user?.userId;

    const save = await Save.findOne({ saveId, playerId: userId }).select('-__v');

    if (!save) {
      return res.status(404).json({
        code: 404,
        message: '存档不存在',
      });
    }

    res.status(200).json({
      code: 200,
      message: '获取存档详情成功',
      data: save,
    });
  } catch (error) {
    console.error('获取存档详情失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   PUT /api/saves/:saveId
 * @desc    更新存档
 * @access  Private
 */
router.put('/:saveId', async (req: Request, res: Response) => {
  try {
    const { saveId } = req.params;
    const userId = (req as any).user?.userId;
    const updateData = req.body;

    // 查找存档
    const save = await Save.findOne({ saveId, playerId: userId });

    if (!save) {
      return res.status(404).json({
        code: 404,
        message: '存档不存在',
      });
    }

    // 更新字段
    const allowedFields = ['saveName', 'gameTime', 'playerLevel', 'attributes', 'currentChapter', 'inventory', 'quests', 'achievements', 'playTime'];
    allowedFields.forEach((field) => {
      if (updateData[field] !== undefined) {
        (save as any)[field] = updateData[field];
      }
    });

    await save.save();

    res.status(200).json({
      code: 200,
      message: '更新存档成功',
      data: save,
    });
  } catch (error) {
    console.error('更新存档失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   DELETE /api/saves/:saveId
 * @desc    删除存档
 * @access  Private
 */
router.delete('/:saveId', async (req: Request, res: Response) => {
  try {
    const { saveId } = req.params;
    const userId = (req as any).user?.userId;

    const save = await Save.findOneAndDelete({ saveId, playerId: userId });

    if (!save) {
      return res.status(404).json({
        code: 404,
        message: '存档不存在',
      });
    }

    res.status(200).json({
      code: 200,
      message: '删除存档成功',
      data: { saveId },
    });
  } catch (error) {
    console.error('删除存档失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   POST /api/saves/:saveId/sync
 * @desc    同步存档到云端
 * @access  Private
 */
router.post('/:saveId/sync', async (req: Request, res: Response) => {
  try {
    const { saveId } = req.params;
    const userId = (req as any).user?.userId;
    const { saveData } = req.body;

    // 查找或创建云端存档
    let save = await Save.findOne({ saveId, playerId: userId });

    if (save) {
      // 更新现有存档
      if (saveData) {
        const allowedFields = ['saveName', 'gameTime', 'playerLevel', 'attributes', 'currentChapter', 'inventory', 'quests', 'achievements', 'playTime'];
        allowedFields.forEach((field) => {
          if (saveData[field] !== undefined) {
            (save as any)[field] = saveData[field];
          }
        });
      }
      save.isCloud = true;
      await save.save();
    } else if (saveData) {
      // 创建新存档
      save = new Save({
        ...saveData,
        saveId,
        playerId: userId,
        isCloud: true,
      });
      await save.save();
    } else {
      return res.status(400).json({
        code: 400,
        message: '存档不存在且未提供存档数据',
      });
    }

    res.status(200).json({
      code: 200,
      message: '同步存档成功',
      data: save,
    });
  } catch (error) {
    console.error('同步存档失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

/**
 * @route   POST /api/saves/batch
 * @desc    批量上传存档
 * @access  Private
 */
router.post('/batch', async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.userId;
    const { saves } = req.body;

    if (!Array.isArray(saves) || saves.length === 0) {
      return res.status(400).json({
        code: 400,
        message: '存档数据无效',
      });
    }

    const results = [];

    for (const saveData of saves) {
      const saveId = saveData.saveId || `save_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      const existingSave = await Save.findOne({ saveId, playerId: userId });
      let save;

      if (existingSave) {
        // 更新现有存档
        const allowedFields = ['saveName', 'gameTime', 'playerLevel', 'attributes', 'currentChapter', 'inventory', 'quests', 'achievements', 'playTime'];
        allowedFields.forEach((field) => {
          if (saveData[field] !== undefined) {
            (existingSave as any)[field] = saveData[field];
          }
        });
        existingSave.isCloud = true;
        save = await existingSave.save();
      } else {
        // 创建新存档
        save = new Save({
          ...saveData,
          saveId,
          playerId: userId,
          isCloud: true,
        });
        await save.save();
      }

      results.push(save);
    }

    res.status(200).json({
      code: 200,
      message: '批量上传存档成功',
      data: {
        total: results.length,
        saves: results,
      },
    });
  } catch (error) {
    console.error('批量上传存档失败:', error);
    res.status(500).json({
      code: 500,
      message: '服务器错误',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
});

export default router;
