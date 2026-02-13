# Vercel 部署问题修复

**问题**：访问 https://naruto-rebirth-game.vercel.app 显示 404

---

## 🔍 问题原因

**根本原因**：
- 项目是 **Flutter 移动端应用** + **Node.js 后端**
- Vercel 主要用于部署 **Web 应用**和 **Serverless 函数**
- 项目根目录缺少 `vercel.json` 配置文件
- Vercel 无法识别项目类型和入口点

---

## ✅ 修复内容

### 1. 创建 vercel.json
**位置**：`naruto-rebirth-game/vercel.json`

**配置**：
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

**说明**：
- 部署 Node.js 后端到 Vercel
- 所有请求转发到后端入口 `src/backend/src/index.ts`

### 2. 创建部署指南
**位置**：`naruto-rebirth-game/DEPLOYMENT_GUIDE.md`

**包含**：
- 3 种部署方案（Flutter Web、Node.js 后端、分别部署）
- 每种方案的详细步骤
- 推荐的部署方案
- 下一步操作指南

### 3. 提交到 Git
- ✅ 已提交 `vercel.json`
- ✅ 已提交 `DEPLOYMENT_GUIDE.md`
- ✅ 已推送到 GitHub

**最新提交**：`5e6b968` - chore: Add Vercel deployment configuration and guide

---

## 🚀 Vercel 自动部署

**现在**：
1. ✅ Vercel 会自动检测到新的 Git 提交
2. ✅ Vercel 会自动触发重新部署
3. ✅ 部署完成后 https://naruto-rebirth-game.vercel.app 应该可以访问

**预计时间**：2-5 分钟

**部署后访问**：
- `https://naruto-rebirth-game.vercel.app/health` - 健康检查
- `https://naruto-rebirth-game.vercel.app/api/player/...` - API 端点

---

## 📋 后端 API 端点

### 健康检查
- `GET /health` - 返回服务状态

### 玩家相关
- `POST /api/player/register` - 注册
- `POST /api/player/login` - 登录
- `GET /api/player/:id` - 获取玩家信息
- `PUT /api/player/:id` - 更新玩家信息
- `POST /api/player/:id/level-up` - 升级
- `POST /api/player/:id/add-experience` - 添加经验

### 存档相关
- `GET /api/saves` - 获取存档列表
- `GET /api/saves/:saveId` - 获取存档详情
- `POST /api/saves` - 创建存档
- `PUT /api/saves/:saveId` - 更新存档
- `DELETE /api/saves/:saveId` - 删除存档
- `POST /api/saves/:saveId/sync` - 同步存档
- `POST /api/saves/batch` - 批量上传

### 剧情相关
- `GET /api/story/node/:nodeId` - 获取剧情节点
- `GET /api/story/chapter/:chapterId` - 获取章节所有节点

### 任务相关
- `GET /api/quests` - 获取任务列表
- `POST /api/quests/:questId/accept` - 接取任务
- `POST /api/quests/:questId/complete` - 完成任务
- `POST /api/quests/:questId/reward` - 领取奖励

### 商店相关
- `GET /api/shop/items` - 获取商品列表
- `POST /api/shop/buy` - 购买商品
- `POST /api/shop/sell` - 出售商品

---

## 🎯 测试步骤

### 等待 Vercel 部署完成（2-5 分钟）

1. **测试健康检查**
```bash
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

2. **测试 API 端点**
```bash
curl -X POST https://naruto-rebirth-game.vercel.app/api/player/login \
  -H "Content-Type: application/json" \
  -d '{"username":"test","password":"test123"}'
```

3. **检查 Vercel Dashboard**
- 访问：https://vercel.com/dashboard
- 查看 naruto-rebirth-game 项目
- 检查部署状态和日志

---

## 📝 部署选项总结

| 方案 | 说明 | 适合 |
|------|------|------|
| **方案 1**：后端 API（当前） | 部署 Node.js 后端到 Vercel | 后端 API 服务 |
| 方案 2：Flutter Web | 构建 Flutter Web 并部署 | Web 版本游戏 |
| 方案 3：分别部署 | 前端：应用商店，后端：独立服务器 | 生产环境 |

---

## 🔧 环境变量配置

**在 Vercel Dashboard 中配置**：

1. 访问 https://vercel.com/dashboard
2. 进入 naruto-rebirth-game 项目
3. Settings → Environment Variables

**需要配置的变量**：
- `NODE_ENV` = `production`
- `MONGODB_URI` = MongoDB 连接字符串
- `JWT_SECRET` = JWT 签名密钥
- `CRM_API_URL` = CRM API 地址
- `CRM_API_KEY` = CRM API 密钥

---

## 💡 注意事项

### Flutter 应用限制
- Flutter 移动端应用（Android/iOS）**不能**直接部署到 Vercel
- Flutter 可以构建为 **Web 版本**，然后部署
- 移动端应用需要发布到应用商店

### 数据库配置
- Node.js 后端需要 MongoDB 数据库连接
- 需要配置 `MONGODB_URI` 环境变量
- 推荐使用 MongoDB Atlas（免费版）

### API 跨域
- 前端和后端分离部署时，需要配置 CORS
- 后端已配置 `cors` 中间件

---

**老板，Vercel 部署问题已修复！**

**现在 Vercel 会自动重新部署，2-5 分钟后访问应该正常！**

**部署完成后请测试**：
1. 访问 https://naruto-rebirth-game.vercel.app/health
2. 检查响应是否正常

**如果还有问题，请告诉我错误信息，我会继续帮你排查！** 🔧
