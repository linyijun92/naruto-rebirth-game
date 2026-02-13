/**
 * Jest Setup Configuration
 *
 * Global test setup and teardown for backend tests
 */

import { MongoMemoryServer } from 'mongodb-memory-server';
import mongoose from 'mongoose';

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

// Global variables for MongoDB memory server
let mongoServer: MongoMemoryServer;

// Mock process.exit to prevent tests from exiting
const originalExit = process.exit;

beforeAll(async () => {
  process.exit = jest.fn() as any;

  // Start MongoDB memory server
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  process.env.MONGODB_URI = uri;

  // Connect to MongoDB
  await mongoose.connect(uri);
});

afterAll(async () => {
  // Close MongoDB connection
  await mongoose.disconnect();

  // Stop MongoDB memory server
  await mongoServer.stop();

  process.exit = originalExit;
});

// Clear all collections after each test
afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    const collection = collections[key];
    await collection.deleteMany({});
  }
});
