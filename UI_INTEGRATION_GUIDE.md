# UI 组件集成示例

## 快速开始指南

### 1. 完整的应用入口示例

如果你想在用户登录后直接进入游戏主界面，可以修改 `app.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/game_home_screen.dart';
import 'providers/navigation_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 模拟初始化加载
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }

    // 检查是否有存档，如果有直接进入游戏主界面
    // 这里简化处理，直接进入游戏主界面
    return const GameHomeScreen();
  }
}
```

---

## 2. 使用底部导航栏示例

### 在主界面中使用

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/common/bottom_nav.dart';
import '../../providers/player_provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: _getCurrentScreen(navProvider.currentIndex),
          bottomNavigationBar: const BottomNav(),
        );
      },
    );
  }

  Widget _getCurrentScreen(int index) {
    switch (index) {
      case 0:
        return const GameHomeScreen();
      case 1:
        return const StoryScreen(); // 待实现
      case 2:
        return const QuestScreen(); // 待实现
      case 3:
        return const ShopScreen(); // 待实现
      case 4:
        return const ProfileScreen(); // 待实现
      default:
        return const GameHomeScreen();
    }
  }
}
```

---

## 3. 监听导航状态变化示例

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';

class NavigationListener extends StatefulWidget {
  const NavigationListener({super.key});

  @override
  State<NavigationListener> createState() => _NavigationListenerState();
}

class _NavigationListenerState extends State<NavigationListener> {
  int _previousIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        // 检测导航变化
        if (_previousIndex != navProvider.currentIndex && _previousIndex != -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onNavigationChanged(navProvider.currentIndex);
          });
        }
        _previousIndex = navProvider.currentIndex;

        return child!;
      },
      child: const Placeholder(), // 你的实际内容
    );
  }

  void _onNavigationChanged(int newIndex) {
    print('导航切换到: $newIndex');
    // 执行一些操作，如保存数据、加载新内容等
  }
}
```

---

## 4. 使用设置界面示例

### 从快捷按钮打开设置

```dart
InkWell(
  onTap: () {
    Navigator.of(context).pushNamed('/settings');
  },
  child: Container(
    child: Text('打开设置'),
  ),
);
```

### 等待设置关闭并获取结果

```dart
Future<void> _openSettings() async {
  final result = await Navigator.of(context).pushNamed('/settings');
  if (result != null) {
    // 处理设置返回结果
    print('设置已更新: $result');
  }
}
```

---

## 5. 访问玩家属性数据示例

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class PlayerAttributeDisplay extends StatelessWidget {
  const PlayerAttributeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('等级: ${playerProvider.level}'),
                Text('经验: ${playerProvider.experience}'),
                Text('货币: ${playerProvider.currency} ${AppConfig.currencyName}'),
                const Divider(),
                Text('查克拉: ${playerProvider.getAttribute('chakra')}'),
                Text('忍术: ${playerProvider.getAttribute('ninjutsu')}'),
                Text('体术: ${playerProvider.getAttribute('taijutsu')}'),
                Text('智力: ${playerProvider.getAttribute('intelligence')}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 6. 更新玩家数据示例

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/player_provider.dart';

class UpdatePlayerButton extends StatelessWidget {
  const UpdatePlayerButton({super.key});

  void _increaseExperience(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(
      context,
      listen: false,
    );
    playerProvider.addExperience(50);

    // 检查是否可以升级
    if (playerProvider.experience >= playerProvider.level * 100) {
      playerProvider.levelUp();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('恭喜升级！'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addCurrency(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(
      context,
      listen: false,
    );
    playerProvider.addCurrency(100);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _increaseExperience(context),
          child: const Text('增加经验'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _addCurrency(context),
          child: const Text('获得货币'),
        ),
      ],
    );
  }
}
```

---

## 7. 自定义地图卡片示例

如果你想添加自定义的地点，可以在 `game_home_screen.dart` 中修改地图区域：

```dart
Widget _buildMapArea() {
  return Container(
    // ... 其他代码
    child: GridView.count(
      crossAxisCount: 2,
      children: [
        // 现有地点
        _buildLocationCard(
          name: '木叶村',
          subtitle: '火之国忍村',
          icon: Icons.home_work,
          color: Colors.green,
          onTap: () => _showLocationDetail('木叶村'),
        ),

        // 添加新地点
        _buildLocationCard(
          name: '终结之谷',
          subtitle: '历史决战之地',
          icon: Icons.terrain,
          color: Colors.red,
          onTap: () => _showLocationDetail('终结之谷'),
        ),

        _buildLocationCard(
          name: '妙木山',
          subtitle: '仙术修行之地',
          icon: Icons.nature,
          color: Colors.lightGreen,
          onTap: () => _showLocationDetail('妙木山'),
        ),
        // ... 更多地点
      ],
    ),
  );
}
```

---

## 8. 主题颜色配置

如果你想更改应用的主题色，可以在 `main.dart` 中修改：

```dart
MaterialApp(
  title: AppConfig.appName,
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    // 主色调
    primaryColor: Colors.orange.shade800,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    // 自定义卡片颜色
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.1),
      elevation: 0,
    ),
    // 自定义按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
      ),
    ),
  ),
  home: const App(),
  routes: {
    '/settings': (context) => const SettingsScreen(),
  },
);
```

---

## 9. 设置项读写示例

```dart
import '../../services/hive_service.dart';

// 保存自定义设置
Future<void> saveCustomSetting() async {
  await HiveService.saveSetting('my_custom_key', 'my_value');
}

// 读取自定义设置
String loadCustomSetting() {
  return HiveService.getSetting('my_custom_key') ?? 'default_value';
}

// 批量保存设置
Future<void> saveMultipleSettings() async {
  await HiveService.saveSetting('setting1', 100);
  await HiveService.saveSetting('setting2', true);
  await HiveService.saveSetting('setting3', ['item1', 'item2']);
}
```

---

## 10. 完整的页面导航示例

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';

class NavigationExample extends StatelessWidget {
  const NavigationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('导航示例'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                final navProvider = Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                );
                navProvider.navigateToStory();
              },
              child: const Text('前往剧情'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final navProvider = Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                );
                navProvider.navigateToQuest();
              },
              child: const Text('前往任务'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final navProvider = Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                );
                navProvider.navigateToShop();
              },
              child: const Text('前往商店'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
              child: const Text('打开设置'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 常见问题

### Q: 如何更改底部导航栏的图标？
A: 在 `bottom_nav.dart` 中修改 `_NavItem` 组件的 `icon` 参数。

### Q: 如何添加新的设置项？
A: 在 `settings_screen.dart` 的 `build` 方法中添加新的 `_buildSection` 或设置项。

### Q: 如何保存游戏进度？
A: 使用 `HiveService.save()` 方法保存数据，或通过 `SaveProvider` 管理存档。

### Q: 如何自定义主题颜色？
A: 在 `main.dart` 的 `MaterialApp` 中配置 `theme` 参数。

---

## 下一步

1. 实现剧情、任务、商店、个人界面
2. 添加游戏逻辑和数据持久化
3. 实现地图地点的详情页面
4. 添加音效和背景音乐
5. 实现任务系统和奖励机制

祝开发顺利！🎮
