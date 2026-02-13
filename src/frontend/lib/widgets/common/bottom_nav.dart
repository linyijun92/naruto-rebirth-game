import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';

/// 底部导航栏组件
class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.orange.shade800,
            Colors.orange.shade900,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Consumer<NavigationProvider>(
          builder: (context, navProvider, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home,
                    label: '首页',
                    index: NavigationProvider.homeIndex,
                    currentIndex: navProvider.currentIndex,
                    onTap: () => navProvider.navigateToHome(),
                  ),
                  _NavItem(
                    icon: Icons.menu_book,
                    label: '剧情',
                    index: NavigationProvider.storyIndex,
                    currentIndex: navProvider.currentIndex,
                    onTap: () => navProvider.navigateToStory(),
                  ),
                  _NavItem(
                    icon: Icons.task_alt,
                    label: '任务',
                    index: NavigationProvider.questIndex,
                    currentIndex: navProvider.currentIndex,
                    onTap: () => navProvider.navigateToQuest(),
                  ),
                  _NavItem(
                    icon: Icons.store,
                    label: '商店',
                    index: NavigationProvider.shopIndex,
                    currentIndex: navProvider.currentIndex,
                    onTap: () => navProvider.navigateToShop(),
                  ),
                  _NavItem(
                    icon: Icons.person,
                    label: '个人',
                    index: NavigationProvider.profileIndex,
                    currentIndex: navProvider.currentIndex,
                    onTap: () => navProvider.navigateToProfile(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 导航项组件
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 4),
                decoration: isSelected
                    ? BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      )
                    : null,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.orange.shade200 : Colors.white70,
                  size: isSelected ? 28 : 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.orange.shade200 : Colors.white70,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
