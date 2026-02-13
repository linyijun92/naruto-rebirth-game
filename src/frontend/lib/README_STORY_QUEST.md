# 剧情引擎和任务系统使用文档

## 概述

本游戏实现了完整的剧情展示引擎和任务系统，支持分支剧情、多结局、任务追踪等功能。

## 1. 剧情引擎

### 文件结构

- `services/story_service.dart` - 剧情服务，管理剧情数据的加载和导航
- `data/models/story.dart` - 剧情数据模型
- `screens/story/story_screen.dart` - 剧情展示界面
- `data/sample_story.json` - 示例剧情数据

### 数据模型

#### StoryNode（剧情节点）
```dart
{
  nodeId: String,           // 节点ID
  chapterId: String,        // 所属章节ID
  type: String,            // 节点类型（dialogue/ending等）
  content: String,         // 剧情内容
  speaker: String?,        // 说话人（可选）
  choices: List<Choice>?,   // 选项列表
  backgroundMusic: String?, // 背景音乐（可选）
  soundEffect: String?     // 音效（可选）
}
```

#### StoryChoice（剧情选项）
```dart
{
  id: String,                    // 选项ID
  text: String,                  // 选项文本
  nextNode: String,              // 下一个节点ID
  requirements: Map<String, dynamic>?  // 触发条件（可选）
}
```

#### Chapter（章节）
```dart
{
  chapterId: String,         // 章节ID
  title: String,             // 章节标题
  description: String,      // 章节描述
  startNodeId: String,       // 起始节点ID
  requiredChapters: List<String>,  // 前置章节
  isUnlocked: bool          // 是否解锁
}
```

### 使用方法

#### 1. 加载剧情数据

```dart
final storyService = StoryService();

// 从JSON字符串加载
await storyService.loadStoryData(jsonString);

// 从文件加载
await storyService.loadStoryFromFile('assets/data/story.json');
```

#### 2. 开始章节

```dart
final playerProvider = PlayerProvider();
await storyService.startChapter('chapter_01', playerProvider);
```

#### 3. 做出选择

```dart
await storyService.makeChoice('choice_id', playerProvider);
```

#### 4. 在UI中使用

```dart
// 在main.dart中添加Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => StoryService()),
    ChangeNotifierProvider(create: (_) => PlayerProvider()),
  ],
  child: MyApp(),
)

// 在MaterialApp中使用
MaterialApp(
  routes: {
    '/story': (context) => const StoryScreen(),
  },
)

// 导航到剧情界面
Navigator.pushNamed(context, '/story');
```

### 条件系统

选项可以设置触发条件，只有满足条件的玩家才能看到和选择该选项：

```dart
{
  "requirements": {
    "level": 5,              // 等级要求
    "chakra": 100,          // 查克拉要求
    "ninjutsu": 50,         // 忍术要求
    "taijutsu": 50,         // 体术要求
    "intelligence": 50,     // 智力要求
    "currency": 500         // 货币要求
  }
}
```

## 2. 任务系统

### 文件结构

- `services/quest_service.dart` - 任务服务，管理任务的加载和状态
- `data/models/quest.dart` - 任务数据模型
- `screens/quest/quest_screen.dart` - 任务界面
- `data/sample_quests.json` - 示例任务数据

### 数据模型

#### Quest（任务）
```dart
{
  questId: String,                  // 任务ID
  title: String,                    // 任务标题
  description: String,              // 任务描述
  type: QuestType,                 // 任务类型（main/side/daily）
  status: QuestStatus,              // 任务状态
  objectives: List<QuestObjective>, // 任务目标
  rewards: List<QuestReward>,       // 任务奖励
  levelRequirement: int,           // 等级要求
  prerequisiteQuests: List<String>, // 前置任务
  sortOrder: int                   // 排序权重
}
```

#### QuestObjective（任务目标）
```dart
{
  id: String,              // 目标ID
  description: String,     // 目标描述
  type: ObjectiveType,     // 目标类型（kill/collect/talk/reachLevel等）
  target: int,            // 目标数量
  current: int,           // 当前进度
  targetId: String?       // 目标ID（可选）
}
```

#### QuestReward（任务奖励）
```dart
{
  id: String?,                    // 物品ID
  name: String,                   // 奖励名称
  type: RewardType,              // 奖励类型（currency/experience/item/attribute/skill）
  amount: int,                   // 数量
  attributes: Map<String, int>?  // 属性奖励（可选）
}
```

### 任务类型

- **Main Quest（主线任务）** - 推动剧情发展的核心任务，不可放弃
- **Side Quest（支线任务）** - 可选任务，可以放弃
- **Daily Quest（日常任务）** - 每日刷新的任务

### 任务状态

- **Locked** - 未解锁
- **Available** - 可接取
- **Active** - 进行中
- **Completed** - 已完成（未领取奖励）
- **Claimed** - 已领取奖励
- **Failed** - 失败

### 使用方法

#### 1. 加载任务数据

```dart
final questService = QuestService();

// 从JSON字符串加载
await questService.loadQuestData(jsonString);

// 从文件加载
await questService.loadQuestFromFile('assets/data/quests.json');
```

#### 2. 接取任务

```dart
final playerProvider = PlayerProvider();
await questService.acceptQuest('quest_id', playerProvider);
```

#### 3. 更新任务进度

```dart
final update = QuestProgressUpdate(
  questId: 'quest_id',
  objectiveId: 'objective_id',
  progress: 1,
  targetId: 'target_id', // 可选
);

await questService.updateProgress(update, playerProvider);
```

#### 4. 领取奖励

```dart
final rewards = await questService.claimReward('quest_id', playerProvider);
// rewards 包含：currency, experience, items, attributes, skills
```

#### 5. 放弃任务

```dart
await questService.abandonQuest('quest_id');
```

#### 6. 重置日常任务

```dart
await questService.resetDailyQuests();
```

#### 7. 在UI中使用

```dart
// 在main.dart中添加Provider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => QuestService()),
    ChangeNotifierProvider(create: (_) => PlayerProvider()),
  ],
  child: MyApp(),
)

// 在MaterialApp中使用
MaterialApp(
  routes: {
    '/quest': (context) => const QuestScreen(),
  },
)

// 导航到任务界面
Navigator.pushNamed(context, '/quest');
```

## 3. 示例数据

### 剧情数据示例

查看 `data/sample_story.json` 了解完整的剧情数据结构，包含：

- 2个章节（重生木叶、忍者学校）
- 多个剧情节点
- 分支选择
- 条件触发

### 任务数据示例

查看 `data/sample_quests.json` 了解完整的任务数据结构，包含：

- 3个主线任务
- 3个支线任务
- 4个日常任务
- 各种目标类型
- 多种奖励类型

## 4. 集成到游戏主流程

```dart
// 在游戏启动时加载所有数据
Future<void> initGame() async {
  // 初始化PlayerProvider
  final playerProvider = PlayerProvider();
  
  // 加载剧情数据
  final storyService = StoryService();
  await storyService.loadStoryFromFile('assets/data/story.json');
  
  // 加载任务数据
  final questService = QuestService();
  await questService.loadQuestFromFile('assets/data/quests.json');
  
  // 检查任务解锁状态
  questService.checkQuestUnlockStatus(playerProvider.level);
}
```

## 5. 保存和加载

### 保存任务状态

```dart
final state = questService.exportState();
// 将state保存到本地存储
```

### 加载任务状态

```dart
final state = await loadFromStorage();
await questService.importState(state);
```

## 6. 注意事项

1. **JSON序列化**：需要运行 `flutter pub run build_runner build` 生成 `.g.dart` 文件
2. **Provider**：确保在应用顶层注册Provider
3. **资源文件**：将JSON数据文件放在 `assets/data/` 目录，并在 `pubspec.yaml` 中声明
4. **状态同步**：任务进度更新会自动通知UI刷新
5. **条件检查**：接取任务和选择剧情选项时会自动检查条件

## 7. 扩展功能

### 添加新的目标类型

在 `ObjectiveType` 枚举中添加新类型，并在 `QuestService.updateProgress` 中处理。

### 添加新的奖励类型

在 `RewardType` 枚举中添加新类型，并在 `QuestService.claimReward` 中处理。

### 自定义UI

- `StoryScreen` 可以根据需要自定义背景、对话框样式
- `QuestScreen` 可以根据需要添加筛选、排序等功能

## 8. 调试

查看日志输出：

```dart
// StoryService会输出详细的日志
debugPrint(storyService.currentNode?.content);

// QuestService会输出任务状态变化
debugPrint('任务状态: ${quest.status}');
```

---

如有问题，请参考示例数据或联系开发团队。
