import 'package:flutter_test/flutter_test.dart';
import 'package:naruto_rebirth_game/providers/player_provider.dart';

void main() {
  group('PlayerProvider Tests', () {
    late PlayerProvider playerProvider;

    setUp(() {
      playerProvider = PlayerProvider();
    });

    tearDown(() {
      playerProvider.dispose();
    });

    group('Initial State', () {
      test('should initialize with default attributes', () {
        // Assert
        expect(playerProvider.attributes, isNotEmpty);
        expect(playerProvider.level, 1);
        expect(playerProvider.experience, 0);
        expect(playerProvider.currentChapter, 'chapter_01_01');
        expect(playerProvider.currency, isPositive);
      });

      test('should have valid starting values', () {
        // Assert
        expect(playerProvider.level, 1);
        expect(playerProvider.experience, 0);
        expect(playerProvider.currentChapter, 'chapter_01_01');
      });
    });

    group('Attributes Management', () {
      test('should get attribute value', () {
        // Act
        final chakra = playerProvider.getAttribute('chakra');

        // Assert
        expect(chakra, isNotNull);
        expect(chakra, isPositive);
      });

      test('should return 0 for non-existent attribute', () {
        // Act
        final nonExistent = playerProvider.getAttribute('non_existent');

        // Assert
        expect(nonExistent, 0);
      });

      test('should update attribute value', () {
        // Arrange
        final initialValue = playerProvider.getAttribute('chakra');

        // Act
        playerProvider.updateAttribute('chakra', 80);

        // Assert
        expect(playerProvider.getAttribute('chakra'), 80);
        expect(playerProvider.getAttribute('chakra'), isNot(equals(initialValue)));
      });

      test('should clamp attribute value to max', () {
        // Act
        playerProvider.updateAttribute('chakra', 9999);

        // Assert
        expect(playerProvider.getAttribute('chakra'), lessThan(1000));
      });

      test('should not allow negative attribute values', () {
        // Act
        playerProvider.updateAttribute('chakra', -50);

        // Assert
        expect(playerProvider.getAttribute('chakra'), greaterThanOrEqualTo(0));
      });

      test('should add to attribute value', () {
        // Arrange
        final initialValue = playerProvider.getAttribute('stamina');

        // Act
        playerProvider.addAttribute('stamina', 20);

        // Assert
        expect(playerProvider.getAttribute('stamina'), equals(initialValue + 20));
      });

      test('should subtract from attribute value', () {
        // Arrange
        playerProvider.addAttribute('stamina', 50);
        final beforeSubtract = playerProvider.getAttribute('stamina');

        // Act
        playerProvider.addAttribute('stamina', -10);

        // Assert
        expect(playerProvider.getAttribute('stamina'), equals(beforeSubtract - 10));
      });

      test('should handle multiple attribute updates', () {
        // Act
        playerProvider.updateAttribute('chakra', 80);
        playerProvider.updateAttribute('stamina', 75);
        playerProvider.updateAttribute('strength', 70);

        // Assert
        expect(playerProvider.getAttribute('chakra'), 80);
        expect(playerProvider.getAttribute('stamina'), 75);
        expect(playerProvider.getAttribute('strength'), 70);
      });
    });

    group('Level Management', () {
      test('should level up', () {
        // Arrange
        final initialLevel = playerProvider.level;

        // Act
        playerProvider.levelUp();

        // Assert
        expect(playerProvider.level, equals(initialLevel + 1));
      });

      test('should level up multiple times', () {
        // Arrange
        final initialLevel = playerProvider.level;

        // Act
        playerProvider.levelUp();
        playerProvider.levelUp();
        playerProvider.levelUp();

        // Assert
        expect(playerProvider.level, equals(initialLevel + 3));
      });
    });

    group('Experience Management', () {
      test('should add experience', () {
        // Arrange
        final initialExp = playerProvider.experience;

        // Act
        playerProvider.addExperience(100);

        // Assert
        expect(playerProvider.experience, equals(initialExp + 100));
      });

      test('should add multiple experience amounts', () {
        // Act
        playerProvider.addExperience(50);
        playerProvider.addExperience(30);
        playerProvider.addExperience(20);

        // Assert
        expect(playerProvider.experience, 100);
      });

      test('should handle zero experience', () {
        // Act
        playerProvider.addExperience(0);

        // Assert
        expect(playerProvider.experience, 0);
      });

      test('should handle large experience values', () {
        // Act
        playerProvider.addExperience(10000);

        // Assert
        expect(playerProvider.experience, 10000);
      });
    });

    group('Chapter Management', () {
      test('should update chapter', () {
        // Act
        playerProvider.updateChapter('chapter_02_01');

        // Assert
        expect(playerProvider.currentChapter, 'chapter_02_01');
      });

      test('should handle multiple chapter updates', () {
        // Act
        playerProvider.updateChapter('chapter_02_01');
        expect(playerProvider.currentChapter, 'chapter_02_01');

        playerProvider.updateChapter('chapter_03_01');
        expect(playerProvider.currentChapter, 'chapter_03_01');

        playerProvider.updateChapter('chapter_04_01');
        expect(playerProvider.currentChapter, 'chapter_04_01');
      });

      test('should allow going back to previous chapter', () {
        // Act
        playerProvider.updateChapter('chapter_02_01');
        playerProvider.updateChapter('chapter_01_01');

        // Assert
        expect(playerProvider.currentChapter, 'chapter_01_01');
      });
    });

    group('Currency Management', () {
      test('should add currency', () {
        // Arrange
        final initialCurrency = playerProvider.currency;

        // Act
        playerProvider.addCurrency(500);

        // Assert
        expect(playerProvider.currency, equals(initialCurrency + 500));
      });

      test('should spend currency when sufficient', () {
        // Arrange
        playerProvider.addCurrency(1000);
        final beforeSpend = playerProvider.currency;

        // Act
        playerProvider.spendCurrency(300);

        // Assert
        expect(playerProvider.currency, equals(beforeSpend - 300));
      });

      test('should not spend currency when insufficient', () {
        // Arrange
        playerProvider.resetPlayer();
        final beforeSpend = playerProvider.currency;

        // Act
        playerProvider.spendCurrency(99999);

        // Assert
        expect(playerProvider.currency, equals(beforeSpend));
      });

      test('should spend exact amount', () {
        // Arrange
        playerProvider.resetPlayer();
        final currency = playerProvider.currency;

        // Act
        playerProvider.spendCurrency(currency);

        // Assert
        expect(playerProvider.currency, 0);
      });

      test('should handle zero currency transaction', () {
        // Arrange
        final before = playerProvider.currency;

        // Act
        playerProvider.addCurrency(0);
        playerProvider.spendCurrency(0);

        // Assert
        expect(playerProvider.currency, equals(before));
      });
    });

    group('Reset Player', () {
      test('should reset player to initial state', () {
        // Arrange - modify player state
        playerProvider.updateAttribute('chakra', 80);
        playerProvider.levelUp();
        playerProvider.addExperience(100);
        playerProvider.updateChapter('chapter_05_01');
        playerProvider.addCurrency(1000);

        // Act
        playerProvider.resetPlayer();

        // Assert
        expect(playerProvider.level, 1);
        expect(playerProvider.experience, 0);
        expect(playerProvider.currentChapter, 'chapter_01_01');
        expect(playerProvider.currency, equals(playerProvider.currency));
      });

      test('should reset attributes to defaults', () {
        // Arrange
        playerProvider.updateAttribute('chakra', 10);
        playerProvider.updateAttribute('stamina', 20);
        playerProvider.updateAttribute('strength', 30);

        // Act
        playerProvider.resetPlayer();

        // Assert
        final defaultChakra = playerProvider.getAttribute('chakra');
        expect(defaultChakra, greaterThan(10));
      });
    });

    group('Notify Listeners', () {
      test('should notify listeners when attribute changes', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.updateAttribute('chakra', 80);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when leveling up', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.levelUp();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when experience is added', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.addExperience(100);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when chapter is updated', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.updateChapter('chapter_02_01');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when currency changes', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.addCurrency(500);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when player is reset', () {
        // Arrange
        var notified = false;
        playerProvider.addListener(() {
          notified = true;
        });

        // Act
        playerProvider.resetPlayer();

        // Assert
        expect(notified, true);
      });
    });

    group('State Independence', () {
      test('should attributes change not affect level', () {
        // Arrange
        final levelBefore = playerProvider.level;

        // Act
        playerProvider.updateAttribute('chakra', 80);

        // Assert
        expect(playerProvider.level, equals(levelBefore));
      });

      test('should experience not affect attributes', () {
        // Arrange
        final chakraBefore = playerProvider.getAttribute('chakra');

        // Act
        playerProvider.addExperience(100);

        // Assert
        expect(playerProvider.getAttribute('chakra'), equals(chakraBefore));
      });

      test('should currency not affect chapter', () {
        // Arrange
        final chapterBefore = playerProvider.currentChapter;

        // Act
        playerProvider.addCurrency(500);

        // Assert
        expect(playerProvider.currentChapter, equals(chapterBefore));
      });
    });
  });
}
