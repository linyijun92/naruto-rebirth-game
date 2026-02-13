import 'package:flutter_test/flutter_test.dart';
import 'package:naruto_rebirth_game/providers/game_provider.dart';

void main() {
  group('GameProvider Tests', () {
    late GameProvider gameProvider;

    setUp(() {
      gameProvider = GameProvider();
    });

    tearDown(() {
      gameProvider.dispose();
    });

    group('Initial State', () {
      test('should initialize with default values', () {
        // Assert
        expect(gameProvider.isPaused, false);
        expect(gameProvider.isLoading, false);
        expect(gameProvider.gameTime, '火影纪元 1年');
      });

      test('should have correct initial game state', () {
        // Assert
        expect(gameProvider.isPaused, false, reason: 'Game should not be paused initially');
        expect(gameProvider.isLoading, false, reason: 'Game should not be loading initially');
      });
    });

    group('Pause/Resume Game', () {
      test('should pause game when pauseGame is called', () {
        // Act
        gameProvider.pauseGame();

        // Assert
        expect(gameProvider.isPaused, true, reason: 'Game should be paused');
      });

      test('should resume game when resumeGame is called', () {
        // Arrange
        gameProvider.pauseGame();
        expect(gameProvider.isPaused, true);

        // Act
        gameProvider.resumeGame();

        // Assert
        expect(gameProvider.isPaused, false, reason: 'Game should be resumed');
      });

      test('should toggle pause state multiple times', () {
        // Arrange
        expect(gameProvider.isPaused, false);

        // Act & Assert
        gameProvider.pauseGame();
        expect(gameProvider.isPaused, true);

        gameProvider.resumeGame();
        expect(gameProvider.isPaused, false);

        gameProvider.pauseGame();
        expect(gameProvider.isPaused, true);

        gameProvider.resumeGame();
        expect(gameProvider.isPaused, false);
      });
    });

    group('Loading State', () {
      test('should set loading state to true', () {
        // Act
        gameProvider.setLoading(true);

        // Assert
        expect(gameProvider.isLoading, true);
      });

      test('should set loading state to false', () {
        // Arrange
        gameProvider.setLoading(true);
        expect(gameProvider.isLoading, true);

        // Act
        gameProvider.setLoading(false);

        // Assert
        expect(gameProvider.isLoading, false);
      });

      test('should handle multiple loading state changes', () {
        // Arrange
        expect(gameProvider.isLoading, false);

        // Act & Assert
        gameProvider.setLoading(true);
        expect(gameProvider.isLoading, true);

        gameProvider.setLoading(false);
        expect(gameProvider.isLoading, false);

        gameProvider.setLoading(true);
        expect(gameProvider.isLoading, true);

        gameProvider.setLoading(false);
        expect(gameProvider.isLoading, false);
      });
    });

    group('Game Time', () {
      test('should update game time', () {
        // Act
        gameProvider.updateGameTime('火影纪元 3年');

        // Assert
        expect(gameProvider.gameTime, '火影纪元 3年');
      });

      test('should handle different time formats', () {
        // Act & Assert
        gameProvider.updateGameTime('火影纪元 10年');
        expect(gameProvider.gameTime, '火影纪元 10年');

        gameProvider.updateGameTime('木叶70年');
        expect(gameProvider.gameTime, '木叶70年');

        gameProvider.updateGameTime('第四次忍界大战');
        expect(gameProvider.gameTime, '第四次忍界大战');
      });

      test('should preserve time across multiple updates', () {
        // Act
        gameProvider.updateGameTime('火影纪元 2年');
        expect(gameProvider.gameTime, '火影纪元 2年');

        gameProvider.updateGameTime('火影纪元 3年');
        expect(gameProvider.gameTime, '火影纪元 3年');

        gameProvider.updateGameTime('火影纪元 4年');
        expect(gameProvider.gameTime, '火影纪元 4年');
      });
    });

    group('Notify Listeners', () {
      test('should notify listeners when game is paused', () {
        // Arrange
        var notified = false;
        gameProvider.addListener(() {
          notified = true;
        });

        // Act
        gameProvider.pauseGame();

        // Assert
        expect(notified, true, reason: 'Listeners should be notified');
      });

      test('should notify listeners when game is resumed', () {
        // Arrange
        gameProvider.pauseGame();
        var notified = false;
        gameProvider.addListener(() {
          notified = true;
        });

        // Act
        gameProvider.resumeGame();

        // Assert
        expect(notified, true, reason: 'Listeners should be notified');
      });

      test('should notify listeners when loading state changes', () {
        // Arrange
        var notified = false;
        gameProvider.addListener(() {
          notified = true;
        });

        // Act
        gameProvider.setLoading(true);

        // Assert
        expect(notified, true, reason: 'Listeners should be notified');
      });

      test('should notify listeners when game time is updated', () {
        // Arrange
        var notified = false;
        gameProvider.addListener(() {
          notified = true;
        });

        // Act
        gameProvider.updateGameTime('火影纪元 2年');

        // Assert
        expect(notified, true, reason: 'Listeners should be notified');
      });

      test('should handle multiple listeners', () {
        // Arrange
        var listener1Notified = false;
        var listener2Notified = false;

        gameProvider.addListener(() {
          listener1Notified = true;
        });

        gameProvider.addListener(() {
          listener2Notified = true;
        });

        // Act
        gameProvider.pauseGame();

        // Assert
        expect(listener1Notified, true);
        expect(listener2Notified, true);
      });
    });

    group('State Independence', () {
      test('should pause state not affect loading state', () {
        // Act
        gameProvider.pauseGame();
        gameProvider.setLoading(true);

        // Assert
        expect(gameProvider.isPaused, true);
        expect(gameProvider.isLoading, true);
      });

      test('should loading state not affect pause state', () {
        // Act
        gameProvider.setLoading(true);
        gameProvider.pauseGame();

        // Assert
        expect(gameProvider.isLoading, true);
        expect(gameProvider.isPaused, true);
      });

      test('should gameTime not affect other states', () {
        // Act
        gameProvider.updateGameTime('火影纪元 2年');
        gameProvider.pauseGame();
        gameProvider.setLoading(true);

        // Assert
        expect(gameProvider.gameTime, '火影纪元 2年');
        expect(gameProvider.isPaused, true);
        expect(gameProvider.isLoading, true);
      });
    });
  });
}
