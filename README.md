# 重生到火影忍者世界

一款文字冒险游戏，带你体验火影忍者的世界。

## 项目简介

《重生到火影忍者世界》是一款跨平台的文字冒险游戏，玩家将在火影忍者的世界中展开冒险，通过选择不同的剧情分支，体验不同的结局。

## 技术栈

### 前端
- **框架**: Flutter 3.x
- **语言**: Dart 3.x
- **状态管理**: Provider/Riverpod
- **本地存储**: Hive
- **网络请求**: Dio

### 后端
- **运行时**: Node.js 20.x
- **框架**: Express.js 4.x
- **语言**: TypeScript 5.x
- **数据库**: MongoDB 7.x
- **ORM**: Mongoose

## 快速开始

### 前置要求
- Flutter SDK 3.x
- Node.js 20.x
- MongoDB 7.x

### 安装依赖

#### 前端
```bash
cd src/frontend
flutter pub get
```

#### 后端
```bash
cd src/backend
npm install
```

### 配置环境变量

复制后端环境变量模板并编辑：
```bash
cd src/backend
cp .env.example .env
# 编辑 .env 文件
```

### 运行项目

#### 前端开发
```bash
cd src/frontend
flutter run
```

#### 后端开发
```bash
cd src/backend
npm run dev
```

## 项目结构

```
naruto-rebirth-game/
├── assets/          # 资源文件
├── docs/            # 项目文档
│   ├── tech/        # 技术文档
│   ├── writing/     # 文案策划文档
│   ├── design/      # UI设计文档
│   └── product/     # 产品需求文档
└── src/             # 源代码
    ├── frontend/    # Flutter前端
    └── backend/     # Node.js后端
```

详细的项目结构说明请查看 [docs/tech/PROJECT_STRUCTURE.md](docs/tech/PROJECT_STRUCTURE.md)

## 核心功能

### 已规划
- ✅ 存档系统（本地 + 云端）
- ✅ 剧情展示引擎（支持分支、多结局）
- ✅ 属性系统（查克拉、忍术、体术、智力）
- ✅ 任务系统（主线、支线、日常）
- ✅ 商店系统（忍具、药品、装备）

### 待开发
- ⏳ 用户系统（注册、登录）
- ⏳ 社交系统（好友、排行榜）
- ⏳ 成就系统
- ⏳ 支付系统

## 开发进度

### 前端（Flutter）
- [x] 项目结构搭建
- [x] 基础框架配置
- [x] 核心模型定义
- [ ] 存档系统实现
- [ ] 剧情引擎实现
- [ ] UI页面开发
- [ ] 测试

### 后端（Node.js）
- [x] 项目结构搭建
- [x] 基础框架配置
- [x] 数据模型定义
- [ ] API接口实现
- [ ] 业务逻辑实现
- [ ] 测试

## 文档

- [技术架构文档](docs/tech/TECH_ARCHITECTURE.md)
- [项目结构文档](docs/tech/PROJECT_STRUCTURE.md)
- [前端README](src/frontend/README.md)
- [后端README](src/backend/README.md)

## 团队成员

### 技术团队
- 技术负责人: 全栈开发

### 待补充
- 产品经理: 需求文档
- 文案策划: 结构化剧情数据
- UI设计师: 设计规范

## 贡献指南

欢迎贡献！请遵循以下步骤：

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证。

## 联系方式

如有问题，请通过以下方式联系：
- 项目仓库: [GitHub](https://github.com/yourusername/naruto-rebirth-game)

---

**当前版本**: v1.0.0
**最后更新**: 2026-02-13
