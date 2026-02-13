import { Router } from 'express';

const router = Router();

// 导入各模块路由
import savesRouter from './saves';
import storyRouter from './story';
import playerRouter from './player';
import questsRouter from './quests';
import shopRouter from './shop';

// 注册路由
router.use('/saves', savesRouter);
router.use('/story', storyRouter);
router.use('/player', playerRouter);
router.use('/quests', questsRouter);
router.use('/shop', shopRouter);

export default router;
