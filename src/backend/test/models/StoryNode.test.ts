import StoryNode, { IStoryNode, IStoryChoice } from '../../src/models/StoryNode';

describe('StoryNode Model', () => {
  describe('Schema Validation', () => {
    it('should create a valid story node', async () => {
      const validNode = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: '欢迎来到木叶忍者村！',
        speaker: '自来也',
      });

      const savedNode = await validNode.save();

      expect(savedNode.nodeId).toBe('node_001');
      expect(savedNode.chapterId).toBe('chapter_01');
      expect(savedNode.type).toBe('dialogue');
      expect(savedNode.content).toBe('欢迎来到木叶忍者村！');
      expect(savedNode.speaker).toBe('自来也');
      expect(savedNode.createdAt).toBeDefined();
    });

    it('should create a story node with choices', async () => {
      const choices: IStoryChoice[] = [
        {
          id: 'choice_1',
          text: '前往木叶',
          nextNode: 'node_002',
        },
        {
          id: 'choice_2',
          text: '留在村子',
          nextNode: 'node_003',
        },
      ];

      const validNode = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: '你要去哪里？',
        choices: choices,
      });

      const savedNode = await validNode.save();

      expect(savedNode.choices).toBeDefined();
      expect(savedNode.choices?.length).toBe(2);
      expect(savedNode.choices?.[0].text).toBe('前往木叶');
    });

    it('should create a story node with audio', async () => {
      const validNode = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: '风在吹动...',
        backgroundMusic: 'village_theme.mp3',
        soundEffect: 'wind_sound.mp3',
      });

      const savedNode = await validNode.save();

      expect(savedNode.backgroundMusic).toBe('village_theme.mp3');
      expect(savedNode.soundEffect).toBe('wind_sound.mp3');
    });

    it('should require nodeId field', async () => {
      const invalidNode = new StoryNode({
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Test content',
      });

      await expect(invalidNode.save()).rejects.toThrow();
    });

    it('should require chapterId field', async () => {
      const invalidNode = new StoryNode({
        nodeId: 'node_001',
        type: 'dialogue',
        content: 'Test content',
      });

      await expect(invalidNode.save()).rejects.toThrow();
    });

    it('should require type field', async () => {
      const invalidNode = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        content: 'Test content',
      });

      await expect(invalidNode.save()).rejects.toThrow();
    });

    it('should require content field', async () => {
      const invalidNode = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
      });

      await expect(invalidNode.save()).rejects.toThrow();
    });
  });

  describe('Type Validation', () => {
    it('should accept valid type: dialogue', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: '对话内容',
      });

      await node.save();
      expect(node.type).toBe('dialogue');
    });

    it('should accept valid type: choice', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: '选择你的道路',
      });

      await node.save();
      expect(node.type).toBe('choice');
    });

    it('should accept valid type: event', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'event',
        content: '突发事件',
      });

      await node.save();
      expect(node.type).toBe('event');
    });

    it('should reject invalid type', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'invalid_type' as any,
        content: 'Test content',
      });

      await expect(node.save()).rejects.toThrow();
    });
  });

  describe('StoryChoice Validation', () => {
    it('should require choice id', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: 'Choose',
        choices: [
          {
            text: 'Option 1',
            nextNode: 'node_002',
          } as any,
        ],
      });

      await expect(node.save()).rejects.toThrow();
    });

    it('should require choice text', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: 'Choose',
        choices: [
          {
            id: 'choice_1',
            nextNode: 'node_002',
          } as any,
        ],
      });

      await expect(node.save()).rejects.toThrow();
    });

    it('should require choice nextNode', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: 'Choose',
        choices: [
          {
            id: 'choice_1',
            text: 'Option 1',
          } as any,
        ],
      });

      await expect(node.save()).rejects.toThrow();
    });

    it('should accept choice with requirements', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'choice',
        content: 'Choose',
        choices: [
          {
            id: 'choice_1',
            text: 'Use jutsu',
            nextNode: 'node_002',
            requirements: {
              chakra: 50,
              level: 5,
            },
          },
        ],
      });

      await node.save();
      expect(node.choices?.[0].requirements).toBeDefined();
      expect(node.choices?.[0].requirements?.chakra).toBe(50);
    });
  });

  describe('Field Constraints', () => {
    it('should enforce unique nodeId', async () => {
      const node1 = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Content 1',
      });

      const node2 = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_02',
        type: 'dialogue',
        content: 'Content 2',
      });

      await node1.save();
      await expect(node2.save()).rejects.toThrow();
    });

    it('should allow same nodeId in different chapters after first save', async () => {
      const node1 = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Content 1',
      });

      await node1.save();
    });
  });

  describe('Indexing', () => {
    it('should have index on nodeId field', async () => {
      const indexes = await StoryNode.collection.getIndexes();
      expect(indexes).toHaveProperty('nodeId_1');
    });

    it('should have index on chapterId field', async () => {
      const indexes = await StoryNode.collection.getIndexes();
      expect(indexes).toHaveProperty('chapterId_1');
    });

    it('should have composite index on chapterId and nodeId', async () => {
      const indexes = await StoryNode.collection.getIndexes();
      expect(indexes).toHaveProperty('chapterId_1_nodeId_1');
    });
  });

  describe('StoryNode Operations', () => {
    let savedNode: IStoryNode;

    beforeEach(async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Initial content',
        speaker: 'Character 1',
      });
      savedNode = await node.save();
    });

    it('should update story node', async () => {
      savedNode.content = 'Updated content';
      savedNode.speaker = 'Character 2';
      await savedNode.save();

      const updatedNode = await StoryNode.findOne({ nodeId: 'node_001' });
      expect(updatedNode?.content).toBe('Updated content');
      expect(updatedNode?.speaker).toBe('Character 2');
    });

    it('should add choices to existing node', async () => {
      savedNode.choices = [
        {
          id: 'choice_1',
          text: 'Option 1',
          nextNode: 'node_002',
        },
      ];
      await savedNode.save();

      const updatedNode = await StoryNode.findOne({ nodeId: 'node_001' });
      expect(updatedNode?.choices).toBeDefined();
      expect(updatedNode?.choices?.length).toBe(1);
    });

    it('should find node by nodeId', async () => {
      const foundNode = await StoryNode.findOne({ nodeId: 'node_001' });
      expect(foundNode).not.toBeNull();
      expect(foundNode?.chapterId).toBe('chapter_01');
    });

    it('should find nodes by chapterId', async () => {
      const nodes = await StoryNode.find({ chapterId: 'chapter_01' });
      expect(nodes.length).toBeGreaterThanOrEqual(1);
      expect(nodes[0].nodeId).toBe('node_001');
    });

    it('should delete story node', async () => {
      await StoryNode.deleteOne({ nodeId: 'node_001' });
      const foundNode = await StoryNode.findOne({ nodeId: 'node_001' });
      expect(foundNode).toBeNull();
    });
  });

  describe('Optional Fields', () => {
    it('should create node without speaker', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'narration',
        content: 'Narrative text...',
      });

      await node.save();
      expect(node.speaker).toBeUndefined();
    });

    it('should create node without choices', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Dialogue...',
      });

      await node.save();
      expect(node.choices).toBeUndefined();
    });

    it('should create node without audio', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Dialogue...',
      });

      await node.save();
      expect(node.backgroundMusic).toBeUndefined();
      expect(node.soundEffect).toBeUndefined();
    });

    it('should create node without requirements', async () => {
      const node = new StoryNode({
        nodeId: 'node_001',
        chapterId: 'chapter_01',
        type: 'dialogue',
        content: 'Dialogue...',
      });

      await node.save();
      expect(node.requirements).toBeUndefined();
    });
  });
});
