import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/story_service.dart';
import '../../providers/player_provider.dart';

/// 剧情展示界面
class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen>
    with SingleTickerProviderStateMixin {
  // 动画控制器
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogAnimation;
  
  // 背景动画
  late AnimationController _bgAnimationController;
  late Animation<double> _bgAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 对话框动画
    _dialogAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _dialogAnimation = CurvedAnimation(
      parent: _dialogAnimationController,
      curve: Curves.easeOut,
    );
    
    // 背景切换动画
    _bgAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bgAnimation = CurvedAnimation(
      parent: _bgAnimationController,
      curve: Curves.easeInOut,
    );
    
    _dialogAnimationController.forward();
  }
  
  @override
  void dispose() {
    _dialogAnimationController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StoryService>(
        builder: (context, storyService, child) {
          final currentNode = storyService.currentNode;
          
          if (currentNode == null) {
            return _buildLoadingScreen();
          }
          
          return Stack(
            children: [
              // 背景
              _buildBackground(),
              
              // 内容区域
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      // 顶部信息栏
                      _buildTopBar(storyService),
                      
                      // 中间内容（留空给背景展示）
                      const Expanded(child: SizedBox()),
                      
                      // 底部对话框
                      _buildDialogBox(currentNode, storyService),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 构建背景
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f3460),
          ],
        ),
      ),
    );
  }
  
  /// 构建顶部信息栏
  Widget _buildTopBar(StoryService storyService) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 返回按钮
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  storyService.goBack();
                },
              ),
              
              const Spacer(),
              
              // 章节信息
              if (storyService.currentChapter != null)
                Text(
                  storyService.currentChapter!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              
              const SizedBox(width: 16),
              
              // 菜单按钮
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _showMenu(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 构建对话框
  Widget _buildDialogBox(StoryNode node, StoryService storyService) {
    return FadeTransition(
      opacity: _dialogAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说话人
            if (node.speaker != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  node.speaker!,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            if (node.speaker != null) const SizedBox(height: 12),
            
            // 对话内容
            Text(
              node.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 选项按钮
            _buildChoices(node, storyService),
          ],
        ),
      ),
    );
  }
  
  /// 构建选项按钮
  Widget _buildChoices(StoryNode node, StoryService storyService) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final availableChoices = storyService.getAvailableChoices(playerProvider);
        
        if (availableChoices.isEmpty) {
          // 没有选项，显示继续按钮
          return Center(
            child: ElevatedButton(
              onPressed: () {
                // 查找下一个节点（通常只有一个选择或自动继续）
                if (node.choices != null && node.choices!.isNotEmpty) {
                  storyService.makeChoice(node.choices!.first.id, playerProvider);
                } else {
                  // 章节结束，返回主菜单
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('继续'),
            ),
          );
        }
        
        // 显示所有可用选项
        return Column(
          children: availableChoices.map((choice) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    storyService.makeChoice(choice.id, playerProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.blue.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(choice.text),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  /// 构建加载界面
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.orange),
          SizedBox(height: 16),
          Text(
            '加载剧情中...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  /// 显示菜单
  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.save, color: Colors.white),
                title: const Text('保存游戏', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSaveDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('游戏设置', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSettingsDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.white),
                title: const Text('返回主菜单', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 显示保存对话框
  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存游戏'),
        content: const Text('游戏已自动保存'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  /// 显示设置对话框
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('游戏设置'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('背景音乐: 开'),
            Text('音效: 开'),
            Text('自动对话速度: 中'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
