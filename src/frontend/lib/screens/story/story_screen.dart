import 'dart:async';
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
  // 对话框动画
  late AnimationController _dialogAnimationController;
  late Animation<double> _dialogAnimation;
  
  // 背景切换动画
  late AnimationController _bgAnimationController;
  late Animation<double> _bgAnimation;
  
  // 打字机效果
  Timer? _typingTimer;
  String _displayedText = '';
  int _typingIndex = 0;
  bool _isTyping = false;
  
  // 菜单状态
  bool _isMenuOpen = false;
  
  // 说话人头像占位符
  final Map<String, String> _speakerAvatars = {
    '鸣人': '🦊',
    '佐助': '⚡',
    '小樱': '🌸',
    '卡卡西': '📖',
    '自来也': '🐸',
    '纲手': '🍷',
    '鼬': '🌙',
    '三代': '🏯',
    '伊鲁卡': '🍎',
    '雏田': '👁️',
  };

  // 背景颜色映射（根据节点ID或章节ID）
  final Map<String, List<Color>> _backgroundColors = {
    'default': [
      const Color(0xFF1a1a2e),
      const Color(0xFF16213e),
      const Color(0xFF0f3460),
    ],
    'forest': [
      const Color(0xFF1B4F28),
      const Color(0xFF2E7D32),
      const Color(0xFF43A047),
    ],
    'village': [
      const Color(0xFF3E2723),
      const Color(0xFF5D4037),
      const Color(0xFF795548),
    ],
    'night': [
      const Color(0xFF0D1117),
      const Color(0xFF161B22),
      const Color(0xFF21262D),
    ],
    'battle': [
      const Color(0xFF4A0000),
      const Color(0xFF8B0000),
      const Color(0xFFB22222),
    ],
  };

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
    _typingTimer?.cancel();
    super.dispose();
  }

  /// 开始打字机效果
  void _startTypingEffect(String text) {
    setState(() {
      _displayedText = '';
      _typingIndex = 0;
      _isTyping = true;
    });

    _typingTimer?.cancel();
    
    const typingSpeed = 30; // 每个字符的毫秒数
    
    _typingTimer = Timer.periodic(
      const Duration(milliseconds: typingSpeed),
      (timer) {
        if (_typingIndex < text.length) {
          setState(() {
            _displayedText = text.substring(0, _typingIndex + 1);
            _typingIndex++;
          });
        } else {
          setState(() {
            _isTyping = false;
          });
          timer.cancel();
        }
      },
    );
  }

  /// 立即显示完整文本
  void _showFullText(String text) {
    _typingTimer?.cancel();
    setState(() {
      _displayedText = text;
      _typingIndex = text.length;
      _isTyping = false;
    });
  }

  /// 获取背景颜色
  List<Color> _getBackgroundColors(String? nodeId, String? chapterId) {
    // 根据节点ID或章节ID返回背景颜色
    if (nodeId != null && _backgroundColors.containsKey(nodeId)) {
      return _backgroundColors[nodeId]!;
    }
    if (chapterId != null) {
      if (chapterId.contains('forest')) return _backgroundColors['forest']!;
      if (chapterId.contains('village')) return _backgroundColors['village']!;
      if (chapterId.contains('night')) return _backgroundColors['night']!;
      if (chapterId.contains('battle')) return _backgroundColors['battle']!;
    }
    return _backgroundColors['default']!;
  }

  /// 获取说话人头像占位符
  String _getSpeakerAvatar(String? speaker) {
    if (speaker == null || !_speakerAvatars.containsKey(speaker)) {
      return '👤';
    }
    return _speakerAvatars[speaker]!;
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

          // 在节点变化时重新开始打字机效果
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_displayedText != currentNode.content) {
              _startTypingEffect(currentNode.content);
            }
          });
          
          final bgColors = _getBackgroundColors(currentNode.nodeId, currentNode.chapterId);

          return Stack(
            children: [
              // 背景
              _buildBackground(bgColors),
              
              // 内容区域
              Positioned.fill(
                child: SafeArea(
                  child: Column(
                    children: [
                      // 顶部信息栏
                      _buildTopBar(storyService, currentNode),
                      
                      // 中间内容区域
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 说话人头像（占位符）
                            if (currentNode.speaker != null)
                              _buildSpeakerAvatar(currentNode.speaker!),
                          ],
                        ),
                      ),
                      
                      // 底部对话框和选项
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 对话框
                          _buildDialogBox(currentNode, storyService),
                          // 选项按钮
                          _buildChoices(currentNode, storyService),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // 菜单覆盖层
              if (_isMenuOpen) _buildMenuOverlay(storyService),
            ],
          );
        },
      ),
    );
  }

  /// 构建背景
  Widget _buildBackground(List<Color> colors) {
    return AnimatedBuilder(
      animation: _bgAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
          // 添加一些装饰性背景元素（可选）
          child: Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: _BackgroundPatternPainter(),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }

  /// 构建顶部信息栏
  Widget _buildTopBar(StoryService storyService, dynamic currentNode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 返回按钮
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                storyService.goBack();
              },
              tooltip: '返回',
            ),
          ),
          
          const Spacer(),
          
          // 章节信息
          if (storyService.currentChapter != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    storyService.currentChapter!.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (storyService.currentChapter!.description.isNotEmpty)
                    Text(
                      storyService.currentChapter!.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          
          const SizedBox(width: 16),
          
          // 菜单按钮
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                _isMenuOpen ? Icons.close : Icons.menu,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isMenuOpen = !_isMenuOpen;
                });
              },
              tooltip: '菜单',
            ),
          ),
        ],
      ),
    );
  }

  /// 构建说话人头像
  Widget _buildSpeakerAvatar(String speaker) {
    return AnimatedBuilder(
      animation: _dialogAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _dialogAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text(
              _getSpeakerAvatar(speaker),
              style: const TextStyle(fontSize: 60),
            ),
          ),
        );
      },
    );
  }

  /// 构建对话框
  Widget _buildDialogBox(dynamic node, StoryService storyService) {
    return FadeTransition(
      opacity: _dialogAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _dialogAnimationController,
          curve: Curves.easeOut,
        )),
        child: GestureDetector(
          onTap: () {
            // 点击对话框继续显示文本
            if (_isTyping) {
              _showFullText(node.content);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withOpacity(0.6),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 说话人名称
                if (node.speaker != null)
                  Row(
                    children: [
                      Text(
                        _getSpeakerAvatar(node.speaker!),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.4),
                            width: 1,
                          ),
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
                    ],
                  ),
                
                if (node.speaker != null) const SizedBox(height: 16),
                
                // 对话文本（打字机效果）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _displayedText.isNotEmpty ? _displayedText : node.content,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.6,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_isTyping)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildTypingCursor(),
                      ),
                  ],
                ),
                
                // 打字提示
                if (!_isTyping)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 16,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '点击继续',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建打字机光标
  Widget _buildTypingCursor() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.5 + (value * 0.5),
          child: const Text(
            '|',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      onEnd: () {
        // 循环动画
      },
    );
  }

  /// 构建选项按钮
  Widget _buildChoices(dynamic node, StoryService storyService) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final availableChoices = storyService.getAvailableChoices(playerProvider);
        
        if (availableChoices.isEmpty) {
          // 没有选项，显示继续按钮
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
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
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '继续 ▶',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }
        
        // 显示所有可用选项
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: availableChoices.asMap().entries.map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              storyService.makeChoice(choice.id, playerProvider);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.blue.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    choice.text,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// 构建菜单覆盖层
  Widget _buildMenuOverlay(StoryService storyService) {
    return AnimatedBuilder(
      animation: _dialogAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _isMenuOpen = false;
            });
          },
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: Center(
              child: ScaleTransition(
                scale: _dialogAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '游戏菜单',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: '查看历史',
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                          });
                          _showHistoryDialog(storyService);
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.undo,
                        title: '返回上一句',
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                          });
                          storyService.goBack();
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: '游戏设置',
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                          });
                          _showSettingsDialog();
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.save,
                        title: '保存进度',
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                          });
                          _showSaveDialog();
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.exit_to_app,
                        title: '返回主菜单',
                        isDanger: true,
                        onTap: () {
                          setState(() {
                            _isMenuOpen = false;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDanger
                ? Colors.red.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDanger
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDanger ? Colors.red : Colors.white70,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: isDanger ? Colors.red : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建加载界面
  Widget _buildLoadingScreen() {
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 24),
            Text(
              '加载剧情中...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示历史对话框
  void _showHistoryDialog(StoryService storyService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '对话历史',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: storyService.history.isEmpty
              ? const Text(
                  '暂无历史记录',
                  style: TextStyle(color: Colors.white70),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: storyService.history.length,
                  itemBuilder: (context, index) {
                    final nodeId = storyService.history[storyService.history.length - 1 - index];
                    final node = storyService.storyNodes[nodeId];
                    if (node == null) return const SizedBox.shrink();
                    
                    return ListTile(
                      title: Text(
                        node.speaker ?? '???',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        node.content,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  /// 显示设置对话框
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '游戏设置',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SettingItem(
              icon: Icons.music_note,
              label: '背景音乐',
              value: '开',
            ),
            SizedBox(height: 12),
            _SettingItem(
              icon: Icons.volume_up,
              label: '音效',
              value: '开',
            ),
            SizedBox(height: 12),
            _SettingItem(
              icon: Icons.speed,
              label: '自动对话速度',
              value: '中',
            ),
            SizedBox(height: 12),
            _SettingItem(
              icon: Icons.skip_next,
              label: '跳过打字效果',
              value: '否',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  /// 显示保存对话框
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(
              '自动保存',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          '游戏已自动保存到当前进度',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
}

/// 背景装饰画笔
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // 绘制一些简单的装饰性图案
    const lineSpacing = 100.0;
    
    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    for (double x = 0; x < size.width; x += lineSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 设置项组件
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
