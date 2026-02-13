import { Router } from 'express';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

/**
 * @route   GET /api/player
 * @desc    获取玩家信息
 * @access  Private
 */
router.get('/', (req, res) => {
  // TODO: 实现获取玩家信息逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   PUT /api/player/attributes
 * @desc    更新玩家属性
 * @access  Private
 */
router.put('/attributes', (req, res) => {
  // TODO: 实现更新属性逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

export default router;
