# 剧情引擎和任务系统 - 快速参考

## 快速开始

### 1. 运行代码生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. 在main.dart中注册Provider
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => StoryService()),
    ChangeNotifierProvider(create: (_) => QuestService()),
    ChangeNotifierProvider(create: (_) => PlayerProvider()),
  ],
  child: MyApp(),
)
```

### 3. 加载数据
```dart
// 剧情
context.read<StoryService>().loadStoryFromFile('assets/story.json');

// 任务
context.read<QuestService>().loadQuestFromFile('assets/quests.json');
```

## 常用API

### StoryService

```dart
// 开始章节
await storyService.startChapter('chapter_01', playerProvider);

// 做出选择
await storyService.makeChoice('choice_id', playerProvider);

// 回退
await storyService.goBack();

// 获取可用选项
final choices = storyService.getAvailableChoices(playerProvider);
```

### QuestService

```dart
// 接取任务
await questService.acceptQuest('quest_id', playerProvider);

// 更新进度
await questService.updateProgress(QuestProgressUpdate(...), playerProvider);

// 领取奖励
final rewards = await questService.claimReward('quest_id', playerProvider);

// 放弃任务
await questService.abandonQuest('quest_id');

// 重置日常任务
await questService.resetDailyQuests();
```

### UI导航

```dart
// 打开剧情界面
Navigator.pushNamed(context, '/story');

// 打开任务界面
Navigator.pushNamed(context, '/quest');
```

## 数据结构速查

### 剧情节点
```json
{
  "nodeId": "node_01",
  "chapterId": "chapter_01",
  "type": "dialogue",
  "content": "剧情内容",
  "speaker": "说话人",
  "choices": [
    {
      "id": "choice_01",
      "text": "选项文本",
      "nextNode": "node_02",
      "requirements": {
        "level": 5
      }
    }
  ]
}
```

### 任务
```json
{
  "questId": "quest_01",
  "title": "任务标题",
  "description": "任务描述",
  "type": "main",
  "status": "available",
  "objectives": [
    {
      "id": "obj_01",
      "description": "击杀3个敌人",
      "type": "kill",
      "target": 3,
      "current": 0
    }
  ],
  "rewards": [
    {
      "name": "银两",
      "type": "currency",
      "amount": 100
    }
  ],
  "levelRequirement": 1,
  "prerequisiteQuests": []
}
```

## 枚举类型

### QuestType（任务类型）
- `main` - 主线
- `side` - 支线
- `daily` - 日常

### QuestStatus（任务状态）
- `locked` - 未解锁
- `available` - 可接取
- `active` - 进行中
- `completed` - 已完成
- `claimed` - 已领取
- `failed` - 失败

### ObjectiveType（目标类型）
- `kill` - 击杀
- `collect` - 收集
- `talk` - 对话
- `reachLevel` - 达到等级
- `completeStory` - 完成剧情
- `train` - 训练

### RewardType（奖励类型）
- `currency` - 货币
- `experience` - 经验
- `item` - 物品
- `attribute` - 属性
- `skill` - 技能

## 条件系统

### 支持的条件
```dart
{
  "level": 5,              // 等级
  "chakra": 100,          // 查克拉
  "ninjutsu": 50,         // 忍术
  "taijutsu": 50,         // 体术
  "intelligence": 50,     // 智力
  "currency": 500         // 货币
}
```

## 文件位置

```
lib/
├── services/
│   ├── story_service.dart      # 剧情服务
│   └── quest_service.dart      # 任务服务
├── data/
│   ├── models/
│   │   ├── story.dart          # 剧情模型
│   │   └── quest.dart          # 任务模型
│   ├── sample_story.json       # 剧情示例
│   └── sample_quests.json      # 任务示例
├── screens/
│   ├── story/
│   │   └── story_screen.dart   # 剧情界面
│   └── quest/
│       └── quest_screen.dart   # 任务界面
└── README_STORY_QUEST.md       # 详细文档
```

## 常见问题

### Q: 如何添加新的剧情节点？
A: 在JSON数据中添加新的node，指定nodeId和nextNode。

### Q: 如何创建新任务？
A: 在任务JSON中添加新任务，指定类型、目标、奖励等。

### Q: 如何保存和加载游戏进度？
A: 使用 `questService.exportState()` 和 `questService.importState()`。

### Q: 如何自定义UI？
A: 修改 `story_screen.dart` 或 `quest_screen.dart` 中的widget。

## 调试技巧

```dart
// 查看当前剧情节点
print(context.read<StoryService>().currentNode?.content);

// 查看任务列表
print(context.read<QuestService>().activeQuests);

// 检查条件
final choices = context.read<StoryService>()
    .getAvailableChoices(playerProvider);
print('可用选项: ${choices.length}');
```

## 下一步

1. 运行代码生成命令
2. 测试示例数据
3. 根据需求修改JSON数据
4. 自定义UI样式
5. 添加音效和图片资源

---

详细文档请参阅 `README_STORY_QUEST.md`
