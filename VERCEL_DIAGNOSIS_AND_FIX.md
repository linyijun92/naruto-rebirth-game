# Vercel 部署诊断和改造方案

**项目名称**：重生到火影忍者世界
**诊断时间**：2026-02-13
**基于**：Vercel 技能文档

---

## 🔍 当前问题诊断

### 问题 1：504 错误 - FUNCTION_INVOCATION_FAILED

**错误信息**：
```
FUNCTION_INVOCATION_FAILED
```

**根本原因**：
- Node.js 后端依赖 MongoDB 数据库连接
- 环境变量 `MONGODB_URI` 未配置
- Vercel Serverless 函数无法连接到 `localhost:27017`

### 问题 2：项目结构不适合 Vercel

**当前结构**：
```
naruto-rebirth-game/
├── src/
│   ├── frontend/  # Flutter 移动端应用
│   └── backend/   # Node.js 后端
└── vercel.json
```

**问题**：
- Flutter 移动端应用无法直接部署到 Vercel
- Vercel 主要用于 Web 应用和 Serverless 函数
- Node.js 后端需要外部数据库（MongoDB 不支持本地连接）

### 问题 3：缺少必要的环境变量

**当前配置**（src/backend/src/config/database.ts）：
```typescript
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/naruto_rebirth';
```

**缺少的环境变量**：
- `MONGODB_URI` - MongoDB 数据库连接字符串
- `JWT_SECRET` - JWT 签名密钥
- `NODE_ENV` - 运行环境（已在 vercel.json 中配置）

---

## ✅ 改造方案

### 方案 1：配置 MongoDB 数据库（推荐，快速）

**步骤**：

#### 1.1 创建 MongoDB Atlas 免费账号

1. 访问 https://www.mongodb.com/cloud/atlas
2. 注册账号（免费版 512MB）
3. 创建新项目：`naruto-rebirth-game`
4. 创建集群（选择免费层：M0 Sandbox）
5. 创建数据库用户
6. 获取连接字符串

**连接字符串格式**：
```
mongodb+srv://<username>:<password>@<cluster>.mongodb.net/<database>?retryWrites=true&w=majority&appName=naruto-rebirth-game
```

#### 1.2 配置 Vercel 环境变量

**方法 1：通过 Vercel CLI（推荐）**

```bash
# 确保已登录 Vercel
vercel login

# 设置环境变量
vercel env add MONGODB_URI
# 输入 MongoDB 连接字符串

vercel env add JWT_SECRET
# 输入随机字符串，例如：random-secure-key-123456

vercel env add NODE_ENV
# 输入：production
```

**方法 2：通过 Vercel Dashboard**

1. 访问 https://vercel.com/dashboard
2. 选择 `naruto-rebirth-game` 项目
3. 进入 Settings → Environment Variables
4. 添加以下变量：
   - `MONGODB_URI` = MongoDB 连接字符串
   - `JWT_SECRET` = 随机安全字符串（至少 32 字符）
   - `NODE_ENV` = `production`

#### 1.3 验证部署

```bash
# Vercel 会自动重新部署
# 等待 2-5 分钟

# 测试健康检查端点
curl https://naruto-rebirth-game.vercel.app/health
```

**预期响应**：
```json
{
  "status": "ok",
  "timestamp": "2026-02-13T...",
  "uptime": ...
}
```

---

### 方案 2：使用 Vercel 兼容的数据库

**问题**：
- MongoDB Atlas 在某些网络环境下可能有延迟
- Vercel Serverless 函数冷启动可能导致连接超时

**替代方案：使用 Serverless 优化的数据库**

#### 2.1 PlanetScale（MySQL 兼容，Serverless 优化）

1. 访问 https://planetscale.com
2. 注册账号并创建数据库
3. 获取连接字符串
4. 在 Vercel 中配置环境变量

**优点**：
- ✅ Serverless 优化
- ✅ 快速连接
- ✅ 免费额度较大（5GB）
- ✅ Vercel 集成良好

**缺点**：
- ❌ 需要修改代码（使用 MySQL 而不是 MongoDB）
- ❌ 需要 ORM 迁移（Mongoose → Prisma/TypeORM）

#### 2.2 Neon（PostgreSQL 兼容，Serverless 优化）

1. 访问 https://neon.tech
2. 注册账号并创建数据库
3. 获取连接字符串
4. 在 Vercel 中配置环境变量

**优点**：
- ✅ Serverless 优化
- ✅ 快速连接
- ✅ 免费额度（0.5GB）
- ✅ Vercel 集成良好

**缺点**：
- ❌ 需要修改代码（使用 PostgreSQL 而不是 MongoDB）
- ❌ 需要 ORM 迁移（Mongoose → Prisma/TypeORM）

**不推荐**：除非你有时间进行数据库迁移

---

### 方案 3：分离部署（长期方案）

**架构**：
```
Flutter 移动端 → Google Play Store / App Store
Flutter Web → Vercel / Netlify
Node.js 后端 → Vercel / Railway / Render
MongoDB → MongoDB Atlas / PlanetScale
```

#### 3.1 前端部署

**Flutter 移动端**：
- Android：构建 APK，发布到 Google Play Store
- iOS：构建 IPA，发布到 App Store

**Flutter Web**：
1. 构建 Web 版本
```bash
cd src/frontend
flutter build web
```

2. 更新 `vercel.json`，指向前端 Web
```json
{
  "builds": [
    {
      "src": "src/frontend/build/web",
      "use": "@vercel/static"
    }
  ]
}
```

3. 提交到 Git，Vercel 自动部署

#### 3.2 后端部署

**选项 A：Vercel**（当前配置）
- 优点：快速部署，免费额度好
- 缺点：Serverless 限制，冷启动延迟

**选项 B：Railway**（推荐用于后端）
1. 访问 https://railway.app
2. 连接 GitHub 仓库
3. 选择 `src/backend` 目录
4. 配置环境变量
5. 部署

**优点**：
- ✅ 支持持久化数据库
- ✅ 没有冷启动问题
- ✅ 更好的性能
- ✅ 合理的价格

**选项 C：Render**（推荐用于后端）
1. 访问 https://render.com
2. 连接 GitHub 仓库
3. 选择 Web Service
4. 配置环境变量
5. 部署

---

## 📋 推荐步骤（按优先级）

### 第 1 步：立即修复（5 分钟）

**目标**：让当前 Vercel 部署工作起来

1. **创建 MongoDB Atlas 免费账号**
   - 访问：https://www.mongodb.com/cloud/atlas
   - 创建项目、集群、用户
   - 获取连接字符串

2. **配置 Vercel 环境变量**
   - 使用 Vercel CLI 或 Dashboard
   - 添加 `MONGODB_URI`、`JWT_SECRET`

3. **验证部署**
   - 等待 Vercel 自动重新部署（2-5 分钟）
   - 测试 `/health` 端点

**预期结果**：504 错误解决，API 正常响应

---

### 第 2 步：优化部署（1-2 小时）

**目标**：提升部署稳定性和性能

1. **添加数据库连接池优化**
```typescript
// src/backend/src/config/database.ts
await mongoose.connect(MONGODB_URI, {
  maxPoolSize: 10,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
  minPoolSize: 2, // Serverless 优化
});
```

2. **添加健康检查端点**
```typescript
// src/backend/src/index.ts
app.get('/health', async (req, res) => {
  try {
    // 检查数据库连接
    if (mongoose.connection.readyState === 1) {
      res.json({
        status: 'ok',
        timestamp: new Date().toISOString(),
        database: 'connected',
      });
    } else {
      res.status(503).json({
        status: 'error',
        timestamp: new Date().toISOString(),
        database: 'disconnected',
      });
    }
  } catch (error) {
    res.status(500).json({
      status: 'error',
      timestamp: new Date().toISOString(),
      error: error.message,
    });
  }
});
```

3. **添加 Vercel 特定配置**
```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "src/backend/src/index.ts",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/src/backend/src/index.ts"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  },
  "functions": {
    "src/backend/src/**/*.ts": {
      "maxDuration": 10,
      "memory": 512
    }
  }
}
```

---

### 第 3 步：长期优化（1-3 天）

**目标**：生产级别的部署方案

1. **CI/CD 集成**
   - 配置 GitHub Actions
   - 自动测试和部署
   - 多环境部署（dev、staging、prod）

2. **监控和日志**
   - 集成 Sentry（错误监控）
   - 集成 LogRocket（前端监控）
   - 集成 Datadog（性能监控）

3. **数据库迁移**
   - 评估是否需要迁移到 Serverless 优化的数据库
   - 使用 Prisma 或 TypeORM
   - 优化查询性能

4. **API 文档**
   - 集成 Swagger/OpenAPI
   - 自动生成文档
   - 提供 API Explorer

---

## 🔧 具体改造代码

### 1. 优化数据库连接（src/backend/src/config/database.ts）

```typescript
import mongoose from 'mongoose';
import logger from './logger';

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/naruto_rebirth';

export const connectDatabase = async (): Promise<void> => {
  try {
    await mongoose.connect(MONGODB_URI, {
      maxPoolSize: 10,
      serverSelectionTimeoutMS: 5000,
      socketTimeoutMS: 45000,
      minPoolSize: 2,  // Serverless 优化
      bufferMaxEntries: 0,  // 关闭缓冲，减少内存占用
      connectTimeoutMS: 10000,
    });

    logger.info('MongoDB connected successfully');

    mongoose.connection.on('error', (error) => {
      logger.error('MongoDB connection error:', error);
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn('MongoDB disconnected');
    });

    mongoose.connection.on('reconnected', () => {
      logger.info('MongoDB reconnected');
    });
  } catch (error) {
    logger.error('Failed to connect to MongoDB:', error);
    throw error;
  }
};
```

### 2. 添加详细健康检查（src/backend/src/index.ts）

```typescript
app.get('/health', async (req, res) => {
  const health = {
    status: 'ok' as 'ok' | 'error',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    database: {
      state: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
      name: mongoose.connection.name,
      host: mongoose.connection.host,
    },
    memory: {
      used: process.memoryUsage().heapUsed,
      total: process.memoryUsage().heapTotal,
      rss: process.memoryUsage().rss,
    },
    cpu: process.cpuUsage(),
  };

  if (health.database.state !== 'connected') {
    health.status = 'error';
    return res.status(503).json(health);
  }

  res.json(health);
});
```

### 3. 优化 vercel.json

```json
{
  "name": "naruto-rebirth-game",
  "version": 2,
  "builds": [
    {
      "src": "src/backend/src/index.ts",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/src/backend/src/index.ts"
    },
    {
      "src": "/health",
      "dest": "/src/backend/src/index.ts"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  },
  "functions": {
    "src/backend/src/**/*.ts": {
      "maxDuration": 10,
      "memory": 512,
      "runtime": "nodejs20.x"
    }
  }
}
```

---

## 🎯 总结

### 当前问题
1. ❌ 504 错误 - 函数调用失败
2. ❌ 缺少 MongoDB 环境变量
3. ❌ 数据库连接字符串指向 localhost
4. ❌ 缺少 JWT_SECRET 环境变量

### 推荐方案
1. ✅ **立即**：配置 MongoDB Atlas 环境变量
2. ✅ **短期**：优化数据库连接和健康检查
3. ✅ **长期**：考虑分离部署或使用 Serverless 优化数据库

### 预期结果
- ✅ 504 错误解决
- ✅ API 正常响应
- ✅ 健康检查端点返回正常状态
- ✅ 部署稳定可靠

---

## 📚 参考资源

**Vercel 技能文档**：
- 部署命令：`vercel deploy`
- 环境变量：`vercel env add <name>`
- 查看日志：`vercel logs <url>`
- 回滚部署：`vercel rollback`

**MongoDB Atlas 文档**：
- 免费层：M0 Sandbox
- 连接字符串格式
- 安全最佳实践

**Vercel 文档**：
- Serverless 函数限制
- 环境变量配置
- 部署最佳实践

---

**老板，我已经基于 Vercel 技能完成了详细的诊断和改造方案！**

**下一步你想做什么？**
1. 我帮你创建 MongoDB Atlas 账号并配置环境变量
2. 我帮你实施代码优化（数据库连接、健康检查）
3. 我帮你评估并实施长期优化方案
4. 其他需求
