# UI 组件快速参考

## 启动画面 (SplashScreen)

**位置**: `src/frontend/lib/screens/splash/splash_screen.dart`

### 特性
- 自动 3 秒跳转到主菜单
- 淡入 + 缩放动画
- 实时加载进度条

### 使用
```dart
// 默认作为启动页面
Navigator.pushNamed(context, '/');
```

---

## 主菜单 (MainMenuScreen)

**位置**: `src/frontend/lib/screens/menu/main_menu_screen.dart`

### 特性
- 5 个功能按钮
- 依次滑入动画
- 交互式对话框

### 菜单按钮
1. **继续游戏** - `/home`
2. **新游戏** - 确认对话框
3. **加载存档** - `/saves`
4. **设置** - 设置对话框
5. **关于** - 关于对话框

### 使用
```dart
Navigator.pushNamed(context, '/menu');
```

---

## 路由配置

### 可用路由
| 路由 | 组件 | 说明 |
|-----|------|------|
| `/` | `SplashScreen` | 启动画面 |
| `/menu` | `MainMenuScreen` | 主菜单 |
| `/home` | `HomeScreen` | 主界面 |
| `/saves` | `SavesScreen` | 存档界面 |
| `/quest` | `QuestScreen` | 任务界面 |
| `/shop` | `ShopScreen` | 商店界面 |
| `/story` | `StoryScreen` | 剧情界面 |

### 导航方法
```dart
// 跳转到指定路由
Navigator.pushNamed(context, '/menu');

// 替换当前路由
Navigator.pushReplacementNamed(context, '/home');

// 返回上一页
Navigator.pop(context);
```

---

## 主题配色 (AppColors)

**位置**: `src/frontend/lib/theme/app_colors.dart`

### 品牌色
```dart
AppColors.primary        // #FF6B00 (橙色)
AppColors.primaryLight   // #FF8C00
AppColors.primaryDark    // #E66000
```

### 背景色
```dart
AppColors.bgPrimary      // #1C1C1C (深灰)
AppColors.bgSecondary    // #282828
AppColors.bgCard         // #303030
```

### 文字色
```dart
AppColors.textPrimary    // #FFFFFF (白色)
AppColors.textSecondary  // #BBBBBB
AppColors.textDisabled   // #666666
```

### 状态色
```dart
AppColors.success        // #43A047 (绿色)
AppColors.warning        // #FF9800 (橙色)
AppColors.error          // #E53935 (红色)
AppColors.info           // #2196F3 (蓝色)
```

### 渐变效果
```dart
// 品牌渐变
const BoxDecoration(
  gradient: AppColors.brandGradient,
)

// 暗色背景
const BoxDecoration(
  gradient: AppColors.darkBgGradient,
)
```

---

## 对话框组件

### 新游戏确认对话框
```dart
_showNewGameDialog() {
  // 自动显示确认对话框
  // 点击"开始"后跳转到 /home
}
```

### 设置对话框
```dart
_showSettingsDialog() {
  // 显示当前设置（音效、背景音乐、振动）
  // 暂为静态显示，待实现实际逻辑
}
```

### 关于对话框
```dart
_showAboutDialog() {
  // 显示游戏版本和描述
}
```

---

## 自定义按钮样式

### 主按钮样式
```dart
Container(
  height: 64,
  decoration: BoxDecoration(
    gradient: AppColors.brandGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 15,
        offset: const Offset(0, 6),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Center(child: /* 内容 */),
    ),
  ),
)
```

### 卡片样式
```dart
Card(
  color: AppColors.bgCard,
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: /* 内容 */,
)
```

---

## 动画示例

### 淡入动画
```dart
AnimationController _controller = AnimationController(
  duration: const Duration(seconds: 2),
  vsync: this,
);

Animation<double> _fadeAnimation = Tween<double>(
  begin: 0.0,
  end: 1.0,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ),
);

FadeTransition(
  opacity: _fadeAnimation,
  child: /* 内容 */,
)
```

### 滑入动画
```dart
Animation<Offset> _slideAnimation = Tween<Offset>(
  begin: const Offset(0, 0.5),
  end: Offset.zero,
).animate(
  CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutBack,
  ),
);

SlideTransition(
  position: _slideAnimation,
  child: /* 内容 */,
)
```

---

## 常用布局

### 居中布局
```dart
Center(
  child: /* 内容 */,
)
```

### 列布局
```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    /* 子组件 1 */,
    const SizedBox(height: 16),
    /* 子组件 2 */,
  ],
)
```

### 横布局
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Icon(Icons.star),
    const SizedBox(width: 8),
    Text('文本'),
  ],
)
```

---

## 间距规范

- **页面内边距**: 24px（水平），20px（垂直）
- **主要元素间距**: 60px
- **中等元素间距**: 40px
- **小元素间距**: 16px
- **按钮高度**: 64px
- **卡片圆角**: 16px

---

## 快速开始新界面

### 1. 创建新界面文件
```dart
// src/frontend/lib/screens/your_screen/your_screen.dart

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class YourScreen extends StatelessWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: /* 内容 */,
    );
  }
}
```

### 2. 添加路由
```dart
// 在 app.dart 中添加路由
case '/your-route':
  return const YourScreen();
```

### 3. 使用主题色
```dart
Container(
  color: AppColors.primary,
  child: Text(
    '文本',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)
```

---

## 常见问题

### Q: 如何修改启动画面时间？
A: 在 `splash_screen.dart` 中修改 `Duration(seconds: 3)`

### Q: 如何添加新路由？
A: 在 `app.dart` 的 `_getRoute` 方法中添加新 case

### Q: 如何修改主题色？
A: 在 `theme/app_colors.dart` 中修改对应的颜色值

### Q: 如何调整动画效果？
A: 修改 `duration` 和 `curve` 参数

---

## 相关文档

- **UI 实现文档**: `docs/design/ui-screen-implementations.md`
- **配色方案**: `docs/design/color-palette.md`
- **开发总结**: `UI_DEVELOPMENT_SUMMARY.md`
- **完成报告**: `UI_ENGINEER_1_COMPLETION_REPORT.md`

---

**更新日期**: 2026-02-13
**维护人**: UI 开发工程师 1
