import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import logger from './config/logger';
import { checkDatabaseConnection } from './config/database';

// 路由
import { register, login, getPlayer, updatePlayer, levelUp, addExperience } from './routes/player';

const app = express();
const PORT = process.env.PORT || 3000;

// 中间件
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// 请求日志
app.use((req, res, next) => {
  logger.info({
    method: req.method,
    path: req.path,
    ip: req.ip,
    userAgent: req.get('user-agent'),
    body: req.body ? JSON.stringify(req.body).substring(0, 100) : undefined,
  });
  next();
});

// API 路由
app.post('/api/player/register', register);
app.post('/api/player/login', login);
app.get('/api/player/:id', getPlayer);
app.put('/api/player/:id', updatePlayer);
app.post('/api/player/:id/level-up', levelUp);
app.post('/api/player/:id/add-experience', addExperience);

// 健康检查端点
app.get('/health', async (req, res) => {
  try {
    const isConnected = await checkDatabaseConnection();

    const health = {
      status: isConnected ? 'ok' : 'error',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV || 'development',
      database: {
        state: isConnected ? 'connected' : 'disconnected',
        name: 'naruto-rebirth-game',
        type: 'supabase',
      },
      memory: {
        used: process.memoryUsage().heapUsed,
        total: process.memoryUsage().heapTotal,
        rss: process.memoryUsage().rss,
      },
      cpu: process.cpuUsage(),
    };

    if (!isConnected) {
      return res.status(503).json(health);
    }

    res.json(health);
  } catch (error) {
    logger.error('Health check error:', error);
    res.status(500).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      error: error.message,
    });
  }
});

// 404 处理
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    path: req.path,
    method: req.method,
  });
});

// 错误处理中间件
app.use((err, req, res, next) => {
  logger.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    timestamp: new Date().toISOString(),
  });
});

// 启动服务器
const startServer = async () => {
  try {
    // 连接数据库（检查连接）
    await checkDatabaseConnection();
    logger.info('Database connected successfully');

    // 启动服务器
    app.listen(PORT, () => {
      logger.info(`Server is running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`Database: Supabase`);
      logger.info(`Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// 处理未捕获的异常
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

// 处理未处理的 Promise 拒绝
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

// Vercel 无服务器环境不启动服务器
// 本地开发环境才启动服务器
if (process.env.NODE_ENV !== 'production' && !process.env.VERCEL) {
  startServer();
}

// 导出 app 用于 Vercel 部署
export default app;
