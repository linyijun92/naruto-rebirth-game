import 'package:flutter_test/flutter_test.dart';
import 'package:naruto_rebirth_game/data/models/save.dart';

void main() {
  group('Save Model Tests', () {
    late Save testSave;

    setUp(() {
      testSave = Save(
        saveId: 'save_123',
        playerId: 'player_456',
        saveName: '我的存档',
        gameTime: '火影纪元 5年',
        playerLevel: 15,
        attributes: {
          'chakra': 100,
          'stamina': 80,
          'strength': 70,
          'speed': 65,
          'intelligence': 60,
        },
        currentChapter: 'chapter3',
        inventory: [
          {'id': 'item1', 'name': '苦无', 'quantity': 10},
          {'id': 'item2', 'name': '手里剑', 'quantity': 20},
        ],
        quests: [
          {'id': 'quest1', 'name': '中忍考试', 'status': 'in_progress'},
        ],
        achievements: [
          {'id': 'ach1', 'name': '初出茅庐', 'unlockedAt': '2026-02-10'},
        ],
        playTime: 7200, // 2 hours in seconds
        createdAt: DateTime(2026, 2, 10, 10, 0),
        updatedAt: DateTime(2026, 2, 13, 14, 0),
      );
    });

    test('should create Save with all fields', () {
      // Assert
      expect(testSave.saveId, 'save_123');
      expect(testSave.playerId, 'player_456');
      expect(testSave.saveName, '我的存档');
      expect(testSave.gameTime, '火影纪元 5年');
      expect(testSave.playerLevel, 15);
      expect(testSave.attributes.length, 5);
      expect(testSave.currentChapter, 'chapter3');
      expect(testSave.inventory.length, 2);
      expect(testSave.quests.length, 1);
      expect(testSave.achievements.length, 1);
      expect(testSave.playTime, 7200);
    });

    test('should handle player attributes correctly', () {
      // Assert
      expect(testSave.attributes['chakra'], 100);
      expect(testSave.attributes['stamina'], 80);
      expect(testSave.attributes['strength'], 70);
    });

    test('should handle inventory items correctly', () {
      // Assert
      expect(testSave.inventory.first['id'], 'item1');
      expect(testSave.inventory.first['name'], '苦无');
      expect(testSave.inventory.first['quantity'], 10);
    });

    test('should serialize Save to JSON correctly', () {
      // Act
      final json = testSave.toJson();

      // Assert
      expect(json['saveId'], 'save_123');
      expect(json['playerId'], 'player_456');
      expect(json['playerLevel'], 15);
      expect(json['attributes'], isA<Map<String, dynamic>>());
    });

    test('should deserialize Save from JSON correctly', () {
      // Arrange
      final json = {
        'saveId': 'save_789',
        'playerId': 'player_999',
        'saveName': '新存档',
        'gameTime': '火影纪元 1年',
        'playerLevel': 1,
        'attributes': {
          'chakra': 50,
          'stamina': 50,
        },
        'currentChapter': 'chapter1',
        'inventory': [],
        'quests': [],
        'achievements': [],
        'playTime': 0,
        'createdAt': DateTime(2026, 2, 13).toIso8601String(),
        'updatedAt': DateTime(2026, 2, 13).toIso8601String(),
      };

      // Act
      final save = Save.fromJson(json);

      // Assert
      expect(save.saveId, 'save_789');
      expect(save.playerLevel, 1);
      expect(save.attributes['chakra'], 50);
    });

    test('should copy Save with updated fields', () {
      // Act
      final updatedSave = testSave.copyWith(
        playerLevel: 20,
        playTime: 9000,
        updatedAt: DateTime(2026, 2, 14, 10, 0),
      );

      // Assert
      expect(updatedSave.saveId, testSave.saveId); // unchanged
      expect(updatedSave.playerLevel, 20); // updated
      expect(updatedSave.playTime, 9000); // updated
      expect(updatedSave.updatedAt, DateTime(2026, 2, 14, 10, 0));
    });

    test('should handle empty lists for inventory, quests, achievements', () {
      // Arrange
      final emptySave = Save(
        saveId: 'save_empty',
        playerId: 'player_empty',
        saveName: 'Empty Save',
        gameTime: '火影纪元 1年',
        playerLevel: 1,
        attributes: {},
        currentChapter: 'chapter1',
        inventory: [],
        quests: [],
        achievements: [],
        playTime: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(emptySave.inventory, isEmpty);
      expect(emptySave.quests, isEmpty);
      expect(emptySave.achievements, isEmpty);
      expect(emptySave.attributes, isEmpty);
    });

    test('should handle timestamps correctly', () {
      // Assert
      expect(testSave.createdAt, isA<DateTime>());
      expect(testSave.updatedAt, isA<DateTime>());
      expect(testSave.updatedAt.isAfter(testSave.createdAt), true);
    });

    test('should create Save with minimal required data', () {
      // Arrange
      final minimalSave = Save(
        saveId: 'save_minimal',
        playerId: 'player_minimal',
        saveName: 'Minimal',
        gameTime: 'Year 1',
        playerLevel: 1,
        attributes: {},
        currentChapter: 'chapter1',
        inventory: [],
        quests: [],
        achievements: [],
        playTime: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert
      expect(minimalSave.saveId, 'save_minimal');
      expect(minimalSave.playerId, 'player_minimal');
      expect(minimalSave.playerLevel, 1);
    });
  });
}
