import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimations = List.generate(
      5,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkBgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 游戏标题
                  _buildTitle(),
                  const SizedBox(height: 60),
                  // 菜单按钮
                  _buildMenuButtons(),
                  const SizedBox(height: 40),
                  // 版本信息
                  _buildVersionInfo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.flash_on,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '重生到火影忍者世界',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: AppColors.primary,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          child: const Text(
            '火之意志，永不熄灭',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primaryLight,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButtons() {
    final menuItems = [
      {
        'text': '继续游戏',
        'icon': Icons.play_arrow,
        'onTap': () => Navigator.pushNamed(context, '/home'),
        'enabled': true,
      },
      {
        'text': '新游戏',
        'icon': Icons.refresh,
        'onTap': () => _showNewGameDialog(),
        'enabled': true,
      },
      {
        'text': '加载存档',
        'icon': Icons.folder_open,
        'onTap': () => Navigator.pushNamed(context, '/saves'),
        'enabled': true,
      },
      {
        'text': '设置',
        'icon': Icons.settings,
        'onTap': () => _showSettingsDialog(),
        'enabled': true,
      },
      {
        'text': '关于',
        'icon': Icons.info_outline,
        'onTap': () => _showAboutDialog(),
        'enabled': true,
      },
    ];

    return Column(
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMenuButton(
                  text: item['text'] as String,
                  icon: item['icon'] as IconData,
                  onTap: item['onTap'] as VoidCallback,
                  enabled: item['enabled'] as bool,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildMenuButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        gradient: enabled ? AppColors.brandGradient : null,
        color: enabled ? null : AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
        border: Border.all(
          color: enabled
              ? Colors.transparent
              : AppColors.textDisabled.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.3),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled ? Colors.white : AppColors.textDisabled,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: TextStyle(
                    color: enabled ? Colors.white : AppColors.textDisabled,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'v1.0.0 | Alpha',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textDisabled,
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '开始新游戏',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要开始新的冒险吗？当前进度将不会被保存。',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '取消',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home');
              },
              child: const Text(
                '开始',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '音效：开启',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '背景音乐：开启',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '振动：开启',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '关闭',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '关于',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '重生到火影忍者世界',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '版本：v1.0.0 Alpha',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '一款基于火影忍者世界的文字冒险游戏',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '火之意志，永不熄灭',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '关闭',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
