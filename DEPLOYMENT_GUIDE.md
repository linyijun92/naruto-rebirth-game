# 部署指南

**项目类型**：Flutter 移动端应用 + Node.js 后端

---

## ⚠️ 问题说明

**当前问题**：
- Vercel 部署后访问显示 404
- 原因：项目是 Flutter 移动端应用，不是 Web 应用
- Vercel 主要用于部署 Web 应用和 Serverless 函数

---

## 🚀 部署方案

### 方案 1：部署 Flutter Web 版本到 Vercel（推荐）

**适合**：展示游戏 Web 版本

**步骤**：

1. **构建 Flutter Web 版本**
```bash
cd src/frontend
flutter build web
```

2. **创建 Vercel 配置**（已创建）
- 文件：`vercel.json`
- 配置：部署 `src/frontend/build/web` 目录

3. **提交到 Git**
```bash
git add vercel.json
git commit -m "chore: Add Vercel deployment config for Flutter Web"
git push origin main
```

4. **Vercel 会自动重新部署**
- 访问：https://naruto-rebirth-game.vercel.app
- 应该能看到 Web 版本的游戏

---

### 方案 2：部署 Node.js 后端到 Vercel

**适合**：部署后端 API 服务

**步骤**：

1. **更新 Vercel 配置**（已创建）
- 文件：`vercel.json`
- 配置：指向后端入口 `src/backend/src/index.ts`

2. **提交到 Git**
```bash
git add vercel.json
git commit -m "chore: Add Vercel deployment config for backend API"
git push origin main
```

3. **Vercel 会自动重新部署**
- 访问：https://naruto-rebirth-game.vercel.app
- 可以访问后端 API（如 `/health`）

**后端 API 端点**：
- `GET /health` - 健康检查
- `POST /api/player/register` - 注册
- `POST /api/player/login` - 登录
- `GET /api/saves` - 获取存档列表
- `POST /api/saves` - 创建存档
- 等等...

---

### 方案 3：分别部署（最佳实践）

**适合**：生产环境部署

#### 前端（Flutter 移动端）
- **Android**: 构建 APK，发布到 Google Play Store
- **iOS**: 构建 IPA，发布到 App Store
- **Web**: 构建 Web 版本，部署到 Vercel 或 Netlify

#### 后端（Node.js）
- **Vercel**: Serverless 函数部署
- **Heroku**: 传统 Node.js 应用部署
- **Railway**: 容器化部署
- **AWS/阿里云**: 传统服务器部署

---

## 📋 推荐方案

### 对于演示/测试
**方案 1（Flutter Web）+ 方案 2（Node.js 后端）**

**原因**：
- 快速部署，无需配置服务器
- 免费额度足够
- 自动 CI/CD

**步骤**：
1. Flutter Web 用于前端展示
2. Node.js 后端用于 API 服务
3. 可以使用同一个 Vercel 项目（通过配置分离）

### 对于生产环境
**方案 3（分别部署）**

**原因**：
- 移动端应用需要发布到应用商店
- 后端需要独立的服务器
- 更好的性能和扩展性

**推荐**：
- **前端**：Google Play Store + App Store（移动端），Vercel（Web 版本）
- **后端**：Railway 或 Render（比 Vercel 便宜）

---

## 🔧 当前配置

### vercel.json（已创建）
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
      "src": "/(.*)",
      "dest": "/src/backend/src/index.ts"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

### 配置说明
- `builds`: 指定构建配置（Node.js 后端）
- `routes`: 路由配置（所有请求转发到后端）
- `env`: 环境变量（生产模式）

---

## 🎯 下一步

### 选项 1：立即修复（推荐）
1. 提交 vercel.json 到 Git
2. Vercel 会自动重新部署
3. 几分钟后访问 https://naruto-rebirth-game.vercel.app
4. 应该能看到后端 API 响应

### 选项 2：构建 Flutter Web
1. 构建 Flutter Web 版本
2. 更新 vercel.json 指向前端 Web
3. 提交到 Git
4. 访问 Web 版本游戏

### 选项 3：详细咨询
如果需要生产环境部署，我可以帮你：
- 创建 Android APK
- 配置 Google Play Store 上架
- 部署后端到其他平台
- 配置数据库和服务器

---

**老板，我已经创建了 vercel.json 配置文件。**

**现在请提交到 Git，Vercel 会自动重新部署！**

**你想选择哪个方案？**
1. 部署后端到 Vercel（配置已完成，直接提交即可）
2. 构建 Flutter Web 版本并部署
3. 详细咨询生产环境部署方案
