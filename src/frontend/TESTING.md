# 前端测试指南

## 测试框架配置

本项目使用 Flutter Test 作为测试框架，配置文件位于 `test/flutter_test_config.dart`。

## 测试结构

```
test/
├── models/           # 数据模型单元测试
│   ├── story_test.dart
│   └── save_test.dart
├── providers/        # Provider 状态管理测试
│   ├── game_provider_test.dart
│   └── player_provider_test.dart
├── services/         # 服务层测试
│   └── (待添加)
└── widgets/          # Widget 组件测试
    └── splash_screen_test.dart
```

## 运行测试

### 运行所有测试
```bash
flutter test
```

### 运行特定测试文件
```bash
flutter test test/models/story_test.dart
```

### 运行特定测试组
```bash
flutter test --name "StoryNode Model Tests"
```

### 生成覆盖率报告
```bash
flutter test --coverage
```

覆盖率报告将生成在 `coverage/lcov.info`，可以使用以下命令查看HTML报告：

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### 监视模式
```bash
flutter test --watch
```

## 测试类型

### 单元测试
测试独立的函数、类和方法，不依赖Flutter框架。

```dart
test('should calculate sum correctly', () {
  final result = sum(2, 3);
  expect(result, 5);
});
```

### Widget测试
测试Widget的渲染和交互，模拟UI操作。

```dart
testWidgets('should display text', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Hello'), findsOneWidget);
});
```

### 集成测试
测试完整的用户流程，需要设备或模拟器。

```bash
flutter drive --target=test_driver/app.dart
```

## 测试最佳实践

### 1. Arrange-Act-Assert模式
```dart
test('should update player level', () {
  // Arrange - 准备测试数据
  final provider = PlayerProvider();
  final initialLevel = provider.level;

  // Act - 执行操作
  provider.levelUp();

  // Assert - 验证结果
  expect(provider.level, initialLevel + 1);
});
```

### 2. 使用描述性的测试名称
```dart
test('should pause game when pauseGame is called', () { });
test('should return 0 for non-existent attribute', () { });
```

### 3. 测试正常和异常情况
```dart
test('should add positive amount to currency', () { });
test('should not spend more currency than available', () { });
```

### 4. 使用Mock对象隔离依赖
```dart
class MockApiService extends Mock implements ApiService {}

test('should load data successfully', () async {
  final mockApi = MockApiService();
  when(mockApi.fetchData()).thenAnswer((_) async => mockData);

  // test with mockApi
});
```

## 测试配置选项

### 常用命令行参数

```bash
--platform=<platform>           # 指定测试平台
--dart-define=<key=value>       # 定义环境变量
--timeout=<seconds>             # 设置超时时间
--plain-name=<pattern>          # 匹配测试名称
--reporter=<reporter>           # 指定报告格式
```

### 示例
```bash
# 指定超时时间为2分钟
flutter test --timeout=120

# 只运行名称包含 "Player" 的测试
flutter test --plain-name="Player"

# 使用compact报告格式
flutter test --reporter=compact
```

## 覆盖率目标

| 模块 | 目标覆盖率 |
|------|-----------|
| Models | 90% |
| Providers | 85% |
| Services | 80% |
| Widgets | 75% |
| **总体** | **70%** |

## 常见问题

### Q: 测试运行失败怎么办？
A: 检查以下几点：
1. 确保所有依赖已正确安装 (`flutter pub get`)
2. 检查测试代码中的语法错误
3. 查看详细的错误日志 (`flutter test --verbose`)

### Q: 如何测试异步代码？
A: 使用 `async/await` 并确保异步操作完成：
```dart
test('should load data asynchronously', () async {
  final data = await apiService.fetchData();
  expect(data, isNotNull);
});
```

### Q: Widget测试中如何等待动画完成？
A: 使用 `pumpAndSettle()`：
```dart
await tester.pumpWidget(MyWidget());
await tester.pumpAndSettle(); // 等待所有动画完成
```

## CI/CD集成

在GitHub Actions中运行测试：

```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

## 参考资源

- [Flutter Testing Documentation](https://docs.flutter.dev/cookbook/testing)
- [flutter_test Package](https://pub.dev/packages/flutter_test)
- [Testing Cheatsheet](https://flutter.dev/docs/cookbook/testing/cheatsheet)
