# 重生到火影忍者世界 - 技术架构文档

## 项目概述

- **项目名称**: 重生到火影忍者世界
- **项目类型**: 文字冒险游戏
- **目标平台**: iOS, Android, Web
- **技术栈**: Flutter (前端) + Node.js + Express (后端) + MongoDB (数据库)

---

## 1. 系统架构

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────┐
│                        客户端层                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   iOS App    │  │ Android App  │  │   Web App    │    │
│  │   (Flutter)  │  │  (Flutter)   │  │  (Flutter)   │    │
│  └──────────────┘  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────────────────────┘
                           ↓ REST API
┌─────────────────────────────────────────────────────────┐
│                       服务层                              │
│  ┌─────────────────────────────────────────────────┐    │
│  │          API Gateway + Express Server            │    │
│  └─────────────────────────────────────────────────┘    │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐        │
│  │ 存档管理 │ │ 剧情引擎 │ │ 属性系统 │ │ 任务系统 │        │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                   │
│  │ 商店系统 │ │ 用户系统 │ │ 支付系统 │                   │
│  └─────────┘ └─────────┘ └─────────┘                   │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│                       数据层                              │
│  ┌─────────────────────────────────────────────────┐    │
│  │                  MongoDB                         │    │
│  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐   │    │
│  │  │ 用户数据│ │ 存档数据│ │ 剧情数据│ │ 游戏配置│   │    │
│  │  └────────┘ └────────┘ └────────┘ └────────┘   │    │
│  │  ┌────────┐ ┌────────┐ ┌────────┐               │    │
│  │  │ 物品数据│ │ 任务数据│ │ 支付记录│               │    │
│  │  └────────┘ └────────┘ └────────┘               │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### 1.2 技术栈说明

#### 前端技术栈
- **框架**: Flutter 3.x
- **语言**: Dart 3.x
- **状态管理**: Provider/Riverpod
- **本地存储**: Hive (轻量级本地数据库)
- **网络请求**: dio
- **UI组件**: Material Design 3

#### 后端技术栈
- **运行时**: Node.js 20.x LTS
- **框架**: Express.js 4.x
- **ORM**: Mongoose
- **认证**: JWT
- **日志**: Winston
- **API文档**: Swagger/OpenAPI

#### 数据库
- **主数据库**: MongoDB 7.x
- **缓存**: Redis (可选，用于高频访问数据)

---

## 2. 模块设计

### 2.1 核心模块

#### 2.1.1 存档系统 (SaveSystem)
**职责**:
- 本地存档管理（Hive）
- 云端存档同步（MongoDB）
- 存档压缩与加密
- 自动/手动存档

**API接口**:
```
POST   /api/saves/create          - 创建新存档
GET    /api/saves/list            - 获取存档列表
GET    /api/saves/:saveId         - 获取存档详情
PUT    /api/saves/:saveId         - 更新存档
DELETE /api/saves/:saveId         - 删除存档
POST   /api/saves/:saveId/sync    - 同步到云端
```

**数据结构**:
```json
{
  "saveId": "uuid",
  "playerId": "uuid",
  "saveName": "存档名称",
  "gameTime": "游戏内时间戳",
  "playerLevel": 1,
  "attributes": {
    "chakra": 100,
    "ninjutsu": 50,
    "taijutsu": 60,
    "intelligence": 70
  },
  "currentChapter": "chapter_01_01",
  "inventory": [...],
  "quests": [...],
  "achievements": [...],
  "playTime": 3600,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T01:00:00Z"
}
```

#### 2.1.2 剧情展示引擎 (StoryEngine)
**职责**:
- 剧情节点管理
- 分支选择逻辑
- 多结局路由
- 剧情资源加载

**API接口**:
```
GET    /api/story/chapters       - 获取章节列表
GET    /api/story/:chapterId     - 获取章节详情
GET    /api/story/:nodeId        - 获取剧情节点
POST   /api/story/:nodeId/choice - 提交选择
```

**数据结构**:
```json
{
  "nodeId": "node_01_01",
  "chapterId": "chapter_01",
  "type": "dialogue/choice/event",
  "content": "剧情文本",
  "speaker": "角色名称",
  "choices": [
    {
      "id": "choice_1",
      "text": "选项文本",
      "nextNode": "node_01_02",
      "requirements": {...}
    }
  ],
  "backgroundMusic": "bgm_01.mp3",
  "soundEffect": "sfx_01.mp3"
}
```

#### 2.1.3 属性系统 (AttributeSystem)
**职责**:
- 玩家属性计算
- 属性增长逻辑
- 属性检查（剧情条件判断）

**属性定义**:
- **查克拉 (Chakra)**: 能量值，影响忍术施展
- **忍术 (Ninjutsu)**: 忍术能力，影响忍术威力
- **体术 (Taijutsu)**: 身体能力，影响近战伤害
- **智力 (Intelligence)**: 智力值，影响策略选项

**API接口**:
```
GET    /api/attributes/:playerId  - 获取玩家属性
PUT    /api/attributes/:playerId  - 更新属性
```

#### 2.1.4 任务系统 (QuestSystem)
**职责**:
- 任务管理（主线/支线/日常）
- 任务进度追踪
- 任务奖励发放

**API接口**:
```
GET    /api/quests/:playerId      - 获取任务列表
GET    /api/quests/:questId       - 获取任务详情
POST   /api/quests/:questId/accept - 接受任务
POST   /api/quests/:questId/progress - 更新进度
POST   /api/quests/:questId/claim - 领取奖励
```

**任务类型**:
- **主线任务**: 推进剧情，必须完成
- **支线任务**: 可选任务，获得额外奖励
- **日常任务**: 每日刷新，日常收益

#### 2.1.5 商店系统 (ShopSystem)
**职责**:
- 商品管理
- 购买逻辑
- 库存管理
- 货币系统

**API接口**:
```
GET    /api/shop/categories      - 获取商品分类
GET    /api/shop/items            - 获取商品列表
POST   /api/shop/purchase         - 购买商品
```

**商品类型**:
- **忍具**: 忍者工具（苦无、起爆符等）
- **药品**: 恢复道具
- **装备**: 提升属性装备

### 2.2 辅助模块

#### 2.2.1 用户系统 (UserSystem)
- 用户注册/登录
- 用户资料管理
- 账号安全

#### 2.2.2 支付系统 (PaymentSystem)
- 充值接口
- 内购验证（iOS/Android）
- 交易记录

---

## 3. 数据库设计

### 3.1 用户集合 (users)
```javascript
{
  _id: ObjectId,
  userId: String (uuid),
  username: String,
  email: String,
  password: String (hashed),
  createdAt: Date,
  updatedAt: Date
}
```

### 3.2 存档集合 (saves)
```javascript
{
  _id: ObjectId,
  saveId: String (uuid),
  playerId: String (ref: users.userId),
  saveName: String,
  gameData: Object,
  playTime: Number (seconds),
  isCloud: Boolean,
  createdAt: Date,
  updatedAt: Date
}
```

### 3.3 剧情节点集合 (story_nodes)
```javascript
{
  _id: ObjectId,
  nodeId: String,
  chapterId: String,
  type: String,
  content: String,
  choices: Array,
  requirements: Object,
  createdAt: Date
}
```

### 3.4 物品集合 (items)
```javascript
{
  _id: ObjectId,
  itemId: String,
  name: String,
  description: String,
  type: String,
  rarity: String,
  effect: Object,
  price: Number
}
```

### 3.5 任务集合 (quests)
```javascript
{
  _id: ObjectId,
  questId: String,
  name: String,
  description: String,
  type: String (main/side/daily),
  objectives: Array,
  rewards: Object,
  prerequisites: Object
}
```

---

## 4. API设计规范

### 4.1 RESTful规范

- **GET**: 获取资源
- **POST**: 创建资源
- **PUT**: 更新资源（全量）
- **PATCH**: 更新资源（部分）
- **DELETE**: 删除资源

### 4.2 响应格式

**成功响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "错误描述",
  "error": { ... }
}
```

### 4.3 状态码

- **200**: 成功
- **201**: 创建成功
- **400**: 请求参数错误
- **401**: 未授权
- **403**: 禁止访问
- **404**: 资源不存在
- **500**: 服务器错误

---

## 5. 安全设计

### 5.1 认证与授权
- JWT Token 认证
- Token 刷新机制
- 权限分级

### 5.2 数据安全
- 密码加密（bcrypt）
- 敏感数据加密存储
- HTTPS 传输

### 5.3 API安全
- 请求频率限制
- SQL/NoSQL注入防护
- XSS防护

---

## 6. 性能优化

### 6.1 前端优化
- 懒加载剧情资源
- 图片压缩与缓存
- 状态管理优化

### 6.2 后端优化
- 数据库索引优化
- API响应缓存（Redis）
- 异步处理（任务队列）

---

## 7. 部署架构

### 7.1 开发环境
```
Frontend (Flutter) ←→ Backend (Node.js) ←→ MongoDB (Local)
```

### 7.2 生产环境
```
Client App ←→ CDN ←→ Load Balancer ←→ API Servers ←→ MongoDB Cluster
```

### 7.3 CI/CD
- GitHub Actions
- 自动化测试
- 自动部署

---

## 8. 技术债务与风险

### 8.1 已知风险
- MongoDB单点故障（需配置副本集）
- 大量剧情数据的加载优化
- 离线模式下的数据同步冲突

### 8.2 后续优化
- 引入消息队列（RabbitMQ）
- 实现热更新机制
- 添加实时对战功能（如需要）

---

## 9. 开发计划

### Phase 1: 基础架构
- [x] 项目结构搭建
- [ ] Flutter项目初始化
- [ ] Node.js项目初始化
- [ ] 数据库设计实现

### Phase 2: 核心功能
- [ ] 存档系统
- [ ] 剧情引擎
- [ ] 属性系统

### Phase 3: 业务功能
- [ ] 任务系统
- [ ] 商店系统
- [ ] 用户系统

### Phase 4: 优化与上线
- [ ] 性能优化
- [ ] 安全加固
- [ ] 测试与部署

---

## 10. 文档索引

- [API接口文档](./API.md) (待创建)
- [数据库设计文档](./DATABASE.md) (待创建)
- [前端开发指南](./FRONTEND_GUIDE.md) (待创建)
- [后端开发指南](./BACKEND_GUIDE.md) (待创建)

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
**维护者**: 技术团队
