import 'package:flutter/material.dart';
import '../../widgets/common/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // 游戏标题
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    '重生到火影忍者世界',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // 开始新游戏按钮
                CustomButton(
                  text: '开始新游戏',
                  icon: Icons.play_arrow,
                  onPressed: () {
                    // TODO: 导航到游戏创建页面
                    _showComingSoonDialog('新游戏功能开发中...');
                  },
                ),

                const SizedBox(height: 20),

                // 继续游戏按钮
                CustomButton(
                  text: '继续游戏',
                  icon: Icons.restore,
                  onPressed: () {
                    // TODO: 导航到存档列表
                    _showComingSoonDialog('存档系统开发中...');
                  },
                ),

                const SizedBox(height: 20),

                // 设置按钮
                CustomButton(
                  text: '设置',
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: 导航到设置页面
                    _showComingSoonDialog('设置功能开发中...');
                  },
                ),

                const SizedBox(height: 20),

                // 关于按钮
                CustomButton(
                  text: '关于',
                  icon: Icons.info,
                  onPressed: () {
                    _showAboutDialog();
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('即将推出'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于游戏'),
        content: const Text(
          '重生到火影忍者世界 v1.0.0\n\n'
          '一款文字冒险游戏，带你体验火影忍者的世界。\n\n'
          '技术团队开发中...',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
