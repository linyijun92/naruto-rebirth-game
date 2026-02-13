# 前端项目 - Flutter

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # App根组件
├── config/
│   ├── api_config.dart          # API配置
│   └── app_config.dart          # 应用配置
├── core/
│   ├── constants/
│   │   ├── app_constants.dart  # 应用常量
│   │   └── storage_keys.dart   # 存储键
│   ├── utils/
│   │   ├── logger.dart         # 日志工具
│   │   └── validator.dart      # 验证工具
│   └── network/
│       ├── api_client.dart     # API客户端
│       ├── api_exception.dart  # 异常处理
│       └── interceptors/       # 请求拦截器
├── data/
│   ├── models/                  # 数据模型
│   │   ├── player.dart         # 玩家模型
│   │   ├── save.dart           # 存档模型
│   │   ├── story.dart          # 剧情模型
│   │   ├── quest.dart          # 任务模型
│   │   └── item.dart           # 物品模型
│   ├── repositories/            # 数据仓库
│   │   ├── save_repository.dart
│   │   ├── story_repository.dart
│   │   └── player_repository.dart
│   └── datasources/             # 数据源
│       ├── local/
│       │   └── save_local_datasource.dart
│       └── remote/
│           └── save_remote_datasource.dart
├── domain/
│   ├── entities/                # 领域实体
│   │   ├── player.dart
│   │   └── save.dart
│   └── usecases/                # 用例
│       ├── load_save.dart
│       ├── save_game.dart
│       └── sync_save.dart
├── providers/                   # 状态管理
│   ├── game_provider.dart       # 游戏状态
│   ├── player_provider.dart     # 玩家状态
│   ├── story_provider.dart      # 剧情状态
│   └── save_provider.dart       # 存档状态
├── screens/                     # 页面
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── game/
│   │   ├── story_screen.dart   # 剧情页面
│   │   ├── menu_screen.dart    # 游戏菜单
│   │   └── shop_screen.dart    # 商店页面
│   ├── save/
│   │   ├── save_list_screen.dart
│   │   └── save_detail_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/                     # 通用组件
│   ├── common/
│   │   ├── custom_button.dart
│   │   ├── dialog_box.dart
│   │   └── loading_indicator.dart
│   ├── game/
│   │   ├── story_card.dart
│   │   ├── attribute_bar.dart
│   │   └── choice_button.dart
│   └── ui/
│       ├── app_bar.dart
│       └── bottom_nav.dart
├── services/                     # 服务
│   ├── storage_service.dart     # 本地存储服务
│   ├── audio_service.dart       # 音频服务
│   └── hive_service.dart        # Hive服务
└── routes/                      # 路由
    └── app_routes.dart

test/                           # 测试
```

## 开发指南

### 环境要求
- Flutter SDK: 3.x
- Dart: 3.x
- Android Studio / VS Code

### 安装依赖
```bash
flutter pub get
```

### 运行项目
```bash
flutter run
```

### 代码生成
```bash
flutter pub run build_runner build
```

### 测试
```bash
flutter test
```

## 核心功能模块

### 1. 存档系统
- 本地存档（Hive）
- 云端同步（API）
- 自动/手动存档

### 2. 剧情引擎
- 剧情节点展示
- 分支选择
- 多结局路由

### 3. 属性系统
- 查克拉、忍术、体术、智力
- 属性增长与检查

### 4. 任务系统
- 主线/支线/日常任务
- 任务进度追踪

### 5. 商店系统
- 物品购买
- 库存管理

## 技术栈

- **框架**: Flutter
- **语言**: Dart
- **状态管理**: Provider/Riverpod
- **本地存储**: Hive
- **网络请求**: Dio
- **代码生成**: json_serializable, hive_generator
