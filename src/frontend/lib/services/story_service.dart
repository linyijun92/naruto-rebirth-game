import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/story.dart';
import '../providers/player_provider.dart';

/// 剧情服务 - 管理剧情数据的加载、解析和导航
class StoryService extends ChangeNotifier {
  // 存储所有剧情节点
  Map<String, StoryNode> _storyNodes = {};
  
  // 存储所有章节
  Map<String, Chapter> _chapters = {};
  
  // 当前剧情节点
  StoryNode? _currentNode;
  
  // 当前章节
  Chapter? _currentChapter;
  
  // 历史记录
  final List<String> _history = [];
  
  // 玩家选择的历史
  final Map<String, String> _choiceHistory = {};
  
  // Getters
  StoryNode? get currentNode => _currentNode;
  Chapter? get currentChapter => _currentChapter;
  Map<String, StoryNode> get storyNodes => _storyNodes;
  Map<String, Chapter> get chapters => _chapters;
  List<String> get history => List.unmodifiable(_history);
  Map<String, String> get choiceHistory => Map.unmodifiable(_choiceHistory);
  
  /// 加载剧情数据（从JSON字符串）
  Future<void> loadStoryData(String jsonData) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonData);
      
      // 加载章节
      if (data['chapters'] != null) {
        for (var chapterJson in data['chapters']) {
          final chapter = Chapter.fromJson(chapterJson);
          _chapters[chapter.chapterId] = chapter;
        }
      }
      
      // 加载剧情节点
      if (data['nodes'] != null) {
        for (var nodeJson in data['nodes']) {
          final node = StoryNode.fromJson(nodeJson);
          _storyNodes[node.nodeId] = node;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载剧情数据失败: $e');
      rethrow;
    }
  }
  
  /// 从文件加载剧情数据
  Future<void> loadStoryFromFile(String filePath) async {
    try {
      // 这里应该是从assets加载，简化实现
      // 实际使用时需要导入 'package:flutter/services.dart'
      // final String response = await rootBundle.loadString(filePath);
      // await loadStoryData(response);
      debugPrint('从文件加载: $filePath');
    } catch (e) {
      debugPrint('从文件加载剧情失败: $e');
      rethrow;
    }
  }
  
  /// 开始章节
  Future<bool> startChapter(String chapterId, PlayerProvider playerProvider) async {
    final chapter = _chapters[chapterId];
    if (chapter == null) {
      debugPrint('章节不存在: $chapterId');
      return false;
    }
    
    // 检查前置章节
    if (chapter.requiredChapters.isNotEmpty) {
      for (var requiredChapterId in chapter.requiredChapters) {
        final requiredChapter = _chapters[requiredChapterId];
        if (requiredChapter == null || !requiredChapter.isUnlocked) {
          debugPrint('前置章节未完成: $requiredChapterId');
          return false;
        }
      }
    }
    
    _currentChapter = chapter;
    await navigateToNode(chapter.startNodeId);
    
    // 更新玩家当前章节
    playerProvider.updateChapter(chapterId);
    
    notifyListeners();
    return true;
  }
  
  /// 导航到指定节点
  Future<void> navigateToNode(String nodeId) async {
    final node = _storyNodes[nodeId];
    if (node == null) {
      debugPrint('节点不存在: $nodeId');
      return;
    }
    
    // 添加到历史记录
    if (_currentNode != null) {
      _history.add(_currentNode!.nodeId);
    }
    
    _currentNode = node;
    notifyListeners();
  }
  
  /// 做出选择
  Future<bool> makeChoice(
    String choiceId,
    PlayerProvider playerProvider,
  ) async {
    if (_currentNode?.choices == null) {
      debugPrint('当前节点没有选项');
      return false;
    }
    
    final choice = _currentNode!.choices!.firstWhere(
      (c) => c.id == choiceId,
      orElse: () => throw Exception('选项不存在: $choiceId'),
    );
    
    // 检查条件
    if (!_checkRequirements(choice.requirements, playerProvider)) {
      debugPrint('不满足选项条件');
      return false;
    }
    
    // 记录选择
    _choiceHistory[_currentNode!.nodeId] = choiceId;
    
    // 导航到下一个节点
    await navigateToNode(choice.nextNode);
    
    return true;
  }
  
  /// 检查条件是否满足
  bool _checkRequirements(
    Map<String, dynamic>? requirements,
    PlayerProvider playerProvider,
  ) {
    if (requirements == null || requirements.isEmpty) {
      return true;
    }
    
    for (var entry in requirements.entries) {
      final key = entry.key;
      final value = entry.value;
      
      switch (key) {
        case 'level':
          if (playerProvider.level < value) return false;
          break;
        case 'chakra':
        case 'ninjutsu':
        case 'taijutsu':
        case 'intelligence':
          if (playerProvider.getAttribute(key) < value) return false;
          break;
        case 'currency':
          if (playerProvider.currency < value) return false;
          break;
        default:
          // 其他条件检查
          break;
      }
    }
    
    return true;
  }
  
  /// 回到上一个节点
  Future<void> goBack() async {
    if (_history.isEmpty) {
      debugPrint('没有历史记录');
      return;
    }
    
    final previousNodeId = _history.removeLast();
    await navigateToNode(previousNodeId);
  }
  
  /// 重置当前章节
  void resetCurrentChapter() {
    _history.clear();
    _choiceHistory.clear();
    _currentNode = null;
    if (_currentChapter != null) {
      _currentNode = _storyNodes[_currentChapter!.startNodeId];
    }
    notifyListeners();
  }
  
  /// 解锁章节
  void unlockChapter(String chapterId) {
    final chapter = _chapters[chapterId];
    if (chapter != null) {
      // 这里需要创建新的Chapter对象，因为Chapter的isUnlocked是final
      // 实际实现可能需要修改Chapter模型或使用其他方式
      debugPrint('解锁章节: $chapterId');
      notifyListeners();
    }
  }
  
  /// 获取可选选项（过滤掉不满足条件的）
  List<StoryChoice> getAvailableChoices(PlayerProvider playerProvider) {
    if (_currentNode?.choices == null) {
      return [];
    }
    
    return _currentNode!.choices!
        .where((choice) => _checkRequirements(choice.requirements, playerProvider))
        .toList();
  }
  
  /// 清空所有数据
  void clear() {
    _storyNodes.clear();
    _chapters.clear();
    _currentNode = null;
    _currentChapter = null;
    _history.clear();
    _choiceHistory.clear();
    notifyListeners();
  }
}
