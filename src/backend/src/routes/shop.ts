import { Router } from 'express';
import { authenticate } from '../middleware/auth';

const router = Router();
router.use(authenticate);

/**
 * @route   GET /api/shop/categories
 * @desc    获取商品分类
 * @access  Private
 */
router.get('/categories', (req, res) => {
  // TODO: 实现获取商品分类逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   GET /api/shop/items
 * @desc    获取商品列表
 * @access  Private
 */
router.get('/items', (req, res) => {
  // TODO: 实现获取商品列表逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   POST /api/shop/purchase
 * @desc    购买商品
 * @access  Private
 */
router.post('/purchase', (req, res) => {
  // TODO: 实现购买商品逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

export default router;
