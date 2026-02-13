import Save, { ISave } from '../../src/models/Save';

describe('Save Model', () => {
  describe('Schema Validation', () => {
    it('should create a valid save', async () => {
      const validSave = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: '木叶忍者',
        gameTime: '火影纪元 3年',
        playerLevel: 15,
        attributes: {
          chakra: 100,
          ninjutsu: 80,
          taijutsu: 75,
          intelligence: 60,
          speed: 70,
          luck: 50,
        },
        currentChapter: 'chapter_03_01',
        inventory: [
          { id: 'item_001', name: '苦无', quantity: 10 },
        ],
        quests: [
          { id: 'quest_001', name: '中忍考试', status: 'in_progress' },
        ],
        achievements: [],
        playTime: 7200,
        isCloud: true,
      });

      const savedSave = await validSave.save();

      expect(savedSave.saveId).toBe('save_123');
      expect(savedSave.playerId).toBe('player_456');
      expect(savedSave.saveName).toBe('木叶忍者');
      expect(savedSave.gameTime).toBe('火影纪元 3年');
      expect(savedSave.playerLevel).toBe(15);
      expect(savedSave.currentChapter).toBe('chapter_03_01');
      expect(savedSave.playTime).toBe(7200);
      expect(savedSave.isCloud).toBe(true);
      expect(savedSave.createdAt).toBeDefined();
      expect(savedSave.updatedAt).toBeDefined();
    });

    it('should require saveId field', async () => {
      const invalidSave = new Save({
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await expect(invalidSave.save()).rejects.toThrow();
    });

    it('should require playerId field', async () => {
      const invalidSave = new Save({
        saveId: 'save_123',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await expect(invalidSave.save()).rejects.toThrow();
    });

    it('should require saveName field', async () => {
      const invalidSave = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await expect(invalidSave.save()).rejects.toThrow();
    });

    it('should require gameTime field', async () => {
      const invalidSave = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        currentChapter: 'chapter_01',
      });

      await expect(invalidSave.save()).rejects.toThrow();
    });

    it('should require currentChapter field', async () => {
      const invalidSave = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
      });

      await expect(invalidSave.save()).rejects.toThrow();
    });
  });

  describe('Default Values', () => {
    it('should default playerLevel to 1', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.playerLevel).toBe(1);
    });

    it('should default attributes to defined values', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.attributes.chakra).toBe(100);
      expect(save.attributes.ninjutsu).toBe(50);
      expect(save.attributes.taijutsu).toBe(50);
      expect(save.attributes.intelligence).toBe(50);
      expect(save.attributes.speed).toBe(50);
      expect(save.attributes.luck).toBe(50);
    });

    it('should default inventory to empty array', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.inventory).toEqual([]);
    });

    it('should default quests to empty array', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.quests).toEqual([]);
    });

    it('should default achievements to empty array', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.achievements).toEqual([]);
    });

    it('should default playTime to 0', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.playTime).toBe(0);
    });

    it('should default isCloud to false', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();
      expect(save.isCloud).toBe(false);
    });

    it('should have default timestamp fields', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save.save();

      expect(save.createdAt).toBeInstanceOf(Date);
      expect(save.updatedAt).toBeInstanceOf(Date);
    });
  });

  describe('Field Constraints', () => {
    it('should enforce saveName maxlength of 50', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'a'.repeat(51),
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await expect(save.save()).rejects.toThrow();
    });

    it('should enforce unique saveId', async () => {
      const save1 = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Save 1',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      const save2 = new Save({
        saveId: 'save_123',
        playerId: 'player_789',
        saveName: 'Save 2',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
      });

      await save1.save();
      await expect(save2.save()).rejects.toThrow();
    });
  });

  describe('Indexing', () => {
    it('should have index on saveId field', async () => {
      const indexes = await Save.collection.getIndexes();
      expect(indexes).toHaveProperty('saveId_1');
    });

    it('should have index on playerId field', async () => {
      const indexes = await Save.collection.getIndexes();
      expect(indexes).toHaveProperty('playerId_1');
    });

    it('should have composite index on playerId and updatedAt', async () => {
      const indexes = await Save.collection.getIndexes();
      expect(indexes).toHaveProperty('playerId_1_updatedAt_-1');
    });

    it('should have index on isCloud field', async () => {
      const indexes = await Save.collection.getIndexes();
      expect(indexes).toHaveProperty('isCloud_1');
    });
  });

  describe('Attributes', () => {
    it('should store all required attributes', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
        attributes: {
          chakra: 90,
          ninjutsu: 85,
          taijutsu: 80,
          intelligence: 75,
          speed: 70,
          luck: 65,
        },
      });

      await save.save();

      expect(save.attributes.chakra).toBe(90);
      expect(save.attributes.ninjutsu).toBe(85);
      expect(save.attributes.taijutsu).toBe(80);
      expect(save.attributes.intelligence).toBe(75);
      expect(save.attributes.speed).toBe(70);
      expect(save.attributes.luck).toBe(65);
    });
  });

  describe('Inventory Management', () => {
    it('should store inventory items', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
        inventory: [
          { id: 'item_001', name: '苦无', quantity: 10 },
          { id: 'item_002', name: '手里剑', quantity: 20 },
          { id: 'item_003', name: '起爆符', quantity: 5 },
        ],
      });

      await save.save();

      expect(save.inventory.length).toBe(3);
      expect(save.inventory[0].name).toBe('苦无');
      expect(save.inventory[2].quantity).toBe(5);
    });

    it('should handle empty inventory', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
        inventory: [],
      });

      await save.save();
      expect(save.inventory).toEqual([]);
    });
  });

  describe('Quest Management', () => {
    it('should store quest data', async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
        quests: [
          { id: 'quest_001', name: '中忍考试', status: 'completed' },
          { id: 'quest_002', name: 'S级任务', status: 'in_progress' },
        ],
      });

      await save.save();

      expect(save.quests.length).toBe(2);
      expect(save.quests[0].name).toBe('中忍考试');
      expect(save.quests[1].status).toBe('in_progress');
    });
  });

  describe('Save Operations', () => {
    let savedSave: ISave;

    beforeEach(async () => {
      const save = new Save({
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: 'Test Save',
        gameTime: 'Year 1',
        currentChapter: 'chapter_01',
        playerLevel: 5,
      });
      savedSave = await save.save();
    });

    it('should update save information', async () => {
      savedSave.playerLevel = 10;
      savedSave.saveName = 'Updated Save';
      savedSave.currentChapter = 'chapter_02_01';
      await savedSave.save();

      const updatedSave = await Save.findOne({ saveId: 'save_123' });
      expect(updatedSave?.playerLevel).toBe(10);
      expect(updatedSave?.saveName).toBe('Updated Save');
      expect(updatedSave?.currentChapter).toBe('chapter_02_01');
    });

    it('should update attributes', async () => {
      savedSave.attributes.chakra = 120;
      savedSave.attributes.speed = 80;
      await savedSave.save();

      const updatedSave = await Save.findOne({ saveId: 'save_123' });
      expect(updatedSave?.attributes.chakra).toBe(120);
      expect(updatedSave?.attributes.speed).toBe(80);
    });

    it('should add item to inventory', async () => {
      savedSave.inventory.push({
        id: 'item_001',
        name: '苦无',
        quantity: 10,
      });
      await savedSave.save();

      const updatedSave = await Save.findOne({ saveId: 'save_123' });
      expect(updatedSave?.inventory.length).toBe(1);
    });

    it('should find save by saveId', async () => {
      const foundSave = await Save.findOne({ saveId: 'save_123' });
      expect(foundSave).not.toBeNull();
      expect(foundSave?.playerId).toBe('player_456');
    });

    it('should find saves by playerId', async () => {
      const saves = await Save.find({ playerId: 'player_456' });
      expect(saves.length).toBeGreaterThanOrEqual(1);
      expect(saves[0].saveId).toBe('save_123');
    });

    it('should find cloud saves', async () => {
      savedSave.isCloud = true;
      await savedSave.save();

      const cloudSaves = await Save.find({ isCloud: true });
      expect(cloudSaves.length).toBeGreaterThanOrEqual(1);
    });

    it('should delete save', async () => {
      await Save.deleteOne({ saveId: 'save_123' });
      const foundSave = await Save.findOne({ saveId: 'save_123' });
      expect(foundSave).toBeNull();
    });
  });
});
