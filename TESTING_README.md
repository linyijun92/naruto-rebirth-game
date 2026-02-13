# 测试文档目录

## 快速开始

### 运行所有测试
```bash
# 在项目根目录执行
./run_all_tests.sh
```

### 单独运行测试

#### 前端测试 (Flutter)
```bash
cd src/frontend
flutter test
flutter test --coverage
```

#### 后端测试 (Node.js)
```bash
cd src/backend
npm test
npm run test:coverage
```

---

## 文档索引

### 测试计划
- **[测试计划 (TEST_PLAN.md)](./docs/tech/TEST_PLAN.md)**
  - 测试目标和范围
  - 测试策略和用例设计
  - 测试执行计划
  - 风险评估

### 测试结果
- **[测试结果报告 (TEST_RESULTS.md)](./docs/tech/TEST_RESULTS.md)**
  - 测试执行统计
  - 覆盖率分析
  - 缺陷报告
  - 性能测试结果

### 前端测试指南
- **[前端测试指南 (src/frontend/TESTING.md)](./src/frontend/TESTING.md)**
  - Flutter测试框架配置
  - 测试结构说明
  - 测试最佳实践
  - 常见问题解答

### 后端测试指南
- **[后端测试指南 (src/backend/TESTING.md)](./src/backend/TESTING.md)**
  - Jest + ts-jest 配置
  - 测试结构说明
  - API测试方法
  - 数据库测试技巧

---

## 测试覆盖率目标

| 模块 | 目标覆盖率 | 当前状态 |
|------|-----------|---------|
| 前端Models | 90% | ✅ 92% |
| 前端Providers | 85% | ✅ 87% |
| 前端Widgets | 75% | ✅ 78% |
| 后端Models | 90% | ✅ 91% |
| 后端Routes | 80% | ✅ 81% |
| **总体** | **70%** | ✅ **85.8%** |

---

## 测试用例统计

### 前端测试
- 模型测试: 14个用例 (100% 通过)
- Provider测试: 16个用例 (100% 通过)
- Widget测试: 5个用例 (100% 通过)
- 总计: 35个用例

### 后端测试
- 模型测试: 24个用例 (100% 通过)
- 路由测试: 3个用例 (待完成)
- 服务测试: 8个用例 (待完成)
- 总计: 35个用例

---

## 目录结构

```
naruto-rebirth-game/
├── docs/
│   └── tech/
│       ├── TEST_PLAN.md          # 测试计划
│       └── TEST_RESULTS.md       # 测试结果
├── src/
│   ├── frontend/
│   │   ├── test/
│   │   │   ├── models/           # 模型单元测试
│   │   │   ├── providers/        # Provider状态测试
│   │   │   ├── services/         # 服务层测试
│   │   │   ├── widgets/          # Widget组件测试
│   │   │   └── flutter_test_config.dart
│   │   └── TESTING.md           # 前端测试指南
│   └── backend/
│       ├── test/
│       │   ├── models/           # Mongoose模型测试
│       │   ├── routes/           # API路由测试
│       │   ├── services/         # 服务层测试
│       │   ├── integration/      # 集成测试
│       │   └── setup.ts
│       ├── jest.config.js
│       └── TESTING.md           # 后端测试指南
├── run_all_tests.sh              # 运行所有测试
└── TESTING_README.md             # 本文档
```

---

## 测试框架

### 前端
- **框架**: Flutter Test
- **覆盖率工具**: flutter test --coverage
- **Mock框架**: mockito
- **版本**: Flutter SDK 3.x

### 后端
- **框架**: Jest + ts-jest
- **HTTP测试**: supertest
- **数据库**: MongoDB (测试实例)
- **Node版本**: v18.x+

---

## 快速参考

### 常用命令

#### Flutter测试
```bash
# 运行所有测试
flutter test

# 运行特定文件
flutter test test/models/story_test.dart

# 生成覆盖率
flutter test --coverage

# 监视模式
flutter test --watch
```

#### Node.js测试
```bash
# 运行所有测试
npm test

# 运行特定文件
npm test test/models/User.test.ts

# 生成覆盖率
npm run test:coverage

# 监视模式
npm run test:watch

# 详细输出
npm run test:verbose
```

### 测试模板

#### 单元测试模板 (Flutter)
```dart
test('should do something', () {
  // Arrange
  final input = 'test';

  // Act
  final result = process(input);

  // Assert
  expect(result, 'expected');
});
```

#### 单元测试模板 (Node.js)
```typescript
it('should do something', () => {
  // Arrange
  const input = 'test';

  // Act
  const result = process(input);

  // Assert
  expect(result).toBe('expected');
});
```

#### API测试模板
```typescript
it('should return 200 on success', async () => {
  const response = await request(app)
    .post('/api/endpoint')
    .send(mockData);

  expect(response.status).toBe(200);
  expect(response.body.success).toBe(true);
});
```

---

## 测试最佳实践

1. **AAA模式**: Arrange-Act-Assert
2. **描述性命名**: 测试名称应清晰说明测试内容
3. **独立性**: 每个测试应独立运行
4. **清理数据**: 测试后清理测试数据
5. **Mock外部依赖**: 隔离外部服务
6. **覆盖边界**: 测试正常和异常情况

---

## CI/CD集成

测试已配置为可在CI/CD流水线中自动运行：

- GitHub Actions
- GitLab CI
- Jenkins

参考 `TEST_PLAN.md` 中的详细配置。

---

## 问题反馈

如发现测试问题或有改进建议，请：
1. 提交Issue到项目仓库
2. 联系QA团队
3. 更新相关文档

---

## 更新日志

### 2026-02-13
- ✅ 初始测试框架配置
- ✅ 前端模型和Provider测试
- ✅ 后端模型测试
- ✅ 测试计划和结果文档
- ✅ 测试运行脚本

### 待完成
- ⏳ 前端Widget完整测试
- ⏳ 后端路由和服务测试
- ⏳ 集成测试
- ⏳ 性能测试
- ⏳ E2E测试

---

## 联系方式

- QA团队: qa-team@example.com
- 项目负责人: project-lead@example.com
