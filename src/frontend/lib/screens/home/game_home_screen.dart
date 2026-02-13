import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../config/app_config.dart';

/// 游戏主界面
class GameHomeScreen extends StatefulWidget {
  const GameHomeScreen({super.key});

  @override
  State<GameHomeScreen> createState() => _GameHomeScreenState();
}

class _GameHomeScreenState extends State<GameHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF4a148c),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部玩家信息栏
              _buildPlayerInfoBar(),

              // 主内容区域
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 左侧：属性快速预览
                      Expanded(
                        flex: 1,
                        child: _buildAttributesPanel(),
                      ),

                      const SizedBox(width: 16),

                      // 中间：地图区域
                      Expanded(
                        flex: 3,
                        child: _buildMapArea(),
                      ),

                      const SizedBox(width: 16),

                      // 右侧：快捷功能按钮
                      Expanded(
                        flex: 1,
                        child: _buildQuickActions(),
                      ),
                    ],
                  ),
                ),
              ),

              // 底部导航栏
              const BottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建顶部玩家信息栏
  Widget _buildPlayerInfoBar() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade700,
                Colors.orange.shade900,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 头像
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.orange.shade300,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // 玩家信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '火影忍者',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.military_tech,
                                color: Colors.yellow,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lv.${playerProvider.level}',
                                style: const TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 经验条
                    _buildExperienceBar(playerProvider),
                  ],
                ),
              ),

              // 货币显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.yellow,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${playerProvider.currency}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建经验条
  Widget _buildExperienceBar(PlayerProvider playerProvider) {
    final expToNextLevel = playerProvider.level * 100;
    final progress = (playerProvider.experience % expToNextLevel) / expToNextLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            Text(
              '${playerProvider.experience % expToNextLevel} / $expToNextLevel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  /// 构建左侧属性面板
  Widget _buildAttributesPanel() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              const Row(
                children: [
                  Icon(
                    Icons.stars,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '属性',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 属性列表
              Expanded(
                child: ListView(
                  children: [
                    _buildAttributeItem(
                      name: '查克拉',
                      value: playerProvider.getAttribute('chakra'),
                      icon: Icons.flash_on,
                      color: Colors.blue,
                      maxValue: 999,
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeItem(
                      name: '忍术',
                      value: playerProvider.getAttribute('ninjutsu'),
                      icon: Icons.auto_fix_high,
                      color: Colors.purple,
                      maxValue: 999,
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeItem(
                      name: '体术',
                      value: playerProvider.getAttribute('taijutsu'),
                      icon: Icons.fitness_center,
                      color: Colors.red,
                      maxValue: 999,
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeItem(
                      name: '智力',
                      value: playerProvider.getAttribute('intelligence'),
                      icon: Icons.psychology,
                      color: Colors.green,
                      maxValue: 999,
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeItem(
                      name: '速度',
                      value: playerProvider.getAttribute('speed'),
                      icon: Icons.speed,
                      color: Colors.cyan,
                      maxValue: 999,
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeItem(
                      name: '幸运',
                      value: playerProvider.getAttribute('luck'),
                      icon: Icons.casino,
                      color: Colors.amber,
                      maxValue: 999,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建属性项
  Widget _buildAttributeItem({
    required String name,
    required int value,
    required IconData icon,
    required Color color,
    required int maxValue,
  }) {
    final progress = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
            Text(
              '$value',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  /// 构建中间地图区域
  Widget _buildMapArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 地图标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade700.withOpacity(0.3),
                  Colors.orange.shade900.withOpacity(0.3),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.map,
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  '世界地图',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 地图内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildLocationCard(
                    name: '木叶村',
                    subtitle: '火之国忍村',
                    icon: Icons.home_work,
                    color: Colors.green,
                    onTap: () => _showLocationDetail('木叶村'),
                  ),
                  _buildLocationCard(
                    name: '砂隐村',
                    subtitle: '风之国忍村',
                    icon: Icons.wb_sunny,
                    color: Colors.amber,
                    onTap: () => _showLocationDetail('砂隐村'),
                  ),
                  _buildLocationCard(
                    name: '雾隐村',
                    subtitle: '水之国忍村',
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    onTap: () => _showLocationDetail('雾隐村'),
                  ),
                  _buildLocationCard(
                    name: '云隐村',
                    subtitle: '雷之国忍村',
                    icon: Icons.cloud,
                    color: Colors.cyan,
                    onTap: () => _showLocationDetail('云隐村'),
                  ),
                  _buildLocationCard(
                    name: '岩隐村',
                    subtitle: '土之国忍村',
                    icon: Icons.landscape,
                    color: Colors.brown,
                    onTap: () => _showLocationDetail('岩隐村'),
                  ),
                  _buildLocationCard(
                    name: '音隐村',
                    subtitle: '田之国忍村',
                    icon: Icons.music_note,
                    color: Colors.purple,
                    onTap: () => _showLocationDetail('音隐村'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建地点卡片
  Widget _buildLocationCard({
    required String name,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建右侧快捷功能按钮
  Widget _buildQuickActions() {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              const Row(
                children: [
                  Icon(
                    Icons.apps,
                    color: Colors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '快捷功能',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 快捷按钮
              _buildQuickActionButton(
                icon: Icons.menu_book,
                label: '剧情',
                color: Colors.purple,
                onTap: () => navProvider.navigateToStory(),
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.task_alt,
                label: '任务',
                color: Colors.blue,
                onTap: () => navProvider.navigateToQuest(),
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.store,
                label: '商店',
                color: Colors.green,
                onTap: () => navProvider.navigateToShop(),
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.psychology,
                label: '属性',
                color: Colors.amber,
                onTap: () {
                  // TODO: 导航到属性页面
                },
              ),
              const SizedBox(height: 12),
              _buildQuickActionButton(
                icon: Icons.settings,
                label: '设置',
                color: Colors.grey,
                onTap: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              ),

              const Spacer(),

              // 通知区域
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade600.withOpacity(0.3),
                      Colors.orange.shade800.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade400.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '新任务！',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '前往木叶村接取',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建快捷功能按钮
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示地点详情对话框
  void _showLocationDetail(String locationName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.orange),
            const SizedBox(width: 8),
            Text(locationName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '这里是火影忍者世界的重要地点。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              '探索等级要求：Lv.1',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '可执行操作：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• 浏览地图'),
            const Text('• 接取任务'),
            const Text('• 访问商店'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 导航到地点详情页
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('正在前往 $locationName...'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('前往'),
          ),
        ],
      ),
    );
  }
}
