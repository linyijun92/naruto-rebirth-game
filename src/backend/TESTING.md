# 后端测试指南

## 测试框架配置

本项目使用 Jest + ts-jest 作为测试框架，配置文件位于 `jest.config.js`。

## 测试结构

```
test/
├── models/           # Mongoose模型单元测试
│   ├── User.test.ts
│   ├── Save.test.ts
│   └── StoryNode.test.ts
├── routes/           # API路由测试
│   └── player.test.ts
├── services/         # 服务层测试
│   └── storyService.test.ts
├── integration/      # 集成测试
│   └── (待添加)
└── setup.ts          # 测试环境配置
```

## 运行测试

### 运行所有测试
```bash
npm test
```

### 运行特定测试文件
```bash
npm test test/models/User.test.ts
```

### 运行特定测试模式
```bash
npm test -- User.model
```

### 生成覆盖率报告
```bash
npm run test:coverage
```

覆盖率报告将生成在 `coverage/` 目录，查看HTML报告：

```bash
# macOS
open coverage/lcov-report/index.html

# Linux
xdg-open coverage/lcov-report/index.html
```

### 监视模式
```bash
npm run test:watch
```

### 详细输出
```bash
npm run test:verbose
```

## 测试类型

### 单元测试
测试独立的函数、类和方法，隔离外部依赖。

```typescript
describe('Calculator', () => {
  it('should add two numbers', () => {
    const result = add(2, 3);
    expect(result).toBe(5);
  });
});
```

### 集成测试
测试多个组件之间的交互，包括数据库操作。

```typescript
describe('User API', () => {
  it('should create a new user', async () => {
    const response = await request(app)
      .post('/api/auth/register')
      .send({ username: 'test', email: 'test@test.com', password: '123456' });

    expect(response.status).toBe(201);
    expect(response.body.data.username).toBe('test');
  });
});
```

### API测试
使用 supertest 测试HTTP端点。

```typescript
import request from 'supertest';

describe('GET /api/player/:id', () => {
  it('should return player data', async () => {
    const response = await request(app).get('/api/player/123');

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});
```

## 测试最佳实践

### 1. Arrange-Act-Assert模式
```typescript
it('should update player attributes', async () => {
  // Arrange - 准备测试数据
  const player = await Player.create(mockPlayerData);
  const updateData = { attributes: { chakra: 110 } };

  // Act - 执行操作
  const response = await request(app)
    .put(`/api/player/${player.playerId}`)
    .send(updateData);

  // Assert - 验证结果
  expect(response.status).toBe(200);
  expect(response.body.data.attributes.chakra).toBe(110);
});
```

### 2. 使用描述性的测试名称
```typescript
it('should return 404 for non-existent user', () => { });
it('should validate email format', () => { });
it('should enforce unique username constraint', () => { });
```

### 3. 清理测试数据
```typescript
describe('User Model', () => {
  afterEach(async () => {
    await User.deleteMany({});
  });

  it('should create user', async () => {
    const user = await User.create(mockUser);
    expect(user).toBeDefined();
  });
});
```

### 4. 使用测试数据库
```typescript
beforeAll(async () => {
  const mongoUri = process.env.MONGODB_URI_TEST || 'mongodb://localhost:27017/test';
  await mongoose.connect(mongoUri);
});

afterAll(async () => {
  await mongoose.connection.close();
});
```

## Mock和Stub

### 使用Jest Mock
```typescript
// Mock函数
const mockFn = jest.fn();
mockFn('arg1');
expect(mockFn).toHaveBeenCalledWith('arg1');

// Mock返回值
const mockService = {
  fetchData: jest.fn().mockResolvedValue({ data: 'test' })
};

// Mock实现
const mockApi = jest.fn().mockImplementation(() => {
  return { id: '123', name: 'test' };
});
```

### Supertest Mock Response
```typescript
const response = await request(app)
  .post('/api/player')
  .send(mockData)
  .expect(201);

expect(response.body.data).toMatchObject({
  playerId: expect.any(String),
  username: mockData.username,
});
```

## 异步测试

### 处理Promise
```typescript
it('should fetch data asynchronously', async () => {
  const data = await service.fetchData();
  expect(data).toBeDefined();
});
```

### 处理错误
```typescript
it('should throw error for invalid input', async () => {
  await expect(service.processData(null)).rejects.toThrow();
});
```

### 超时处理
```typescript
it('should timeout after 5 seconds', async () => {
  await expect(
    slowOperation(),
  ).resolves.toBe('result');
}, 10000); // 10秒超时
```

## 数据库测试

### 使用测试数据库
```typescript
beforeAll(async () => {
  await mongoose.connect('mongodb://localhost:27017/naruto-test', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });
});

afterAll(async () => {
  await mongoose.connection.dropDatabase();
  await mongoose.connection.close();
});
```

### 填充测试数据
```typescript
const createTestData = async () => {
  return await Promise.all([
    User.create(mockUser1),
    User.create(mockUser2),
    Save.create(mockSave),
  ]);
};
```

### 清理数据
```typescript
afterEach(async () => {
  await User.deleteMany({});
  await Save.deleteMany({});
});
```

## 覆盖率目标

| 模块 | 行覆盖率 | 分支覆盖率 | 函数覆盖率 |
|------|---------|-----------|-----------|
| Models | 90% | 85% | 90% |
| Routes | 80% | 75% | 80% |
| Services | 85% | 80% | 85% |
| **总体** | **70%** | **65%** | **70%** |

## 测试配置详解

### jest.config.js
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src', '<rootDir>/test'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/index.ts',
    '!src/**/*.d.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
};
```

## CI/CD集成

### GitHub Actions示例
```yaml
name: Backend Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mongodb:
        image: mongo:6.0
        ports:
          - 27017:27017
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm ci
      - run: npm run test:coverage
      - uses: codecov/codecov-action@v3
```

## 常见问题

### Q: 如何跳过某个测试？
A: 使用 `.skip()`：
```typescript
it.skip('should do something', () => {
  // 此测试将被跳过
});
```

### Q: 如何只运行某个测试？
A: 使用 `.only()`：
```typescript
it.only('should do this', () => {
  // 只运行此测试
});
```

### Q: 如何测试抛出异常的函数？
A: 使用 `toThrow()`：
```typescript
expect(() => riskyOperation()).toThrow(Error);
await expect(asyncOperation()).rejects.toThrow();
```

### Q: 如何处理异步超时？
A: 在 `jest.config.js` 中设置或使用 `jest.setTimeout()`：
```typescript
jest.setTimeout(10000); // 10秒
```

## 参考资源

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [ts-jest Documentation](https://kulshekhar.github.io/ts-jest/)
- [Supertest Documentation](https://github.com/visionmedia/supertest)
- [MongoDB Testing Best Practices](https://mongoosejs.com/docs/jest.html)
