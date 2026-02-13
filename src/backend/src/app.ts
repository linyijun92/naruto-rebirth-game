import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { errorHandler } from './middleware/error';
import { rateLimiter } from './middleware/rateLimit';
import logger from './config/logger';
import routes from './routes';

const app: Application = express();

// 安全中间件
app.use(helmet());

// CORS配置
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
}));

// 压缩响应
app.use(compression());

// 请求日志
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('combined', {
    stream: {
      write: (message: string) => logger.info(message.trim()),
    },
  }));
}

// 解析请求体
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// API限流
app.use('/api/', rateLimiter);

// 健康检查
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// API路由
app.use('/api', routes);

// 404处理
app.use((req, res) => {
  res.status(404).json({
    code: 404,
    message: 'API endpoint not found',
  });
});

// 错误处理中间件（必须在所有路由之后）
app.use(errorHandler);

export default app;
