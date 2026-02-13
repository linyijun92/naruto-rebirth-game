import User, { IUser } from '../../src/models/User';

describe('User Model', () => {
  describe('Schema Validation', () => {
    it('should create a valid user', async () => {
      const validUser = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      const savedUser = await validUser.save();

      expect(savedUser.userId).toBe('user_123');
      expect(savedUser.username).toBe('narutofan');
      expect(savedUser.email).toBe('naruto@konoha.com');
      expect(savedUser.password).toBe('password123');
      expect(savedUser.createdAt).toBeDefined();
      expect(savedUser.updatedAt).toBeDefined();
    });

    it('should require userId field', async () => {
      const invalidUser = new User({
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await expect(invalidUser.save()).rejects.toThrow();
    });

    it('should require username field', async () => {
      const invalidUser = new User({
        userId: 'user_123',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await expect(invalidUser.save()).rejects.toThrow();
    });

    it('should require email field', async () => {
      const invalidUser = new User({
        userId: 'user_123',
        username: 'narutofan',
        password: 'password123',
      });

      await expect(invalidUser.save()).rejects.toThrow();
    });

    it('should require password field', async () => {
      const invalidUser = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
      });

      await expect(invalidUser.save()).rejects.toThrow();
    });
  });

  describe('Field Constraints', () => {
    it('should enforce unique userId', async () => {
      const user1 = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      const user2 = new User({
        userId: 'user_123',
        username: 'sakurafan',
        email: 'sakura@konoha.com',
        password: 'password456',
      });

      await user1.save();
      await expect(user2.save()).rejects.toThrow();
    });

    it('should enforce unique username', async () => {
      const user1 = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      const user2 = new User({
        userId: 'user_456',
        username: 'narutofan',
        email: 'sakura@konoha.com',
        password: 'password456',
      });

      await user1.save();
      await expect(user2.save()).rejects.toThrow();
    });

    it('should enforce unique email', async () => {
      const user1 = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      const user2 = new User({
        userId: 'user_456',
        username: 'sakurafan',
        email: 'naruto@konoha.com',
        password: 'password456',
      });

      await user1.save();
      await expect(user2.save()).rejects.toThrow();
    });

    it('should trim username', async () => {
      const user = new User({
        userId: 'user_123',
        username: '  narutofan  ',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await user.save();
      expect(user.username).toBe('narutofan');
    });

    it('should lowercase email', async () => {
      const user = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'NARUTO@KONOHA.COM',
        password: 'password123',
      });

      await user.save();
      expect(user.email).toBe('naruto@konoha.com');
    });

    it('should enforce username minlength of 3', async () => {
      const user = new User({
        userId: 'user_123',
        username: 'ab',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await expect(user.save()).rejects.toThrow();
    });

    it('should enforce username maxlength of 20', async () => {
      const user = new User({
        userId: 'user_123',
        username: 'a'.repeat(21),
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await expect(user.save()).rejects.toThrow();
    });

    it('should enforce password minlength of 6', async () => {
      const user = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: '12345',
      });

      await expect(user.save()).rejects.toThrow();
    });
  });

  describe('Default Values', () => {
    it('should have default timestamp fields', async () => {
      const user = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });

      await user.save();

      expect(user.createdAt).toBeInstanceOf(Date);
      expect(user.updatedAt).toBeInstanceOf(Date);
    });
  });

  describe('Indexing', () => {
    it('should have index on email field', async () => {
      const indexes = await User.collection.getIndexes();
      expect(indexes).toHaveProperty('email_1');
    });

    it('should have index on username field', async () => {
      const indexes = await User.collection.getIndexes();
      expect(indexes).toHaveProperty('username_1');
    });

    it('should have unique index on userId field', async () => {
      const indexes = await User.collection.getIndexes();
      expect(indexes).toHaveProperty('userId_1');
    });
  });

  describe('User Operations', () => {
    let savedUser: IUser;

    beforeEach(async () => {
      const user = new User({
        userId: 'user_123',
        username: 'narutofan',
        email: 'naruto@konoha.com',
        password: 'password123',
      });
      savedUser = await user.save();
    });

    it('should update user information', async () => {
      savedUser.username = 'sasukefan';
      savedUser.email = 'sasuke@konoha.com';
      await savedUser.save();

      const updatedUser = await User.findOne({ userId: 'user_123' });
      expect(updatedUser?.username).toBe('sasukefan');
      expect(updatedUser?.email).toBe('sasuke@konoha.com');
    });

    it('should find user by userId', async () => {
      const foundUser = await User.findOne({ userId: 'user_123' });
      expect(foundUser).not.toBeNull();
      expect(foundUser?.username).toBe('narutofan');
    });

    it('should find user by email', async () => {
      const foundUser = await User.findOne({ email: 'naruto@konoha.com' });
      expect(foundUser).not.toBeNull();
      expect(foundUser?.username).toBe('narutofan');
    });

    it('should find user by username', async () => {
      const foundUser = await User.findOne({ username: 'narutofan' });
      expect(foundUser).not.toBeNull();
      expect(foundUser?.email).toBe('naruto@konoha.com');
    });

    it('should delete user', async () => {
      await User.deleteOne({ userId: 'user_123' });
      const foundUser = await User.findOne({ userId: 'user_123' });
      expect(foundUser).toBeNull();
    });
  });
});
