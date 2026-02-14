# 火影忍者游戏优化 - 快速参考指南

## 📋 修改概览

| 模块 | 状态 | API 集成 | 备用数据 |
|------|------|----------|----------|
| 🏪 商店 | ✅ 完成 | ✅ 是 | ✅ 有 |
| 💾 存档 | ✅ 完成 | ✅ 是 | ✅ 有 |
| 📖 剧情 | 🔄 框架 | ⏳ 待实现 | ✅ 有 |
| 📋 任务 | 🔄 框架 | ⏳ 待实现 | ✅ 有 |

---

## 🔄 API 端点速查

### 已集成的 API
```
GET    /api/shop/items        - 获取商品列表 ✅
POST   /api/shop/purchase     - 购买商品 ✅
GET    /api/saves             - 获取存档列表 ✅
POST   /api/saves             - 创建存档 ✅
DELETE /api/saves/:saveId     - 删除存档 ✅
```

### 待实现的 API
```
GET  /api/story/:chapterId  - 获取章节详情 ⏳
GET  /api/quests            - 获取任务列表 ⏳
```

---

## 📝 函数对照表

### 商店系统
| 原函数 | 新状态 | 说明 |
|--------|--------|------|
| `loadShop()` | → `async` | 调用 `/api/shop/items` |
| `buyItem()` | → `async` | 调用 `/api/shop/purchase` |
| `displayShopItems()` | 更新 | 支持 API 数据结构 |
| `loadShopFallback()` | 新增 | 备用数据 |

### 存档系统
| 原函数 | 新状态 | 说明 |
|--------|--------|------|
| `loadSaves()` | → `async` | 调用 `/api/saves` |
| `createSave()` | 新增 | 调用 `POST /api/saves` |
| `deleteSave()` | 新增 | 调用 `DELETE /api/saves/:saveId` |
| `loadSave()` | 新增 | 加载存档框架 |
| `displaySaves()` | 更新 | 显示更多信息 |

### 剧情系统
| 原函数 | 新状态 | 说明 |
|--------|--------|------|
| `loadStory()` | → `async` | API 调用框架 |
| `loadStoryFallback()` | 新增 | 备用数据 |

### 任务系统
| 原函数 | 新状态 | 说明 |
|--------|--------|------|
| `loadQuests()` | → `async` | API 调用框架 |
| `loadQuestsFallback()` | 新增 | 备用数据 |

---

## 🔧 代码模式

### 标准 API 调用模式
```javascript
async function loadXXX() {
  try {
    // 1. 调用 API
    const response = await fetch(`${API_BASE_URL}/endpoint`, {
      headers: {
        'Authorization': `Bearer ${gameState.token}`
      }
    });

    // 2. 解析响应
    const result = await response.json();

    // 3. 检查结果
    if (result.success && result.data) {
      // 4. 使用 API 数据
      displayXXX(result.data);
    } else {
      // 5. API 失败，使用备用数据
      console.warn('API failed, using fallback');
      loadXXXFallback();
    }
  } catch (error) {
    // 6. 错误处理
    console.error('Error:', error);
    loadXXXFallback();
  }
}
```

### 备用数据函数模式
```javascript
function loadXXXFallback() {
  // 提供硬编码的备用数据
  const data = [ ... ];
  displayXXX(data);
}
```

---

## 🎯 快速任务清单

### ✅ 已完成
- [x] 商店 API 集成
- [x] 存档 API 集成
- [x] 购买功能实现
- [x] 创建存档功能
- [x] 删除存档功能
- [x] 错误处理机制
- [x] 备用数据机制
- [x] 文档更新

### ⏳ 待完成
- [ ] 加载存档完整恢复
- [ ] 商店出售功能
- [ ] 后端实现剧情 API
- [ ] 后端实现任务 API
- [ ] 数据缓存机制

---

## 🐛 调试技巧

### 查看 API 调用
打开浏览器开发者工具 → Network 标签 → 查看请求

### 查看错误日志
打开浏览器开发者工具 → Console 标签 → 查看日志

### 测试备用数据
断开网络连接或停止后端服务，观察是否使用备用数据

### 验证数据同步
1. 修改数据（购买商品、创建存档）
2. 刷新页面
3. 检查数据是否保持一致

---

## 📞 常见问题

### Q: 为什么剧情和任务还是用硬编码数据？
A: 后端 API 尚未实现，前端框架已就绪。等 API 实现后，只需修改 `loadStory()` 和 `loadQuests()` 函数即可。

### Q: API 失败时会发生什么？
A: 自动切换到备用数据，游戏功能不受影响，用户可以继续使用。

### Q: 如何切换到使用 API？
A: 确保 API 返回正确的数据结构，前端会自动使用 API 数据。

### Q: 如何测试购买功能？
A:
1. 登录游戏
2. 进入商店
3. 选择商品
4. 点击购买
5. 查看货币是否减少

---

## 📚 相关文档

- `OPTIMIZATION_SUMMARY.md` - 详细优化总结
- `TEST_PLAN.md` - 完整测试计划
- `OPTIMIZATION_COMPLETE.md` - 完成报告
- `CHANGELOG.md` - 变更日志

---

## 🚀 快速开始

### 1. 验证修改
```bash
cd /root/.openclaw/workspace/naruto-rebirth-game
# 运行验证脚本（见 TEST_PLAN.md）
```

### 2. 测试功能
- 登录游戏
- 测试商店购买
- 测试存档创建和删除
- 查看剧情和任务（使用备用数据）

### 3. 查看文档
- 阅读 `OPTIMIZATION_COMPLETE.md` 了解详细内容
- 阅读 `TEST_PLAN.md` 了解测试方法

---

**快速参考指南版本：1.0**
**更新日期：2026-02-14**
**用途：帮助开发者快速了解优化内容**
