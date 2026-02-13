# 项目结构文档

## 目录结构总览

```
naruto-rebirth-game/
├── assets/                      # 资源文件
│   ├── ui/                      # UI资源（待UI设计提供）
│   ├── sounds/                  # 音效和音乐
│   └── images/                  # 图片资源
│
├── docs/                        # 项目文档
│   ├── tech/                    # 技术文档
│   │   ├── TECH_ARCHITECTURE.md # 技术架构文档
│   │   ├── PROJECT_STRUCTURE.md # 项目结构文档（本文件）
│   │   ├── API.md               # API接口文档（待创建）
│   │   ├── DATABASE.md          # 数据库设计文档（待创建）
│   │   ├── FRONTEND_GUIDE.md    # 前端开发指南（待创建）
│   │   └── BACKEND_GUIDE.md     # 后端开发指南（待创建）
│   ├── writing/                 # 文案策划文档
│   ├── design/                  # UI设计文档
│   └── product/                 # 产品需求文档
│
└── src/                         # 源代码
    ├── frontend/                # 前端项目（Flutter）
    │   ├── lib/                # Dart源码
    │   │   ├── main.dart      # 应用入口
    │   │   ├── app.dart       # App根组件
    │   │   ├── config/        # 配置文件
    │   │   ├── core/          # 核心模块
    │   │   │   ├── constants/ # 常量定义
    │   │   │   ├── utils/     # 工具类
    │   │   │   └── network/   # 网络模块
    │   │   ├── data/          # 数据层
    │   │   │   ├── models/    # 数据模型
    │   │   │   ├── repositories/ # 数据仓库
    │   │   │   └── datasources/ # 数据源
    │   │   ├── domain/        # 领域层
    │   │   │   ├── entities/  # 实体
    │   │   │   └── usecases/  # 用例
    │   │   ├── providers/     # 状态管理
    │   │   ├── screens/       # 页面
    │   │   ├── widgets/       # 组件
    │   │   ├── services/      # 服务
    │   │   └── routes/        # 路由
    │   ├── test/              # 测试文件
    │   ├── pubspec.yaml      # Flutter依赖配置
    │   └── README.md         # 前端文档
    │
    └── backend/              # 后端项目（Node.js + Express）
        ├── src/              # TypeScript源码
        │   ├── index.ts     # 应用入口
        │   ├── app.ts       # Express应用配置
        │   ├── config/      # 配置文件
        │   │   ├── database.ts  # 数据库配置
        │   │   ├── jwt.ts       # JWT配置
        │   │   └── logger.ts    # 日志配置
        │   ├── middleware/  # 中间件
        │   │   ├── auth.ts      # 认证中间件
        │   │   ├── error.ts     # 错误处理
        │   │   └── rateLimit.ts # 限流
        │   ├── routes/      # 路由
        │   │   ├── index.ts     # 路由汇总
        │   │   ├── saves.ts     # 存档路由
        │   │   ├── story.ts     # 剧情路由
        │   │   ├── player.ts    # 玩家路由
        │   │   ├── quests.ts    # 任务路由
        │   │   └── shop.ts      # 商店路由
        │   ├── controllers/ # 控制器（待实现）
        │   ├── services/    # 业务逻辑（待实现）
        │   ├── models/      # 数据模型
        │   │   ├── User.ts
        │   │   ├── Save.ts
        │   │   ├── StoryNode.ts
        │   │   ├── Quest.ts
        │   │   └── Item.ts
        │   ├── validators/  # 数据验证（待实现）
        │   ├── utils/       # 工具函数
        │   │   └── responseHandler.ts
        │   └── types/       # TypeScript类型（待实现）
        ├── dist/            # 编译输出
        ├── logs/            # 日志文件
        ├── package.json     # Node.js依赖配置
        ├── tsconfig.json    # TypeScript配置
        ├── .env.example     # 环境变量模板
        └── README.md        # 后端文档
```

## 模块说明

### 前端模块（Flutter）

#### 1. config/ - 配置模块
- `api_config.dart`: API端点和请求配置
- `app_config.dart`: 应用配置（游戏规则、常量等）

#### 2. core/ - 核心模块
- `constants/`: 应用常量定义
- `utils/`: 通用工具类（日志、验证等）
- `network/`: 网络请求封装（API客户端、拦截器）

#### 3. data/ - 数据层
- `models/`: JSON序列化模型
- `repositories/`: 数据仓库（Clean Architecture）
- `datasources/`: 本地和远程数据源

#### 4. domain/ - 领域层
- `entities/`: 业务实体
- `usecases/`: 业务用例

#### 5. providers/ - 状态管理
- 使用Provider/Riverpod管理应用状态
- 包含游戏、玩家、存档、剧情等状态

#### 6. screens/ - 页面
- Splash Screen
- Home Screen
- Game Screens（剧情、菜单、商店等）
- Save Screens（存档列表、详情）
- Settings Screen

#### 7. widgets/ - 组件
- `common/`: 通用组件（按钮、对话框等）
- `game/`: 游戏相关组件（属性条、剧情卡片等）
- `ui/`: UI组件（导航栏等）

#### 8. services/ - 服务
- `storage_service.dart`: 本地存储
- `audio_service.dart`: 音频播放
- `hive_service.dart`: Hive数据库服务

### 后端模块（Node.js + Express）

#### 1. config/ - 配置模块
- `database.ts`: MongoDB连接配置
- `jwt.ts`: JWT认证配置
- `logger.ts`: Winston日志配置

#### 2. middleware/ - 中间件
- `auth.ts`: JWT认证中间件
- `error.ts`: 统一错误处理
- `rateLimit.ts`: API限流

#### 3. routes/ - 路由层
- RESTful API路由定义
- 包含存档、剧情、玩家、任务、商店等模块

#### 4. models/ - 数据模型
- Mongoose Schema定义
- User, Save, StoryNode, Quest, Item等模型

#### 5. utils/ - 工具函数
- `responseHandler.ts`: 统一响应格式

## 待实现部分

### 前端
- [ ] 完善所有Screen页面
- [ ] 实现完整的Repository层
- [ ] 添加本地和远程数据源
- [ ] 实现音频服务
- [ ] 添加测试用例

### 后端
- [ ] 实现所有Controller
- [ ] 实现所有Service业务逻辑
- [ ] 添加数据验证中间件
- [ ] 实现用户注册登录
- [ ] 添加完整的CRUD操作
- [ ] 添加单元测试和集成测试

### 文档
- [ ] API接口文档（Swagger）
- [ ] 数据库设计详细文档
- [ ] 前端开发指南
- [ ] 后端开发指南

## 开发流程

### 前端开发
1. 创建数据模型（data/models/）
2. 实现数据源（data/datasources/）
3. 实现仓库（data/repositories/）
4. 创建Provider（providers/）
5. 实现页面（screens/）
6. 添加组件（widgets/）

### 后端开发
1. 定义数据模型（models/）
2. 实现路由（routes/）
3. 创建控制器（controllers/）
4. 实现业务逻辑（services/）
5. 添加验证（validators/）
6. 编写测试

## 命名规范

### Flutter (Dart)
- 文件名: `snake_case.dart`
- 类名: `PascalCase`
- 变量名: `camelCase`
- 常量名: `lowerCamelCase` 或 `UPPER_SNAKE_CASE`
- 私有成员: `_camelCase`

### Node.js (TypeScript)
- 文件名: `PascalCase.ts` 或 `camelCase.ts`
- 类名: `PascalCase`
- 变量名: `camelCase`
- 常量名: `UPPER_SNAKE_CASE`
- 接口名: `PascalCase`（带`I`前缀，如`IUser`）

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
**维护者**: 技术团队
