import { Router } from 'express';
import { optionalAuth } from '../middleware/auth';

const router = Router();

// 使用可选认证（未登录用户也可以查看剧情）
router.use(optionalAuth);

/**
 * @route   GET /api/story/chapters
 * @desc    获取章节列表
 * @access  Public
 */
router.get('/chapters', (req, res) => {
  // TODO: 实现获取章节列表逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   GET /api/story/:chapterId
 * @desc    获取章节详情
 * @access  Public
 */
router.get('/:chapterId', (req, res) => {
  // TODO: 实现获取章节详情逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   GET /api/story/nodes/:nodeId
 * @desc    获取剧情节点
 * @access  Public
 */
router.get('/nodes/:nodeId', (req, res) => {
  // TODO: 实现获取剧情节点逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

/**
 * @route   POST /api/story/nodes/:nodeId/choice
 * @desc    提交剧情选择
 * @access  Private
 */
router.post('/nodes/:nodeId/choice', (req, res) => {
  // TODO: 实现提交剧情选择逻辑
  res.status(501).json({
    code: 501,
    message: 'Not Implemented',
  });
});

export default router;
