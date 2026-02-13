# 后端开发指南

## 技术栈

- **运行时**: Node.js 20.x
- **框架**: Express.js 4.x
- **语言**: TypeScript 5.x
- **数据库**: MongoDB 7.x
- **ORM**: Mongoose
- **认证**: JWT
- **日志**: Winston
- **验证**: express-validator

---

## 开发环境设置

### 1. 安装 Node.js

```bash
# 使用 nvm 安装
nvm install 20
nvm use 20

# 验证安装
node --version
npm --version
```

### 2. 安装依赖

```bash
cd src/backend
npm install
```

### 3. 配置环境变量

```bash
cp .env.example .env
# 编辑 .env 文件，配置你的环境变量
```

### 4. 启动 MongoDB

```bash
# macOS
brew services start mongodb-community

# Linux
sudo systemctl start mongod

# Windows
net start MongoDB
```

---

## 项目结构说明

```
src/
├── index.ts                 # 应用入口
├── app.ts                   # Express应用配置
├── config/                  # 配置文件
│   ├── database.ts          # 数据库配置
│   ├── jwt.ts               # JWT配置
│   └── logger.ts            # 日志配置
├── middleware/              # 中间件
│   ├── auth.ts              # 认证中间件
│   ├── error.ts             # 错误处理
│   └── rateLimit.ts         # 限流
├── routes/                  # 路由
├── controllers/             # 控制器
├── services/                # 业务逻辑
├── models/                  # 数据模型
├── validators/              # 数据验证
├── utils/                   # 工具函数
└── types/                   # TypeScript类型
```

---

## 开发规范

### 命名规范

**文件命名**:
- 模型文件: `PascalCase.ts` (如 `User.ts`)
- 路由文件: `PascalCase.ts` (如 `saves.ts`)
- 服务文件: `PascalCase.ts` (如 `saveService.ts`)

**类命名**: `PascalCase`
```typescript
class UserController {}
class SaveService {}
```

**接口命名**: `PascalCase` (带`I`前缀)
```typescript
interface IUser {
  userId: string;
  username: string;
}
```

**变量/函数命名**: `camelCase`
```typescript
const userId = '123';
function getUser() {}
```

**常量命名**: `UPPER_SNAKE_CASE`
```typescript
const MAX_RETRY_ATTEMPTS = 3;
const API_BASE_URL = 'https://api.example.com';
```

### Import 顺序

1. Node.js 内置模块
2. 第三方库
3. 项目内部模块

```typescript
import express, { Request, Response } from 'express';
import mongoose from 'mongoose';
import jwt from 'jsonwebtoken';

import { verifyToken } from '../config/jwt';
import { successResponse } from '../utils/responseHandler';
import User from '../models/User';
```

---

## 路由开发

### 路由模板

```typescript
import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import * as controller from '../controllers/saveController';
import * as validator from '../validators/saveValidator';

const router = Router();

// 所有接口需要认证
router.use(authenticate);

// 获取存档列表
router.get('/', validator.listSaves, controller.listSaves);

// 获取存档详情
router.get('/:saveId', validator.getSave, controller.getSave);

// 创建存档
router.post('/', validator.createSave, controller.createSave);

// 更新存档
router.put('/:saveId', validator.updateSave, controller.updateSave);

// 删除存档
router.delete('/:saveId', validator.deleteSave, controller.deleteSave);

export default router;
```

### 路由注册

```typescript
// routes/index.ts
import { Router } from 'express';
import savesRouter from './saves';
import storyRouter from './story';

const router = Router();

router.use('/saves', savesRouter);
router.use('/story', storyRouter);

export default router;
```

---

## 控制器开发

### 控制器模板

```typescript
import { Response } from 'express';
import { AuthRequest } from '../middleware/auth';
import { successResponse, errorResponse } from '../utils/responseHandler';
import SaveService from '../services/saveService';

export const listSaves = async (req: AuthRequest, res: Response) => {
  try {
    const userId = req.userId!;
    const saves = await SaveService.listSaves(userId);

    return successResponse(res, saves);
  } catch (error) {
    return errorResponse(res, '获取存档列表失败', 500, error);
  }
};

export const getSave = async (req: AuthRequest, res: Response) => {
  try {
    const { saveId } = req.params;
    const userId = req.userId!;

    const save = await SaveService.getSave(saveId, userId);

    if (!save) {
      return errorResponse(res, '存档不存在', 404);
    }

    return successResponse(res, save);
  } catch (error) {
    return errorResponse(res, '获取存档失败', 500, error);
  }
};
```

---

## 服务层开发

### 服务模板

```typescript
import Save from '../models/Save';
import { ISave } from '../models/Save';
import { createError } from '../middleware/error';

class SaveService {
  /**
   * 获取存档列表
   */
  async listSaves(userId: string): Promise<ISave[]> {
    return await Save.find({ playerId: userId }).sort({ updatedAt: -1 });
  }

  /**
   * 获取存档详情
   */
  async getSave(saveId: string, userId: string): Promise<ISave | null> {
    return await Save.findOne({ saveId, playerId: userId });
  }

  /**
   * 创建存档
   */
  async createSave(saveData: Partial<ISave>, userId: string): Promise<ISave> {
    const newSave = new Save({
      ...saveData,
      playerId: userId,
    });

    return await newSave.save();
  }

  /**
   * 更新存档
   */
  async updateSave(
    saveId: string,
    userId: string,
    updateData: Partial<ISave>
  ): Promise<ISave | null> {
    return await Save.findOneAndUpdate(
      { saveId, playerId: userId },
      updateData,
      { new: true }
    );
  }

  /**
   * 删除存档
   */
  async deleteSave(saveId: string, userId: string): Promise<boolean> {
    const result = await Save.deleteOne({ saveId, playerId: userId });
    return result.deletedCount > 0;
  }
}

export default new SaveService();
```

---

## 数据验证

### 使用 express-validator

```typescript
import { body, param } from 'express-validator';

export const createSave = [
  body('saveName')
    .trim()
    .notEmpty()
    .withMessage('存档名称不能为空')
    .isLength({ max: 50 })
    .withMessage('存档名称最多50个字符'),

  body('gameData')
    .notEmpty()
    .withMessage('游戏数据不能为空'),

  // 其他验证...
];

export const getSave = [
  param('saveId')
    .notEmpty()
    .withMessage('存档ID不能为空'),
];
```

### 在路由中使用验证

```typescript
import { validate } from '../middleware/validation';

router.post('/', validator.createSave, validate, controller.createSave);
```

---

## 错误处理

### 自定义错误

```typescript
import { createError } from '../middleware/error';

// 在控制器或服务中使用
throw createError('存档不存在', 404);
```

### 统一错误响应

```typescript
// 所有错误都会被 error middleware 捕获并统一返回
{
  "code": 404,
  "message": "存档不存在"
}
```

---

## 数据库操作

### 使用 Mongoose

```typescript
// 查询
const saves = await Save.find({ playerId: userId });
const save = await Save.findOne({ saveId });

// 创建
const newSave = new Save(saveData);
await newSave.save();

// 更新
const updated = await Save.findByIdAndUpdate(id, updateData, { new: true });

// 删除
await Save.findByIdAndDelete(id);

// 聚合查询
const result = await Save.aggregate([
  { $match: { playerId: userId } },
  { $sort: { updatedAt: -1 } },
  { $limit: 10 },
]);
```

---

## 日志记录

### 使用 Winston

```typescript
import logger from '../config/logger';

// 不同级别的日志
logger.error('Error message', error);
logger.warn('Warning message');
logger.info('Info message');
logger.debug('Debug message');
```

---

## 测试

### 单元测试

```typescript
import { describe, it, expect, beforeEach } from '@jest/globals';
import SaveService from '../services/saveService';

describe('SaveService', () => {
  beforeEach(async () => {
    // 测试前准备
    await Save.deleteMany({});
  });

  it('should create a save', async () => {
    const saveData = {
      saveId: 'test_001',
      playerId: 'user_001',
      saveName: 'Test Save',
    };

    const save = await SaveService.createSave(saveData, 'user_001');

    expect(save.saveName).toBe('Test Save');
  });
});
```

### API 测试

```typescript
import request from 'supertest';
import app from '../app';

describe('Save API', () => {
  it('GET /api/saves should return saves list', async () => {
    const response = await request(app)
      .get('/api/saves')
      .set('Authorization', 'Bearer valid_token')
      .expect(200);

    expect(response.body.code).toBe(200);
  });
});
```

---

## 性能优化

### 1. 数据库查询优化

```typescript
// 使用索引
Save.find({ playerId: userId })  // 确保 playerId 有索引

// 使用投影（只返回需要的字段）
Save.find({ playerId: userId }).select('saveName updatedAt')

// 限制返回数量
Save.find({ playerId: userId }).limit(10)
```

### 2. 缓存策略

```typescript
// 使用内存缓存（简单场景）
const cache = new Map();

async function getCachedData(key: string) {
  if (cache.has(key)) {
    return cache.get(key);
  }

  const data = await fetchData();
  cache.set(key, data);
  return data;
}

// 使用 Redis（推荐，生产环境）
```

### 3. 异步操作优化

```typescript
// 使用 Promise.all 并行执行
const [saves, quests] = await Promise.all([
  Save.find({ playerId: userId }),
  Quest.find({ playerId: userId }),
]);
```

---

## 安全最佳实践

### 1. 输入验证

```typescript
// 始终验证用户输入
const { saveName } = req.body;
if (!saveName || saveName.length > 50) {
  throw createError('存档名称无效', 400);
}
```

### 2. SQL/NoSQL 注入防护

```typescript
// 使用 Mongoose 的参数化查询（自动防护）
Save.findOne({ saveId: req.params.saveId })  // ✅ 安全

// 避免
Save.findOne(`{ saveId: "${req.params.saveId}" }`)  // ❌ 危险
```

### 3. 敏感数据处理

```typescript
// 不要返回敏感数据
const user = await User.findById(userId);
const { password, ...safeUserData } = user.toObject();
return safeUserData;
```

### 4. 速率限制

```typescript
// 使用 rate limit 中间件
router.use('/api/', rateLimiter);
```

---

## 调试技巧

### 1. 使用调试器

```bash
# 使用 VS Code 调试
# 创建 .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "program": "${workspaceFolder}/src/index.ts",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["run", "dev:debug"]
    }
  ]
}
```

### 2. 日志调试

```typescript
logger.debug('Request data:', JSON.stringify(req.body, null, 2));
logger.debug('Query:', JSON.stringify(req.query, null, 2));
```

### 3. 数据库调试

```typescript
// 启用 Mongoose 调试模式
mongoose.set('debug', true);
```

---

## 部署

### 1. 构建生产版本

```bash
npm run build
npm start
```

### 2. 使用 PM2 守护进程

```bash
npm install -g pm2
pm2 start dist/index.js --name naruto-api
pm2 startup
pm2 save
```

### 3. 环境变量配置

生产环境必须配置：
- `NODE_ENV=production`
- `MONGODB_URI` (生产数据库)
- `JWT_SECRET` (强密码)
- `CORS_ORIGIN` (前端域名)

---

## 常见问题

### 1. MongoDB 连接失败

检查：
- MongoDB 服务是否运行
- 连接字符串是否正确
- 网络是否可访问

### 2. TypeScript 编译错误

确保：
- 安装了所有类型定义包 `@types/*`
- `tsconfig.json` 配置正确

### 3. 内存泄漏

- 及时关闭数据库连接
- 避免全局变量
- 使用事件监听器时记得移除

---

## 参考资源

- [Node.js 官方文档](https://nodejs.org/docs)
- [Express 官方文档](https://expressjs.com)
- [TypeScript 官方文档](https://www.typescriptlang.org/docs)
- [Mongoose 官方文档](https://mongoosejs.com/docs)
- [JWT 官方文档](https://jwt.io/introduction)

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
**维护者**: 技术团队
