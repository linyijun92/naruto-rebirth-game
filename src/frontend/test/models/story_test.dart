import 'package:flutter_test/flutter_test.dart';
import 'package:naruto_rebirth_game/data/models/story.dart';

void main() {
  group('StoryNode Model Tests', () {
    test('should create StoryNode with valid data', () {
      // Arrange
      final choice = StoryChoice(
        id: 'choice1',
        text: '前往木叶',
        nextNode: 'node2',
      );

      final storyNode = StoryNode(
        nodeId: 'node1',
        chapterId: 'chapter1',
        type: 'dialogue',
        content: '欢迎来到木叶忍者村！',
        speaker: '自来也',
        choices: [choice],
        backgroundMusic: 'village_theme.mp3',
        soundEffect: 'ambient_wind.mp3',
      );

      // Assert
      expect(storyNode.nodeId, 'node1');
      expect(storyNode.chapterId, 'chapter1');
      expect(storyNode.type, 'dialogue');
      expect(storyNode.content, '欢迎来到木叶忍者村！');
      expect(storyNode.speaker, '自来也');
      expect(storyNode.choices, isNotEmpty);
      expect(storyNode.choices!.first.id, 'choice1');
      expect(storyNode.backgroundMusic, 'village_theme.mp3');
      expect(storyNode.soundEffect, 'ambient_wind.mp3');
    });

    test('should create StoryNode with minimal required fields', () {
      // Arrange
      final storyNode = StoryNode(
        nodeId: 'node1',
        chapterId: 'chapter1',
        type: 'narration',
        content: '故事开始...',
      );

      // Assert
      expect(storyNode.nodeId, 'node1');
      expect(storyNode.chapterId, 'chapter1');
      expect(storyNode.type, 'narration');
      expect(storyNode.content, '故事开始...');
      expect(storyNode.speaker, isNull);
      expect(storyNode.choices, isNull);
      expect(storyNode.backgroundMusic, isNull);
      expect(storyNode.soundEffect, isNull);
    });

    test('should serialize and deserialize StoryNode correctly', () {
      // Arrange
      final originalNode = StoryNode(
        nodeId: 'node1',
        chapterId: 'chapter1',
        type: 'dialogue',
        content: '你好！',
        speaker: '鸣人',
      );

      // Act
      final json = originalNode.toJson();
      final deserializedNode = StoryNode.fromJson(json);

      // Assert
      expect(deserializedNode.nodeId, originalNode.nodeId);
      expect(deserializedNode.chapterId, originalNode.chapterId);
      expect(deserializedNode.type, originalNode.type);
      expect(deserializedNode.content, originalNode.content);
      expect(deserializedNode.speaker, originalNode.speaker);
    });
  });

  group('StoryChoice Model Tests', () {
    test('should create StoryChoice with valid data', () {
      // Arrange
      final requirements = {
        'chakra': 50,
        'level': 5,
      };

      final choice = StoryChoice(
        id: 'choice1',
        text: '使用螺旋丸',
        nextNode: 'node2',
        requirements: requirements,
      );

      // Assert
      expect(choice.id, 'choice1');
      expect(choice.text, '使用螺旋丸');
      expect(choice.nextNode, 'node2');
      expect(choice.requirements, isNotNull);
      expect(choice.requirements!['chakra'], 50);
    });

    test('should create StoryChoice without requirements', () {
      // Arrange
      final choice = StoryChoice(
        id: 'choice1',
        text: '继续前进',
        nextNode: 'node2',
      );

      // Assert
      expect(choice.id, 'choice1');
      expect(choice.text, '继续前进');
      expect(choice.nextNode, 'node2');
      expect(choice.requirements, isNull);
    });

    test('should serialize and deserialize StoryChoice correctly', () {
      // Arrange
      final originalChoice = StoryChoice(
        id: 'choice1',
        text: '选择A',
        nextNode: 'node2',
      );

      // Act
      final json = originalChoice.toJson();
      final deserializedChoice = StoryChoice.fromJson(json);

      // Assert
      expect(deserializedChoice.id, originalChoice.id);
      expect(deserializedChoice.text, originalChoice.text);
      expect(deserializedChoice.nextNode, originalChoice.nextNode);
    });
  });

  group('Chapter Model Tests', () {
    test('should create Chapter with valid data', () {
      // Arrange
      final chapter = Chapter(
        chapterId: 'chapter1',
        title: '第一章：忍者学校',
        description: '故事开始的地方',
        startNodeId: 'node1',
        requiredChapters: [],
        isUnlocked: true,
      );

      // Assert
      expect(chapter.chapterId, 'chapter1');
      expect(chapter.title, '第一章：忍者学校');
      expect(chapter.description, '故事开始的地方');
      expect(chapter.startNodeId, 'node1');
      expect(chapter.requiredChapters, isEmpty);
      expect(chapter.isUnlocked, true);
    });

    test('should create Chapter with required chapters', () {
      // Arrange
      final chapter = Chapter(
        chapterId: 'chapter2',
        title: '第二章：中忍考试',
        description: '证明你的实力',
        startNodeId: 'node10',
        requiredChapters: ['chapter1'],
      );

      // Assert
      expect(chapter.chapterId, 'chapter2');
      expect(chapter.requiredChapters, contains('chapter1'));
      expect(chapter.isUnlocked, false); // default value
    });

    test('should serialize and deserialize Chapter correctly', () {
      // Arrange
      final originalChapter = Chapter(
        chapterId: 'chapter1',
        title: '第一章',
        description: '描述',
        startNodeId: 'node1',
        requiredChapters: [],
        isUnlocked: true,
      );

      // Act
      final json = originalChapter.toJson();
      final deserializedChapter = Chapter.fromJson(json);

      // Assert
      expect(deserializedChapter.chapterId, originalChapter.chapterId);
      expect(deserializedChapter.title, originalChapter.title);
      expect(deserializedChapter.description, originalChapter.description);
      expect(deserializedChapter.startNodeId, originalChapter.startNodeId);
      expect(deserializedChapter.isUnlocked, originalChapter.isUnlocked);
    });
  });
}
