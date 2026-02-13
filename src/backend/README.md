# 后端项目 - Node.js + Express

## 项目结构

```
src/
├── index.ts                     # 应用入口
├── app.ts                       # Express应用配置
├── config/
│   ├── database.ts              # 数据库配置
│   ├── jwt.ts                   # JWT配置
│   └── logger.ts                # 日志配置
├── middleware/
│   ├── auth.ts                  # 认证中间件
│   ├── error.ts                 # 错误处理中间件
│   ├── validation.ts            # 请求验证中间件
│   └── rateLimit.ts             # 限流中间件
├── routes/
│   ├── index.ts                 # 路由汇总
│   ├── saves.ts                 # 存档路由
│   ├── story.ts                 # 剧情路由
│   ├── player.ts                # 玩家路由
│   ├── quests.ts                # 任务路由
│   └── shop.ts                  # 商店路由
├── controllers/
│   ├── saveController.ts
│   ├── storyController.ts
│   ├── playerController.ts
│   ├── questController.ts
│   └── shopController.ts
├── services/
│   ├── saveService.ts
│   ├── storyService.ts
│   ├── playerService.ts
│   ├── questService.ts
│   └── shopService.ts
├── models/
│   ├── User.ts
│   ├── Save.ts
│   ├── StoryNode.ts
│   ├── Quest.ts
│   └── Item.ts
├── validators/
│   ├── saveValidator.ts
│   ├── playerValidator.ts
│   └── authValidator.ts
├── utils/
│   ├── responseHandler.ts      # 响应处理
│   ├── errorHandler.ts          # 错误处理
│   └── helpers.ts               # 工具函数
└── types/
    └── index.ts                 # TypeScript类型定义

dist/                            # 编译输出目录
```

## 开发指南

### 环境要求
- Node.js: 20.x LTS
- MongoDB: 7.x
- TypeScript: 5.x

### 安装依赖
```bash
npm install
```

### 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件，配置你的环境变量
```

### 开发模式运行
```bash
npm run dev
```

### 生产模式运行
```bash
npm run build
npm start
```

### 运行测试
```bash
npm test
```

### 代码检查
```bash
npm run lint
npm run lint:fix
```

## 核心功能模块

### 1. 存档管理
- 创建存档
- 查询存档列表
- 更新存档
- 删除存档
- 云端同步

### 2. 剧情系统
- 章节管理
- 剧情节点获取
- 分支选择处理

### 3. 玩家系统
- 玩家属性管理
- 经验与等级系统
- 货币系统

### 4. 任务系统
- 任务列表
- 任务接受
- 任务进度更新
- 任务奖励

### 5. 商店系统
- 商品列表
- 购买逻辑
- 库存管理

## API文档

待使用Swagger/OpenAPI生成API文档。

## 安全措施

- JWT认证
- 请求频率限制
- 数据验证
- SQL/NoSQL注入防护
- CORS配置
- Helmet安全头

## 技术栈

- **运行时**: Node.js 20.x
- **框架**: Express.js 4.x
- **语言**: TypeScript 5.x
- **数据库**: MongoDB 7.x
- **ORM**: Mongoose
- **认证**: JWT
- **日志**: Winston
- **验证**: express-validator
