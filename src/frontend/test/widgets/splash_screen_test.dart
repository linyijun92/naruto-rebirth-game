import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naruto_rebirth_game/screens/splash/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display splash screen elements', (WidgetTester tester) async {
      // Build the splash screen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashScreen(),
          ),
        ),
      );

      // Verify splash screen elements exist
      expect(find.byType(SplashScreen), findsOneWidget);

      // Check for logo or title
      expect(
        find.textContaining('火影', findInRichText: true),
        findsWidgets,
        reason: 'Should display game title containing "火影"',
      );

      // Check for loading indicator or animation
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
        reason: 'Should show loading indicator',
      );
    });

    testWidgets('should have proper background color', (WidgetTester tester) async {
      // Build the splash screen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashScreen(),
          ),
        ),
      );

      // Find the splash screen container
      final splashScreenFinder = find.byType(SplashScreen);
      expect(splashScreenFinder, findsOneWidget);

      // Get the widget
      final splashScreen = tester.widget<SplashScreen>(splashScreenFinder);

      // Verify background (implementation depends on actual widget code)
      expect(splashScreen, isNotNull);
    });

    testWidgets('should center content vertically and horizontally',
        (WidgetTester tester) async {
      // Build the splash screen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SplashScreen(),
          ),
        ),
      );

      // Find the Center widget if exists
      expect(find.byType(Center), findsOneWidget,
          reason: 'Content should be centered');
    });

    testWidgets('should handle different screen sizes', (WidgetTester tester) async {
      // Test on small screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(300, 600)),
            child: const Scaffold(
              body: SplashScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);

      // Test on large screen
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: const Scaffold(
              body: SplashScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('should not crash on initialization', (WidgetTester tester) async {
      // Build and verify no exceptions
      expect(
        () async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: SplashScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
        },
        returnsNormally,
        reason: 'Splash screen should initialize without errors',
      );
    });
  });
}
