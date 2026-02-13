import 'package:json_annotation/json_annotation.dart';

part 'quest.g.dart';

/// 任务类型
enum QuestType {
  main,      // 主线任务
  side,      // 支线任务
  daily,     // 日常任务
}

/// 任务状态
enum QuestStatus {
  locked,    // 未解锁
  available, // 可接取
  active,    // 进行中
  completed, // 已完成（未领取奖励）
  claimed,   // 已领取奖励
  failed,    // 失败
}

/// 任务目标类型
enum ObjectiveType {
  kill,          // 击败敌人
  collect,       // 收集物品
  talk,          // 对话
  reachLevel,    // 达到等级
  completeStory, // 完成剧情
  train,         // 训练
}

/// 任务目标
@JsonSerializable()
class QuestObjective {
  final String id;
  final String description;
  final ObjectiveType type;
  final int target;       // 目标数量
  final int current;      // 当前进度
  final String? targetId; // 目标ID（如敌人ID、物品ID等）

  QuestObjective({
    required this.id,
    required this.description,
    required this.type,
    required this.target,
    this.current = 0,
    this.targetId,
  });

  /// 是否完成
  bool get isCompleted => current >= target;

  factory QuestObjective.fromJson(Map<String, dynamic> json) =>
      _$QuestObjectiveFromJson(json);

  Map<String, dynamic> toJson() => _$QuestObjectiveToJson(this);

  QuestObjective copyWith({
    String? id,
    String? description,
    ObjectiveType? type,
    int? target,
    int? current,
    String? targetId,
  }) {
    return QuestObjective(
      id: id ?? this.id,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      current: current ?? this.current,
      targetId: targetId ?? this.targetId,
    );
  }
}

/// 任务奖励
@JsonSerializable()
class QuestReward {
  final String? id;           // 物品ID
  final String name;          // 奖励名称
  final RewardType type;      // 奖励类型
  final int amount;           // 数量
  final Map<String, int>? attributes; // 属性奖励

  QuestReward({
    this.id,
    required this.name,
    required this.type,
    required this.amount,
    this.attributes,
  });

  factory QuestReward.fromJson(Map<String, dynamic> json) =>
      _$QuestRewardFromJson(json);

  Map<String, dynamic> toJson() => _$QuestRewardToJson(this);
}

/// 奖励类型
enum RewardType {
  currency,      // 货币
  experience,    // 经验
  item,          // 物品
  attribute,     // 属性
  skill,         // 技能
}

/// 任务模型
@JsonSerializable()
class Quest {
  final String questId;
  final String title;
  final String description;
  final QuestType type;
  final QuestStatus status;
  final List<QuestObjective> objectives;
  final List<QuestReward> rewards;
  final int levelRequirement; // 等级要求
  final List<String> prerequisiteQuests; // 前置任务ID
  final DateTime? startTime;     // 开始时间
  final DateTime? endTime;       // 结束时间（用于限时任务）
  final DateTime? completedTime;  // 完成时间
  final int sortOrder;           // 排序权重

  Quest({
    required this.questId,
    required this.title,
    required this.description,
    required this.type,
    this.status = QuestStatus.locked,
    required this.objectives,
    required this.rewards,
    this.levelRequirement = 1,
    this.prerequisiteQuests = const [],
    this.startTime,
    this.endTime,
    this.completedTime,
    this.sortOrder = 0,
  });

  /// 是否所有目标都已完成
  bool get areAllObjectivesCompleted {
    return objectives.every((obj) => obj.isCompleted);
  }

  /// 总进度百分比
  double get progress {
    if (objectives.isEmpty) return 1.0;
    int totalProgress = objectives.fold(0, (sum, obj) => sum + obj.current);
    int totalTarget = objectives.fold(0, (sum, obj) => sum + obj.target);
    if (totalTarget == 0) return 1.0;
    return totalProgress / totalTarget;
  }

  /// 是否可以领取奖励
  bool get canClaimReward {
    return status == QuestStatus.completed;
  }

  /// 是否可以接取
  bool get canAccept {
    return status == QuestStatus.available;
  }

  /// 是否进行中
  bool get isActive {
    return status == QuestStatus.active;
  }

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);

  Map<String, dynamic> toJson() => _$QuestToJson(this);

  Quest copyWith({
    String? questId,
    String? title,
    String? description,
    QuestType? type,
    QuestStatus? status,
    List<QuestObjective>? objectives,
    List<QuestReward>? rewards,
    int? levelRequirement,
    List<String>? prerequisiteQuests,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? completedTime,
    int? sortOrder,
  }) {
    return Quest(
      questId: questId ?? this.questId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      objectives: objectives ?? this.objectives,
      rewards: rewards ?? this.rewards,
      levelRequirement: levelRequirement ?? this.levelRequirement,
      prerequisiteQuests: prerequisiteQuests ?? this.prerequisiteQuests,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completedTime: completedTime ?? this.completedTime,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// 任务进度更新事件
class QuestProgressUpdate {
  final String questId;
  final String objectiveId;
  final int progress;
  final String? targetId;

  QuestProgressUpdate({
    required this.questId,
    required this.objectiveId,
    required this.progress,
    this.targetId,
  });
}
