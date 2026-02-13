# API接口文档

## 基础信息

- **Base URL**: `http://localhost:3000/api`
- **认证方式**: JWT Bearer Token
- **响应格式**: JSON

## 通用响应格式

### 成功响应
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

### 错误响应
```json
{
  "code": 400,
  "message": "错误描述",
  "error": { ... }
}
```

## 状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 429 | 请求过于频繁 |
| 500 | 服务器错误 |

---

## API端点

### 1. 健康检查

#### GET /health
检查服务器状态

**响应**:
```json
{
  "status": "ok",
  "message": "Server is running",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

---

### 2. 存档系统 (Saves)

所有存档接口都需要认证 (`Authorization: Bearer <token>`)

#### POST /saves
创建新存档

**请求头**:
```
Authorization: Bearer <token>
```

**请求体**:
```json
{
  "saveName": "存档名称",
  "gameData": {
    "playerLevel": 1,
    "attributes": {
      "chakra": 100,
      "ninjutsu": 50,
      "taijutsu": 50,
      "intelligence": 50
    },
    "currentChapter": "chapter_01_01"
  }
}
```

**响应**:
```json
{
  "code": 201,
  "message": "存档创建成功",
  "data": {
    "saveId": "uuid",
    "saveName": "存档名称",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### GET /saves
获取存档列表

**查询参数**:
- `page`: 页码（默认1）
- `pageSize`: 每页数量（默认10）

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "data": [...],
    "pagination": {
      "total": 10,
      "page": 1,
      "pageSize": 10,
      "totalPages": 1
    }
  }
}
```

#### GET /saves/:saveId
获取存档详情

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "saveId": "uuid",
    "saveName": "存档名称",
    "gameData": { ... },
    "playTime": 3600,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T01:00:00Z"
  }
}
```

#### PUT /saves/:saveId
更新存档

**请求体**: 同创建存档

**响应**: 同创建存档

#### DELETE /saves/:saveId
删除存档

**响应**:
```json
{
  "code": 200,
  "message": "存档删除成功"
}
```

#### POST /saves/:saveId/sync
同步存档到云端

**响应**:
```json
{
  "code": 200,
  "message": "存档同步成功"
}
```

---

### 3. 剧情系统 (Story)

#### GET /story/chapters
获取章节列表

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "chapterId": "chapter_01",
      "title": "第一章：木叶村的新人",
      "description": "...",
      "isUnlocked": true
    }
  ]
}
```

#### GET /story/:chapterId
获取章节详情

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "chapterId": "chapter_01",
    "title": "第一章",
    "description": "...",
    "startNodeId": "node_01_01",
    "totalNodes": 50
  }
}
```

#### GET /story/nodes/:nodeId
获取剧情节点

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "nodeId": "node_01_01",
    "chapterId": "chapter_01",
    "type": "dialogue",
    "content": "剧情文本内容",
    "speaker": "角色名",
    "choices": [
      {
        "id": "choice_1",
        "text": "选项文本",
        "nextNode": "node_01_02",
        "requirements": { ... }
      }
    ],
    "backgroundMusic": "bgm_01.mp3",
    "soundEffect": "sfx_01.mp3"
  }
}
```

#### POST /story/nodes/:nodeId/choice
提交剧情选择

**请求头**: 需要 `Authorization: Bearer <token>`

**请求体**:
```json
{
  "choiceId": "choice_1"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "nextNodeId": "node_01_02",
    "rewards": { ... }
  }
}
```

---

### 4. 玩家系统 (Player)

#### GET /player
获取玩家信息

**请求头**: 需要 `Authorization: Bearer <token>`

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "userId": "uuid",
    "username": "玩家名",
    "level": 10,
    "experience": 5000,
    "currency": 10000,
    "attributes": {
      "chakra": 200,
      "ninjutsu": 150,
      "taijutsu": 120,
      "intelligence": 180
    },
    "currentChapter": "chapter_05",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### PUT /player/attributes
更新玩家属性

**请求头**: 需要 `Authorization: Bearer <token>`

**请求体**:
```json
{
  "chakra": 10,
  "ninjutsu": 5
}
```

**响应**:
```json
{
  "code": 200,
  "message": "属性更新成功",
  "data": {
    "attributes": { ... }
  }
}
```

---

### 5. 任务系统 (Quests)

所有任务接口都需要认证

#### GET /quests
获取任务列表

**查询参数**:
- `type`: 任务类型（main/side/daily）
- `status`: 任务状态（active/completed）

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "questId": "quest_001",
      "name": "任务名称",
      "description": "任务描述",
      "type": "main",
      "status": "active",
      "objectives": [
        {
          "id": "obj_1",
          "description": "目标描述",
          "current": 3,
          "required": 5,
          "completed": false
        }
      ],
      "rewards": {
        "experience": 1000,
        "currency": 500
      }
    }
  ]
}
```

#### GET /quests/:questId
获取任务详情

**响应**: 同任务列表中的单个任务

#### POST /quests/:questId/accept
接受任务

**响应**:
```json
{
  "code": 200,
  "message": "任务已接受"
}
```

#### POST /quests/:questId/progress
更新任务进度

**请求体**:
```json
{
  "objectiveId": "obj_1",
  "progress": 1
}
```

**响应**:
```json
{
  "code": 200,
  "message": "进度已更新",
  "data": {
    "questId": "quest_001",
    "isCompleted": false
  }
}
```

#### POST /quests/:questId/claim
领取任务奖励

**响应**:
```json
{
  "code": 200,
  "message": "奖励已领取",
  "data": {
    "rewards": { ... },
    "newExperience": 6000,
    "newCurrency": 10500
  }
}
```

---

### 6. 商店系统 (Shop)

所有商店接口都需要认证

#### GET /shop/categories
获取商品分类

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "categoryId": "tools",
      "name": "忍具",
      "description": "忍者工具"
    },
    {
      "categoryId": "medicine",
      "name": "药品",
      "description": "恢复类道具"
    }
  ]
}
```

#### GET /shop/items
获取商品列表

**查询参数**:
- `category`: 商品分类
- `rarity`: 稀有度
- `page`: 页码

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "data": [
      {
        "itemId": "item_001",
        "name": "苦无",
        "description": "基本的忍者武器",
        "type": "tool",
        "category": "tools",
        "rarity": "common",
        "price": 100,
        "maxStack": 99
      }
    ],
    "pagination": { ... }
  }
}
```

#### POST /shop/purchase
购买商品

**请求体**:
```json
{
  "itemId": "item_001",
  "quantity": 10
}
```

**响应**:
```json
{
  "code": 200,
  "message": "购买成功",
  "data": {
    "newCurrency": 9000,
    "item": { ... }
  }
}
```

---

## 错误码

| 错误码 | 说明 |
|--------|------|
| 400 | 请求参数错误 |
| 401 | 未授权，token无效或过期 |
| 403 | 禁止访问，权限不足 |
| 404 | 资源不存在 |
| 409 | 资源冲突（如存档名称重复） |
| 429 | 请求过于频繁 |
| 500 | 服务器内部错误 |

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
