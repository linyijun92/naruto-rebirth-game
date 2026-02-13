import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/quest.dart';
import '../providers/player_provider.dart';

/// 任务服务 - 管理任务的加载、更新和状态
class QuestService extends ChangeNotifier {
  // 所有任务
  Map<String, Quest> _quests = {};
  
  // 活跃任务ID列表
  final List<String> _activeQuests = [];
  
  // 已完成任务ID列表（未领取奖励的）
  final List<String> _completedQuests = [];
  
  // 已领取奖励的任务ID列表
  final List<String> _claimedQuests = [];
  
  // Getters
  Map<String, Quest> get quests => _quests;
  List<String> get activeQuests => List.unmodifiable(_activeQuests);
  List<String> get completedQuests => List.unmodifiable(_completedQuests);
  List<String> get claimedQuests => List.unmodifiable(_claimedQuests);
  
  /// 获取指定类型的任务
  List<Quest> getQuestsByType(QuestType type) {
    return _quests.values
        .where((quest) => quest.type == type)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  
  /// 获取活跃任务列表
  List<Quest> getActiveQuestList() {
    return _activeQuests
        .map((id) => _quests[id])
        .whereType<Quest>()
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  
  /// 获取可领取奖励的任务
  List<Quest> getClaimableQuests() {
    return _completedQuests
        .map((id) => _quests[id])
        .whereType<Quest>()
        .toList();
  }
  
  /// 获取可接取的任务
  List<Quest> getAvailableQuests(int playerLevel) {
    return _quests.values
        .where((quest) =>
            quest.status == QuestStatus.available &&
            quest.levelRequirement <= playerLevel)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
  
  /// 加载任务数据（从JSON字符串）
  Future<void> loadQuestData(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      
      if (data['quests'] != null) {
        for (var questJson in data['quests']) {
          final quest = Quest.fromJson(questJson);
          _quests[quest.questId] = quest;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载任务数据失败: $e');
      rethrow;
    }
  }
  
  /// 从文件加载任务数据
  Future<void> loadQuestFromFile(String filePath) async {
    try {
      debugPrint('从文件加载任务: $filePath');
      // 实际使用时需要从assets加载
    } catch (e) {
      debugPrint('从文件加载任务失败: $e');
      rethrow;
    }
  }
  
  /// 接取任务
  Future<bool> acceptQuest(
    String questId,
    PlayerProvider playerProvider,
  ) async {
    final quest = _quests[questId];
    if (quest == null) {
      debugPrint('任务不存在: $questId');
      return false;
    }
    
    // 检查状态
    if (quest.status != QuestStatus.available) {
      debugPrint('任务不可接取: ${quest.status}');
      return false;
    }
    
    // 检查等级要求
    if (playerProvider.level < quest.levelRequirement) {
      debugPrint('等级不足，需要等级: ${quest.levelRequirement}');
      return false;
    }
    
    // 检查前置任务
    for (var prerequisiteId in quest.prerequisiteQuests) {
      final prerequisite = _quests[prerequisiteId];
      if (prerequisite == null || 
          !(_claimedQuests.contains(prerequisiteId))) {
        debugPrint('前置任务未完成: $prerequisiteId');
        return false;
      }
    }
    
    // 更新任务状态
    final updatedQuest = quest.copyWith(
      status: QuestStatus.active,
      startTime: DateTime.now(),
    );
    _quests[questId] = updatedQuest;
    
    // 添加到活跃任务列表
    if (!_activeQuests.contains(questId)) {
      _activeQuests.add(questId);
    }
    
    notifyListeners();
    return true;
  }
  
  /// 更新任务进度
  Future<void> updateProgress(
    QuestProgressUpdate update,
    PlayerProvider playerProvider,
  ) async {
    final quest = _quests[update.questId];
    if (quest == null || quest.status != QuestStatus.active) {
      return;
    }
    
    // 更新对应的目标
    final objectives = quest.objectives.map((obj) {
      if (obj.id == update.objectiveId) {
        // 检查targetId是否匹配（如果指定了）
        if (update.targetId != null && obj.targetId != update.targetId) {
          return obj;
        }
        
        // 更新进度（不超过目标值）
        final newProgress = (obj.current + update.progress).clamp(0, obj.target);
        return obj.copyWith(current: newProgress);
      }
      return obj;
    }).toList();
    
    // 更新任务
    _quests[update.questId] = quest.copyWith(objectives: objectives);
    
    // 检查任务是否完成
    final updatedQuest = _quests[update.questId]!;
    if (updatedQuest.areAllObjectivesCompleted) {
      _completeQuest(update.questId);
    }
    
    notifyListeners();
  }
  
  /// 完成任务
  void _completeQuest(String questId) {
    final quest = _quests[questId];
    if (quest == null) return;
    
    // 更新状态
    _quests[questId] = quest.copyWith(
      status: QuestStatus.completed,
      completedTime: DateTime.now(),
    );
    
    // 从活跃任务中移除
    _activeQuests.remove(questId);
    
    // 添加到已完成列表
    if (!_completedQuests.contains(questId)) {
      _completedQuests.add(questId);
    }
    
    // 解锁后续任务
    _unlockDependentQuests(questId);
  }
  
  /// 解锁依赖此任务的其他任务
  void _unlockDependentQuests(String completedQuestId) {
    for (var quest in _quests.values) {
      if (quest.prerequisiteQuests.contains(completedQuestId) &&
          quest.status == QuestStatus.locked) {
        // 检查所有前置任务是否都已完成
        bool allPrereqsCompleted = true;
        for (var prereqId in quest.prerequisiteQuests) {
          if (!_claimedQuests.contains(prereqId)) {
            allPrereqsCompleted = false;
            break;
          }
        }
        
        if (allPrereqsCompleted) {
          _quests[quest.questId] = quest.copyWith(
            status: QuestStatus.available,
          );
        }
      }
    }
  }
  
  /// 领取奖励
  Future<Map<String, dynamic>> claimReward(
    String questId,
    PlayerProvider playerProvider,
  ) async {
    final quest = _quests[questId];
    if (quest == null) {
      throw Exception('任务不存在: $questId');
    }
    
    if (!quest.canClaimReward) {
      throw Exception('任务不可领取奖励');
    }
    
    // 发放奖励
    final rewards = <String, dynamic>{};
    
    for (var reward in quest.rewards) {
      switch (reward.type) {
        case RewardType.currency:
          playerProvider.addCurrency(reward.amount);
          rewards['currency'] = (rewards['currency'] ?? 0) + reward.amount;
          break;
        case RewardType.experience:
          playerProvider.addExperience(reward.amount);
          rewards['experience'] = (rewards['experience'] ?? 0) + reward.amount;
          break;
        case RewardType.attribute:
          if (reward.attributes != null) {
            reward.attributes!.forEach((key, value) {
              playerProvider.addAttribute(key, value);
            });
            rewards['attributes'] = reward.attributes;
          }
          break;
        case RewardType.item:
          // TODO: 添加物品到背包
          rewards['items'] = [...(rewards['items'] as List? ?? []), reward];
          break;
        case RewardType.skill:
          // TODO: 解锁技能
          rewards['skills'] = [...(rewards['skills'] as List? ?? []), reward];
          break;
      }
    }
    
    // 更新任务状态
    _quests[questId] = quest.copyWith(status: QuestStatus.claimed);
    
    // 从已完成列表移除，添加到已领取列表
    _completedQuests.remove(questId);
    if (!_claimedQuests.contains(questId)) {
      _claimedQuests.add(questId);
    }
    
    notifyListeners();
    return rewards;
  }
  
  /// 放弃任务
  Future<void> abandonQuest(String questId) async {
    final quest = _quests[questId];
    if (quest == null) return;
    
    // 主线任务不能放弃
    if (quest.type == QuestType.main) {
      debugPrint('主线任务不能放弃');
      return;
    }
    
    // 只有活跃任务可以放弃
    if (quest.status != QuestStatus.active) {
      return;
    }
    
    // 重置任务状态
    _quests[questId] = quest.copyWith(
      status: QuestStatus.available,
      startTime: null,
      objectives: quest.objectives.map((obj) => obj.copyWith(current: 0)).toList(),
    );
    
    // 从活跃任务移除
    _activeQuests.remove(questId);
    
    notifyListeners();
  }
  
  /// 重置日常任务
  Future<void> resetDailyQuests() async {
    for (var questId in _claimedQuests.toList()) {
      final quest = _quests[questId];
      if (quest != null && quest.type == QuestType.daily) {
        // 重置为可接取状态
        _quests[questId] = quest.copyWith(
          status: QuestStatus.available,
          startTime: null,
          completedTime: null,
          objectives: quest.objectives.map((obj) => obj.copyWith(current: 0)).toList(),
        );
        
        // 从已领取列表移除
        _claimedQuests.remove(questId);
      }
    }
    
    notifyListeners();
  }
  
  /// 检查并更新任务解锁状态
  void checkQuestUnlockStatus(int playerLevel) {
    for (var quest in _quests.values) {
      if (quest.status == QuestStatus.locked) {
        // 检查等级
        if (playerLevel >= quest.levelRequirement) {
          // 检查前置任务
          bool allPrereqsCompleted = true;
          for (var prereqId in quest.prerequisiteQuests) {
            if (!_claimedQuests.contains(prereqId)) {
              allPrereqsCompleted = false;
              break;
            }
          }
          
          if (allPrereqsCompleted) {
            _quests[quest.questId] = quest.copyWith(
              status: QuestStatus.available,
            );
          }
        }
      }
    }
    
    notifyListeners();
  }
  
  /// 获取任务详情
  Quest? getQuest(String questId) {
    return _quests[questId];
  }
  
  /// 清空所有数据
  void clear() {
    _quests.clear();
    _activeQuests.clear();
    _completedQuests.clear();
    _claimedQuests.clear();
    notifyListeners();
  }
  
  /// 导出任务状态（用于保存）
  Map<String, dynamic> exportState() {
    return {
      'activeQuests': _activeQuests,
      'completedQuests': _completedQuests,
      'claimedQuests': _claimedQuests,
      'quests': _quests.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
  
  /// 导入任务状态（用于加载）
  Future<void> importState(Map<String, dynamic> state) async {
    try {
      _activeQuests.clear();
      _completedQuests.clear();
      _claimedQuests.clear();
      _quests.clear();
      
      if (state['activeQuests'] != null) {
        _activeQuests.addAll(List<String>.from(state['activeQuests']));
      }
      
      if (state['completedQuests'] != null) {
        _completedQuests.addAll(List<String>.from(state['completedQuests']));
      }
      
      if (state['claimedQuests'] != null) {
        _claimedQuests.addAll(List<String>.from(state['claimedQuests']));
      }
      
      if (state['quests'] != null) {
        for (var entry in (state['quests'] as Map).entries) {
          final quest = Quest.fromJson(entry.value);
          _quests[entry.key] = quest;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('导入任务状态失败: $e');
      rethrow;
    }
  }
}
