/**
 * Jest Setup Configuration
 *
 * Global test setup and teardown for backend tests
 */

// Mock console methods to reduce noise in test output
global.console = {
  ...console,
  log: jest.fn(),
  debug: jest.fn(),
  info: jest.fn(),
  warn: jest.fn(),
};

// Increase timeout for database operations
jest.setTimeout(10000);

// Setup environment variables for testing
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-secret-key-for-testing';
process.env.MONGODB_URI = 'mongodb://localhost:27017/naruto-rebirth-test';

// Mock process.exit to prevent tests from exiting
const originalExit = process.exit;
beforeAll(() => {
  process.exit = jest.fn() as any;
});

afterAll(() => {
  process.exit = originalExit;
});
