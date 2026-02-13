# 数据库设计文档

## 数据库概述

- **数据库类型**: MongoDB 7.x
- **连接方式**: Mongoose ODM
- **字符集**: UTF-8

---

## 集合设计

### 1. users (用户表)

存储用户账号信息。

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| _id | ObjectId | MongoDB自动生成 | Primary |
| userId | String | 用户唯一ID | Unique, Index |
| username | String | 用户名 | Unique, Index |
| email | String | 邮箱 | Unique, Index |
| password | String | 密码（bcrypt加密） | - |
| createdAt | Date | 创建时间 | - |
| updatedAt | Date | 更新时间 | - |

**索引**:
```javascript
{ userId: 1 }           // 唯一索引
{ email: 1 }             // 唯一索引
{ username: 1 }          // 唯一索引
```

**示例文档**:
```javascript
{
  _id: ObjectId("..."),
  userId: "user_001",
  username: "naruto",
  email: "naruto@konoha.com",
  password: "$2b$10$...",
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  updatedAt: ISODate("2024-01-01T00:00:00Z")
}
```

---

### 2. saves (存档表)

存储玩家游戏存档数据。

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| _id | ObjectId | MongoDB自动生成 | Primary |
| saveId | String | 存档唯一ID | Unique, Index |
| playerId | String | 玩家ID | Index |
| saveName | String | 存档名称 | - |
| gameTime | String | 游戏内时间 | - |
| playerLevel | Number | 玩家等级 | - |
| attributes | Object | 玩家属性 | - |
| attributes.chakra | Number | 查克拉值 | - |
| attributes.ninjutsu | Number | 忍术能力 | - |
| attributes.taijutsu | Number | 体术能力 | - |
| attributes.intelligence | Number | 智力值 | - |
| currentChapter | String | 当前章节ID | - |
| inventory | Array | 物品栏 | - |
| quests | Array | 任务列表 | - |
| achievements | Array | 成就列表 | - |
| playTime | Number | 游戏时长（秒） | - |
| isCloud | Boolean | 是否云端存档 | Index |
| createdAt | Date | 创建时间 | - |
| updatedAt | Date | 更新时间 | Index |

**索引**:
```javascript
{ saveId: 1 }                      // 唯一索引
{ playerId: 1 }                    // 索引，用于查询玩家的所有存档
{ playerId: 1, updatedAt: -1 }     // 复合索引，按更新时间排序
{ isCloud: 1 }                     // 索引，用于筛选云端存档
```

**示例文档**:
```javascript
{
  _id: ObjectId("..."),
  saveId: "save_001",
  playerId: "user_001",
  saveName: "木叶新人",
  gameTime: "火影纪元1年",
  playerLevel: 10,
  attributes: {
    chakra: 200,
    ninjutsu: 150,
    taijutsu: 120,
    intelligence: 180
  },
  currentChapter: "chapter_05",
  inventory: [
    { itemId: "item_001", quantity: 10 }
  ],
  quests: [
    { questId: "quest_001", status: "completed" }
  ],
  achievements: [],
  playTime: 36000,
  isCloud: true,
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  updatedAt: ISODate("2024-01-02T00:00:00Z")
}
```

---

### 3. story_nodes (剧情节点表)

存储游戏剧情节点数据。

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| _id | ObjectId | MongoDB自动生成 | Primary |
| nodeId | String | 节点唯一ID | Unique, Index |
| chapterId | String | 所属章节ID | Index |
| type | String | 节点类型 | - |
| content | String | 剧情内容 | - |
| speaker | String | 说话者（可选） | - |
| choices | Array | 分支选项 | - |
| choices[].id | String | 选项ID | - |
| choices[].text | String | 选项文本 | - |
| choices[].nextNode | String | 下一节点ID | - |
| choices[].requirements | Object | 选项要求 | - |
| backgroundMusic | String | 背景音乐 | - |
| soundEffect | String | 音效 | - |
| requirements | Object | 节点进入要求 | - |
| createdAt | Date | 创建时间 | - |

**节点类型枚举**:
- `dialogue`: 对话节点
- `choice`: 选择节点
- `event`: 事件节点

**索引**:
```javascript
{ nodeId: 1 }                     // 唯一索引
{ chapterId: 1 }                  // 索引，查询章节的所有节点
{ chapterId: 1, nodeId: 1 }       // 复合索引
```

**示例文档**:
```javascript
{
  _id: ObjectId("..."),
  nodeId: "node_01_01",
  chapterId: "chapter_01",
  type: "dialogue",
  content: "你好，我是火影忍者世界的新人！",
  speaker: "主角",
  choices: [
    {
      id: "choice_1",
      text: "前往忍者学校",
      nextNode: "node_01_02",
      requirements: {
        attributes: {
          intelligence: { min: 10 }
        }
      }
    }
  ],
  backgroundMusic: "bgm_konoha_village.mp3",
  soundEffect: null,
  createdAt: ISODate("2024-01-01T00:00:00Z")
}
```

---

### 4. quests (任务表)

存储游戏任务数据。

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| _id | ObjectId | MongoDB自动生成 | Primary |
| questId | String | 任务唯一ID | Unique, Index |
| name | String | 任务名称 | - |
| description | String | 任务描述 | - |
| type | String | 任务类型 | Index |
| objectives | Array | 任务目标 | - |
| objectives[].id | String | 目标ID | - |
| objectives[].description | String | 目标描述 | - |
| objectives[].target | String | 目标对象 | - |
| objectives[].current | Number | 当前进度 | - |
| objectives[].required | Number | 目标要求 | - |
| objectives[].completed | Boolean | 是否完成 | - |
| rewards | Object | 任务奖励 | - |
| rewards.experience | Number | 经验奖励 | - |
| rewards.currency | Number | 货币奖励 | - |
| rewards.items | Array | 物品奖励 | - |
| rewards.attributes | Object | 属性奖励 | - |
| prerequisites | Object | 前置条件 | - |
| isRepeatable | Boolean | 是否可重复 | - |
| cooldownHours | Number | 冷却时间（小时） | - |
| createdAt | Date | 创建时间 | - |
| updatedAt | Date | 更新时间 | - |

**任务类型枚举**:
- `main`: 主线任务
- `side`: 支线任务
- `daily`: 日常任务

**索引**:
```javascript
{ questId: 1 }        // 唯一索引
{ type: 1 }          // 索引，按类型查询
```

**示例文档**:
```javascript
{
  _id: ObjectId("..."),
  questId: "quest_001",
  name: "初次修炼",
  description: "完成第一次查克拉修炼",
  type: "main",
  objectives: [
    {
      id: "obj_1",
      description: "修炼查克拉",
      target: "chakra",
      current: 0,
      required: 100,
      completed: false
    }
  ],
  rewards: {
    experience: 1000,
    currency: 500,
    attributes: {
      chakra: 10
    }
  },
  prerequisites: {
    level: { min: 1 }
  },
  isRepeatable: false,
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  updatedAt: ISODate("2024-01-01T00:00:00Z")
}
```

---

### 5. items (物品表)

存储游戏物品数据。

| 字段名 | 类型 | 说明 | 索引 |
|--------|------|------|------|
| _id | ObjectId | MongoDB自动生成 | Primary |
| itemId | String | 物品唯一ID | Unique, Index |
| name | String | 物品名称 | - |
| description | String | 物品描述 | - |
| type | String | 物品类型 | Index |
| category | String | 物品分类 | Index |
| rarity | String | 稀有度 | Index |
| effect | Object | 物品效果 | - |
| effect.type | String | 效果类型 | - |
| effect.target | String | 效果目标 | - |
| effect.value | Number | 效果值 | - |
| price | Number | 购买价格 | - |
| sellPrice | Number | 出售价格 | - |
| maxStack | Number | 最大堆叠数 | - |
| icon | String | 图标路径 | - |
| createdAt | Date | 创建时间 | - |
| updatedAt | Date | 更新时间 | - |

**物品类型枚举**:
- `tool`: 忍具
- `medicine`: 药品
- `equipment`: 装备
- `material`: 材料

**稀有度枚举**:
- `common`: 普通（白色）
- `uncommon`: 优秀（绿色）
- `rare`: 稀有（蓝色）
- `epic`: 史诗（紫色）
- `legendary`: 传说（橙色）

**效果类型枚举**:
- `attribute`: 增加属性
- `recover`: 恢复属性
- `special`: 特殊效果

**索引**:
```javascript
{ itemId: 1 }                       // 唯一索引
{ type: 1 }                         // 索引，按类型查询
{ category: 1 }                     // 索引，按分类查询
{ type: 1, category: 1 }            // 复合索引
{ rarity: 1 }                       // 索引，按稀有度查询
```

**示例文档**:
```javascript
{
  _id: ObjectId("..."),
  itemId: "item_001",
  name: "苦无",
  description: "基本的忍者投掷武器",
  type: "tool",
  category: "weapons",
  rarity: "common",
  effect: {
    type: "attribute",
    target: "taijutsu",
    value: 5
  },
  price: 100,
  sellPrice: 50,
  maxStack: 99,
  icon: "assets/icons/kunai.png",
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  updatedAt: ISODate("2024-01-01T00:00:00Z")
}
```

---

## 数据库关系图

```
users (1) ----< (n) saves
                    |
                    v
              (游戏数据关联)

saves (n) ----< (m) quests
                   (任务进度)

story_nodes (m) ----< (n) choices
                          |
                          v
                    (剧情分支)

items (n) ----< (m) saves.inventory
                 (物品栏)
```

---

## 性能优化建议

### 1. 索引策略
- 为所有查询字段创建索引
- 为频繁的复合查询创建复合索引
- 定期监控索引使用情况

### 2. 查询优化
- 使用`limit()`限制返回数量
- 避免使用`skip()`进行大数据分页
- 使用投影只返回需要的字段

### 3. 写入优化
- 使用批量写入操作
- 合理使用`updateOne`和`updateMany`
- 避免频繁的创建和删除文档

### 4. 数据分片（当数据量大时）
- 按playerId分片（存档数据）
- 按chapterId分片（剧情数据）

---

## 数据备份策略

### 备份频率
- 每日全量备份
- 每小时增量备份

### 备份保留
- 保留最近7天的每日备份
- 保留最近30天的每周备份
- 保留最近的每月备份

### 灾难恢复
- RTO（恢复时间目标）: 1小时
- RPO（恢复点目标）: 1小时

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
**维护者**: 技术团队
