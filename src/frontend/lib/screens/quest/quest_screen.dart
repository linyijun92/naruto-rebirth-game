import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/quest.dart';
import '../../services/quest_service.dart';
import '../../providers/player_provider.dart';

/// 任务界面
class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen>
    with SingleTickerProviderStateMixin {
  // 当前选中的标签
  QuestType _selectedType = QuestType.main;
  
  // 筛选状态
  QuestStatus? _selectedFilter;
  
  // 展开的任务描述
  final Set<String> _expandedDescriptions = {};
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedType = QuestType.main;
          break;
        case 1:
          _selectedType = QuestType.side;
          break;
        case 2:
          _selectedType = QuestType.daily;
          break;
      }
      // 切换标签时重置筛选
      _selectedFilter = null;
    });
  }

  void _toggleDescription(String questId) {
    setState(() {
      if (_expandedDescriptions.contains(questId)) {
        _expandedDescriptions.remove(questId);
      } else {
        _expandedDescriptions.add(questId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('任务列表'),
        backgroundColor: const Color(0xFF0f3460),
        elevation: 0,
        actions: [
          // 筛选按钮
          PopupMenuButton<QuestStatus?>(
            icon: Icon(
              Icons.filter_list,
              color: _selectedFilter != null ? Colors.orange : Colors.white70,
            ),
            tooltip: '筛选任务',
            onSelected: (QuestStatus? status) {
              setState(() {
                _selectedFilter = status;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 20),
                    SizedBox(width: 8),
                    Text('全部'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: QuestStatus.available,
                child: Row(
                  children: [
                    Icon(Icons.lock_open, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('可接取'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: QuestStatus.active,
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('进行中'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: QuestStatus.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('已完成'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: QuestStatus.claimed,
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('已领取'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '主线'),
            Tab(text: '支线'),
            Tab(text: '日常'),
          ],
        ),
      ),
      body: Column(
        children: [
          // 筛选状态标签
          if (_selectedFilter != null)
            _buildFilterTag(),
          // 任务列表
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(QuestType.main),
                _buildQuestList(QuestType.side),
                _buildQuestList(QuestType.daily),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterTag() {
    String filterText;
    Color filterColor;
    
    switch (_selectedFilter) {
      case QuestStatus.available:
        filterText = '可接取';
        filterColor = Colors.orange;
        break;
      case QuestStatus.active:
        filterText = '进行中';
        filterColor = Colors.blue;
        break;
      case QuestStatus.completed:
        filterText = '已完成';
        filterColor = Colors.green;
        break;
      case QuestStatus.claimed:
        filterText = '已领取';
        filterColor = Colors.grey;
        break;
      default:
        filterText = '';
        filterColor = Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: filterColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: filterColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filterText,
                  style: TextStyle(
                    color: filterColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: filterColor,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '${_getQuestCount()} 个任务',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建任务列表
  Widget _buildQuestList(QuestType type) {
    return Consumer2<QuestService, PlayerProvider>(
      builder: (context, questService, playerProvider, child) {
        // 检查并更新任务解锁状态
        WidgetsBinding.instance.addPostFrameCallback((_) {
          questService.checkQuestUnlockStatus(playerProvider.level);
        });

        // 获取所有任务
        List<Quest> allQuests = [];

        // 活跃任务
        allQuests.addAll(
          questService.getActiveQuestList()
              .where((q) => q.type == type)
              .toList(),
        );

        // 可接取任务
        allQuests.addAll(
          questService.getAvailableQuests(playerProvider.level)
              .where((q) => q.type == type)
              .toList(),
        );

        // 可领取奖励的任务
        allQuests.addAll(
          questService.getClaimableQuests()
              .where((q) => q.type == type)
              .toList(),
        );

        // 已领取的任务
        allQuests.addAll(
          questService.claimedQuests
              .map((id) => questService.getQuest(id))
              .whereType<Quest>()
              .where((q) => q.type == type)
              .toList(),
        );

        // 按状态筛选
        if (_selectedFilter != null) {
          allQuests = allQuests.where((q) => q.status == _selectedFilter).toList();
        }

        // 按排序权重排序
        allQuests.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        if (allQuests.isEmpty) {
          return _buildEmptyState(type);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: allQuests.length,
          itemBuilder: (context, index) {
            final quest = allQuests[index];
            return _buildQuestCard(quest, playerProvider, questService);
          },
        );
      },
    );
  }

  /// 获取任务数量
  int _getQuestCount() {
    final questService = context.read<QuestService>();
    final playerProvider = context.read<PlayerProvider>();
    
    List<Quest> allQuests = [];
    
    allQuests.addAll(
      questService.getActiveQuestList()
          .where((q) => q.type == _selectedType)
          .toList(),
    );
    
    allQuests.addAll(
      questService.getAvailableQuests(playerProvider.level)
          .where((q) => q.type == _selectedType)
          .toList(),
    );
    
    allQuests.addAll(
      questService.getClaimableQuests()
          .where((q) => q.type == _selectedType)
          .toList(),
    );
    
    allQuests.addAll(
      questService.claimedQuests
          .map((id) => questService.getQuest(id))
          .whereType<Quest>()
          .where((q) => q.type == _selectedType)
          .toList(),
    );

    if (_selectedFilter != null) {
      allQuests = allQuests.where((q) => q.status == _selectedFilter).toList();
    }
    
    return allQuests.length;
  }

  /// 构建空状态
  Widget _buildEmptyState(QuestType type) {
    String message;
    IconData iconData;
    
    switch (type) {
      case QuestType.main:
        message = '暂无主线任务';
        iconData = Icons.assignment_outlined;
        break;
      case QuestType.side:
        message = '暂无支线任务';
        iconData = Icons.assignment_outlined;
        break;
      case QuestType.daily:
        message = '今日日常任务已完成';
        iconData = Icons.check_circle_outline;
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建任务卡片
  Widget _buildQuestCard(
    Quest quest,
    PlayerProvider playerProvider,
    QuestService questService,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (quest.status) {
      case QuestStatus.active:
        statusColor = Colors.blue;
        statusText = '进行中';
        statusIcon = Icons.play_circle_outline;
        break;
      case QuestStatus.completed:
        statusColor = Colors.green;
        statusText = '已完成';
        statusIcon = Icons.check_circle;
        break;
      case QuestStatus.available:
        statusColor = Colors.orange;
        statusText = '可接取';
        statusIcon = Icons.lock_open;
        break;
      case QuestStatus.claimed:
        statusColor = Colors.grey;
        statusText = '已领取';
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未解锁';
        statusIcon = Icons.lock;
    }

    // 任务类型图标
    IconData typeIcon;
    Color typeColor;
    switch (quest.type) {
      case QuestType.main:
        typeIcon = Icons.star;
        typeColor = Colors.red;
        break;
      case QuestType.side:
        typeIcon = Icons.bookmark;
        typeColor = Colors.orange;
        break;
      case QuestType.daily:
        typeIcon = Icons.today;
        typeColor = Colors.green;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF16213e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleDescription(quest.questId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行：类型图标 + 任务名称 + 状态标签
              Row(
                children: [
                  // 类型图标
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      typeIcon,
                      size: 18,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 任务名称
                  Expanded(
                    child: Text(
                      quest.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 状态标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 任务描述（可展开）
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: _expandedDescriptions.contains(quest.questId) ? null : 2,
                    overflow: _expandedDescriptions.contains(quest.questId)
                        ? null
                        : TextOverflow.ellipsis,
                  ),
                  GestureDetector(
                    onTap: () => _toggleDescription(quest.questId),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _expandedDescriptions.contains(quest.questId)
                                ? '收起'
                                : '展开',
                            style: TextStyle(
                              color: Colors.orange.withOpacity(0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            _expandedDescriptions.contains(quest.questId)
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 16,
                            color: Colors.orange.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (quest.levelRequirement > 1) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 14,
                      color: playerProvider.level >= quest.levelRequirement
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '等级要求: ${quest.levelRequirement}',
                      style: TextStyle(
                        color: playerProvider.level >= quest.levelRequirement
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // 进度条（只有进行中的任务才显示）
              if (quest.isActive) _buildProgressBar(quest),

              // 任务目标
              _buildObjectives(quest),

              const SizedBox(height: 12),

              // 奖励
              _buildRewards(quest),

              const SizedBox(height: 12),

              // 操作按钮
              _buildActionButtons(quest, playerProvider, questService),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar(Quest quest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 14,
                  color: Colors.orange.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  '任务进度',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              '${(quest.progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: quest.progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 构建任务目标
  Widget _buildObjectives(Quest quest) {
    if (quest.objectives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flag,
              size: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '任务目标',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...quest.objectives.map((objective) {
          final isCompleted = objective.isCompleted;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: isCompleted ? Colors.green : Colors.white54,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective.description,
                    style: TextStyle(
                      color: isCompleted ? Colors.green.withOpacity(0.8) : Colors.white,
                      fontSize: 13,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${objective.current}/${objective.target}',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 构建奖励
  Widget _buildRewards(Quest quest) {
    if (quest.rewards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.card_giftcard,
              size: 14,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              '任务奖励',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quest.rewards.map((reward) {
            IconData rewardIcon;
            Color rewardBgColor;
            switch (reward.type) {
              case RewardType.currency:
                rewardIcon = Icons.monetization_on;
                rewardBgColor = Colors.amber.withOpacity(0.15);
                break;
              case RewardType.experience:
                rewardIcon = Icons.star;
                rewardBgColor = Colors.yellow.withOpacity(0.15);
                break;
              case RewardType.item:
                rewardIcon = Icons.inventory_2;
                rewardBgColor = Colors.purple.withOpacity(0.15);
                break;
              case RewardType.attribute:
                rewardIcon = Icons.trending_up;
                rewardBgColor = Colors.green.withOpacity(0.15);
                break;
              case RewardType.skill:
                rewardIcon = Icons.auto_stories;
                rewardBgColor = Colors.blue.withOpacity(0.15);
                break;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: rewardBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    rewardIcon,
                    size: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${reward.name} x${reward.amount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(
    Quest quest,
    PlayerProvider playerProvider,
    QuestService questService,
  ) {
    if (quest.canClaimReward) {
      // 可领取奖励
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              final rewards = await questService.claimReward(
                quest.questId,
                playerProvider,
              );
              _showRewardDialog(rewards);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('领取奖励失败: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.card_giftcard, size: 20),
          label: const Text('领取奖励'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      );
    } else if (quest.canAccept) {
      // 可接取
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final success = await questService.acceptQuest(
              quest.questId,
              playerProvider,
            );
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('接取任务失败，可能不满足条件'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(Icons.add_circle_outline, size: 20),
          label: const Text('接取任务'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      );
    } else if (quest.isActive && quest.type != QuestType.main) {
      // 进行中且非主线任务，可以放弃
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await _showAbandonConfirmDialog(quest.title);
                if (confirm == true) {
                  questService.abandonQuest(quest.questId);
                }
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text('放弃任务'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.withOpacity(0.8),
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (quest.status == QuestStatus.claimed) {
      // 已领取
      return SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all, size: 20, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '已领取奖励',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// 显示奖励对话框
  void _showRewardDialog(Map<String, dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              '任务奖励',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rewards['currency'] != null)
              _buildRewardItem('💰 货币', '${rewards['currency']}'),
            if (rewards['experience'] != null)
              _buildRewardItem('⭐ 经验', '${rewards['experience']}'),
            if (rewards['attributes'] != null)
              _buildRewardItem('💪 属性提升', ''),
            if (rewards['items'] != null)
              _buildRewardItem('🎁 获得物品', ''),
            if (rewards['skills'] != null)
              _buildRewardItem('📖 解锁技能', ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
            child: const Text('确定', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (value.isNotEmpty) ...[
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 显示放弃确认对话框
  Future<bool?> _showAbandonConfirmDialog(String questTitle) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              '确认放弃',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '确定要放弃任务 "$questTitle" 吗？\n放弃后需要重新接取。',
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.2),
              foregroundColor: Colors.white70,
            ),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认放弃'),
          ),
        ],
      ),
    );
  }
}
