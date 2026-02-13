# 前端开发指南

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart 3.x
- **状态管理**: Provider/Riverpod
- **本地存储**: Hive
- **网络请求**: Dio
- **代码生成**: json_serializable, hive_generator

---

## 开发环境设置

### 1. 安装Flutter

```bash
# 下载Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# 添加到环境变量
export PATH="$PATH:`pwd`/flutter/bin"

# 验证安装
flutter doctor
```

### 2. 安装依赖

```bash
cd src/frontend
flutter pub get
```

### 3. 配置IDE

推荐使用 VS Code + Flutter 插件，或 Android Studio + Flutter 插件。

---

## 项目结构说明

```
lib/
├── main.dart              # 应用入口
├── app.dart               # App根组件
├── config/                # 配置文件
│   ├── api_config.dart    # API配置
│   └── app_config.dart    # 应用配置
├── core/                  # 核心模块
│   ├── constants/         # 常量定义
│   ├── utils/             # 工具类
│   └── network/           # 网络模块
├── data/                  # 数据层
│   ├── models/            # 数据模型
│   ├── repositories/      # 数据仓库
│   └── datasources/       # 数据源
├── domain/                # 领域层
│   ├── entities/          # 业务实体
│   └── usecases/          # 业务用例
├── providers/             # 状态管理
├── screens/               # 页面
├── widgets/               # 组件
├── services/              # 服务
└── routes/                # 路由
```

---

## 开发规范

### 命名规范

**文件命名**: `snake_case.dart`
```dart
// ✅ 正确
save_screen.dart
custom_button.dart

// ❌ 错误
SaveScreen.dart
Custom-Button.dart
```

**类命名**: `PascalCase`
```dart
// ✅ 正确
class SaveScreen {}
class CustomButton {}

// ❌ 错误
class saveScreen {}
class custom_button {}
```

**变量命名**: `camelCase`
```dart
// ✅ 正确
final String playerName;
int playerLevel;

// ❌ 错误
final String PlayerName;
int player_level;
```

**常量命名**: `lowerCamelCase` 或 `UPPER_SNAKE_CASE`
```dart
// ✅ 正确
const int maxSaveSlots = 10;
const String API_BASE_URL = 'https://api.example.com';

// ❌ 错误
const int MaxSaveSlots = 10;
const String apiBaseUrl = 'https://api.example.com';
```

**私有成员**: `_camelCase`
```dart
class SaveProvider {
  String _saveName;  // 私有成员

  String get saveName => _saveName;  // 公开getter
}
```

### 代码格式化

使用官方格式化工具：
```bash
flutter format .
```

配置 `.editorconfig` 和 `.analysis_options` 自动格式化。

### 注释规范

**文档注释**: `///`
```dart
/// 加载存档数据
///
/// 返回 [Save] 对象，如果存档不存在则抛出异常。
Future<Save> loadSave(String saveId) async {
  // ...
}
```

**单行注释**: `//`
```dart
// 初始化Hive数据库
await HiveService.init();
```

### Import 顺序

1. Dart SDK
2. Flutter SDK
3. 第三方包
4. 项目内部文件

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/save.dart';
import '../providers/game_provider.dart';
```

---

## 状态管理最佳实践

### Provider 使用示例

**1. 创建Provider**
```dart
class SaveProvider extends ChangeNotifier {
  List<Save> _saves = [];
  bool _isLoading = false;

  List<Save> get saves => _saves;
  bool get isLoading => _isLoading;

  Future<void> loadSaves() async {
    _isLoading = true;
    notifyListeners();

    try {
      _saves = await _saveRepository.getSaves();
    } catch (e) {
      // 处理错误
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**2. 使用Provider**
```dart
// 在 Widget 中使用
class SaveListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final saveProvider = Provider.of<SaveProvider>(context);

    return ListView.builder(
      itemCount: saveProvider.saves.length,
      itemBuilder: (context, index) {
        return SaveCard(save: saveProvider.saves[index]);
      },
    );
  }
}
```

**3. 修改状态**
```dart
void _addSave() {
  final saveProvider = Provider.of<SaveProvider>(context, listen: false);
  saveProvider.addSave(newSave);
}
```

---

## 网络请求最佳实践

### API客户端封装

```dart
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: ApiConfig.connectTimeout,
    receiveTimeout: ApiConfig.receiveTimeout,
  ));

  Future<T> get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data['data'] as T;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

### 错误处理

```dart
Exception _handleError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return Exception('连接超时');
    case DioExceptionType.receiveTimeout:
      return Exception('响应超时');
    case DioExceptionType.badResponse:
      return Exception(error.response?.data['message'] ?? '请求失败');
    default:
      return Exception('网络错误');
  }
}
```

---

## 本地存储最佳实践

### Hive 使用示例

```dart
// 初始化
await Hive.initFlutter();
await Hive.openBox('saves');

// 保存数据
await box.put('save_001', saveData);

// 读取数据
final saveData = box.get('save_001');

// 删除数据
await box.delete('save_001');
```

---

## UI 组件开发

### 自定义 Widget 模板

```dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 调试技巧

### 1. 使用 Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 2. 日志输出

```dart
import 'package:flutter/foundation.dart';

void main() {
  debugPrint('Debug message');
}
```

### 3. 热重载

- **热重载**: `r` (保持应用状态)
- **热重启**: `R` (重置应用状态)

---

## 测试

### 单元测试

```dart
void main() {
  test('SaveProvider should add save', () {
    final provider = SaveProvider();
    provider.addSave(testSave);

    expect(provider.saves.length, 1);
  });
}
```

### Widget 测试

```dart
void main() {
  testWidgets('CustomButton should display text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomButton(
          text: 'Test',
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## 性能优化

### 1. 使用 const 构造函数

```dart
// ✅ 正确
const Text('Hello');

// ❌ 错误
Text('Hello');
```

### 2. 懒加载

```dart
// 使用 FutureBuilder 或 ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
)
```

### 3. 图片优化

```dart
// 缓存图片
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

---

## 常见问题

### 1. 状态不更新

确保在修改状态后调用 `notifyListeners()`：
```dart
void updateState() {
  _state = newState;
  notifyListeners();  // 不要忘记这行！
}
```

### 2. 内存泄漏

及时释放资源：
```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 3. 构建卡顿

- 使用 `ListView.builder` 而不是 `ListView`
- 避免在 build 方法中进行耗时操作
- 使用 `const` 减少重建

---

## 参考资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Dart 语言指南](https://dart.dev/guides)
- [Provider 文档](https://pub.dev/packages/provider)
- [Hive 文档](https://pub.dev/packages/hive)

---

**文档版本**: v1.0
**最后更新**: 2026-02-13
**维护者**: 技术团队
