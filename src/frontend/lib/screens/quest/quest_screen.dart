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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuestList(QuestType.main),
          _buildQuestList(QuestType.side),
          _buildQuestList(QuestType.daily),
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

        // 获取活跃任务
        final activeQuests = questService.getActiveQuestList()
            .where((q) => q.type == type)
            .toList();

        // 获取可接取的任务
        final availableQuests = questService.getAvailableQuests(playerProvider.level)
            .where((q) => q.type == type)
            .toList();

        // 获取可领取奖励的任务
        final claimableQuests = questService.getClaimableQuests()
            .where((q) => q.type == type)
            .toList();

        // 合并所有任务
        final allQuests = [...claimableQuests, ...activeQuests, ...availableQuests];

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

  /// 构建空状态
  Widget _buildEmptyState(QuestType type) {
    String message;
    switch (type) {
      case QuestType.main:
        message = '暂无主线任务';
        break;
      case QuestType.side:
        message = '暂无支线任务';
        break;
      case QuestType.daily:
        message = '今日日常任务已完成';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
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

    switch (quest.status) {
      case QuestStatus.active:
        statusColor = Colors.blue;
        statusText = '进行中';
        break;
      case QuestStatus.completed:
        statusColor = Colors.green;
        statusText = '已完成';
        break;
      case QuestStatus.available:
        statusColor = Colors.orange;
        statusText = '可接取';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '未知';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和状态
            Row(
              children: [
                Expanded(
                  child: Text(
                    quest.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 描述
            Text(
              quest.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),

            if (quest.levelRequirement > 1) ...[
              const SizedBox(height: 8),
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

            const SizedBox(height: 12),

            // 进度条
            if (quest.isActive)
              _buildProgressBar(quest),

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
            const Text(
              '进度',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              '${(quest.progress * 100).toInt()}%',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: quest.progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 构建任务目标
  Widget _buildObjectives(Quest quest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务目标',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        ...quest.objectives.map((objective) {
          final isCompleted = objective.isCompleted;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 16,
                  color: isCompleted ? Colors.green : Colors.white70,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective.description,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.white,
                      fontSize: 13,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  '${objective.current}/${objective.target}',
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontSize: 13,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '奖励',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: quest.rewards.map((reward) {
            String icon;
            switch (reward.type) {
              case RewardType.currency:
                icon = '💰';
                break;
              case RewardType.experience:
                icon = '⭐';
                break;
              case RewardType.item:
                icon = '🎁';
                break;
              case RewardType.attribute:
                icon = '💪';
                break;
              case RewardType.skill:
                icon = '📖';
                break;
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(icon),
                  const SizedBox(width: 4),
                  Text(
                    '${reward.name} x${reward.amount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
        child: ElevatedButton(
          onPressed: () async {
            try {
              final rewards = await questService.claimReward(
                quest.questId,
                playerProvider,
              );
              _showRewardDialog(rewards);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('领取奖励失败: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('领取奖励'),
        ),
      );
    } else if (quest.canAccept) {
      // 可接取
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final success = await questService.acceptQuest(
              quest.questId,
              playerProvider,
            );
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('接取任务失败')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('接取任务'),
        ),
      );
    } else if (quest.isActive && quest.type != QuestType.main) {
      // 进行中且非主线任务，可以放弃
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                questService.abandonQuest(quest.questId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('放弃任务'),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// 显示奖励对话框
  void _showRewardDialog(Map<String, dynamic> rewards) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange),
            SizedBox(width: 8),
            Text('任务奖励'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rewards['currency'] != null)
              Text('💰 货币: ${rewards['currency']}'),
            if (rewards['experience'] != null)
              Text('⭐ 经验: ${rewards['experience']}'),
            if (rewards['attributes'] != null)
              Text('💪 属性提升'),
            if (rewards['items'] != null)
              Text('🎁 获得物品'),
            if (rewards['skills'] != null)
              Text('📖 解锁技能'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
