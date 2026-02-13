# 开发文档

## 项目概述

"重生到火影忍者世界"是一个文字冒险游戏，玩家可以在火影忍者的世界中成长，学习忍术，完成任务。

## 技术栈

### 后端
- Node.js + Express
- MongoDB + Mongoose
- JWT 认证
- bcryptjs 密码加密

### 前端
- Flutter
- Dio 网络请求
- Provider 状态管理
- Hive 本地存储

## 已实现功能

### 1. 商店系统

#### 后端 API (Node.js)

**商品分类**
- `GET /api/shop/categories` - 获取商品分类列表
- `GET /api/shop/items` - 获取商品列表（支持分页和筛选）
- `POST /api/shop/purchase` - 购买商品
- `POST /api/shop/sell` - 出售商品

**物品类型**
- `tool` - 忍具（手里剑、苦无、起爆符等）
- `medicine` - 药品（治疗药、查克拉药、复活药等）
- `equipment` - 装备（忍具袋、防具、武器等）
- `material` - 材料

**稀有度**
- `common` - N 普通
- `uncommon` - R 稀有
- `rare` - SR 史诗
- `epic` - SSR 传说
- `legendary` - UR 神话

#### 前端实现 (Flutter)

**文件结构**
- `lib/data/models/item.dart` - 物品数据模型
- `lib/services/shop_service.dart` - 商店服务（API 调用）
- `lib/screens/shop/shop_screen.dart` - 商店界面

**功能特性**
- 分类浏览商品
- 类型筛选（忍具、药品、装备、材料）
- 稀有度筛选
- 物品详情展示
- 购买功能
- 使用功能
- 装备/卸下装备功能
- 分页加载

### 2. 用户系统

#### 后端 API (Node.js)

**认证接口**
- `POST /api/player/register` - 用户注册
- `POST /api/player/login` - 用户登录
- `POST /api/player/logout` - 用户登出
- `GET /api/player` - 获取玩家信息
- `PUT /api/player/attributes` - 更新玩家属性

**库存管理**
- `GET /api/player/inventory` - 获取玩家库存
- `POST /api/player/inventory/use` - 使用物品
- `POST /api/player/inventory/equip` - 装备物品
- `POST /api/player/inventory/unequip` - 卸下装备

#### 前端实现 (Flutter)

**文件结构**
- `lib/services/auth_service.dart` - 认证服务（含 JWT 拦截器）
- `lib/screens/auth/login_screen.dart` - 登录和注册界面

**功能特性**
- 用户注册（用户名、邮箱、密码）
- 用户登录（邮箱、密码）
- JWT Token 自动管理
- Token 过期自动登出
- 表单验证
- 密码可见性切换

### 3. 数据模型

**后端模型**
- `User.ts` - 用户模型（用户名、邮箱、密码）
- `Player.ts` - 玩家模型（属性、库存、装备等）
- `Item.ts` - 物品模型（名称、类型、稀有度、效果等）

**前端模型**
- `item.dart` - 物品模型和库存模型
- `save.dart` - 存档模型

## 快速开始

### 后端启动

```bash
cd src/backend
npm install
npm run dev
```

### 前端启动

```bash
cd src/frontend
flutter pub get
flutter run
```

### 数据库初始化

首次启动后端时，会自动初始化商店物品数据。

## API 接口说明

### 认证流程

1. 注册
```bash
POST /api/player/register
{
  "username": "naruto",
  "email": "naruto@example.com",
  "password": "password123"
}
```

响应：
```json
{
  "code": 200,
  "message": "注册成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "userId": "user_xxx",
      "username": "naruto",
      "email": "naruto@example.com"
    }
  }
}
```

2. 登录
```bash
POST /api/player/login
{
  "email": "naruto@example.com",
  "password": "password123"
}
```

3. 访问受保护接口（在请求头中添加 Token）
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 商店接口示例

获取商品列表（分页和筛选）
```bash
GET /api/shop/items?page=1&pageSize=20&type=medicine&rarity=common
```

购买商品
```bash
POST /api/shop/purchase
{
  "itemId": "medicine_heal_n",
  "quantity": 5
}
```

## 数据库设计

### Player Schema

```typescript
{
  playerId: string,        // 玩家ID
  userId: string,          // 用户ID（关联User表）
  level: number,           // 等级
  experience: number,      // 经验值
  gold: number,            // 金币
  chakra: number,          // 当前查克拉
  maxChakra: number,       // 最大查克拉
  health: number,          // 当前生命值
  maxHealth: number,       // 最大生命值
  inventory: Array<{       // 库存
    itemId: string,
    quantity: number,
    equipped: boolean
  }>,
  equipment: Map<string, string>,  // 装备 {category: itemId}
  attributes: {            // 属性
    strength: number,
    agility: number,
    intelligence: number,
    chakra: number
  },
  currentChapter: string, // 当前章节
  flags: Map<string, any>, // 游戏标记
  stats: {                // 统计
    totalPlayTime: number,
    missionsCompleted: number,
    enemiesDefeated: number,
    itemsCollected: number
  }
}
```

## 开发注意事项

### 前端
1. 所有网络请求都通过 Dio 拦截器自动添加 JWT Token
2. 使用 json_serializable 生成序列化代码：`flutter pub run build_runner build`
3. 状态管理使用 Provider
4. 本地数据使用 Hive 存储

### 后端
1. 使用 JWT 进行身份认证
2. 密码使用 bcryptjs 加密
3. 使用 mongoose 进行数据库操作
4. 统一的错误处理和响应格式

### 代码规范
- 遵循 ESLint 和 Prettier 配置
- 使用 TypeScript 类型检查
- 前端遵循 Flutter 官方代码规范

## 待完成功能

- [ ] 忍术系统
- [ ] 战斗系统
- [ ] 任务系统
- [ ] 剧情系统
- [ ] 社交系统（好友、公会）
- [ ] 排行榜系统
- [ ] 成就系统

## 测试

### 后端测试
```bash
cd src/backend
npm test
```

### 前端测试
```bash
cd src/frontend
flutter test
```

## 部署

### 后端部署
```bash
cd src/backend
npm run build
npm start
```

### 前端打包
```bash
cd src/frontend
flutter build apk  # Android
flutter build ios  # iOS
```

## 联系方式

技术团队
